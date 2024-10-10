package ;

import tests.LevelTest;
import util.Notifier;
import tests.MultisheetTest.MultiSheetSmokeTest;
import tests.SmokeTest;
import CommonTestSteps.TestSucceeds;
import CommonTestSteps.AddColumnPopup_Confirm;
import CommonTestSteps.AddColumnPopup_ChooseType;
import CommonTestSteps.AddColumnPopup_ChooseName;
import CommonTestSteps.NewSheetPopup_Confirm;
import CommonTestSteps.NewSheetPopup_ChooseName;
import CommonTestSteps.ResetUI;
import thx.Timer;
import js.jquery.Helper.*;
import js.jquery.JQuery;

@:access(Main)
abstract class UITest {
    public var main: Main;
    public var database: DatabaseTestUtils;
    public var description: String;
    public var context: Map<String, Dynamic> = [];

    public function new(description: String, main: Main) {
        this.main = main;    
        this.description = description;
        this.database = new DatabaseTestUtils(main);
        TestUtils;
    }

    public function resetUI() {
        this.main.prefs.curFile = null;
        this.main.load(true);
    }

    var stepRunner: UITestStep;
    public function steps(s: Array<UITestStep>): UITestCoroutineResult {
        if(stepRunner == null){
            stepRunner = new StepsMerger(s).mergeSteps();
        }    
        return stepRunner(this);
    }

    var currentStep: Int = 0;
    public function run(): UITestCoroutineResult {
        try{
            switch onFrame(currentStep) {
                case Delay: return Delay;
                case NextStep: {
                    currentStep++;
                    return Delay;
                }
                case DelayUntil(predicate):{ 
                    if(!predicate()) {
                        trace("predicate failed, delaying");
                        return Delay;
                    }
                    trace("predicate succeeded, moving to next step");
                    currentStep++;
                    return NextStep;
                }
                case Success: return Success;
                case Failure(msg): return Failure(msg);
                case Error(msg): return Error(msg);
            }

        }
        catch(e) {
            return Error(e.stack.toString());
        }
    }

    abstract function onFrame(step: Int): UITestCoroutineResult;
}

enum UITestCoroutineResult {
    Delay;
    NextStep;
    Success;
    DelayUntil(predicate: Void -> Bool);
    Failure(msg: String);
    Error(msg: String);
}

class UITestRunner {
    
    var tests:Array<UITest>;
    
    var currentTestIndex:Int;
    
    var currentTest:UITest;
    var main: Main;

    public function new(main: Main) {
        this.main = main;
        
        tests = [];
        currentTestIndex = -1;
        addTest(new SmokeTest(main));
        addTest(new MultiSheetSmokeTest(main));
        addTest(new LevelTest(main));
    }

    
    public function addTest(test:UITest):Void {
        tests.push(test);
    }

    
    public function start():Void {
        if (tests.length > 0) {
            currentTestIndex = 0;
            currentTest = tests[currentTestIndex];
            Notifier.notify("Running test: " + currentTest.description);
            var cr = null;
            cr = () -> {
                if (currentTest != null) {
                    var result:UITestCoroutineResult = currentTest.run();
                    switch (result) {
                        case Delay | NextStep | DelayUntil(_):
                            
                        case Success:
                            
                            Notifier.notify("Test successful: " + currentTest.description);
                            moveToNextTest();
                        case Failure(msg):
                            
                            Notifier.notify("Test failed: " + currentTest.description);
                            trace("Test failed: " + msg);
                            moveToNextTest();
                        case Error(msg):
                            
                            Notifier.notify("Test error: " + currentTest.description);
                            trace("Test error: " + msg);
                            moveToNextTest();
                    }
                    Timer.delay(cr, 10);
                } else {
                    
                    
                    trace("All tests completed.");
                }
            }
            Timer.delay(cr, 10);
        } else {
            currentTestIndex = -1;
            currentTest = null;
        }
    }

    
    public function onFrame():Void {
       
    }

    
    private function moveToNextTest():Void {
        currentTestIndex++;
        if (currentTestIndex < tests.length) {
            currentTest = tests[currentTestIndex];
            Notifier.notify("Running test: " + currentTest.description);
        } else {
            currentTest = null; 
        }
    }
}



typedef UITestStep = (UITest) -> UITestCoroutineResult;

class StepsMerger {

    var steps:Array<UITestStep>;
    var currentStepIndex:Int = 0;

    public function new(steps: Array<UITestStep>) {
        this.steps = steps;
        this.currentStepIndex = 0;
    }

    public function mergeSteps():UITestStep {
        return function(test: UITest): UITestCoroutineResult {
            if (currentStepIndex >= steps.length) {
                
                return NextStep;
            }
            
            var stepFunc = steps[currentStepIndex];
            
            var result = stepFunc(test);
            switch (result) {
                case DelayUntil(predicate):{ 
                    if(!predicate()) {
                        trace("predicate failed, delaying");
                        return Delay;
                    }
                    trace("predicate succeeded, moving to next step");
                    currentStepIndex++;
                    return NextStep;
                }
                case NextStep:
                    currentStepIndex++;
                    trace("Moving on to step " + currentStepIndex);
                    return Delay;
                default:
                    
                    return result;
            }
        }
    }
}


