package plugins;


import plugin.util.LevelPluginUtils.EditPropsUtil;
import plugin.util.LevelPluginUtils.EditPropsUtil;
import plugin.util.LevelPluginUtils.LevelObjectDisplayUtil;
import plugin.Plugin;
import plugin.Plugin.LevelPlugin_LevelObjectDisplay;
import plugin.Plugin.LevelPlugin_LevelObjectEditProps;
import js.Browser;
import js.html.SelectElement;
import plugin.util.LevelObjectPluginContext;
import js.jquery.Helper.*;
import js.jquery.JQuery;


var editProps: LevelPlugin_LevelObjectEditProps = {
    type: "LevelPlugin_LevelObjectEditProps",
    appliesToObject: function(context:LevelObjectPluginContext):Bool {
        return context.layerName == "other" && context.rowObject.kind == "shadow";
    },
    render: (context) -> {
        var html = "
            <div>
                <h3>Shadow</h3>
                <label for='fadeDirection'>Fade Direction:</label>
                <select id='fadeDirection'>
                    <option value='Up'>Up</option>
                    <option value='Down'>Down</option>
                    <option value='Left'>Left</option>
                    <option value='Right'>Right</option>
                </select>
                <br>
                <label for='layer'>Layer:</label>
                <select id='layer'></select>
            </div>
        ";
        var form = J(html);
        J(context.propsContainer).append(form);

        var fadeDirectionElement = cast(context.propsContainer.querySelector("#fadeDirection"), SelectElement);
        var layerElement = cast(context.propsContainer.querySelector("#layer"), SelectElement);

        var layers = context.levelUtils.getLayers();
        for (layer in layers) {
            var option = (cast Browser.document.createElement('option'): SelectElement);
            option.value = layer.name;
            option.innerText = layer.name;
            layerElement.appendChild(option);
        }

        if (context.rowObject.extraData != null && context.rowObject.extraData.length > 0) {
            if (context.rowObject.extraData[0].key == "fadeDirection") {
                fadeDirectionElement.value = context.rowObject.extraData[0].value;
            }
            if (context.rowObject.extraData.length > 1 && context.rowObject.extraData[1].key == "layer") {
                layerElement.value = context.rowObject.extraData[1].value;
            }
        }

        var sb = EditPropsUtil.createSaveButton(context);
        var fb = EditPropsUtil.createRenderNormalFormButton(context);
        J(context.propsContainer).append(sb);
        J(context.propsContainer).append(fb);
    },
    writeToSheet: function(context:LevelObjectPluginContext):Void {
        var fadeDirectionElement = cast(context.propsContainer.querySelector("#fadeDirection"), SelectElement);
        var layerElement = cast(context.propsContainer.querySelector("#layer"), SelectElement);

        context.rowObject.extraData = [
            {
                key: "fadeDirection",
                value: fadeDirectionElement.value
            },
            {
                key: "layer",
                value: layerElement.value
            }
        ];
    }
};

var display: LevelPlugin_LevelObjectDisplay = {
    type: "LevelPlugin_LevelObjectDisplay",
    appliesToObject: function(context:LevelObjectPluginContext):Bool {
        return context.layerName == "other" && context.rowObject.kind != null && context.rowObject.kind == "shadow";
    },
    execute: function(context:LevelObjectPluginContext):Void {
        LevelObjectDisplayUtil.textOverlay(context, "S", 0xFFF00101, true);
    }
};

var export: Array<Plugin> = [editProps, display];