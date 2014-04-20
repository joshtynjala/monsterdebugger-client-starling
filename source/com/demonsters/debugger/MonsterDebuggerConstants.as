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
	 * The Monster Debugger constants.
	 */
	internal class MonsterDebuggerConstants
	{
		
		// Commands
		internal static const COMMAND_HELLO					:String = "HELLO";
		internal static const COMMAND_INFO					:String = "INFO";
		internal static const COMMAND_TRACE					:String = "TRACE";
		internal static const COMMAND_PAUSE					:String = "PAUSE";
		internal static const COMMAND_RESUME				:String = "RESUME";
		internal static const COMMAND_BASE					:String = "BASE";
		internal static const COMMAND_INSPECT				:String = "INSPECT";
		internal static const COMMAND_GET_OBJECT			:String = "GET_OBJECT";
		internal static const COMMAND_GET_PROPERTIES		:String = "GET_PROPERTIES";
		internal static const COMMAND_GET_FUNCTIONS			:String = "GET_FUNCTIONS";
		internal static const COMMAND_GET_PREVIEW			:String = "GET_PREVIEW";
		internal static const COMMAND_SET_PROPERTY			:String = "SET_PROPERTY";
		internal static const COMMAND_CALL_METHOD			:String = "CALL_METHOD";
		internal static const COMMAND_HIGHLIGHT				:String = "HIGHLIGHT";
		internal static const COMMAND_START_HIGHLIGHT		:String = "START_HIGHLIGHT";
		internal static const COMMAND_STOP_HIGHLIGHT		:String = "STOP_HIGHLIGHT";
		internal static const COMMAND_CLEAR_TRACES			:String = "CLEAR_TRACES";
		internal static const COMMAND_MONITOR				:String = "MONITOR";
		internal static const COMMAND_SAMPLES				:String = "SAMPLES";
		internal static const COMMAND_SNAPSHOT				:String = "SNAPSHOT";
		internal static const COMMAND_NOTFOUND				:String = "NOTFOUND";
		
		
		// Types
		internal static const TYPE_VOID					:String = "void";
		internal static const TYPE_NULL					:String = "null";
		internal static const TYPE_ARRAY				:String = "Array";
		internal static const TYPE_BOOLEAN				:String = "Boolean";
		internal static const TYPE_NUMBER				:String = "Number";
		internal static const TYPE_OBJECT				:String = "Object";
		internal static const TYPE_VECTOR				:String = "Vector.";
		internal static const TYPE_STRING				:String = "String";
		internal static const TYPE_INT					:String = "int";
		internal static const TYPE_UINT					:String = "uint";
		internal static const TYPE_XML					:String = "XML";
		internal static const TYPE_XMLLIST				:String = "XMLList";
		internal static const TYPE_XMLNODE				:String = "XMLNode";
		internal static const TYPE_XMLVALUE				:String = "XMLValue";
		internal static const TYPE_XMLATTRIBUTE			:String = "XMLAttribute";
		internal static const TYPE_METHOD				:String = "MethodClosure";
		internal static const TYPE_FUNCTION				:String = "Function";
		internal static const TYPE_BYTEARRAY			:String = "ByteArray";	
		internal static const TYPE_WARNING				:String = "Warning";
		internal static const TYPE_NOT_FOUND			:String = "Not found";
		internal static const TYPE_UNREADABLE			:String = "Unreadable";
		
		
		// Access types
		internal static const ACCESS_VARIABLE			:String = "variable";
		internal static const ACCESS_CONSTANT			:String = "constant";
		internal static const ACCESS_ACCESSOR			:String = "accessor";
		internal static const ACCESS_METHOD				:String = "method";
		internal static const ACCESS_DISPLAY_OBJECT		:String = "displayObject";
		
		
		// Permission types
		internal static const PERMISSION_READWRITE		:String = "readwrite";
		internal static const PERMISSION_READONLY		:String = "readonly";
		internal static const PERMISSION_WRITEONLY		:String = "writeonly";
		
		
		// Icon types
		internal static const ICON_DEFAULT				:String = "iconDefault";
		internal static const ICON_ROOT					:String = "iconRoot";
		internal static const ICON_WARNING				:String = "iconWarning";
		internal static const ICON_VARIABLE				:String = "iconVariable";
		internal static const ICON_DISPLAY_OBJECT		:String = "iconDisplayObject";
		internal static const ICON_VARIABLE_READONLY	:String = "iconVariableReadonly";
		internal static const ICON_VARIABLE_WRITEONLY	:String = "iconVariableWriteonly";
		internal static const ICON_XMLNODE				:String = "iconXMLNode";
		internal static const ICON_XMLVALUE				:String = "iconXMLValue";
		internal static const ICON_XMLATTRIBUTE 		:String = "iconXMLAttribute";
		internal static const ICON_FUNCTION				:String = "iconFunction";
		
		
		// Path delimiter
		internal static const DELIMITER					:String = ".";
		
	}
	
}