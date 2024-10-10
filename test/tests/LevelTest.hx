package tests;

import Main.K;
import util.InlineTimer;
import platform.VFileSystem.InMemoryFileSystem;
import CommonTestSteps.SetInputValue;
import CommonTestSteps.Click;
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
    var TILE_PATH = InMemoryFileSystem.VIRTUAL_DRIVE + "test/data/tiles.png";
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
            NewSheetPopup_ChooseType("level"),
            NewSheetPopup_Confirm,
            (test) -> {
                var bytes = haxe.Resource.getBytes("test_tileset");
                VFile.saveBytes(TILE_PATH, bytes);
                return NextStep;
            },
            ClickEditLevelButton(0),
            (test) -> {
                return DelayUntil(() -> {
                    @:privateAccess var level = test.main.level;
                    var isNewLayerButtonRendered = J(UISelectors.LEVEL_MENU_NEW_LAYER_BUTTON).length > 0;
                    return isNewLayerButtonRendered;
                });
            },
            
            Click(UISelectors.LEVEL_MENU_NEW_LAYER_BUTTON),
            SetInputValue(UISelectors.LEVEL_NEW_LAYER_NAME_INPUT, "test_layer"),
            Click(UISelectors.LEVEL_NEW_LAYER_CREATE_BUTTON),
            (test) -> {
                @:privateAccess var level = test.main.level;
                @:privateAccess level.setTilesetPath(TILE_PATH);
                return NextStep;
            },
            (test) -> {
                return DelayUntil(() -> {
                    return InlineTimer.hasTimedOut("LevelTest1", 500);
                });
            },
            LevelControls.ChoosePalette(0,0),
            LevelControls.LeftClickTilemap(0,0),
            LevelControls.LeftClickTilemap(0,1),
            (test) -> {
                this.context["selection1"] = test.main.level.currentLayer.currentSelection + "";
                return NextStep;
            },
            LevelControls.ChoosePalette(0,1),
            LevelControls.LeftClickTilemap(1,0),
            LevelControls.LeftClickTilemap(1,1),
            (test) -> {
                var aa = test.main.level.currentLayer.getDataAt(0,0) - 1;
                var ab = test.main.level.currentLayer.getDataAt(0,1) - 1;
                var ba = test.main.level.currentLayer.getDataAt(1,0) - 1;
                var bb = test.main.level.currentLayer.getDataAt(1,1) - 1;
                var val = test.main.level.currentLayer.currentSelection;
                this.context["selection2"] = val;
                if(aa == this.context["selection1"] && ab == this.context["selection1"] && ba == val && bb == val) {
                    return NextStep;
                }
                return Failure("Tile written to layer incorrectly. Actual: " + Std.string([aa,ab,ba,bb]) + " Expected: " + val);
            },
            //Test selection

            (test) -> {
                var canvas = LevelControls.getMapContentJ();
                var tileSize = test.main.level.tileSize * test.main.level.zoomView;
                var offset = canvas.offset();
                trace("offset: " + offset.left + ", " + offset.top);
                var mouseX = Std.int(offset.left - (tileSize * 0));
                var mouseY = Std.int(offset.top - (tileSize * 0));
                this.context["mouseX"] = mouseX;
                this.context["mouseY"] = mouseY;
                TestUtils.mouseEvent("mousemove", mouseX, mouseY);
                return NextStep;
            },
            (test) -> {
                TestUtils.keyEvent("keydown", 'S'.code);
                return NextStep;
            },
            (test) -> {
                var mouseX = this.context["mouseX"];
                var mouseY = this.context["mouseY"];
                TestUtils.mouseEvent("mousedown", mouseX, mouseY); // Left button is usually button 0
                return NextStep;
            },
            (test) -> {
                var tileSize = test.main.level.tileSize * test.main.level.zoomView;
                this.context["mouseX"] += tileSize;
                this.context["mouseY"] += tileSize;
                TestUtils.mouseEvent("mousemove", this.context["mouseX"], this.context["mouseY"]);
                return NextStep;
            },
            (test) -> {
                var mouseX = this.context["mouseX"];
                var mouseY = this.context["mouseY"];
                TestUtils.mouseEvent("mouseup", mouseX, mouseY);
                return NextStep;
            },
            (test) -> {
                TestUtils.keyEvent("keyup", 'S'.code);
                return NextStep;
            },
            (test) -> {
                // Move mouse back to selection start
                var tileSize = LevelControls.getTileSize();
                this.context["mouseX"] -= tileSize;
                this.context["mouseY"] -= tileSize;
                TestUtils.mouseEvent("mousemove", this.context["mouseX"], this.context["mouseY"]);
                return NextStep;
            },
            (test) -> {
                var canvas = test.main.level.view.getCanvas();
                var mouseX = this.context["mouseX"];
                var mouseY = this.context["mouseY"];
                TestUtils.mouseEvent("mousedown", mouseX, mouseY);
                return NextStep;
            },
            (test) -> {
                var canvas = test.main.level.view.getCanvas();
                var tileSize = LevelControls.getTileSize();
                this.context["mouseX"] += tileSize * 2;
                this.context["mouseY"] += tileSize * 2;
                TestUtils.mouseEvent("mousemove", this.context["mouseX"], this.context["mouseY"]);
                return NextStep;
            },
            (test) -> {
                var mouseX = this.context["mouseX"];
                var mouseY = this.context["mouseY"];
                TestUtils.mouseEvent("mouseup", mouseX, mouseY);
                return NextStep;
            },
            (test) -> {
                TestUtils.keyEvent("keyup", 'S'.code);
                return NextStep;
            },
            (test) -> {
                // Move mouse back to selection start
                var tileSize = LevelControls.getTileSize();
                this.context["mouseX"] -= tileSize;
                this.context["mouseY"] -= tileSize;
                TestUtils.mouseEvent("mousemove", this.context["mouseX"], this.context["mouseY"]);
                return NextStep;
            },
            (test) -> {
                var mouseX = this.context["mouseX"];
                var mouseY = this.context["mouseY"];
                TestUtils.mouseEvent("mousedown", mouseX, mouseY);
                return NextStep;
            },
            (test) -> {
                var tileSize = LevelControls.getTileSize();
                this.context["mouseX"] += tileSize * 2;
                this.context["mouseY"] += tileSize * 2;
                TestUtils.mouseEvent("mousemove", this.context["mouseX"], this.context["mouseY"]);
                return NextStep;
            },
            (test) -> {
                var mouseX = this.context["mouseX"];
                var mouseY = this.context["mouseY"];
                TestUtils.mouseEvent("mouseup", mouseX, mouseY);
                return NextStep;
            },
            (test) -> {
                TestUtils.keyEvent("keydown", K.ESC);
                TestUtils.keyEvent("keyup", K.ESC);
                return NextStep;
            },
            (test) -> {
                var aa = test.main.level.currentLayer.getDataAt(0, 0) - 1;
                var ab = test.main.level.currentLayer.getDataAt(0, 1) - 1;
                var ba = test.main.level.currentLayer.getDataAt(1, 0) - 1;
                var bb = test.main.level.currentLayer.getDataAt(1, 1) - 1;
                if (aa != -1 || ab != -1 || ba != -1 || bb != -1) {
                    return Failure("Tiles at original position not cleared");
                }
                var sel1 = Std.parseInt(this.context["selection1"]);
                var sel2 = Std.parseInt(this.context["selection2"]);
         
                var aa_new = test.main.level.currentLayer.getDataAt(4, 4) - 1;
                var ab_new = test.main.level.currentLayer.getDataAt(4, 5) - 1;
                var ba_new = test.main.level.currentLayer.getDataAt(5, 4) - 1;
                var bb_new = test.main.level.currentLayer.getDataAt(5, 5) - 1;
         
                if (aa_new == sel1 && ab_new == sel1 && ba_new == sel2 && bb_new == sel2) {
                    return NextStep;
                } else {
                    return Failure("Tiles at new position not correct. Actual: " + Std.string([aa_new,ab_new,ba_new,bb_new]) + " Expected: " + Std.string([sel1,sel1,sel2,sel2]));
                }
            },
            TestSucceeds
        ]);
    }

}