package util;

import js.html.ImageData;
import js.html.AnchorElement;
import haxe.io.UInt8Array;
import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.RenderingContext;
import util.render.Image3D;

class LevelTools {
    

    public static function exportToPNG(canvas: CanvasElement): Void {

        Browser.window.requestAnimationFrame(function(dt) {
            var dataURL = canvas.toDataURL('image/png');
            var a = (cast Browser.document.createElement('a'): AnchorElement);
            a.href = dataURL;
            a.download = 'level.png';
            a.click();
        });

    }

}