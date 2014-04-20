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
	
	
	/**
	 * @private
	 * The Monster Debugger connection
	 */
	internal class MonsterDebuggerConnection
	{
		
		// Connector class
		private static var connector:IMonsterDebuggerConnection;

		
		/**
		 * Start the class
		 */
		internal static function initialize():void
		{
			/*FDT_IGNORE*/
			CONFIG::Default { connector = new MonsterDebuggerConnectionDefault(); }
			/*FDT_IGNORE*/
			
			/*FDT_IGNORE*/
			CONFIG::Mobile { connector = new MonsterDebuggerConnectionMobile(); }
			/*FDT_IGNORE*/
		}
		
		
		/**
		 * @param value: The address to connect to
		 */
		internal static function set address(value:String):void {
			connector.address = value;
		}
		
		
		/**
		 * Get connected status.
		 */
		internal static function get connected():Boolean {
			return connector.connected;
		}
		
		
		/**
		 *  Start processing the queue.
		 */
		internal static function processQueue():void {
			connector.processQueue();
		}
		
		
		/**
		 * Send data to the desktop application.
		 * @param id: The id of the plugin
		 * @param data: The data to send
		 * @param direct: Use the queue or send direct (handshake)
		 */
		internal static function send(id:String, data:Object, direct:Boolean = false):void {
			connector.send(id, data, direct);
		}
		
		
		/**
		 * Connect the socket.
		 */
		internal static function connect():void {
			connector.connect();
		}
	
	}
}

