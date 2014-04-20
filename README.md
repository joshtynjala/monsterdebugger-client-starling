# Monster Debugger Client Library for Starling Framework

This fork of the [Monster Debugger](http://www.demonsterdebugger.com) client library adds support for [Starling Framework](http://gamua.com/starling/). Developers gain the ability to explore a Starling application at runtime, including display list introspection, editing properties, running methods, and seeing traces... everything Monster Debugger supports on the classic display list works with Starling too!

This fork of the client library works with the official version of the Monster Debugger Adobe AIR application, completely unmodified, that can be downloaded from [demonsterdebugger.com](http://www.demonsterdebugger.com).

### Example Code

Setting up Monster Debugger with Starling Framework is as simple as passing a Starling display object to `MonsterDebugger.initialize()`:

	package {

		import com.demonsters.debugger.MonsterDebugger;
		import starling.display.Sprite;
		
		public class Main extends Sprite {
		
			public function Main() {
			
				// Start the MonsterDebugger with a Starling display object
				MonsterDebugger.initialize(this);
				MonsterDebugger.trace(this, "Hello World!");
			}
		}
	}

## What is Monster Debugger?

[Monster Debugger](http://www.demonsterdebugger.com) has been developed by Amsterdam based design studio [De Monsters](http://www.demonsters.com/) to assist in debugging applications created in Flash, Flex and AIR. With Monster Debugger you can:

* Trace various types of data that are present in your project and view them in a friendly way.
* Explore your live application
* Edit properties at runtime
* Run methods and get the results at runtime
* See detailed traces

Monster Debugger has been developed as an AIR application and thus runs on Windows, Mac and Linux. By adding an ActionScript class to your projects you are ready to start debugging your application using Monster Debugger.