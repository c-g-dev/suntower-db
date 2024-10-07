import haxe.Timer;
import util.Toast;
import plugin.Plugin;
import plugin.util.PluginCompat.PLUGIN;
import UITest.UITestRunner;
import platform.MenuItem;
import plugin.Plugin.MenuPluginContext;
import plugin.Plugin.MenuPlugin_Window_ShouldApply;
import plugin.Plugin.MenuPlugin_Window;
import js.jquery.Helper.*;
import js.jquery.JQuery;


var runUnitTestsMenuPluginWindow: MenuPlugin_Window = {
    type: "MenuPlugin_Window",
    shouldApply: MenuPlugin_Window_ShouldApply.Always,
    menuPath: ["Dev"],
    getMenu: function(context: MenuPluginContext): Dynamic {
        var runUnitTestsPopupHTML: String = '
            <div id="run-unit-tests-popup" class="modal" style="display:none">
                <div class="content info">
                    <form id="unit_tests_form" onsubmit="return false">
                        <h1>Run Unit Tests?</h1>
                        <p>
                            Unit tests will validate the integrity of the GUI.<br/><br/>
                            Running unit tests will reset all data. Please save your work.<br/><br/>
                            Would you like to run unit tests?
                        </p> 
                        <p class="buttons">
                            <input type="button" id="confirm_unit_tests_button" value="Confirm"/>
                            <input type="button" id="cancel_unit_tests_button" value="Cancel"/>
                        </p>
                    </form>
                </div>
            </div>';

        J("#helpers").append(J(runUnitTestsPopupHTML));

        J("#confirm_unit_tests_button").click((e) -> {
            Toast.show("Unit tests will start in 5 seconds. Beware of blinking lights.");
            Timer.delay(() -> {
                new UITestRunner(PLUGIN.dyn(context.model)).start();
            }, 5000);
            J("#run-unit-tests-popup").hide();
        });

        J("#cancel_unit_tests_button").click((e) -> {
            J("#run-unit-tests-popup").hide();
        });

        var mi: MenuItem = new MenuItem({label: "Run Unit Tests"});
        mi.click = () -> {
            trace("Run Unit Tests clicked");
            J("#run-unit-tests-popup").show();
        }

        return mi;
    }
};