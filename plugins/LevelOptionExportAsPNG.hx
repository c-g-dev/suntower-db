import plugin.util.PluginCompat.PLUGIN;
import js.html.AnchorElement;
import js.html.CanvasElement;
import js.Browser;
import util.LevelTools;
import plugin.Plugin;
import haxe.Timer;
import system.lvl.Level;
import util.render.Image3D;
import system.SharedRepo;
import plugin.Plugin.LevelPluginTrigger;
import plugin.Plugin.LevelPlugin;

function exportToPNG(canvas: CanvasElement): Void {

    PLUGIN.window.requestAnimationFrame((dt) -> {
        var dataURL = canvas.toDataURL('image/png');
        var a = (cast PLUGIN.document.createElement('a'): AnchorElement);
        a.href = dataURL;
        a.download = 'level.png';
        a.click();
    });

}

var pngExportPlugin: LevelPlugin = {
    type: "LevelPlugin",
    execute: (onTrigger) -> {
        
        switch onTrigger {
            case LevelPluginTrigger.LevelOpen(_): {
                var level = onTrigger.getParameters()[0];
                var opt = level.content.find(".submenu.options");
                opt.append('<div class="item pngExportPlugin">
					<input type="submit" name="pngExport" value="Export as PNG"/>
				</div>');
                opt.find("[name=pngExport]").on('click', (e) -> {
                    exportToPNG(level.view.getCanvas());
                });
            }
            case LevelPluginTrigger.LevelClose(_): {
                var level = onTrigger.getParameters()[0];
                var opt = level.content.find(".submenu.options");
                opt.find(".pngExportPlugin").remove();
            }
            default:
        }
        return null;
    }
}

var export:Array<Plugin> = [pngExportPlugin];