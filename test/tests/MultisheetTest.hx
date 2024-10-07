package tests;

import CommonTestSteps.InsertLine;
import CommonTestSteps.AddColumn;
import CommonTestSteps.LaunchNewSheetPopup;
import UITest.StepsMerger;
import haxe.Json;
import UITest.UITestCoroutineResult;
import CommonTestSteps.DoubleClickCell;
import CommonTestSteps.TestSucceeds;
import CommonTestSteps.NewSheetPopup_Confirm;
import CommonTestSteps.NewSheetPopup_ChooseName;
import CommonTestSteps.ResetUI;
import js.jquery.Helper.*;
import js.jquery.JQuery;


var CreateSheet = (sheetName: String) -> {
    return new StepsMerger([
        LaunchNewSheetPopup,
        NewSheetPopup_ChooseName(sheetName),
        NewSheetPopup_Confirm
    ]).mergeSteps();
}


var SelectSheet = (sheetName: String) -> {
    return (test) -> {
        var sheetTabs = J("#sheets li");
        var found = false;
        for (i in 0...sheetTabs.length) {
            var tab = sheetTabs.eq(i);
            if (tab.text() == sheetName) {
                tab.click();
                found = true;
                break;
            }
        }
        if (!found) {
            return Failure("Couldn't find sheet tab for " + sheetName);
        }
        return NextStep;
    };
}


var SetCellValue = (x: Int, y: Int, value: Dynamic) -> {
    return new StepsMerger([
        DoubleClickCell(x, y),
        (test) -> {
            J(UISelectors.CELL(x, y) + " > input").val(value.toString());
            return NextStep;
        },
        (test) -> {
            J(UISelectors.CELL(x, y) + " > input").blur();
            return NextStep;
        }
    ]).mergeSteps();
}

class MultiSheetSmokeTest extends UITest {
    public function new(main: Main) {  
        super("Multiple sheets test", main);
    }

    function onFrame(step: Int): UITestCoroutineResult {
        return steps([
            ResetUI,
            
            CreateSheet("sheet1"),
            
            AddColumn("col1", "string"),
            AddColumn("col2", "int"),
            AddColumn("col3", "bool"),
            
            CreateSheet("sheet2"),
            
            AddColumn("colA", "float"),
            AddColumn("colB", "string"),
            
            SelectSheet("sheet1"),
            InsertLine,
            SetCellValue(0, 0, "value1"),
            SetCellValue(1, 0, 123),
            SetCellValue(2, 0, true),
            
            SelectSheet("sheet2"),
            InsertLine,
            SetCellValue(0, 0, 3.14),
            SetCellValue(1, 0, "valueB"),
            
            (test) -> {
                var val = test.database.export();
                trace("Export: " + val);
                if (Json.stringify(Json.parse(val)) != Json.stringify(Json.parse(expectedValue()))) {
                    return Failure("Database export value incorrect");
                }
                return NextStep;
            },
            TestSucceeds
        ]);
    }

    function expectedValue(): String {
        return '{
	"sheets": [
		{
			"sheetType": "data_table",
			"name": "sheet1",
			"columns": [
				{
					"typeStr": "1",
					"name": "col1",
                    "display": null
				},
				{
					"typeStr": "3",
					"name": "col2",
					"display": null
				},
				{
					"typeStr": "2",
					"name": "col3",
					"display": null
				}
			],
			"lines": [
				{
					"col1": "value1",
					"col2": 123,
					"col3": true
				}
			],
			"separators": [],
			"props": {}
		},
		{
			"sheetType": "data_table",
			"name": "sheet2",
			"columns": [
				{
					"typeStr": "4",
					"name": "colA",
					"display": null
				},
				{
					"typeStr": "1",
					"name": "colB",
					"display": null
				}
			],
			"lines": [
				{
					"colA": 3.14,
					"colB": "valueB"
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