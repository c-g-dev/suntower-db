package system.sheettype;

import thx.Timer;
import haxe.Json;
import util.query.Querier;
import data.Data.Column;
import system.db.Sheet;
import js.lib.Promise;
import data.Data.ColumnType;
import js.html.Element;
import js.jquery.Helper.*;

interface SheetView {
    function getElement(): Element;
}

typedef SheetViewContext = {
    var sheet: Sheet;
    var rowIndex: Dynamic;
    var row: Dynamic;
    var sheetView: SheetView;
    var handler: SheetViewHandler;
}

typedef SheetViewHandler = {
    var definition: {
        name: String,
        schema: Array<{n: String, t: ColumnType}>
    };
    function render(context: SheetViewContext): SheetView;
    function toRowObject(context: SheetViewContext): Promise<Dynamic>;
    var ?onClose: (SheetViewContext) -> Promise<Void>;
}

class SheetViewManager {
    static var HANDLERS:Map<String, SheetViewHandler> = [];
    static var CURRENT_CONTEXT: SheetViewContext = null;

    public static function register(handler:SheetViewHandler) {
        HANDLERS.set(handler.definition.name, handler);
    }

    public static function getHandler(name:String):SheetViewHandler {
        return HANDLERS.get(name);
    }

    public static function exists(name:String):Bool {
        trace("SheetViewManager exists: " + name + " " + HANDLERS.exists(name) + " " + HANDLERS);
        return HANDLERS.exists(name);
    }

    public static function getRegisteredTypes():Array<String> {
        var result:Array<String> = [];
        for (k => _ in HANDLERS) {
            result.push(k);
        }
        return result;
    }

    public static function populateTable(sheet: Sheet, id: String, model: Main): Void {
        trace("populate table: " + id + " " + sheet.getName() + " " + sheet.sheetType); 
        var handler = getHandler(id);
        var cols = handler.definition.schema;
 
        for( c in cols ) {
            if( sheet.hasColumn(c.n) ) {
                if( !sheet.hasColumn(c.n, [c.t]) ) {
                    model.error("Column " + c.n + " already exists but does not have type " + c.t);
                    return;
                }
            } else {
                inline function mkCol(n, t) : Column return { name : n, type : t, typeStr : null };
                var col = mkCol(c.n, c.t);
                sheet.addColumn(col);
            }
        }

    }
    
    public static function open(sheet: Sheet, rowIndex: Int, model: Main): Void {
        //@:privateAccess trace("open: " + sheet.sheet + " " + sheet.name + " " + rowIndex);
        if( CURRENT_CONTEXT != null ) {
            close(model);
        }

        var st = sheet.sheetType;
        var handler = getHandler(st);
        if( handler != null ) {
            CURRENT_CONTEXT = {
                sheet: sheet,
                rowIndex: rowIndex,
                row: sheet.getLines()[rowIndex],
                sheetView: null,
                handler: handler
            };
            CURRENT_CONTEXT.sheetView = handler.render(CURRENT_CONTEXT);
            renderView(model);
        }
    }

    static function renderView(model: Main): Void {
        if (CURRENT_CONTEXT == null) return;

        J("#content").css("display", "none");
        J("#custom-view-container").css("display", "block");
        J("#custom-view-content").css("display", "block");
        J("#custom-view-content").append(CURRENT_CONTEXT.sheetView.getElement());
        J("#custom-view-header").find(".options input[type='submit']").on("click", (e) -> {
            close(model);
        });
    }

    public static function close(model: Main): Void {
        if( CURRENT_CONTEXT != null ) {
            var rowObject = CURRENT_CONTEXT.handler.toRowObject(CURRENT_CONTEXT);
            var q = new Querier(model.base);
            q.update(CURRENT_CONTEXT.sheet.getName(), rowObject, (eachRow, idx) -> {
                return idx == CURRENT_CONTEXT.rowIndex;
            });
            model.save();

            var unrender = () -> {
                var ctc = J("#custom-view-content");
                ctc.empty();
                ctc.css("display", "none");
                J("#custom-view-container").css("display", "none");
                J("#content").css("display", "block");
                cast(model, Main).initContent();
                @:privateAccess cast(model, Main).refresh();
            };

            haxe.Timer.delay(() -> {
                if(CURRENT_CONTEXT.handler.onClose != null){
                    CURRENT_CONTEXT.handler.onClose(CURRENT_CONTEXT).then((_) -> {
                        unrender();
                    });
                }
                else{
                    unrender();
                }
                
                CURRENT_CONTEXT = null;
            }, 0);

        }
    }
}