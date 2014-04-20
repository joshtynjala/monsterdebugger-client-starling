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

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	
	internal class MonsterDebuggerConnectionDefault implements IMonsterDebuggerConnection
	{
		
		// Max queue length
		private const MAX_QUEUE_LENGTH:int = 500;
		
		
		// Properties
		private var _socket:Socket;
		private var _connecting:Boolean;
		private var _process:Boolean;
		private var _bytes:ByteArray;
		private var _package:ByteArray;
		private var _length:uint;
		private var _retry:Timer;
		private var _timeout:Timer;
		private var _address:String;
		private var _port:int;
		
		
		// Data buffer
		private var _queue:Array = [];

		
		
		public function MonsterDebuggerConnectionDefault()
		{
			// Create the socket
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, connectHandler, false, 0, false);
			_socket.addEventListener(Event.CLOSE, closeHandler, false, 0, false);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, closeHandler, false, 0, false);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, closeHandler, false, 0, false);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler, false, 0, false);
			
			// Set properties
			_connecting = false;
			_process = false;
			_address = "127.0.0.1";
			_port = 5840;
			_timeout = new Timer(2000, 1);
			_timeout.addEventListener(TimerEvent.TIMER, closeHandler, false, 0, false);
			_retry = new Timer(1000, 1);
			_retry.addEventListener(TimerEvent.TIMER, retryHandler, false, 0, false);
		}
		
		
		/**
		 * @param value: The address to connect to
		 */
		public function set address(value:String):void {
			_address = value;
		}
		
		
		/**
		 * Get connected status.
		 */
		public function get connected():Boolean {
			if (_socket == null) return false;
			return _socket.connected;
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
			if (direct && id == MonsterDebuggerCore.ID && _socket.connected)
			{				
				// Get the data
				var bytes:ByteArray = new MonsterDebuggerData(id, data).bytes;
				
				// Write it to the socket
				_socket.writeUnsignedInt(bytes.length);
				_socket.writeBytes(bytes);
				_socket.flush();
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
			
			if (!_connecting && MonsterDebugger.enabled) {
				try
				{
					// Load crossdomain
					Security.loadPolicyFile('xmlsocket://' + _address + ':' + _port);
					
					// Connect the socket
					_connecting = true;
					_socket.connect(_address, _port);
					
					// Start timeout
					_retry.stop();
					_timeout.reset();
					_timeout.start();
				}
				catch(e:Error)
				{
					// MonsterDebugger.logger(["error"]);
					// MonsterDebugger.logger([e.message]);
					closeHandler();
				}
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
			if (!_socket.connected) {
				connect();
				return;
			}
			
			// Get the data
			var bytes:ByteArray = MonsterDebuggerData(_queue.shift()).bytes;
			
			// Write it to the socket
			_socket.writeUnsignedInt(bytes.length);
			_socket.writeBytes(bytes);
			_socket.flush();
			
			// Clear the data
			// bytes.clear(); // FP10
			bytes = null;
			
			// Proceed queue
			if (_queue.length > 0) {
				next();
			}
		}
		
		
		/**
		 * Connection is made.
		 */
		private function connectHandler(event:Event):void
		{
			_timeout.stop();
			_retry.stop();
			
			// Set the flags and clear the bytes
			_connecting = false;
			_bytes = new ByteArray();
			_package = new ByteArray();
			_length = 0;
			
			// Send hello and wait for handshake
			_socket.writeUTFBytes("<hello/>" + "\n");
			_socket.writeByte(0);
			_socket.flush();
		}
		
		
		/**
		 * Retry is done.
		 */
		private function retryHandler(event:TimerEvent):void
		{
			// Just retry
			_retry.stop();
			connect();
		}
		
		
		/**
		 * Connection closed.
		 * Due to a timeout or connection error.
		 */
		private function closeHandler(event:Event = null):void
		{
			// Resume if we have paused the applicatio we're debugging
			MonsterDebuggerUtils.resume();
			
			// Select a new address to connect
			if (!_retry.running) {
				_connecting = false;
				_process = false;
				_timeout.stop();
				_retry.reset();
				_retry.start();
			}
		}
		
		
		/**
		 * Socket data is available.
		 */
		private function dataHandler(event:ProgressEvent):void
		{
			// Clear and read the bytes
			_bytes = new ByteArray();
			_socket.readBytes(_bytes, 0, _socket.bytesAvailable);

			// Reset position
			_bytes.position = 0;
			processPackage();
		}
		

		/**
		 * Process package.
		 */
		private function processPackage():void
		{
			// Return if null bytes available
			if (_bytes.bytesAvailable == 0) {
				return;
			}

			// Read the size
			if (_length == 0) {
				_length = _bytes.readUnsignedInt();
				_package = new ByteArray();
			}

			// Load the data
			if (_package.length < _length && _bytes.bytesAvailable > 0)
			{
				// Get the data
				var l:uint = _bytes.bytesAvailable;
				if (l > _length - _package.length) {
					l = _length - _package.length;
				}
				_bytes.readBytes(_package, _package.length, l);
			}

			// Check if we have all the data
			if (_length != 0 && _package.length == _length) 
			{
				// Parse the bytes and send them for handeling to the core
				var item:MonsterDebuggerData = MonsterDebuggerData.read(_package);
				if (item.id != null) {
					MonsterDebuggerCore.handle(item);
				}
	
				// Clear the old data
				_length = 0;
				_package = null;
			}

			// Check if there is another package
			if (_length == 0 && _bytes.bytesAvailable > 0) {
				processPackage();
			}
		}
		
	}
}
