import plugin.Plugin;
import plugin.Plugin.MenuPlugin_Window;

import haxe.Json;
import util.query.SqlEngine;
import js.html.TextAreaElement;
import js.Browser;
import platform.MenuItem;
import js.jquery.Helper.J;
import plugin.Plugin.MenuPlugin_Window_ShouldApply;

var menuPluginWindow: MenuPlugin_Window = {
    type: "MenuPlugin_Window",
    shouldApply: MenuPlugin_Window_ShouldApply.Always,
    menuPath: ["Database"],
    getMenu: function(context: MenuPluginContext): Dynamic {
        var runQueryPopupHTML: String = '
            <div id="run-query-popup" class="modal" style="display:none">
                <div class="content">
                    <form id="query_form" onsubmit="return false">
                        <h1>Run Query</h1>
                        <p>
                            <span>Query</span>
                            <textarea id="query_input"></textarea>
                        </p>
                        <p>
                            <span>Result</span>
                            <textarea id="result_area" readonly></textarea>
                        </p>
                        <p class="buttons">
                            <input type="submit" id="run_query_button" value="Run Query"/>
                            <input type="submit" value="Close" onclick="$(this).parents(\'.modal\').hide()"/>
                        </p>
                    </form>
                </div>
            </div>';

        J("#helpers").append(J(runQueryPopupHTML));
        J("#run_query_button").click((e) -> {
            var query:String = cast(J("#query_input").get(0), TextAreaElement).value;
            var q = new SqlEngine(context.model.base);
            var result = q.run(query);
            cast(J("#result_area").get(0), TextAreaElement).value = Json.stringify(result);
        });

        var mi: MenuItem = new MenuItem({label: "Run Query"});
        mi.click = () -> {
			trace("run query clicked");
            J("#run-query-popup").show();
        }
        
        return mi;
    }
};

var export: Array<Plugin> = [menuPluginWindow];