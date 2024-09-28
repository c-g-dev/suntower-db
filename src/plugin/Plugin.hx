package plugin;

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
    var type: String;
    var ?name: String;
}

typedef MenuPlugin_Window = Plugin & {
    var menuPath: Array<String>;
    var shouldApply: MenuPlugin_Window_ShouldApply;
    function getMenu(context: MenuPluginContext): MenuItem;
}

enum MenuPlugin_Window_ShouldApply {
    Always;
    ToSheet(appliesToSheet: (Dynamic) -> Bool);
    ToSheetView(appliesToSheet: (Dynamic) -> Bool);
}

typedef MenuPlugin_RowContext = MenuPlugin_Window & {
    function appliesToRow(context: MenuPluginContext): Bool;
}

typedef MenuPlugin_SheetContext = MenuPlugin_Window & {
    function appliesToSheet(context: MenuPluginContext): Bool;
}

typedef MenuPluginContext = {
    var ?sheet: Dynamic;
    var ?row: Dynamic;
    var ?rowIndex: Int;
    var model: Model;
}

interface SheetView {
    function getElement(): Element;
}

typedef SheetViewPluginContext = {
    var sheet: Dynamic;
    var row: Dynamic;
    var sheetView: SheetView;
}

typedef SheetViewPlugin = Plugin & {
    function render(context: SheetViewPluginContext): SheetView;
    function getRowObject(context: SheetViewPluginContext): Dynamic;
    function onClose(context: SheetViewPluginContext): Void;
}


typedef LevelPlugin<T> = Plugin & {
    var trigger: LevelPluginTrigger<T>;
    function shouldApply(context: T): Bool;
    function execute(context: T): Void;
}

enum LevelPluginTrigger<T> {
    Draw: LevelPluginTrigger<{}>;
    LevelOptionsRender: LevelPluginTrigger<{level: Level}>;
    LayerOptionsRender: LevelPluginTrigger<{level: Level, layer: LayerData}>;
}

typedef LevelPlugin_LevelObjectDisplay = Plugin & {
    function appliesToObject(context: LevelObjectPluginContext): Bool;
    function execute(context: LevelObjectPluginContext): Void;
}
typedef LevelPlugin_LevelObjectEditProps = Plugin & {
    function appliesToObject(context: LevelObjectPluginContext): Bool;
    function render(context: LevelObjectPluginContext): Void;
    function writeToSheet(context: LevelObjectPluginContext): Void;
}
typedef LevelPlugin_LevelObjectScript = Plugin & {
    var scriptName: String;
    function appliesToObject(context: LevelObjectPluginContext): Bool;
    function execute(context: LevelObjectPluginContext): Void;
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

	public static function loadAll(model:Model) {
        //retrieve native class mappings from macro and force proxy them
        var map: Map<String,String> = Reflect.field(Type.resolveClass("Macro_NativeMappings"), "map");
        for (key => value in map) {
            if(Syntax.code("window[{0}]", value) != null){
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

        //addPlugin(generateSchemaPlugin);
    }
	
    public static function load(filePath:String) {
        var pluginFile = platform.VFile.getContent(filePath);

        // clean lines for hscript parser
        var lines = pluginFile.split("\n");
        var cleanedLines = [];
        for (line in lines) {
            if (line.trim().startsWith("package ")) {
                continue; // Skip the package statement
            }

            line = PluginParsingHelper.processLineForCastSyntax(line);

            //TODO
            //if line has "(cast " or " cast "
            //the expression will need to change to use the safe cast operation
            //eg
                //(cast Browser.document.createElement('option'): SelectElement)
                //will need to transform into
                //cast(Browser.document.createElement('option'), SelectElement)

            cleanedLines.push(line);
        }
        pluginFile = cleanedLines.join("\n");

        final rules:RawIrisConfig = {name: "My Script", autoRun: false, autoPreset: true, exportVariable: "export" };
		var myScript:Iris = new Iris(pluginFile, rules);

        myScript.set("J", (e) -> {
            return new js.jquery.JQuery(e);
        });
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