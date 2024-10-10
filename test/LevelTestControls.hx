import UITest.StepsMerger;
import js.jquery.Helper.*;
import js.jquery.JQuery;

class LevelTestControls {

    var main: Main;
    
    public function new(main: Main) {
        this.main = main;
    }

    public function ChoosePalette(x:Int, y:Int) {
        return new StepsMerger([
            TestUtils.asStep(() -> {
                var offset = getPaletteJ().offset();
                var tilesize = getTileSize();
                TestUtils.mouseMove((x * tilesize) + Std.int(offset.left + (tilesize / 2)), (y * tilesize) + Std.int(offset.top + (tilesize / 2)));
            }),
            TestUtils.asStep(() -> {
                var offset = getPaletteJ().offset();
                var tilesize = getTileSize();
                TestUtils.mouseEvent("mousedown", (x * tilesize) + Std.int(offset.left + (tilesize / 2)), (y * tilesize) + Std.int(offset.top + (tilesize / 2)));
            }),
            TestUtils.asStep(() -> {
                var offset = getPaletteJ().offset();
                var tilesize = getTileSize();
                TestUtils.mouseEvent("mouseup", (x * tilesize) + Std.int(offset.left + (tilesize / 2)), (y * tilesize) + Std.int(offset.top + (tilesize / 2)));
            }),
        ]).mergeSteps();
    }

     
    public function getTileSize(): Int {
        @:privateAccess var level = main.level;
        @:privateAccess return level.props.tileSize;
    }


    function getPaletteJ() {
        return J(".level .palette .content .select");
    }
    

    public function LeftClickTilemap(x:Int, y:Int) {
        return new StepsMerger([
            TestUtils.asStep(() -> {
                var offset = getMapContentJ().offset();
                var tilesize = getTileSize();
                TestUtils.mouseMove((x * tilesize) + Std.int(offset.left + (tilesize / 2)), (y * tilesize) + Std.int(offset.top + (tilesize / 2)));
            }),
            TestUtils.asStep(() -> {
                var offset = getMapContentJ().offset();
                var tilesize = getTileSize();
                TestUtils.mouseEvent("mousedown", (x * tilesize) + Std.int(offset.left + (tilesize / 2)), (y * tilesize) + Std.int(offset.top + (tilesize / 2)));
            }),
            TestUtils.asStep(() -> {
                var offset = getMapContentJ().offset();
                var tilesize = getTileSize();
                TestUtils.mouseEvent("mouseup", (x * tilesize) + Std.int(offset.left + (tilesize / 2)), (y * tilesize) + Std.int(offset.top + (tilesize / 2)));
            }),
        ]).mergeSteps();
    }

    public function getMapContentJ() {
        @:privateAccess var viewport = main.level.view.viewport;
        return J(viewport);
    }
    
}