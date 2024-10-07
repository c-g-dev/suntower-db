package tests;

import CommonTestSteps.ClickNewSheetAnchor;
import haxe.Json;
import UITest.UITestCoroutineResult;
import CommonTestSteps.DoubleClickCell;
import CommonTestSteps.TestSucceeds;
import CommonTestSteps.AddColumnPopup_Confirm;
import CommonTestSteps.AddColumnPopup_ChooseType;
import CommonTestSteps.AddColumnPopup_ChooseName;
import CommonTestSteps.NewSheetPopup_Confirm;
import CommonTestSteps.NewSheetPopup_ChooseName;
import CommonTestSteps.ResetUI;
import js.jquery.Helper.*;
import js.jquery.JQuery;

class SmokeTest extends UITest {

    public function new(main: Main) {  
        super("Smoke test", main);
    }

    function onFrame(step:Int):UITestCoroutineResult {
        return steps([
            ResetUI,
            ClickNewSheetAnchor,
            NewSheetPopup_ChooseName("test"),
            NewSheetPopup_Confirm,
            (test) -> {
                var newColumn = J(UISelectors.ADD_A_COLUMN_ANCHOR);
                newColumn.get(0).click();
                return NextStep;
            },
            AddColumnPopup_ChooseName("test_col"),
            AddColumnPopup_ChooseType("string"),
            AddColumnPopup_Confirm,
            (test) -> {
                if( !database.columnExists("test", "test_col") ) {
                    return Failure("Column not created");
                }
                return NextStep;
            },
            (test) -> {
                trace("inserting line");
                var newColumn = J(UISelectors.INSERT_LINE_ANCHOR);
                newColumn.get(0).click();
                return NextStep;
            },
            DoubleClickCell(0,0),
            (test) -> {
                J(UISelectors.CELL(0,0) + " > input").val("testValue");
                return NextStep;
            },
            (test) -> {
                J(UISelectors.CELL(0,0) + " > input").blur();
                return NextStep;
            },
            (test) -> {
                var val = database.export();
                if( Json.stringify(Json.parse(val)) != Json.stringify(Json.parse(expectedValue())) ) {
                    return Failure("Database export value incorrect");
                }
                return NextStep;
            },
            TestSucceeds
        ]);
        
    }

    function expectedValue(): String {
        return ' {
                    "sheets": [
                        {
                            "sheetType": "data_table",
                            "name": "test",
                            "columns": [
                                {
                                    "typeStr": "1",
                                    "name": "test_col"
                                }
                            ],
                            "lines": [
                                {
                                    "test_col": "testValue"
                                }
                            ],
                            "separators": [],
                            "props": {}
                        }
                    ],
                    "customTypes": [],
                    "compress": false
                }';
    }
    
}