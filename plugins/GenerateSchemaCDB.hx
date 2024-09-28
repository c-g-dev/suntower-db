package menus;

import data.Parser;
import util.CastleDBSchemaGenerator;
import platform.MenuItem;
import plugin.Plugin;
import plugin.Plugin.MenuPlugin_Window;
import plugin.Plugin.MenuPlugin_Window_ShouldApply;
import haxe.Json;
import util.query.SqlEngine;
import js.html.TextAreaElement;
import js.Browser;
import util.DatabaseTools;
import js.jquery.Helper.*;

var generateSchemaPlugin:MenuPlugin_Window = {
	type: "MenuPlugin_Window",
	shouldApply: MenuPlugin_Window_ShouldApply.Always,
	menuPath: ["Generate"],
	getMenu: function(context:MenuPluginContext):Dynamic {
		var mi:MenuItem = new MenuItem({label: "Generate Schema CDB"});
		mi.click = () -> {
				DatabaseTools.saveSchema(context.model.base);
		}

		return mi;
	}
};

var export:Array<Plugin> = [generateSchemaPlugin];
