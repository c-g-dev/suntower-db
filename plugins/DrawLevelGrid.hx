import system.lvl.LayerData;
import plugin.util.PluginCompat.PLUGIN;
import plugin.Plugin;
import haxe.Timer;
import system.lvl.Level;
import util.render.Image3D;
import system.SharedRepo;
import plugin.Plugin.LevelPluginTrigger;
import plugin.Plugin.LevelPlugin;

function renderPaletteOptions(level: Level) {
    Timer.delay(() -> {
        var pal = level.content.find(".palette");
        
        var optTile = pal.find(".opt.tile");
        
        optTile.append('<div class="icon gridFill drawGridPlugin_transient" title="Fill grid cell"></div>');
        var gridFillIcon = optTile.find(".gridFill");
    
        
        if (SharedRepo.get("FillGridMode") == true) {
            gridFillIcon.addClass("active");
        }
    
        
        gridFillIcon.on('click', (e) -> {
            var fillGridMode = SharedRepo.get("FillGridMode");
            if (fillGridMode == null) fillGridMode = false;
            fillGridMode = !fillGridMode;
            SharedRepo.set("FillGridMode", fillGridMode);
    
            if (fillGridMode) {
                gridFillIcon.addClass("active");
            } else {
                gridFillIcon.removeClass("active");
            }
        });
    },0);
    
}

function unrenderPaletteOptions(level: Level) {
    var pal = level.content.find(".palette");
    
    pal.find(".drawGridPlugin_transient").remove();
}

function renderLevelOptions(level: Level) {
    var opt = level.content.find(".submenu.options");
        
    
    opt.append('<div class="item"><label class="drawGridPlugin_transient">Grid Size <input type="text" name="gridSize"/></label></div>');

    
    opt.append('<div class="item"><label class="drawGridPlugin_transient">Show Grid <input type="checkbox" name="showGrid"/></label></div>');

    
    var initialGridSize = SharedRepo.get("LevelGridSize");
    opt.find("[name=gridSize]").val(initialGridSize);

    
    var initialShowGrid = SharedRepo.get("LevelShowGrid");
    opt.find("[name=showGrid]").prop("checked", initialShowGrid);

    
    var onGridSettingsChange = () -> {
        
        var gridSizeStr = opt.find("[name=gridSize]").val();
        var gridSize = Std.parseInt(gridSizeStr);

        
        if (gridSize == null || gridSize <= 0) {
            gridSize = 32; 
        }

        
        var showGrid = opt.find("[name=showGrid]").prop("checked");

        
        SharedRepo.set("LevelGridSize", gridSize);
        SharedRepo.set("LevelShowGrid", showGrid);

        Timer.delay(() -> {
            level.draw();
        }, 0);
        
    };

    
    opt.find("[name=gridSize]").on('change', (e) -> {
        onGridSettingsChange();
    });

    
    opt.find("[name=showGrid]").on('change', (e) -> {
        onGridSettingsChange();
    });
}

function unrenderLevelOptions(level: Level) {
    var opt = level.content.find(".submenu.options");
    opt.find(".drawGridPlugin_transient").remove();
}

function drawGrid(view: Image3D, cellWidth: Int, cellHeight: Int) {
    var width = view.width;
    var height = view.height;
    var col = 0xFF000000; 

    for (x in 0...width) {
        if (x % cellWidth == 0) {
            view.fillRect(x, 0, 1, height, col); 
        }
    }

    for (y in 0...height) {
        if (y % cellHeight == 0) {
            view.fillRect(0, y, width, 1, col); 
        }
    }
}

var drawGridPlugin: LevelPlugin = {
    type: "LevelPlugin",
    execute: (onTrigger) -> {
        switch PLUGIN.dyn(onTrigger) {
            case LevelPluginTrigger.BeforeDraw(_, _, _, _): {
                var level = Type.enumParameters(onTrigger)[0];
                var layer = Type.enumParameters(onTrigger)[1];
                var x = Type.enumParameters(onTrigger)[2];
                var y = Type.enumParameters(onTrigger)[3];

                if(SharedRepo.get("FillGridMode") == true && SharedRepo.exists("LevelGridSize")){
                    var l: LayerData = level.currentLayer;
                    if( !l.enabled() ) return PLUGIN.dyn(true);
                    switch( l.data ) {
                        case Tiles(_, _): {
                            var data = Type.enumParameters(l.data)[1];

                            var gridSize = SharedRepo.get("LevelGridSize");
                            var tileSize = level.tileSize;
                            if (gridSize == null || gridSize <= 0 || tileSize == null || tileSize <= 0) {
                                return PLUGIN.dyn(true); 
                            }
            
                            
                            var gridTileWidth = Math.floor(gridSize / tileSize);
                            var gridTileHeight = Math.floor(gridSize / tileSize);
                            if (gridTileWidth <= 0) gridTileWidth = 1;
                            if (gridTileHeight <= 0) gridTileHeight = 1;
            
                            
                            var startX = Math.floor(x / gridTileWidth) * gridTileWidth;
                            var startY = Math.floor(y / gridTileHeight) * gridTileHeight;
            
                            
                            var width = level.width;
                            var height = level.height;
            
                            var id = l.currentSelection + 1;
                            var changed = false;
            
                            
                            for (dx in 0...gridTileWidth) {
                                for (dy in 0...gridTileHeight) {
                                    var tileX = startX + dx;
                                    var tileY = startY + dy;
                                    
                                    if (tileX >= 0 && tileX < width && tileY >= 0 && tileY < height) {
                                        var p = tileX + (tileY * width);
                                        data[p] = id;
                                        changed = true;
                                    }
                                }
                            }
            
                            if (changed) {
                                l.dirty = true;
                                level.save();
                                level.draw();
                            }
                            return PLUGIN.dyn(false); 
                        }
                        default:
                    }
                }
                
                return PLUGIN.dyn(true);
            }
            case LevelRedraw(_, _): {
                var level = Type.enumParameters(onTrigger)[0];
                var view = Type.enumParameters(onTrigger)[1];

                if(SharedRepo.get("LevelShowGrid") == true){
                    drawGrid(level.view, SharedRepo.get("LevelGridSize"), SharedRepo.get("LevelGridSize"));
                }
            }
            case LevelOpen(_): {
                var level = Type.enumParameters(onTrigger)[0];

                renderLevelOptions(level);
                renderPaletteOptions(level);
            }
            case LevelClose(_): {
                var level = Type.enumParameters(onTrigger)[0];

                unrenderLevelOptions(level);
                unrenderPaletteOptions(level);
            }
            default:
        }
        return null;
    }
}

var export:Array<Plugin> = [drawGridPlugin];