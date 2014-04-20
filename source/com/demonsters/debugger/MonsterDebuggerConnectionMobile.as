/**
 * 
 * This is the client code that needs to be implemented into a 
 * Flash, FLEX or AIR application to collect debug information 
 * in De Monster Debugger. 
 * 
 * Be aware that any traces made to De Monster Debugger may 
 * be viewed by others. De MonsterDebugger is intended to be 
 * used to debug Flash, FLEX or AIR applications in a protective
 * environment that they will not be used in the final launch. 
 * Please make sure that you do not send any debug material to
 * the debugger from a live running application. 
 * 
 * Use at your own risk.
 * 
 * @author		Ferdi Koomen, Joost Harts and Stijn van der Laan
 * @company 	De Monsters
 * @link 		http://www.MonsterDebugger.com
 * @version 	3.02
 * 
 *
 * Special thanks to: 
 * Arjan van Wijk and Thijs Broerse for their feedback on the 2.5 version
 * Michel Wacker for sharing his P2P AIRborne library
 *
 * 
 * Copyright 2011, De Monsters
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 */
package com.demonsters.debugger
{


	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	
	internal class MonsterDebuggerConnectionMobile implements IMonsterDebuggerConnection
	{
		
		// Max queue length
		private const MAX_QUEUE_LENGTH:int = 500;
		
		
		// Group pin
		private const PIN:String = "monsterdebugger";
		
		
		// Connection properties
		private var _multiCastIP:String = "225.225.0.1";
		private var _multiCastPort:String = "58000";
		private var _connection:NetConnection;
		private var _group:NetGroup;
		private var _id:String;
		private var _connected:Boolean;
		private var _connectedNeighbor:String;
		private var _process:Boolean;

		
		// Data buffer
		private var _queue:Array = [];

		
		public function MonsterDebuggerConnectionMobile()
		{
			_connected = false;
			_connectedNeighbor = null;
			_process = false;
		}
		
		
		/**
		 * Called whenever something happens on the peer-to-peer connection.
		 * Once the connection is established a group is joined.
		 * Once the group was joined, we setup messaging.
		 */
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					joinGroup();
					break;
				case "NetGroup.Connect.Success":
					_id = _group.convertPeerIDToGroupAddress(_connection.nearID);					
					break;
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Closed":
				case "NetGroup.Connect.Rejected":
				case "NetGroup.Connect.Failed":
					_connected = false;
					_connectedNeighbor = null;
					_process = false;
					break;
			}
		}
		
		
		/**
		 * Creates a new or joins an existing NetGroup on the peer-2-peer connection
		 * that allows multicast communication.
		 */
		private function joinGroup():void
		{
			// Create group specifications
			var groupSpec:GroupSpecifier = new GroupSpecifier(PIN);
			groupSpec.ipMulticastMemberUpdatesEnabled = true;
			groupSpec.routingEnabled = true;
			groupSpec.addIPMulticastAddress(_multiCastIP + ':' + _multiCastPort);
			
			// Create a new net group to receive posts
			_group = new NetGroup(_connection, groupSpec.groupspecWithoutAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, onGroupUpdates, false, 0, true);
		}
		
		
		/**
		 * Called whenever something happens in the group we've joined on the peer-to-peer
		 * group. Other neighbors messages are being evaluated and we send out our own
		 * address as soon as we join successfully.
		 */
		private function onGroupUpdates(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetGroup.Neighbor.Connect":
					if (!_connected && _connectedNeighbor == null) {
						_connected = true;
						_connectedNeighbor = event.info.neighbor;
						_process = false;
					}
				break;
					
					
				case "NetGroup.Neighbor.Disconnect":
					_connected = false;
					_connectedNeighbor = null;
					_process = false;
					MonsterDebuggerUtils.resume();
				break;
					
					
				case "NetGroup.SendTo.Notify":
					if (event.info.from == _connectedNeighbor) {
						var item:MonsterDebuggerData = new MonsterDebuggerData(event.info.message.id, event.info.message.data);
						if (item.id != null) {
							MonsterDebuggerCore.handle(item);
						}
					}
				break;
			}
		}
		
		
		/**
		 * @param value: The address to connect to
		 */
		public function set address(value:String):void {
			// No need to set the address
		}
		
		
		/**
		 * Get connected status.
		 */
		public function get connected():Boolean {
			return _connected;
		}
		
		
		/**
		 *  Start processing the queue.
		 */
		public function processQueue():void {
			if (!_process) {
				_process = true;
				if (_queue.length > 0) {
					next();
				}
			}
		}
		
		
		/**
		 * Send data to the desktop application.
		 * @param id: The id of the plugin
		 * @param data: The data to send
		 * @param direct: Use the queue or send direct (handshake)
		 */
		public function send(id:String, data:Object, direct:Boolean = false):void {
			
			// Send direct (in case of handshake)
			if (direct && id == MonsterDebuggerCore.ID && _connected && _connectedNeighbor != null)
			{				
				// Get the data
				var obj:Object = {};
				obj["id"] = id;
				obj["data"] = data;
				
				// Write it to the group
				_group.sendToAllNeighbors(obj);
				return;
			}
			
			// Add to normal queue
			_queue.push(new MonsterDebuggerData(id, data));
			if (_queue.length > MAX_QUEUE_LENGTH){
				_queue.shift();
			}
			if (_queue.length > 0) {
				next();
			}
		}
		
		
		/**
		 * Connect the socket.
		 */
		public function connect():void {
			if (!_connected && _connection == null && MonsterDebugger.enabled) {
				_connection = new NetConnection();
				_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
				_connection.connect('rtmfp:');
			}
		}
		
		
		/**
		 * Process the next item in queue.
		 */
		private function next():void
		{
			// If the debugger is disabled dont connect
			if (!MonsterDebugger.enabled) {
				return;
			}
			
			// Check if we can process the queue
			if (!_process) {
				return;
			}
			
			// Check if we should connect the socket
			if (!_connected) {
				connect();
				return;
			}
			
			// Get the data
			var data:MonsterDebuggerData = _queue.shift();
			var obj:Object = {};
			obj["id"] = data.id;
			obj["data"] = data.data;
			
			// Write it to the group
			// XXX: Broadcast ipv send to neighbors
			// XXX: Subnet ipv 255.255.0.1
			_group.sendToAllNeighbors(obj);
			
			// Proceed queue
			if (_queue.length > 0) {
				next();
			}
		}
		
	}
}
