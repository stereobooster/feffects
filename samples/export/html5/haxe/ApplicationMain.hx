#if !macro
#if (nme && !flambe)

import Main;
import haxe.Resource;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Loader;
import nme.events.Event;
import nme.media.Sound;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLLoaderDataFormat;
import nme.Assets;
import nme.Lib;

#if haxe3
import haxe.ds.StringMap;
#else
typedef StringMap<T> = Hash<T>;
#end

class ApplicationMain {

	private static var completed:Int;
	private static var preloader:NMEPreloader;
	private static var total:Int;

	public static var loaders:StringMap <Loader>;
	public static var urlLoaders:StringMap <URLLoader>;

	public static function main() {
		completed = 0;
		loaders = new StringMap <Loader>();
		urlLoaders = new StringMap <URLLoader>();
		total = 0;
		
		nme.Lib.setPackage("filt3rek", "FEffectsSample", "com.filt3rek.FEffectsSample", "1.0.0");
		nme.Lib.current.loaderInfo = nme.display.LoaderInfo.create (null);

		

		
		preloader = new NMEPreloader();
		
		Lib.current.addChild(preloader);
		preloader.onInit();

		
		
		var resourcePrefix = "NME_:bitmap_";
		for (resourceName in Resource.listNames()) {
			if (StringTools.startsWith (resourceName, resourcePrefix)) {
				var type = Type.resolveClass(StringTools.replace (resourceName.substring(resourcePrefix.length), "_", "."));
				if (type != null) {
					total++;
					var instance = Type.createInstance (type, [ 0, 0, true, 0x00FFFFFF, bitmapClass_onComplete ]);
				}
			}
		}
		
		if (total == 0) {
			begin();
		} else {
			for (path in loaders.keys()) {
				var loader:Loader = loaders.get(path);
				loader.contentLoaderInfo.addEventListener("complete",
          loader_onComplete);
				loader.load (new URLRequest (path));
			}

			for (path in urlLoaders.keys()) {
				var urlLoader:URLLoader = urlLoaders.get(path);
				urlLoader.addEventListener("complete", loader_onComplete);
				urlLoader.load(new URLRequest (path));
			}
		}
	}

	private static function begin():Void {
		preloader.addEventListener(Event.COMPLETE, preloader_onComplete);
		preloader.onLoaded ();
	}
	
	private static function bitmapClass_onComplete(instance:BitmapData):Void {
		completed++;
		var classType = Type.getClass (instance);
		Reflect.setField (classType, "preload", instance);
		if (completed == total) {
			begin ();
		}
	}

	private static function loader_onComplete(event:Event):Void {
		completed ++;
		preloader.onUpdate (completed, total);
		if (completed == total) {
			begin ();
		}
	}

	private static function preloader_onComplete(event:Event):Void {
		preloader.removeEventListener(Event.COMPLETE, preloader_onComplete);
		Lib.current.removeChild(preloader);
		preloader = null;
		if (Reflect.field(Main, "main") == null)
		{
			var mainDisplayObj = Type.createInstance(DocumentClass, []);
			if (Std.is(mainDisplayObj, browser.display.DisplayObject))
				nme.Lib.current.addChild(cast mainDisplayObj);
		}
		else
		{
			Reflect.callMethod(Main, Reflect.field (Main, "main"), []);
		}
	}
}

@:build(DocumentClass.build())
class DocumentClass extends Main {}

#else

import Main;

class ApplicationMain {

	public static function main() {
		if (Reflect.field(Main, "main") == null) {
			Type.createInstance(Main, []);
		} else {
			Reflect.callMethod(Main, Reflect.field(Main, "main"), []);
		}
	}
}

#end
#else

import haxe.macro.Context;
import haxe.macro.Expr;

class DocumentClass {
	
	macro public static function build ():Array<Field> {
		var classType = Context.getLocalClass().get();
		var searchTypes = classType;
		while (searchTypes.superClass != null) {
			if (searchTypes.pack.length == 2 && searchTypes.pack[1] == "display" && searchTypes.name == "DisplayObject") {
				var fields = Context.getBuildFields();
				var method = macro {
					return nme.Lib.current.stage;
				}
				fields.push ({ name: "get_stage", access: [ APrivate, AOverride ], kind: FFun({ args: [], expr: method, params: [], ret: macro :nme.display.Stage }), pos: Context.currentPos() });
				return fields;
			}
			searchTypes = searchTypes.superClass.t.get();
		}
		return null;
	}
	
}
#end