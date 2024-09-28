package plugin.util;

import plugin.Plugin.MenuPlugin_Window;
import system.WindowMenuManager.TransientWindowMenuState;

class PluginHelper {
    public static function createTransientWindowMenuState(plugin: MenuPlugin_Window): TransientWindowMenuState {
        var result: TransientWindowMenuState = {
            menuPath: plugin.menuPath,
            isDisplayed: false,
            shouldApply: function(model) {
                @:privateAccess  switch plugin.shouldApply {
                    case Always: return true;
                    case ToSheet(appliesToSheet): {
                        return appliesToSheet((cast model: Main).viewSheet);
                    }
                    case ToSheetView(appliesToSheet): {
                        return appliesToSheet((cast model: Main).viewSheet);
                    }
                }
                return true;
            },
            createMenuItem: function(model) {
                @:privateAccess return plugin.getMenu({
                    model: model,
                    sheet: (cast model: Main).viewSheet
                });
            }
        };

        return result;
    }
}