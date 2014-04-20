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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	
	/**
	 * @private
	 * The Monster Debugger core functions
	 */
	internal class MonsterDebuggerCore
	{
		
		// Monitor and highlight interval timer
		private static const MONITOR_UPDATE:int = 1000;
		private static const HIGHLITE_COLOR:uint = 0x3399FF;
		
		
		// Monitor timer
		private static var _monitorTimer:Timer;
		private static var _monitorSprite:Sprite;
		private static var _monitorTime:Number;
		private static var _monitorStart:Number;
		private static var _monitorFrames:int;
		

		// The root of the application
		private static var _base:Object = null;
		
		
		// The stage needed for highlight
		private static var _stage:Stage = null;
		
		
		// Highlight sprite
		private static var _highlight:Sprite;
		private static var _highlightInfo:TextField;
		private static var _highlightTarget:DisplayObject;
		private static var _highlightMouse:Boolean;
		private static var _highlightUpdate:Boolean;


		// The core id
		internal static const ID:String = "com.demonsters.debugger.core";
		
		
		/**
		 * Start the class.
		 */
		internal static function initialize():void
		{	
			// Reset the monitor values
			_monitorTime = new Date().time;
			_monitorStart = new Date().time;
			_monitorFrames = 0;
			
			// Create the monitor timer
			_monitorTimer = new Timer(MONITOR_UPDATE);
			_monitorTimer.addEventListener(TimerEvent.TIMER, monitorTimerCallback, false, 0, true);
			_monitorTimer.start();
			
			// Regular check for stage
			if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage) {
				_stage = _base["stage"] as Stage;
			}
			
			// Create the monitor sprite
			// This is needed for the enterframe ticks
			_monitorSprite = new Sprite();
			_monitorSprite.addEventListener(Event.ENTER_FRAME, frameHandler, false, 0, true);
			
			var format:TextFormat = new TextFormat();
			format.font = "Arial";
			format.color = 0xFFFFFF;
			format.size = 11;
			format.leftMargin = 5;
			format.rightMargin = 5;
			
			// Create the textfield for the highlight and inspect
			_highlightInfo = new TextField();
			_highlightInfo.embedFonts = false;
			_highlightInfo.autoSize = TextFieldAutoSize.LEFT;
			_highlightInfo.mouseWheelEnabled = false;
			_highlightInfo.mouseEnabled = false;
			_highlightInfo.condenseWhite = false;
			_highlightInfo.embedFonts = false;
			_highlightInfo.multiline = false;
			_highlightInfo.selectable = false;
			_highlightInfo.wordWrap = false;
			_highlightInfo.defaultTextFormat = format;
			_highlightInfo.text = "";
			
			// Create the highlight
			_highlight = new Sprite();
			_highlightMouse = false;
			_highlightTarget = null;
			_highlightUpdate = false;
		}

		
		/**
		 * Getter and setter for base.
		 */
		internal static function get base():* {
			return _base;
		}
		internal static function set base(value:*):void {
			_base = value;
		}
		
		
		/**
		 * @private
		 * See MonsterDebugger class
		 */
		internal static function trace(caller:*, object:*, person:String = "", label:String = "", color:uint = 0x000000, depth:int = 5):void
		{
			if (MonsterDebugger.enabled) {
				
				// Get the object information
				var xml:XML = XML(MonsterDebuggerUtils.parse(object, "", 1, depth, false));

				// Create the data
				var data:Object = {
					command:	MonsterDebuggerConstants.COMMAND_TRACE,
					memory:		MonsterDebuggerUtils.getMemory(),
					date:		new Date(),
					target:		String(caller),
					reference:	MonsterDebuggerUtils.getReferenceID(caller),
					xml:		xml,
					person:		person,
					label:		label,
					color:		color
				};
		
				// Send the data
				send(data);
			}
		}
		
		
		/**
		 * @private
		 * See MonsterDebugger class
		 */
		internal static function snapshot(caller:*, object:DisplayObject, person:String = "", label:String = ""):void
		{
			if (MonsterDebugger.enabled) {
				
				// Create the bitmapdata
				var bitmapData:BitmapData = MonsterDebuggerUtils.snapshot(object);
				if (bitmapData != null)
				{					
					// Write the bitmap in the bytearray
					var bytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
	
					// Create the data
					var data:Object = {
						command:	MonsterDebuggerConstants.COMMAND_SNAPSHOT, 
						memory:		MonsterDebuggerUtils.getMemory(),
						date:		new Date(), 
						target:		String(caller), 
						reference:	MonsterDebuggerUtils.getReferenceID(caller),
						bytes:		bytes, 
						width:		bitmapData.width, 
						height:		bitmapData.height,
						person:		person,
						label:		label
					};
					
					// Send the data
					send(data);
				}
			}
		}
		
		
		/**
		 * @private
		 * See MonsterDebugger class
		 */
		internal static function breakpoint(caller:*, id:String = "breakpoint"):void
		{
			// Only break when enabled and connected
			if (MonsterDebugger.enabled && MonsterDebuggerConnection.connected) {
				
				// Get the stacktrace
				var stack:XML = MonsterDebuggerUtils.stackTrace();

				// Create the data
				var data:Object = {
					command:	MonsterDebuggerConstants.COMMAND_PAUSE, 
					memory:		MonsterDebuggerUtils.getMemory(),
					date:		new Date(), 
					target:		String(caller),
					reference:	MonsterDebuggerUtils.getReferenceID(caller),
					stack:		stack, 
					id:			id
				};
				
				// Send the data
				send(data);
				
				// Try to pause the system
				MonsterDebuggerUtils.pause();
			}
		}
		
		
		/**
		 * @private
		 * See MonsterDebugger class
		 */
		internal static function inspect(object:*):void
		{
			if (MonsterDebugger.enabled) {
				
				// Set the new root
				_base = object;
				
				// Get the new target
				var obj:* = MonsterDebuggerUtils.getObject(_base, "", 0);
				if (obj != null)
				{
					// Parse the new target
					var xml:XML = XML(MonsterDebuggerUtils.parse(obj, "", 1, 2, true));
					send({command:MonsterDebuggerConstants.COMMAND_BASE, xml:xml});			
				}
			}
		}
		
		
		/**
		 * @private
		 * See MonsterDebugger class
		 */
		internal static function clear():void
		{
			if (MonsterDebugger.enabled) {
				send({command:MonsterDebuggerConstants.COMMAND_CLEAR_TRACES});
			}
		}
		
		
		/**
		 * Send the capabilities and information.
		 * This is send after the HELLO command.
		 */
		internal static function sendInformation():void
		{
			// Get basic data
			var playerType:String = Capabilities.playerType;
			var playerVersion:String = Capabilities.version;
			var isDebugger:Boolean = Capabilities.isDebugger;
			var isFlex:Boolean = false;	
			var fileTitle:String = "";
			var fileLocation:String = "";
			
			// Check for Flex framework
			try{
				var UIComponentClass:* = getDefinitionByName("mx.core::UIComponent");
				if (UIComponentClass != null) isFlex = true;
			} catch (e1:Error) {}
			
			// Get the location
			if (_base is DisplayObject && _base.hasOwnProperty("loaderInfo")) {
				if (DisplayObject(_base).loaderInfo != null) {
					fileLocation = unescape(DisplayObject(_base).loaderInfo.url);
				}
			}
			if (_base.hasOwnProperty("stage")) {
				if (_base["stage"] != null && _base["stage"] is Stage) {
					fileLocation = unescape(Stage(_base["stage"]).loaderInfo.url);
				}
			}
			
			// Check for browser
			if (playerType == "ActiveX" || playerType == "PlugIn") {
				if (ExternalInterface.available) {
					try {
						var tmpLocation:String = ExternalInterface.call("window.location.href.toString");
						var tmpTitle:String = ExternalInterface.call("window.document.title.toString");
						if (tmpLocation != null) fileLocation = tmpLocation;
						if (tmpTitle != null) fileTitle = tmpTitle;
					} catch (e2:Error) {
						// External interface FAIL
					}
				}
			}
			
			// Check for Adobe AIR
			if (playerType == "Desktop") {
				try{
					var NativeApplicationClass:* = getDefinitionByName("flash.desktop::NativeApplication");
					if (NativeApplicationClass != null) {
						var descriptor:XML = NativeApplicationClass["nativeApplication"]["applicationDescriptor"];
						var ns:Namespace = descriptor.namespace();
						var filename:String = descriptor.ns::filename;
						var FileClass:* = getDefinitionByName("flash.filesystem::File");
						if (Capabilities.os.toLowerCase().indexOf("windows") != -1) {
							filename += ".exe";
							fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
						} else if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {
							filename += ".app";
							fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
						}
					}
				} catch (e3:Error) {}
			}
			
			if (fileTitle == "" && fileLocation != "") {
				var slash:int = Math.max(fileLocation.lastIndexOf("\\"), fileLocation.lastIndexOf("/"));
				if (slash != -1) {
					fileTitle = fileLocation.substring(slash + 1, fileLocation.lastIndexOf("."));
				} else {
					fileTitle = fileLocation;
				}
			}
			
			// Default
			if (fileTitle == "") {
				fileTitle = "Application";
			}
			
			// Create the data
			var data:Object = {
				command:			MonsterDebuggerConstants.COMMAND_INFO,
				debuggerVersion:	MonsterDebugger.VERSION,
				playerType:			playerType,
				playerVersion:		playerVersion,
				isDebugger:			isDebugger,
				isFlex:				isFlex,
				fileLocation:		fileLocation,
				fileTitle:			fileTitle
			};
			
			// Send the data direct
			send(data, true);
			
			// Start the queue after that
			MonsterDebuggerConnection.processQueue();
		}
		

		/**
		 * Handle incoming data from the connection.
		 * @param item: Data from the desktop application
		 */
		internal static function handle(item:MonsterDebuggerData):void
		{
			if (MonsterDebugger.enabled) {
				
				// If the id is empty just return
				if (item.id == null || item.id == "") {
					return;
				}
				
				// Check if we should handle the call internaly
				if (item.id == MonsterDebuggerCore.ID) {
					handleInternal(item);
				}
			}
		}
		
		
		/**
		 * Handle internal commands from the connection.
		 * @param item: Data from the desktop application
		 */
		private static function handleInternal(item:MonsterDebuggerData):void
		{
			// Vars for loop
			var obj:*;
			var xml:XML;
			var method:Function;
			
			// Do the actions
			switch(item.data["command"])
			{
				// Get the application info and start processing queue
				case MonsterDebuggerConstants.COMMAND_HELLO:
					sendInformation();
				break;

				// Get the root xml structure (object)
				case MonsterDebuggerConstants.COMMAND_BASE:
					obj = MonsterDebuggerUtils.getObject(_base, "", 0);
					if (obj != null) {
						xml = XML(MonsterDebuggerUtils.parse(obj, "", 1, 2, true));
						send({command:MonsterDebuggerConstants.COMMAND_BASE, xml:xml});
					}
				break;
				
				// Inspect
				case MonsterDebuggerConstants.COMMAND_INSPECT:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						_base = obj;
						xml = XML(MonsterDebuggerUtils.parse(obj, "", 1, 2, true));
						send({command:MonsterDebuggerConstants.COMMAND_BASE, xml:xml});
					}
				break;
				
				// Return the parsed object
				case MonsterDebuggerConstants.COMMAND_GET_OBJECT:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						xml = XML(MonsterDebuggerUtils.parse(obj, item.data["target"], 1, 2, true));
						send({command:MonsterDebuggerConstants.COMMAND_GET_OBJECT, xml:xml});
					}
				break;
				
				// Return a list of properties
				case MonsterDebuggerConstants.COMMAND_GET_PROPERTIES:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						xml = XML(MonsterDebuggerUtils.parse(obj, item.data["target"], 1, 1, false));
						send({command:MonsterDebuggerConstants.COMMAND_GET_PROPERTIES, xml:xml});
					}
				break;
				
				// Return a list of functions
				case MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						xml = XML(MonsterDebuggerUtils.parseFunctions(obj, item.data["target"]));
						send({command:MonsterDebuggerConstants.COMMAND_GET_FUNCTIONS, xml:xml});
					}
				break;
				
				// Adjust a property and return the value
				case MonsterDebuggerConstants.COMMAND_SET_PROPERTY:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 1);
					if (obj != null) {
						try {
							obj[item.data["name"]] = item.data["value"];
							send({command:MonsterDebuggerConstants.COMMAND_SET_PROPERTY, target:item.data["target"], value:obj[item.data["name"]]});
						} catch (e1:Error) {
							//
						}
					}
				break;
				
				// Return a preview
				case MonsterDebuggerConstants.COMMAND_GET_PREVIEW:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (obj != null && MonsterDebuggerUtils.isDisplayObject(obj)) {
						var displayObject:DisplayObject = obj as DisplayObject;
						var bitmapData:BitmapData = MonsterDebuggerUtils.snapshot(displayObject, new Rectangle(0, 0, 300, 300));
						if (bitmapData != null) {	
							var bytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
							send({command:MonsterDebuggerConstants.COMMAND_GET_PREVIEW, bytes:bytes, width:bitmapData.width, height:bitmapData.height});
						}
					}
				break;
				
				// Call a method and return the answer
				case MonsterDebuggerConstants.COMMAND_CALL_METHOD:
					method = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (method != null && method is Function) {
						if (item.data["returnType"] == MonsterDebuggerConstants.TYPE_VOID) {
							method.apply(null, item.data["arguments"]);
						} else {
							try {
								obj = method.apply(null, item.data["arguments"]);
								xml = XML(MonsterDebuggerUtils.parse(obj, "", 1, 5, false));
								send({command:MonsterDebuggerConstants.COMMAND_CALL_METHOD, id:item.data["id"], xml:xml});
							} catch (e2:Error) {
								//
							}							
						}
					}
				break;
				
				// Pause the application
				case MonsterDebuggerConstants.COMMAND_PAUSE:
					MonsterDebuggerUtils.pause();
					send({command:MonsterDebuggerConstants.COMMAND_PAUSE});
				break;
				
				// Resume the application
				case MonsterDebuggerConstants.COMMAND_RESUME:
					MonsterDebuggerUtils.resume();
					send({command:MonsterDebuggerConstants.COMMAND_RESUME});
				break;
				
				// Set the highlite on an object
				case MonsterDebuggerConstants.COMMAND_HIGHLIGHT:
					obj = MonsterDebuggerUtils.getObject(_base, item.data["target"], 0);
					if (obj != null && MonsterDebuggerUtils.isDisplayObject(obj)) {
						if (DisplayObject(obj).stage != null && DisplayObject(obj).stage is Stage) {
							_stage = obj["stage"];
						}
						if (_stage != null) {
							highlightClear();
							send({command:MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
							_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
							_highlight.mouseEnabled = false;
							_highlightTarget = DisplayObject(obj);
							_highlightMouse = false;
							_highlightUpdate = true;
						}
					}
				break;
				
				// Show the highlight
				case MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT:
					highlightClear();
					_highlight.addEventListener(MouseEvent.CLICK, highlightClicked, false, 0, true);
					_highlight.mouseEnabled = true;
					_highlightTarget = null;
					_highlightMouse = true;
					_highlightUpdate = true;
					send({command:MonsterDebuggerConstants.COMMAND_START_HIGHLIGHT});
				break;
				
				// Remove the highlight
				case MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT:
					highlightClear();
					_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
					_highlight.mouseEnabled = false;
					_highlightTarget = null;
					_highlightMouse = false;
					_highlightUpdate = false;
					send({command:MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
				break;
			}
		}
		
		
		/**
		 * Monitor timer callback.
		 */
		private static function monitorTimerCallback(event:TimerEvent):void
		{
			if (MonsterDebugger.enabled) {
				
				// Calculate the frames per second
				var now:Number = new Date().time;
				var delta:Number = now - _monitorTime;
				var fps:uint = _monitorFrames / delta * 1000; // Miliseconds to seconds
				var fpsMovie:uint = 0;
				if (_stage == null) {
					if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage){
						_stage = Stage(_base["stage"]);
					}
				}
				if (_stage != null) {
					fpsMovie = _stage.frameRate;
				}
				
				// Reset
				_monitorFrames = 0;
				_monitorTime = now;
				
				// Check if we can send the data
				if (MonsterDebuggerConnection.connected)
				{
					// Create the data
					var data:Object = {
						command:		MonsterDebuggerConstants.COMMAND_MONITOR,
						memory:			MonsterDebuggerUtils.getMemory(), 
						fps:			fps, 
						fpsMovie:		fpsMovie, 
						time:			now
					};
					
					// Send the data
					send(data);
				}
			}
		}
		

		/**
		 * Enterframe ticker callback.
		 */
		private static function frameHandler(event:Event):void {
			if (MonsterDebugger.enabled) {
				_monitorFrames++;
				if (_highlightUpdate) {
					highlightUpdate();
				}
			}
		}
		
		
		/**
		 * Highlight clicked.
		 */
		private static function highlightClicked(event:MouseEvent):void
		{
			// Stop
			event.preventDefault();
			event.stopImmediatePropagation();
			
			// Clear the highlight
			highlightClear();
			
			// Get objects under point
			_highlightTarget = MonsterDebuggerUtils.getObjectUnderPoint(_stage, new Point(_stage.mouseX, _stage.mouseY));
			
			// Stop mouse interactions
			_highlightMouse = false;
			_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
			_highlight.mouseEnabled = false;
			
			// Inspect
			if (_highlightTarget != null) {
				inspect(_highlightTarget);
				highlightDraw(false);
			}
			
			// Send stop
			send({command:MonsterDebuggerConstants.COMMAND_STOP_HIGHLIGHT});
		}
		
		
		/**
		 * Highlight timer callback.
		 */
		private static function highlightUpdate():void
		{
			// Clear the highlight
			highlightClear();
			
			// Mouse interactions
			if (_highlightMouse) {
				
				// Regular check for stage
				if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage) {
					_stage = _base["stage"] as Stage;
				}
				
				// Desktop check
				if (Capabilities.playerType == "Desktop") {
					var NativeApplicationClass:* = getDefinitionByName("flash.desktop::NativeApplication");
					if (NativeApplicationClass != null && NativeApplicationClass["nativeApplication"]["activeWindow"] != null) {
						_stage = NativeApplicationClass["nativeApplication"]["activeWindow"]["stage"];
					}
				}
	
				// Return if no stage is found
				if (_stage == null) {
					_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
					_highlight.mouseEnabled = false;
					_highlightTarget = null;
					_highlightMouse = false;
					_highlightUpdate = false;
					return;
				}
				
				// Get objects under point
				_highlightTarget = MonsterDebuggerUtils.getObjectUnderPoint(_stage, new Point(_stage.mouseX, _stage.mouseY));
				if (_highlightTarget != null) {
					highlightDraw(true);
				}
				return;
			}
			
			// Only update the target
			if (_highlightTarget != null) {
				if (_highlightTarget.stage == null || _highlightTarget.parent == null) {
					_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
					_highlight.mouseEnabled = false;
					_highlightTarget = null;
					_highlightMouse = false;
					_highlightUpdate = false;
					return;
				}
				highlightDraw(false);
			}
		}
		
		
		/**
		 * Highlight an object.
		 */
		private static function highlightDraw(fill:Boolean):void
		{
			// Return if needed
			if (_highlightTarget == null) {
				return;
			}
			
			// Get the outer bounds
			var boundsOuter:Rectangle = _highlightTarget.getBounds(_stage);
			if (_highlightTarget is Stage) {
				boundsOuter.x = 0;
				boundsOuter.y = 0;
				boundsOuter.width = _highlightTarget["stageWidth"];
				boundsOuter.height = _highlightTarget["stageHeight"];
			} else {
				boundsOuter.x = int(boundsOuter.x + 0.5);
				boundsOuter.y = int(boundsOuter.y + 0.5);
				boundsOuter.width = int(boundsOuter.width + 0.5);
				boundsOuter.height = int(boundsOuter.height + 0.5);
			}

			// Get the inner bounds for border
			var boundsInner:Rectangle = boundsOuter.clone();
			boundsInner.x += 2;
			boundsInner.y += 2;
			boundsInner.width -= 4;
			boundsInner.height -= 4;
			if (boundsInner.width < 0) boundsInner.width = 0;
			if (boundsInner.height < 0) boundsInner.height = 0;
			
			// Draw the first border
			_highlight.graphics.clear();
			_highlight.graphics.beginFill(HIGHLITE_COLOR, 1);
			_highlight.graphics.drawRect(boundsOuter.x, boundsOuter.y, boundsOuter.width, boundsOuter.height);
			_highlight.graphics.drawRect(boundsInner.x, boundsInner.y, boundsInner.width, boundsInner.height);
			if (fill) {
				_highlight.graphics.beginFill(HIGHLITE_COLOR, 0.25);
				_highlight.graphics.drawRect(boundsInner.x, boundsInner.y , boundsInner.width, boundsInner.height);
			}
			
			// Set the text
			if (_highlightTarget.name != null) {
				_highlightInfo.text = String(_highlightTarget.name) + " - " + String(MonsterDebuggerDescribeType.get(_highlightTarget).@name);
			} else {
				_highlightInfo.text = String(MonsterDebuggerDescribeType.get(_highlightTarget).@name);
			}
			
			// Calculate the text size			
			var boundsText:Rectangle = new Rectangle(
				boundsOuter.x, 
				boundsOuter.y - (_highlightInfo.textHeight + 3), 
				_highlightInfo.textWidth + 15, 
				_highlightInfo.textHeight + 5
			);
			
			// Check for offset values
			if (boundsText.y < 0) boundsText.y = boundsOuter.y + boundsOuter.height;
			if (boundsText.y + boundsText.height > _stage.stageHeight) boundsText.y = _stage.stageHeight - boundsText.height;
			if (boundsText.x < 0) boundsText.x = 0;
			if (boundsText.x + boundsText.width > _stage.stageWidth) boundsText.x = _stage.stageWidth - boundsText.width;
			
			// Draw text container
			_highlight.graphics.beginFill(HIGHLITE_COLOR, 1);
			_highlight.graphics.drawRect(boundsText.x, boundsText.y, boundsText.width, boundsText.height);
			_highlight.graphics.endFill();
			
			// Set position
			_highlightInfo.x = boundsText.x;
			_highlightInfo.y = boundsText.y;
			
			// Add the highlight to the objects parent
			try {
				_stage.addChild(_highlight);
				_stage.addChild(_highlightInfo);
			} catch(e:Error) {
				// clearHighlight();
			}
		}
		
		
		/**
		 * Clear the highlight on a object
		 */
		private static function highlightClear():void
		{
			if (_highlight != null && _highlight.parent != null) {
				_highlight.parent.removeChild(_highlight);
				_highlight.graphics.clear();
				_highlight.x = 0;
				_highlight.y = 0;
			}
			if (_highlightInfo != null && _highlightInfo.parent != null) {
				_highlightInfo.parent.removeChild(_highlightInfo);
				_highlightInfo.x = 0;
				_highlightInfo.y = 0;
			}
		}
		
		
		/**
		 * Send data to the desktop application.
		 * @param data: The data to send
		 * @param direct: Use the queue or send direct (handshake)
		 */
		private static function send(data:Object, direct:Boolean = false):void
		{
			if (MonsterDebugger.enabled) {
				MonsterDebuggerConnection.send(MonsterDebuggerCore.ID, data, direct);
			}
		}
		
	}
	
}