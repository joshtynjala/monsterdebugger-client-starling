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
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	
	/**
	 * @private
	 * The Monster Debugger DescribeType. This Calls flash.utils.describeType() 
	 * for the first time and caches the return value so that subsequent calls 
	 * return faster.
	 */
	internal class MonsterDebuggerDescribeType
	{

		// Simple xml cache
		private static var cache:Object = {};

		
		/**
		 *  Calls flash.utils.describeType() for the first time and caches
		 *  the return value so that subsequent calls return faster.
		 *  @param object: The target object
		 */
		internal static function get(object:*):XML
		{
			// Save the classname as key
			var key:String = getQualifiedClassName(object);
			
			// Check if we found the item in cache
			if (key in cache) {
				return cache[key];
			}
			
			// Else save the item and return that
			var xml:XML = describeType(object);
			cache[key] = xml;
			return xml;
		}
	}
}
