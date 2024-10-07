package tests;

import CommonTestSteps.ClickEditLevelButton;
import CommonTestSteps.NewSheetPopup_ChooseType;
import CommonTestSteps.TestSucceeds;
import CommonTestSteps.NewSheetPopup_Confirm;
import CommonTestSteps.NewSheetPopup_ChooseName;
import CommonTestSteps.ClickNewSheetAnchor;
import platform.VFile;
import CommonTestSteps.ResetUI;
import UITest.UITestCoroutineResult;
import js.jquery.Helper.*;
import js.jquery.JQuery;

class LevelTest extends UITest {
    var TILE_PATH = "VIRTUAL::" + "test/data/tiles.png";
    var LevelControls: LevelTestControls;

    public function new(main: Main) {
        super("Level test", main);
        LevelControls = new LevelTestControls(main);
    }

    function onFrame(step:Int):UITestCoroutineResult {
        return steps([
            ResetUI,
            ClickNewSheetAnchor,
            NewSheetPopup_ChooseName("test"),
            NewSheetPopup_ChooseType("Level"),
            NewSheetPopup_Confirm,
            (test) -> {
                var bytes = haxe.Resource.getBytes("testTileset.png");
                VFile.saveBytes(TILE_PATH, bytes);
                return NextStep;
            },
            ClickEditLevelButton(0),
            (test) -> {
                @:privateAccess var level = test.main.level;
                @:privateAccess level.setTilesetPath(TILE_PATH);
                return NextStep;
            },
            LevelControls.ChoosePalette(0,0),
            LevelControls.LeftClickTilemap(0,0),
            LevelControls.LeftClickTilemap(0,1),
            LevelControls.ChoosePalette(0,1),
            LevelControls.LeftClickTilemap(1,0),
            LevelControls.LeftClickTilemap(1,1),

            TestSucceeds
        ]);
    }

}