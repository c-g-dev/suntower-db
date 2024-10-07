class LevelTestControls {

    var main: Main;
    
    public function new(main: Main) {
        this.main = main;
    }

    public function ChoosePalette(x:Int, y:Int) {
        return TestUtils.asStep(() -> {
            var offset = getPalette().offset();
            var tilesize = getPaletteTileSize();
            TestUtils.click(x * tilesize + offset.left, y * tilesize + offset.top);
        });
    }

    public function LeftClickTilemap(x:Int, y:Int) {
        return TestUtils.asStep(() -> {
            var offset = getMapContent().offset();
            var tilesize = getTilesize();
            TestUtils.click(x * tilesize + offset.left, y * tilesize + offset.top);
        });
    }
}