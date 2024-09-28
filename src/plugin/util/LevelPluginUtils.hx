package plugin.util;

import util.render.Image;
import util.Caching;
import plugin.Plugin;
import plugin.Plugin.PluginType;
import plugin.Plugin.LevelPlugin_LevelObjectScript;
import util.Toast;
import js.html.Element;
import plugin.Plugin.LevelPlugin_LevelObjectEditProps;
import plugin.Plugin.PluginType;
import js.html.OptionElement;
import js.html.SelectElement;
import js.jquery.Helper.*;

using ludi.commons.extensions.All;

class LevelObjectScriptUtil {
	public static function isScriptEmpty(context:LevelObjectPluginContext):Bool {
		return context.rowObject.script == null
			|| context.rowObject.script == ""
			|| ((context.rowObject.script is Array) && context.rowObject.script.length == 0);
	}

    public static function buildScriptDropdown(context:LevelObjectPluginContext):Element {
		var applicableScripts:Array<LevelPlugin_LevelObjectScript> = new Array<LevelPlugin_LevelObjectScript>();
		for (eachPlugin in Plugins.get(PluginType.LevelPlugin_LevelObjectScript)) {
            if ((cast eachPlugin: LevelPlugin_LevelObjectScript).appliesToObject(context)) {
                applicableScripts.push(cast eachPlugin);
            }
		}

		var container = js.Browser.document.createElement("div");

		var dropdown:SelectElement = cast js.Browser.document.createElement("select");
		for (script in applicableScripts) {
			var option:OptionElement = cast js.Browser.document.createElement("option");
			option.text = script.scriptName;
			option.value = script.scriptName;
			dropdown.appendChild(option);
		}

		var runButton = js.Browser.document.createElement("button");
		runButton.textContent = "Run";
		runButton.addEventListener("click", function(e) {
			context.refresh();
			var selectedOption = dropdown.value;
			var chosenPlugin = applicableScripts.find(function(script) {
				return script.scriptName == selectedOption;
			});
			if (chosenPlugin != null) {
				chosenPlugin.execute(context);
				@:privateAccess context.level.editProps(context.layerData, context.rowIdx);
			}
		});

		container.appendChild(dropdown);
		container.appendChild(runButton);

		return container;
	}
}


class EditPropsUtil {

    public static function renderPlugin(context: LevelObjectPluginContext): Void {
        for (eachPlugin in (cast Plugins.get(PluginType.LevelPlugin_LevelObjectEditProps): Array<LevelPlugin_LevelObjectEditProps>)) {
            if (eachPlugin.appliesToObject(context)) {
                J(context.defaultEditPropsElement).hide();
                eachPlugin.render(context);
                context.appliedPlugins.push(eachPlugin);
            }
        }
    }

    public static function createSaveButton(context: LevelObjectPluginContext): Element {
        var button = J("<input class='button' type='submit' value='Save'/>");
        button.click((e) -> {
            (cast context.thisPlugin: LevelPlugin_LevelObjectEditProps).writeToSheet(context);
            context.level.save();
            Toast.show("Saved");
        });
        return button.get(0);
    }

    public static function createRenderNormalFormButton(context: LevelObjectPluginContext): Element {
        var button = J("<input class='button' type='submit' value='Edit All Props'/>");
        button.click((e) -> {
            J(context.defaultEditPropsElement).show();
        });
        return button.get(0);
    }
}

class LevelObjectDisplayUtil {

    public static function apply(context: LevelObjectPluginContext) {
        // Apply all Display_LevelObjectPlugin plugins
        for (eachPlugin in (cast Plugins.get(PluginType.LevelPlugin_LevelObjectDisplay): Array<LevelPlugin_LevelObjectDisplay>)) {
            if(!eachPlugin.appliesToObject(context)) continue;
            eachPlugin.execute(context);
        }
        
    }
    public static function textOverlay(context: LevelObjectPluginContext, text: String, color: Int, tessellate: Bool): Void {
        var img: Image = Caching.get("textOverlay_" + text + "_" + color);
        if(img == null) {
            trace("making text image in cache");
            img = new Image(32, 32);
            img.text(text, 16, 16, color);
            Caching.set("textOverlay_" + text + "_" + color, img);
        }
        if(tessellate) {
            var stride = context.rowObject.width;
            var draft = context.rowObject.height;
            for(py in 0...draft){
                for(px in 0...stride){
                    context.levelObjectImage.image.draw(img, context.levelObjectImage.x + (px*32), context.levelObjectImage.y + (py*32));
                }
            }
        }
        else{
            context.levelObjectImage.image.draw(img, context.levelObjectImage.x,context.levelObjectImage.y);
        }
    }
}