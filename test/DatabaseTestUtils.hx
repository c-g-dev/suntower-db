package ;

import data.Parser;

class DatabaseTestUtils {
    var main:Main;
    public function new(main: Main) {
        this.main = main;
    }
    public function sheetExists(s:String): Bool {
        return this.main.base.getSheet(s) != null;
    }

    public function columnExists(s:String, s2:String) {
        for (col in this.main.base.getSheet(s).getColumns()) {
            if(col.name == s2){
                return true;
            }
        }
        return false;
    }

    public function export(): String {
        return Parser.save(this.main.base.data);
    }
}