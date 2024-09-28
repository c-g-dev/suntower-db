package plugin.level;

import plugin.util.LevelPluginUtils.LevelObjectScriptUtil;
import plugin.Plugin;
import plugin.Plugin.LevelPlugin_LevelObjectScript;
import plugin.Plugin.LevelPlugin_LevelObjectEditProps;
import js.Browser;
import js.html.SelectElement;
import plugin.util.LevelObjectPluginContext;
import js.jquery.Helper.*;
import js.jquery.JQuery;


var script: LevelPlugin_LevelObjectScript = {
    type: "LevelPlugin_LevelObjectScript",
    scriptName: "Clear script",
    appliesToObject: function(context: LevelObjectPluginContext): Bool {
        return !LevelObjectScriptUtil.isScriptEmpty(context);
    },
    execute: function(context: LevelObjectPluginContext): Void {
        Reflect.deleteField(context.rowObject, "script");
    }
};

var export: Array<Plugin> = [script];