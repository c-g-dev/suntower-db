import UITest.UITestStep;
import js.html.MouseEvent;
import js.Browser;

class TestUtils {
    public static function click(x: Int, y: Int){
        var ev: MouseEvent = cast Browser.document.createEvent("MouseEvent");
        var el = Browser.document.elementFromPoint(x,y);
        ev.initMouseEvent(
            "click",
            true /* bubble */, true /* cancelable */,
            Browser.window, null,
            x, y, 0, 0, /* coordinates */
            false, false, false, false, /* modifier keys */
            0 /*left*/, null
        );
        el.dispatchEvent(ev);
    }

    public static function startTraceMouseEvents(): Void {
        Browser.window.onmousemove = (e: MouseEvent) -> {
            trace(e.clientX + "," + e.clientY);
        };
    }

    public static function stopTraceMouseEvents(): Void {
        Browser.window.onmousemove = null;
    }

    public static function asStep(cb: () -> Void): UITestStep {
        return (test) -> {
            cb();
            return NextStep;
        }
    }
}