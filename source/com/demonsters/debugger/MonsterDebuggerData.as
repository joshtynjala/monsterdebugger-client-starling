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
	import flash.utils.ByteArray;

	
	/**
	 * The Monster Debugger shared data.
	 */
	public class MonsterDebuggerData
	{
		
		// Properties
		private var _id:String;
		private var _data:Object;
	
		
		/**
		 * Shared data class between the client and desktop application.
		 * @param id: The plugin id
		 * @param data: The data to send over the socket connection
		 */
		public function MonsterDebuggerData(id:String, data:Object)
		{
			// Save data
			_id = id;
			_data = data;
		}
		
		
		/**
		 * Get the plugin id.
		 */
		public function get id():String{
			return _id;
		}
		
		
		/**
		 * Get the data object.
		 */
		public function get data():Object {
			return _data;
		}
		
		
		/**
		 * Get the raw bytes.
		 */
		public function get bytes():ByteArray
		{
			// Create the holders
			var bytesId:ByteArray = new ByteArray();
			var bytesData:ByteArray = new ByteArray();
			
			// Save the objects
			bytesId.writeObject(_id);
			bytesData.writeObject(_data);
			
			// Write in one object
			var item:ByteArray = new ByteArray();
			item.writeUnsignedInt(bytesId.length);
			item.writeBytes(bytesId);
			item.writeUnsignedInt(bytesData.length);
			item.writeBytes(bytesData);
			item.position = 0;
			
			// Clear the old objects
			bytesId = null;
			bytesData = null;
			
			// Return the object
			return item;
		}
		
		
		/**
		 * Convert raw bytes.
		 */
		public function set bytes(value:ByteArray):void
		{
			// Create the holders
			var bytesId:ByteArray = new ByteArray();
			var bytesData:ByteArray = new ByteArray();
			
			// Decompress the value and read bytes
			try {
				value.readBytes(bytesId, 0, value.readUnsignedInt());
				value.readBytes(bytesData, 0, value.readUnsignedInt());
				
				// Save vars
				_id = bytesId.readObject() as String;
				_data = bytesData.readObject() as Object;
			} catch (e:Error) {
				_id = null;
				_data = null;
			}
			
			// Clear the old objects
			bytesId = null;
			bytesData = null;
		}
		
		
		/**
		 * Convert raw bytes to a MonsterDebuggerData object.
		 * @param bytes: The raw bytes to convert
		 */
		public static function read(bytes:ByteArray):MonsterDebuggerData
		{
			var item:MonsterDebuggerData = new MonsterDebuggerData(null, null);
			item.bytes = bytes;
			return item;
		}
	}
	
}