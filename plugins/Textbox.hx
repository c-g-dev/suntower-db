package plugin.impl;

import plugin.util.LevelPluginUtils.EditPropsUtil;
import plugin.Plugin;
import plugin.util.LevelPluginUtils.LevelObjectScriptUtil;
import plugin.util.LevelPluginUtils.LevelObjectDisplayUtil;
import plugin.Plugin.LevelPlugin_LevelObjectScript;
import plugin.Plugin.LevelPlugin_LevelObjectDisplay;
import plugin.util.LevelObjectPluginContext;
import plugin.Plugin.LevelPlugin_LevelObjectEditProps;
import plugin.util.LevelObjectPluginContext;
import js.html.SelectElement;
import js.html.Element;
import js.html.TextAreaElement;
import js.jquery.Helper.*;
import js.jquery.JQuery;

var editProps: LevelPlugin_LevelObjectEditProps = {
    type: "LevelPlugin_LevelObjectEditProps",
    appliesToObject: function(context:LevelObjectPluginContext):Bool {
        return true;
    },
    render: function(context:LevelObjectPluginContext):Void {
        var html = "
            <div>
                <h3>Textbox</h3>
                <label for='eventType'>Event Type:</label>
                <select id='eventType'>
                    <option value='OnInteract'>OnInteract</option>
                    <option value='OnWalk'>OnWalk</option>
                </select>
                <br>
                <label for='contentText'>Content:</label>
                <textarea id='contentText'></textarea>
            </div>
        ";
        var form = J(html);
		J(context.propsContainer).append(form);

		var eventTypeElement = cast(context.propsContainer.querySelector("#eventType"), SelectElement);
		var contentTextElement = cast(context.propsContainer.querySelector("#contentText"), TextAreaElement);

		var defaultEventType = "OnInteract";
		if (context.rowObject.eventType != null && context.rowObject.eventType.length > 0 && context.rowObject.eventType[0] == 1) {
			defaultEventType = "OnWalk";
		}
		eventTypeElement.value = defaultEventType;

		var defaultContentText = "";
		if (context.rowObject.script != null && context.rowObject.script.length > 1 && context.rowObject.script[0] == 2) {
			defaultContentText = context.rowObject.script[1];
		}
		contentTextElement.value = defaultContentText;

		J(context.propsContainer).append(EditPropsUtil.createSaveButton(context));
		J(context.propsContainer).append(EditPropsUtil.createRenderNormalFormButton(context));
    },
    writeToSheet: function(context:LevelObjectPluginContext):Void {

    }
};

var display: LevelPlugin_LevelObjectDisplay = {
    type: "LevelPlugin_LevelObjectDisplay",
    appliesToObject: function(context:LevelObjectPluginContext):Bool {
        return context.layerName == "events" && context.rowObject.script != null && context.rowObject.script[0] == 2;
    },
    execute: function(context:LevelObjectPluginContext):Void {
        LevelObjectDisplayUtil.textOverlay(context, "T", 0xFFF00101, true);
    }
};

var script: LevelPlugin_LevelObjectScript = {
    type: "LevelPlugin_LevelObjectScript",
    scriptName: "Create Textbox",
    appliesToObject: function (context: LevelObjectPluginContext): Bool{
        return context.layerName == "events" && LevelObjectScriptUtil.isScriptEmpty(context);
    },
    execute: function (context: LevelObjectPluginContext): Void {
        context.rowObject.script = [2, ""];
        if(context.rowObject.width == 1){
            context.rowObject.width = 2;
        }
        if(context.rowObject.height == 1){
            context.rowObject.height = 2;
        }
    }
};

var export: Array<Plugin> = [editProps, display, script];