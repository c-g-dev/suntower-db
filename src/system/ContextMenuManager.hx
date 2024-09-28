package system;

import plugin.Plugin.MenuPlugin_SheetContext;
import plugin.Plugin.MenuPlugin_RowContext;
import plugin.Plugin.Plugins;
import plugin.Plugin.PluginType;
import system.db.Sheet;
import platform.MenuItem;

class ContextMenuManager {
    public static function getMenuItemsForRow(model: Model, sheet: Sheet, idx: Int): Array<MenuItem> {
        var result: Array<MenuItem> = [];
        var plugins: Array<MenuPlugin_RowContext> = cast Plugins.get(PluginType.MenuPlugin_RowContext);
        for (eachPlugin in plugins) {
            trace("eachPlugin: " + eachPlugin);

            var ctx = {
                sheet: sheet,
                row: sheet.lines[idx],
                rowIndex: idx,
                model: model
            };

            if(eachPlugin.appliesToRow(ctx)){
                var newItem = eachPlugin.getMenu(ctx);
                trace("newItem: " + newItem);
                result.push(newItem);
            }
        }
        return result;
    }
    public static function getMenuItemsForSheet(model: Model, sheet: Sheet): Array<MenuItem> {
        var result: Array<MenuItem> = [];
        var plugins: Array<MenuPlugin_SheetContext> = cast Plugins.get(PluginType.MenuPlugin_SheetContext);
        for (eachPlugin in plugins) {
            //if(eachPlugin.appliesToSheet(sheet)){
                //result.push(eachPlugin.getMenu());
           // }
        }
        return result;
    }
}