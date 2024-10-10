import js.html.KeyboardEvent;
import UITest.UITestStep;
import js.html.MouseEvent;
import js.Browser;
import js.jquery.Helper.*;
import js.jquery.JQuery;

class TestUtils {

    public static function mouseEvent(event: String, x: Int, y: Int){
        var ev: MouseEvent = cast Browser.document.createEvent("MouseEvent");
        var el = Browser.document.elementFromPoint(x,y);
        ev.initMouseEvent(
            event,
            true /* bubble */, true /* cancelable */,
            Browser.window, null,
            x, y, x, y, /* coordinates */
            false, false, false, false, /* modifier keys */
            0 /*left*/, null
        );
        el.dispatchEvent(ev);
    }

    public static function click(x: Int, y: Int){
        trace("click: " + x + "," + y);
        var ev: MouseEvent = cast Browser.document.createEvent("MouseEvent");
        var el = Browser.document.elementFromPoint(x,y);
        ev.initMouseEvent(
            "click",
            true /* bubble */, true /* cancelable */,
            Browser.window, null,
            x, y, x, y, /* coordinates */
            false, false, false, false, /* modifier keys */
            0 /*left*/, null
        );
        el.dispatchEvent(ev);
    }

    public static function mouseMove(x: Int, y: Int){
        trace("mousemove: " + x + "," + y);
        var ev: MouseEvent = cast Browser.document.createEvent("MouseEvent");
        var el = Browser.document.elementFromPoint(x,y);
        ev.initMouseEvent(
            "mousemove",
            true /* bubble */, true /* cancelable */,
            Browser.window, null,
            x, y, x, y, /* coordinates */
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

    public static function getCell(x:Int, y:Int) {
        return J(UISelectors.CELL(x, y));
    }

    public static function keyEvent(eventType: String, keyCode: Int) {
        var e: KeyboardEvent; 
        var key = String.fromCharCode(keyCode);
        var eventInit = {
            key: key,
            code: "Key" + key.toUpperCase(),
            keyCode: keyCode,
            which: keyCode,
            bubbles: true,
            cancelable: true,
            shiftKey: false,
            ctrlKey: false,
            metaKey: false
        };
        
        e = new KeyboardEvent(eventType, eventInit);

        Browser.document.dispatchEvent(e);
    }

}