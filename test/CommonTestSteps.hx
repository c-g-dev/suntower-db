
import js.Browser;
import js.html.Element;
import js.html.KeyboardEvent;
import UITest.StepsMerger;
import UITest.UITestCoroutineResult;
import UITest.UITestStep;
import thx.Timer;
import js.jquery.Helper.*;
import js.jquery.JQuery;

var ResetUI: UITestStep = (test) -> {
    test.resetUI();
    return NextStep;
}

var ClickNewSheetAnchor: UITestStep = (test) -> {
    var createNewSheetControl = J(".castle#content > a");
    trace(createNewSheetControl.html());
    if( !(createNewSheetControl.html() == "Create a sheet")) {
        return Failure("Create a sheet anchor not found");
    }
    createNewSheetControl.get(0).click();
    return NextStep;
}

var LaunchNewSheetPopup: UITestStep = (test) -> {
    @:privateAccess test.main.newSheet();
    return NextStep;
}

var NewSheetPopup_ChooseName = (name: String) -> {
    return (test) -> {
        var popup = J("#newsheet");
        if( !popup.is(":visible") ) {
            return Failure("Popup not visible");
        }
        var popupSheetField = popup.find("#sheet_name");
        popupSheetField.val(name);
        return NextStep;
    }
}    

var NewSheetPopup_ChooseType = (name: String) -> { 
    return (test) -> {
        var popup = J("#newsheet");
        if( !popup.is(":visible") ) {
            return Failure("Popup not visible");
        }
        var popupSheetField = popup.find("#sheet_type");
        popupSheetField.val(name);
        return NextStep;
    }
}

var NewSheetPopup_Confirm: UITestStep = (test) -> {
    var popup = J("#newsheet");
    if( !popup.is(":visible") ) {
        return Failure("Popup not visible");
    }
    J("#newsheet #sheet_form > p.buttons > input[type=submit]:nth-child(1)").get(0).click();
    return NextStep;
}

var ClickEditLevelButton= (row: Int) -> {
    return (test) -> {
        var cell = J("#content > table > tr:nth-child(" + Std.int(2 + row) + ") > td > input");
        //var firstChildInCell = cell.children().get(0);
        var editButton = cell;
        editButton.click();
        return NextStep;
    }
} 

var Click = (selector: String) -> {
    return (test) -> {
        var button = J(selector);
        button.get(0).click();
        return NextStep;
    }
}

var SetInputValue = (selector: String, value: String) -> {
    return (test) -> {
        var input = J(selector);
        input.val(value);
        return NextStep;
    }
}


var AddColumnPopup: UITestStep = (test) -> {
    @:privateAccess test.main.newColumn();
    return NextStep;
}

var AddColumnPopup_ChooseName = (name: String) -> {
    return (test) -> {
        var iname = J(UISelectors.NEW_COLUMN_NAME_INPUT);
        iname.val(name);
        return NextStep;
    };   
}

var AddColumnPopup_ChooseType = (type: String) -> {
    return (test) -> {
        var itype = J(UISelectors.NEW_COLUMN_TYPE_SELECT);
        itype.val(type);
        return NextStep;
    };   
}

var AddColumnPopup_Confirm = (test) -> {
    J(UISelectors.NEW_COLUMN_CREATE_BUTTON).get(0).click();
    return NextStep;
}

var AddColumn = (name: String, type: String) -> {
    return new StepsMerger([
        AddColumnPopup,
        AddColumnPopup_ChooseName(name),
        AddColumnPopup_ChooseType(type),
        AddColumnPopup_Confirm
    ]).mergeSteps();
}

var InsertLine = (test: UITest) -> {
    @:privateAccess test.main.insertLine();
    return NextStep;
}

var DoubleClickCell = (x: Int, y: Int) -> {
    return (test) -> {
        var cell = J(UISelectors.CELL(x, y));
        cell.dblclick();
        return NextStep;
    }    
}

var DefocusSheetCells = (test) -> {
    
    return NextStep;
}

var AssertCellValue = (x: Int, y: Int, value: String) -> {
    return (test) -> {
        if(test.database.getCellValue(x,y) != value){
            return Failure("Cell value incorrect");
        }
        return NextStep;
    }
}
    


var TestSucceeds: UITestStep = (test) -> {
    return Success;
}