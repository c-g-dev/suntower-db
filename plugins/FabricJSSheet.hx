package system.sheettype;

import plugin.Plugin;
import plugin.Plugin.SheetViewPlugin;
import haxe.Json;
import system.sheettype.SheetView.SheetViewContext;
import data.Data.ColumnType;
import js.html.Element;
import system.sheettype.SheetView.SheetViewHandler;
import js.Browser;
import js.html.IFrameElement;
import js.html.Element;
import js.html.Window;
import js.html.Document;
import js.html.CanvasElement;
import js.html.Event;
import js.Syntax;

import plugin.util.PluginCompat.PLUGIN;

var FabricJSSheetView = (context) -> {
    var iframe: IFrameElement;
    var canvas: Dynamic;
    var readyPromise: Dynamic;

    var result: Dynamic = {};
    Reflect.setField(result, "getElement", () -> {
        return iframe;
    });
    Reflect.setField(result, "exportToJSON", () -> {
        return readyPromise.then((_) -> {
            if (canvas != null && canvas.toJSON != null) {
                var json:String = Json.stringify(canvas.toJSON());
                return PLUGIN.promiseResolve(json);
            } else {
                trace('Canvas is not ready or toJSON is not available.');
                return PLUGIN.promiseReject('Canvas is not ready');
            }
        });
    });
    Reflect.setField(result, "importFromJSON", (json) -> {
        return readyPromise.then((_) -> {
            if (canvas != null && canvas.loadFromJSON != null) {
                return PLUGIN.promise((resolve, reject) -> {
                    canvas.loadFromJSON(json, () -> {
                        canvas.renderAll();
                        resolve(null);
                    });
                });
            } else {
                trace('Canvas is not ready or loadFromJSON is not available.');
                return PLUGIN.promiseReject('Canvas is not ready');
            }
        });
    });
    Reflect.setField(result, "getFabricHTMLContent", () -> {
        return '
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <title>Fabric.js Free Drawing Demo</title>
        <!-- Include Fabric.js library from CDN -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/fabric.js/5.3.0/fabric.min.js"></script>
        <style>
          body {
            font-family: sans-serif;
            margin: 20px;
          }
          #c {
            border: 1px solid #ccc;
          }
          #drawing-mode-options {
            margin-top: 10px;
          }
          label {
            display: inline-block;
            width: 150px;
          }
          input, select {
            margin-bottom: 10px;
          }
        </style>
        </head>
        <body>
        
        <canvas id="c" width="600" height="400"></canvas>
        
        <br>
        
        <button id="drawing-mode">Cancel drawing mode</button>
        <button id="clear-canvas">Clear</button>
        
        <div id="drawing-mode-options">
        
          <label for="drawing-mode-selector">Brush:</label>
          <select id="drawing-mode-selector">
            <option value="Pencil">Pencil</option>
            <option value="Circle">Circle</option>
            <option value="Spray">Spray</option>
            <option value="Pattern">Pattern</option>
            <option value="hline">Hline</option>
            <option value="vline">Vline</option>
            <option value="square">Square</option>
            <option value="diamond">Diamond</option>
            <option value="texture">Texture</option>
          </select>
        
          <br>
        
          <label for="drawing-color">Drawing color:</label>
          <input type="color" id="drawing-color" value="#000000">
        
          <br>
        
          <label for="drawing-shadow-color">Shadow color:</label>
          <input type="color" id="drawing-shadow-color" value="#000000">
        
          <br>
        
          <label for="drawing-line-width">Line width:</label>
          <input type="range" id="drawing-line-width" min="1" max="150" value="1" oninput="document.getElementById(\'line-width-value\').innerHTML = this.value;">
          <span id="line-width-value">1</span>
        
          <br>
        
          <label for="drawing-shadow-width">Shadow width:</label>
          <input type="range" id="drawing-shadow-width" min="0" max="50" value="0" oninput="document.getElementById(\'shadow-width-value\').innerHTML = this.value;">
          <span id="shadow-width-value">0</span>
        
          <br>
        
          <label for="drawing-shadow-offset">Shadow offset:</label>
          <input type="range" id="drawing-shadow-offset" min="0" max="50" value="0" oninput="document.getElementById(\'shadow-offset-value\').innerHTML = this.value;">
          <span id="shadow-offset-value">0</span>
        
        </div>
        
        <script>
        (function() {
            var $ = function(id){return document.getElementById(id)};
        
            var canvas = this.__canvas = new fabric.Canvas(\'c\', {
                isDrawingMode: true
            });
        
            fabric.Object.prototype.transparentCorners = false;
        
            var drawingModeEl = $(\'drawing-mode\'),
                drawingOptionsEl = $(\'drawing-mode-options\'),
                drawingColorEl = $(\'drawing-color\'),
                drawingShadowColorEl = $(\'drawing-shadow-color\'),
                drawingLineWidthEl = $(\'drawing-line-width\'),
                drawingShadowWidth = $(\'drawing-shadow-width\'),
                drawingShadowOffset = $(\'drawing-shadow-offset\'),
                clearEl = $(\'clear-canvas\');
        
            clearEl.onclick = function() { canvas.clear() };
        
            drawingModeEl.onclick = function() {
                canvas.isDrawingMode = !canvas.isDrawingMode;
                if (canvas.isDrawingMode) {
                drawingModeEl.innerHTML = \'Cancel drawing mode\';
                drawingOptionsEl.style.display = \'\';
                }
                else {
                drawingModeEl.innerHTML = \'Enter drawing mode\';
                drawingOptionsEl.style.display = \'none\';
                }
            };
        
            if (fabric.PatternBrush) {
                var vLinePatternBrush = new fabric.PatternBrush(canvas);
                vLinePatternBrush.getPatternSrc = function() {
        
                var patternCanvas = fabric.document.createElement(\'canvas\');
                patternCanvas.width = patternCanvas.height = 10;
                var ctx = patternCanvas.getContext(\'2d\');
        
                ctx.strokeStyle = this.color;
                ctx.lineWidth = 5;
                ctx.beginPath();
                ctx.moveTo(0, 5);
                ctx.lineTo(10, 5);
                ctx.closePath();
                ctx.stroke();
        
                return patternCanvas;
                };
        
                var hLinePatternBrush = new fabric.PatternBrush(canvas);
                hLinePatternBrush.getPatternSrc = function() {
        
                var patternCanvas = fabric.document.createElement(\'canvas\');
                patternCanvas.width = patternCanvas.height = 10;
                var ctx = patternCanvas.getContext(\'2d\');
        
                ctx.strokeStyle = this.color;
                ctx.lineWidth = 5;
                ctx.beginPath();
                ctx.moveTo(5, 0);
                ctx.lineTo(5, 10);
                ctx.closePath();
                ctx.stroke();
        
                return patternCanvas;
                };
        
                var squarePatternBrush = new fabric.PatternBrush(canvas);
                squarePatternBrush.getPatternSrc = function() {
        
                var squareWidth = 10, squareDistance = 2;
        
                var patternCanvas = fabric.document.createElement(\'canvas\');
                patternCanvas.width = patternCanvas.height = squareWidth + squareDistance;
                var ctx = patternCanvas.getContext(\'2d\');
        
                ctx.fillStyle = this.color;
                ctx.fillRect(0, 0, squareWidth, squareWidth);
        
                return patternCanvas;
                };
        
                var diamondPatternBrush = new fabric.PatternBrush(canvas);
                diamondPatternBrush.getPatternSrc = function() {
        
                var squareWidth = 10, squareDistance = 5;
                var patternCanvas = fabric.document.createElement(\'canvas\');
                var rect = new fabric.Rect({
                    width: squareWidth,
                    height: squareWidth,
                    angle: 45,
                    fill: this.color
                });
        
                var canvasWidth = rect.getBoundingRect().width;
        
                patternCanvas.width = patternCanvas.height = canvasWidth + squareDistance;
                rect.set({ left: canvasWidth / 2, top: canvasWidth / 2 });
        
                var ctx = patternCanvas.getContext(\'2d\');
                rect.render(ctx);
        
                return patternCanvas;
                };
        
                var img = new Image();
                img.src = \'https://fabricjs.com/assets/honey_im_subtle.png\';
        
                var texturePatternBrush = new fabric.PatternBrush(canvas);
                texturePatternBrush.source = img;
            }
        
            $(\'drawing-mode-selector\').onchange = function() {
        
                if (this.value === \'hline\') {
                canvas.freeDrawingBrush = vLinePatternBrush;
                }
                else if (this.value === \'vline\') {
                canvas.freeDrawingBrush = hLinePatternBrush;
                }
                else if (this.value === \'square\') {
                canvas.freeDrawingBrush = squarePatternBrush;
                }
                else if (this.value === \'diamond\') {
                canvas.freeDrawingBrush = diamondPatternBrush;
                }
                else if (this.value === \'texture\') {
                canvas.freeDrawingBrush = texturePatternBrush;
                }
                else {
                canvas.freeDrawingBrush = new fabric[this.value + \'Brush\'](canvas);
                }
        
                if (canvas.freeDrawingBrush) {
                var brush = canvas.freeDrawingBrush;
                brush.color = drawingColorEl.value;
                if (brush.getPatternSrc) {
                    brush.source = brush.getPatternSrc.call(brush);
                }
                brush.width = parseInt(drawingLineWidthEl.value, 10) || 1;
                brush.shadow = new fabric.Shadow({
                    blur: parseInt(drawingShadowWidth.value, 10) || 0,
                    offsetX: 0,
                    offsetY: 0,
                    affectStroke: true,
                    color: drawingShadowColorEl.value,
                });
                }
            };
        
            drawingColorEl.onchange = function() {
                var brush = canvas.freeDrawingBrush;
                brush.color = this.value;
                if (brush.getPatternSrc) {
                brush.source = brush.getPatternSrc.call(brush);
                }
            };
            drawingShadowColorEl.onchange = function() {
                canvas.freeDrawingBrush.shadow.color = this.value;
            };
            drawingLineWidthEl.onchange = function() {
                canvas.freeDrawingBrush.width = parseInt(this.value, 10) || 1;
                document.getElementById(\'line-width-value\').innerHTML = this.value;
            };
            drawingShadowWidth.onchange = function() {
                canvas.freeDrawingBrush.shadow.blur = parseInt(this.value, 10) || 0;
                document.getElementById(\'shadow-width-value\').innerHTML = this.value;
            };
            drawingShadowOffset.onchange = function() {
                canvas.freeDrawingBrush.shadow.offsetX = parseInt(this.value, 10) || 0;
                canvas.freeDrawingBrush.shadow.offsetY = parseInt(this.value, 10) || 0;
                document.getElementById(\'shadow-offset-value\').innerHTML = this.value;
            };
        
            if (canvas.freeDrawingBrush) {
                var brush = canvas.freeDrawingBrush;
                brush.color = drawingColorEl.value;
                if (brush.getPatternSrc) {
                    brush.source = brush.getPatternSrc.call(brush);
                }
                brush.width = parseInt(drawingLineWidthEl.value, 10) || 1;
                brush.shadow = new fabric.Shadow({
                    blur: parseInt(drawingShadowWidth.value, 10) || 0,
                    offsetX: 0,
                    offsetY: 0,
                    affectStroke: true,
                    color: drawingShadowColorEl.value,
                });
            }
        
            // Expose the canvas to the window object so it can be accessed from the parent
            window.canvas = canvas;
        })();
        </script>
        </body>
        </html>
                ';
    });

    iframe = PLUGIN.dyn(PLUGIN.document.createElement('iframe'));
    iframe.style.border = 'none';
    iframe.width = '800';
    iframe.height = '600';
	
    iframe.srcdoc = result.getFabricHTMLContent();

    readyPromise = PLUGIN.promise((resolve, reject) -> {
        iframe.onload = (_) -> {
            var iframeWindow =  iframe.contentWindow;
            if (iframeWindow != null) {
                canvas = PLUGIN.dyn(iframeWindow).canvas;
                if (canvas != null) {
                    resolve(null);
                } else {
                    trace('Canvas not found in iframe.');
                    reject('Canvas not found');
                }
            } else {
                trace('Unable to access iframe contentWindow.');
                reject('Unable to access iframe contentWindow');
            }
        };
    });

    var row = context.sheet.getLines()[context.rowIndex];
    if(row != null && row.json != null && row.json.length > 0) {
        result.importFromJSON(row.json).then((_) -> {
            
        });
    }

    return result;
}

var FabricJSSheetHandler:SheetViewPlugin =  {
    type: "SheetViewPlugin",
    definition: {
        name: "FabricJS Demo Sheet",
        schema: [
            {n: "id", t: ColumnType.TString},
            {n: "json", t: ColumnType.TString},
        ]
    },
    render: (context) -> {
        return FabricJSSheetView(PLUGIN.dyn(context));
    },
    toRowObject: (context) -> {
        var sheetView =  context.sheetView;
        var currentRow = context.sheet.getLines()[context.rowIndex];
        return PLUGIN.dyn(sheetView).exportToJSON().then((json) -> {
            currentRow.json = json;
            return currentRow;
        });
    },
}

var export:Array<Plugin> = [FabricJSSheetHandler];

