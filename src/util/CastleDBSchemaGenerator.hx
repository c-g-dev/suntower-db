package util;

import haxe.Json;
import haxe.io.Path;

using StringTools;

class CastleDBSchemaGenerator {
    static var sheetClassNames:Array<{ sheetName:String, className:String, columns:Array<Dynamic> }> = [];
    static var enumCache = new Map<String, Array<String>>();

    public static function generateSchema(jsonString:String):String {
        var output = new StringBuf();

        try {
            var db = Json.parse(jsonString);


            if (db.customTypes != null) {
                for (customType in (cast db.customTypes: Array<Dynamic>)) {
                    generateEnum(customType, output);
                    output.add('\n');
                }
            }


            if (db.sheets != null) {
                for (sheet in (cast db.sheets: Array<Dynamic>)) {

                    if (sheet.props != null && sheet.props.hide == true) {
                        continue;
                    }
                    var className = generateClass(sheet, output);
                    output.add('\n');


                    sheetClassNames.push({
                        sheetName: sheet.name,
                        className: className,
                        columns: sheet.columns
                    });
                }
            }

            generateEnums(output);


            generateTableKindEnum(sheetClassNames, output);


            generateDatabaseClass(sheetClassNames, output);

        } catch (e) {
            trace(e.stack);
        }

        return output.toString();
    }

    static function generateEnum(customType:Dynamic, output:StringBuf):Void {
        var enumName = customType.name;
        output.add('enum ' + enumName + ' {\n');
        for (caseDef in (cast customType.cases: Array<Dynamic>)) {
            output.add('\t' + caseDef.name);
            if (caseDef.args != null && caseDef.args.length > 0) {
                var args = caseDef.args.map(function(arg) {
                    var typeStr = getTypeFromTypeStr(enumName, caseDef.name, arg.typeStr);
                    return arg.name + ':' + typeStr;
                });
                output.add('(' + args.join(', ') + ')');
            }
            output.add(';\n');
        }
        output.add('}\n');
    }

    static function generateClass(sheet:Dynamic, output:StringBuf):String {
        var className = capitalize(sheet.name);
        output.add('class ' + className + ' {\n');

        if (sheet.columns != null) {
            for (column in (cast sheet.columns: Array<Dynamic>)) {
                var fieldName = column.name;
                var typeStr = getTypeFromTypeStr(className, fieldName, column.typeStr, true);
                var opt = column.opt == true;
                var fieldType = opt ? 'Null<' + typeStr + '>' : typeStr;
                output.add('\tpublic var ' + fieldName + ':' + fieldType + ';\n');
            }
        }

        output.add('\tpublic function new() {}\n');
        output.add('}\n');
        return className;
    }

    static function getTypeFromTypeStr(sheetName: String, fieldName: String, typeStr:String, isField:Bool = false):String {
        var type:String;


        switch (typeStr) {
            case '0':
                type = 'String'; 
                
            case '1':
                type = 'String'; 
                
            case '2':
                type = 'Bool'; 
                
            case '3':
                type = 'Int'; 
                
            case '4':
                type = 'Float'; 
                
            case '7':
                type = 'String'; 
                
            case '8':
                type = 'Array<Dynamic>'; 
                
            case '10':
                type = 'Int'; 
                
            default: {
                if ((~/^5:(.+)$/).match(typeStr)) {
                    var values = typeStr.substr(2).split(',');
                    var enumName = capitalize(sheetName) + "_" + capitalize(fieldName);
                    if (isField) {
                        ensureEnumDefined(enumName, values);
                    }
                    type = enumName;
                }
                else if ((~/^6:(.+)$/).match(typeStr)) {
                    type = capitalizeFirstChar(typeStr.substr(2)); 
                }
                else if ((~/^9:(.+)$/).match(typeStr)) {
                    type = capitalizeFirstChar(typeStr.substr(2)); 
                }
                else if (typeStr == '8') {
                    type = 'Array<Dynamic>'; 
                }
                else {
                    type = 'Dynamic'; 
                }
            }
        }

        return type;
    }

    static function ensureEnumDefined(enumName:String, values:Array<String>):Void {
        if (!enumCache.exists(enumName)) {
            enumCache.set(enumName, values);
        }
    }

    static function capitalize(s:String):String {
        if (s.indexOf('@') != -1) {
            s = s.split('@')[0]; 
        }
        return capitalizeFirstChar(s);
    }

    static function capitalizeFirstChar(s:String):String {
        s = s.substr(0, 1).toUpperCase() + s.substr(1);
        return s;
    }


    static function generateEnums(output:StringBuf):Void {
        for (enumName in enumCache.keys()) {
            var values = enumCache.get(enumName);
            output.add('enum ' + enumName + ' {\n');
            for (value in values) {
                var cleanValue = makeValidEnumValue(value);
                output.add('\t' + cleanValue + ';\n');
            }
            output.add('}\n\n');
        }
        enumCache = new Map<String, Array<String>>(); 
    }

    static function makeValidEnumValue(value:String):String {

        var cleanValue = (~/[^a-zA-Z0-9_]/g).replace(value, '_');
        switch cleanValue.charCodeAt(0) {
            case '0'.code, '1'.code, '2'.code, '3'.code, '4'.code, '5'.code, '6'.code, '7'.code, '8'.code, '9'.code: {
                cleanValue = '_' + cleanValue;
            }
        }
        return capitalizeFirstChar(cleanValue);
    }

    static function generateTableKindEnum(sheetClassNames:Array<Dynamic>, output:StringBuf):Void {
        output.add('enum TableKind<T> {\n');
        for (entry in sheetClassNames) {
            var sheetName = capitalizeFirstChar(entry.sheetName);
            var className = entry.className;
            output.add('\t' + sheetName + ' : TableKind<' + className + '>;\n');
        }
        output.add('}\n');
    }

    static function generateDatabaseClass(sheetClassNames:Array<Dynamic>, output:StringBuf):Void {
        output.add('class Database {\n');
        output.add('\tvar tables:Map<TableKind<Dynamic>, Array<Dynamic>>;\n\n');
        output.add('\tpublic function new(json:String) {\n');
        output.add('\t\ttables = new Map<TableKind<Dynamic>, Array<Dynamic>>();\n');
        output.add('\t\tvar db = Json.parse(json);\n');
        output.add('\t\tif (db.sheets != null) {\n');
        output.add('\t\t\tfor (sheet in (cast db.sheets: Array<Dynamic>)) {\n');
        output.add('\t\t\t\tvar sheetName = sheet.name;\n');
        output.add('\t\t\t\tvar lines: Array<Dyunamic> = sheet.lines;\n');
        output.add('\t\t\t\tswitch (sheetName) {\n');

        for (entry in sheetClassNames) {
            var sheetName = entry.sheetName;
            var className = entry.className;
            var sheetNameCapitalized = capitalizeFirstChar(sheetName);
            output.add('\t\t\t\t\tcase "' + sheetName + '": {\n');
            output.add('\t\t\t\t\t\tvar items = [];\n');
            output.add('\t\t\t\t\t\tfor (line in lines) {\n');
            output.add('\t\t\t\t\t\t\tvar item:' + className + ' = create' + className + '(line);\n');
            output.add('\t\t\t\t\t\t\titems.push(item);\n');
            output.add('\t\t\t\t\t\t}\n');
            output.add('\t\t\t\t\t\ttables.set(TableKind.' + sheetNameCapitalized + ', items);\n');
            output.add('\t\t\t\t\t\t\n');
            output.add('\t\t\t\t\t}\n');
        }

        output.add('\t\t\t\t\tdefault: {}\n');
        output.add('\t\t\t\t}\n');
        output.add('\t\t\t}\n');
        output.add('\t\t}\n');
        output.add('\t}\n\n');


        output.add('\tpublic function get<T>(kind: TableKind<T>): Array<T> {\n');
        output.add('\t\treturn cast tables.get(kind);\n');
        output.add('\t}\n');


        for (entry in sheetClassNames) {
            var className = entry.className;
            var columns: Array<Dynamic> = entry.columns;
            output.add('\n\tfunction create' + className + '(data:Dynamic):' + className + ' {\n');
            output.add('\t\tvar obj = new ' + className + '();\n');

            for (column in columns) {
                var fieldName = column.name;
                var typeStr = getTypeFromTypeStr(className, fieldName, column.typeStr, true);
                var opt = column.opt == true;
                var fieldType = opt ? 'Null<' + typeStr + '>' : typeStr;
                var parseCode = generateFieldParsingCode('data', fieldName, typeStr, opt);
                output.add('\t\tobj.' + fieldName + ' = ' + parseCode + ';\n');
            }
            output.add('\t\treturn obj;\n');
            output.add('\t}\n');
        }

        output.add('}\n');
    }

    static function generateFieldParsingCode(dataVar:String, fieldName:String, fieldType:String, isOptional:Bool):String {

        var dataAccess = dataVar + '.' + fieldName;
        var code = '';

        switch (fieldType) {
            case 'String', 'Int', 'Float', 'Bool':
                code = dataAccess;
                
            case 'Array<Dynamic>':
                code = dataAccess;
                
            default:
                if ((~/^Array<.+>$/).match(fieldType)) {

                    code = dataAccess;
                } else if (enumCache.exists(fieldType)) {

                    code = '(cast ' + dataAccess + ' : ' + fieldType + ')';
                } else {

                    code = '(cast ' + dataAccess + ' : ' + fieldType + ')';
                }
        }

        return code;
    }
}