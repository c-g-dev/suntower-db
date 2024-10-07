package util.query;

import hxsqlparser.SqlCommandParse;
import haxe.Json;
import system.db.Database;
import data.Parser;
import data.Data;

using ludi.commons.extensions.All;

class Querier {

    var database: Database;

    public function new(database: Database) {
        this.database = database;
    }

    public function select(fields: Array<Field>, fromTable: String, whereClause: (Dynamic, Int) -> Bool):Dynamic {
        var s = this.database.data.sheets
            .filter(sheet -> sheet.name == fromTable)
            .map(sheet -> sheet.lines.filter((e) -> {
                return whereClause(e, sheet.lines.indexOf(e));
            }))
            .map(line -> {
                trace("each select line: " + Json.stringify(line));
                var result = {};
                var returnAll: Bool = false;
                for (eachField in fields) {
                    if(eachField.all){
                        returnAll = true;
                        break;
                    }
                    Reflect.setField(result, eachField.field, Reflect.field(line, eachField.field));
                }
                if(returnAll){
                    for (field in Reflect.fields(line)) {
                        Reflect.setField(result, field, Reflect.field(line, field));
                    }
                }
                return result;
            });
        
        return [
            for(eachField in Reflect.fields(s[0])){
                Reflect.field(s[0], eachField);
            }
        ];
    }

    public function delete(fromTable: String, whereClause: (Dynamic, Int) -> Bool):Void {
        var table = this.database.data.sheets.find(sheet -> sheet.name == fromTable);
        if (table != null) {
            table.lines = table.lines.filter(line -> !whereClause(line, table.lines.indexOf(line)));
        }
        database.syncbackData();
    }

    public function update(fromTable: String, fields: Dynamic, whereClause: (Dynamic, Int) -> Bool):Void {
        var table = this.database.data.sheets.find(sheet -> sheet.name == fromTable);
        if (table != null) {
            for (line in table.lines) {
                if (whereClause(line, table.lines.indexOf(line))) {
                    for (field in Reflect.fields(fields)) {
                        Reflect.setField(line, field, Reflect.field(fields, field));
                    }
                }
            }
        }
        database.syncbackData();
    }

    public function insert(fromTable: String, row: Dynamic, ?writeback: Bool = true):Void {
        var objArg = parseObjectClause(row);
        switch objArg {
            case None: {}
            case Multiple(arr): {
                for (row in arr) {
                    insert(fromTable, row, false);
                }
            }
            case Single(val): {
                var table = this.database.data.sheets.find(sheet -> sheet.name == fromTable);
                if (table != null) {
                    var s = database.getSheet(table.name);
                    var o = s.newLine();
                    for (field in Reflect.fields(val)) {
                        Reflect.setField(o, field, Reflect.field(val, field));
                    }
                }
            }
        }
        if(writeback) {
            database.syncbackData();
        }
    }

    public function count(fromTable: String, whereClause: Dynamic -> Bool):Int {
        var table = this.database.data.sheets.find(sheet -> sheet.name == fromTable);
        if (table != null) {
            return table.lines.filter(whereClause).length;
        }
        return 0;
    }

    public function createTable(tableName: String, fields: Array<Column>):Void {
        this.database.data.sheets.push({
            sheetType: "Data Sheet",
            name: tableName,
            columns: fields,
            lines: [],
            props: {},
            separators: []
        });
        database.syncbackData();
    }

    public function dropTable(tableName: String):Void {
        this.database.data.sheets = this.database.data.sheets.filter(sheet -> sheet.name != tableName);
    }

    public function addColumn(tableName: String, columnName: String, columnType: ColumnType):Void {
        var table = this.database.data.sheets.find(sheet -> sheet.name == tableName);
        if (table != null) {
            table.columns.push({
                name: columnName,
                type: columnType,
                typeStr: Parser.saveType(columnType),
            });
        }
    }

    public function dropColumn(tableName: String, columnName: String):Void {
        var table = this.database.data.sheets.find(sheet -> sheet.name == tableName);
        if (table != null) {
            table.columns = table.columns.filter(column -> column.name != columnName);
        }
    }

    public function getColumns(tableName: String):Array<Column> {
        var table = this.database.data.sheets.find(sheet -> sheet.name == tableName);
        if (table != null) {
            return table.columns;
        }
        return [];
    }

    static function parseObjectClause(arg: Dynamic): ObjectClauseType {
        if (arg == null) {
            return ObjectClauseType.None;
        } else if (arg is Array) {
            if(arg.length == 0) {
                return ObjectClauseType.None;
            }
            return ObjectClauseType.Multiple(arg);
        } else {
            return ObjectClauseType.Single(arg);
        }
    }
}

enum ObjectClauseType {
    None;
    Multiple(arr: Array<Dynamic>);
    Single(val: Dynamic);
}
