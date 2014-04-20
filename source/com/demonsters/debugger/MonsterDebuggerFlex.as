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

	import mx.core.UIComponent;
	import mx.logging.Log;
	import flash.display.DisplayObject;


	public class MonsterDebuggerFlex extends UIComponent
	{


		/**
		 * Init the Monster Debugger
		 */
		override public function initialize():void
		{
			MonsterDebugger.initialize(this.parent);
			Log.addTarget(new MonsterDebuggerFlexTarget());
		}


		/**
		 * The trace function of the MonsterDebugger can be used to display standard objects like
		 * Strings, Numbers, Arrays, etc. But it can also be used to display more complex objects like
		 * custom classes, XML or even multidimensional arrays containing XML nodes for that matter.
		 * It will send a snapshot of those objects to the desktop application where you can inspect them.
		 */
		public final function trace(caller:*, object:*, person:String = "", label:String = "", color:uint = 0x000000, depth:int = 5):void
		{
			MonsterDebugger.trace(caller, object, person, label, color, depth);
		}


		/**
		 * Makes a snapshot of a DisplayObject and sends it to the desktop application. This can be useful
		 * if you need to compare visual states or display a hidden interface item. Snapshot will return
		 * an un-rotated, completely visible (100% alpha) representation of the supplied DisplayObject.
		 */
		public final function snapshot(caller:*, object:DisplayObject, person:String = "", label:String = ""):void
		{
			MonsterDebugger.snapshot(caller, object, person, label);
		}


		/**
		 * Since version 3.0 the MonsterDebugger supports breakpoints. Calling this function will pause
		 * your application on that specific point. All timers, event listeners, animations, etc. will
		 * stop, but you can still inspect your application using the MonsterDebugger desktop application.
		 * Note: This function is only available when running your application in the Flash Debug Player
		 * or Adobe AIR’s ADL launcher.
		 */
		public final function breakpoint(caller:*, id:String = "breakpoint"):void
		{
			MonsterDebugger.breakpoint(caller, id);
		}


		/**
		 * This function will change the base target of the MonsterDebugger that was set in the initialize
		 * function and send the new target to the desktop application for inspection. For example: This
		 * can be easy when you want to inspect a loaded SWF movie or an active window in case of Adobe AIR.
		 * The main advantage of inspect over a trace if the live browsing capabilities in the desktop
		 * application and the possibility to adjust properties and run methods.
		 */
		public final function inspect(object:*):void
		{
			MonsterDebugger.inspect(object);
		}


		/**
		 * This will clear all traces in the connected MonsterDebugger desktop application.
		 */
		public final function clear():void
		{
			MonsterDebugger.clear();
		}
	}
}



import com.demonsters.debugger.MonsterDebugger;
import mx.logging.AbstractTarget;
import mx.logging.ILogger;
import mx.logging.LogEvent;
import mx.logging.LogEventLevel;


/**
 * INTERNAL FLEX LOGGER TARGET
 */
class MonsterDebuggerFlexTarget extends AbstractTarget
{

	public function MonsterDebuggerFlexTarget()
	{
		super();
	}


	/**
	 * Override the regular log event handler.
	 */
	override public function logEvent(event:LogEvent):void
	{
		// Save logger
		var logger:ILogger = event.target as ILogger;

		// Check the level to run
		switch (event.level) {
			case LogEventLevel.FATAL:
				MonsterDebugger.trace(logger.category, event.message, "", "FATAL", 0xFF0000);
				break;
			case LogEventLevel.ERROR:
				MonsterDebugger.trace(logger.category, event.message, "", "ERROR", 0xFF0000);
				break;
			case LogEventLevel.WARN:
				MonsterDebugger.trace(logger.category, event.message, "", "WARN", 0xFF9A0D);
				break;
			case LogEventLevel.INFO:
				MonsterDebugger.trace(logger.category, event.message, "", "INFO", 0x39B500);
				break;
			case LogEventLevel.DEBUG:
			case LogEventLevel.ALL:
				MonsterDebugger.trace(logger.category, event.message, "", "DEBUG");
				break;
		}
	}
}