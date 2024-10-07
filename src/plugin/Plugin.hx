package plugin;

import plugin.util.PluginCompat.PLUGIN;
import util.ReflectObj;
import util.render.Image3D;
import ludi.commons.util.View;
import system.sheettype.SheetView;
import system.lvl.Level;
import util.Toast;
import js.Syntax;
import plugin.util.PluginParsingHelper;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig.RawIrisConfig;
import js.html.Element;
import system.lvl.LayerData;
import data.Types.Layer;
import platform.MenuItem;
import plugin.util.LevelObjectPluginContext;
import js.jquery.Helper.*;

using StringTools;

typedef Plugin = {
	var type:String;
	var ?name:String;
}

typedef MenuPlugin_Window = Plugin & {
	var menuPath:Array<String>;
	var shouldApply:MenuPlugin_Window_ShouldApply;
	function getMenu(context:MenuPluginContext):MenuItem;
}

enum MenuPlugin_Window_ShouldApply {
	Always;
	ToSheet(appliesToSheet:(Dynamic) -> Bool);
	ToSheetView(appliesToSheet:(Dynamic) -> Bool);
}

typedef MenuPlugin_RowContext = MenuPlugin_Window & {
	function appliesToRow(context:MenuPluginContext):Bool;
}

typedef MenuPlugin_SheetContext = MenuPlugin_Window & {
	function appliesToSheet(context:MenuPluginContext):Bool;
}

typedef MenuPluginContext = {
	var ?sheet:Dynamic;
	var ?row:Dynamic;
	var ?rowIndex:Int;
	var model:Model;
}

typedef SheetViewPlugin = Plugin & SheetViewHandler;

enum LevelPluginTrigger<T> {
	BeforeDraw(level:Level, layer:LayerData, x:Int, y:Int):LevelPluginTrigger<Bool>;
	LevelRedraw(level:Level, view: Image3D);
	LevelOpen(level:Level);
    LevelClose(level:Level);
	LayerChange(level:Level, layer:LayerData);
}

typedef LevelPlugin = Plugin & {
	function execute<T>(onTrigger:LevelPluginTrigger<T>):T;
}

typedef LevelPlugin_LevelObjectDisplay = Plugin & {
	function appliesToObject(context:LevelObjectPluginContext):Bool;
	function execute(context:LevelObjectPluginContext):Void;
}

typedef LevelPlugin_LevelObjectEditProps = Plugin & {
	function appliesToObject(context:LevelObjectPluginContext):Bool;
	function render(context:LevelObjectPluginContext):Void;
	function writeToSheet(context:LevelObjectPluginContext):Void;
}

typedef LevelPlugin_LevelObjectScript = Plugin & {
	var scriptName:String;
	function appliesToObject(context:LevelObjectPluginContext):Bool;
	function execute(context:LevelObjectPluginContext):Void;
}

enum abstract PluginType(String) from String to String {
	var MenuPlugin_Window = "MenuPlugin_Window";
	var MenuPlugin_RowContext = "MenuPlugin_RowContext";
	var MenuPlugin_SheetContext = "MenuPlugin_SheetContext";
	var SheetViewPlugin = "SheetViewPlugin";
	var LevelPlugin_LevelOptions = "LevelPlugin_LevelOptions";
	var LevelPlugin_LayerOptions = "LevelPlugin_LayerOptions";
	var LevelPlugin_LevelObjectDisplay = "LevelPlugin_LevelObjectDisplay";
	var LevelPlugin_LevelObjectEditProps = "LevelPlugin_LevelObjectEditProps";
	var LevelPlugin_LevelObjectScript = "LevelPlugin_LevelObjectScript";
}

class Plugins {
	public static var LOADED:Map<String, Array<Plugin>> = new Map<String, Array<Plugin>>();
	static final PLUGIN_DIRECTORY = "./plugins";
	static var GLOBAL:Dynamic = {};

	public static function get(type:String):Array<Plugin> {
		if (!LOADED.exists(type)) {
			return [];
		}
		return LOADED.get(type);
	}

    public static function getAs<T>(type:String, view: View<T>):Array<T> {
		return cast get(type);
	}

	public static function loadAll(model:Model) {
		// retrieve native class mappings from macro and force proxy them
		var map:Map<String, String> = Reflect.field(Type.resolveClass("Macro_NativeMappings"), "map");
		for (key => value in map) {
			if (Syntax.code("window[{0}]", value) != null) {
				Iris.addProxyImport(key, Syntax.code("window[{0}]", value));
			}
		}
		var dir = platform.VFileSystem.readDirectory(PLUGIN_DIRECTORY);
		for (file in dir) {
			trace("found file: " + file);
			if (file.endsWith(".hx")) {
				trace("loading plugin: " + file);
				try {
					load(PLUGIN_DIRECTORY + "/" + file);
					trace("Successfully loaded plugin: " + file);
				} catch (e) {
					trace("Error loading plugin: " + file + " \n" + e);
					Toast.show("Error loading plugin: " + file);
				}
			}
		}

		var sheetViews = LOADED["SheetViewPlugin"];
		if(sheetViews != null){
			for (value in sheetViews) {
				SheetViewManager.register(cast value);
			}
		}
	
	}

	public static function load(filePath:String) {
		var pluginFile = platform.VFile.getContent(filePath);

		var lines = pluginFile.split("\n");
		var cleanedLines = [];
		for (line in lines) {
			if (line.trim().startsWith("package ")) {
				continue; 
			}

			line = PluginParsingHelper.processLine(line);

			cleanedLines.push(line);
		}
		pluginFile = cleanedLines.join("\n");

		final rules:RawIrisConfig = {
			name: "My Script",
			autoRun: false,
			autoPreset: true,
			exportVariable: "export"
		};
		var myScript:Iris = new Iris(pluginFile, rules);

		myScript.set("J", (e) -> {
			return new js.jquery.JQuery(e);
		});
		myScript.set("Reflect", ReflectObj);
		myScript.set("Type", TypeObj);
		myScript.set("PLUGIN", PLUGIN);

		var ret = myScript.execute();

		var loadedPlugins:Array<Plugin> = [];
		if (ret is Array) {
			loadedPlugins = ret;
		} else {
			loadedPlugins = [cast ret];
		}

		for (pluginObject in loadedPlugins) {
			addPlugin(pluginObject);
		}
	}

	public static function addPlugin(plugin:Plugin) {
		if (!LOADED.exists(plugin.type)) {
			LOADED.set(plugin.type, new Array<Plugin>());
		}

		LOADED.get(plugin.type).push(plugin);
	}
}
