import plugin.Plugin.MenuPlugin_Window_ShouldApply;
import plugin.Plugin.MenuPluginContext;
import platform.MenuItem;
import plugin.Plugin.MenuPlugin_RowContext;

var menuPlugin = {
    type: "MenuPlugin_RowContext",
    menuPath: [],
    shouldApply: MenuPlugin_Window_ShouldApply.Always,
    appliesToRow: (context) -> {
        return true;
    },
    getMenu: (context) -> {
        var ndup = new MenuItem( { label : "Duplicate" } );
        ndup.click = () -> {
			context.sheet.copyLine(context.rowIndex);
			context.model.refresh();
			context.model.save();
		};
        return ndup;
    }
};

var export = [menuPlugin];