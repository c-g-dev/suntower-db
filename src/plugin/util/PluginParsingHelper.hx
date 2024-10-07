package plugin.util;

using StringTools;

class PluginParsingHelper {

    public static function processLine(line:String):String {
        line = processLineForCastSyntax(line);
        
        

        /*line = line.replace("=cast ", "");
        line = line.replace("= cast ", "");
        line = line.replace(" cast ", "");*/

        return line;
    }

    public static function processLineForTypeParams(line:String):String {
        var newLine = "";
        var i = 0;
        var length = line.length;
        
        var inSingleLineComment = false;
        var inMultiLineComment = false;
        var inString = false;
        var stringDelimiter = '';
        
        while (i < length) {
            var char = line.charAt(i);
            
            if (inString) {
                newLine += char;
                if (char == stringDelimiter) {
                    if (i == 0 || line.charAt(i - 1) != '\\') {
                        inString = false;
                    }
                }
                i++;
            } else if (inSingleLineComment) {
                newLine += char;
                if (char == '\n') {
                    inSingleLineComment = false;
                }
                i++;
            } else if (inMultiLineComment) {
                newLine += char;
                if (char == '*' && i + 1 < length && line.charAt(i + 1) == '/') {
                    newLine += '/';
                    inMultiLineComment = false;
                    i += 2;
                } else {
                    i++;
                }
            } else {
                
                if (char == '/' && i + 1 < length) {
                    var nextChar = line.charAt(i + 1);
                    if (nextChar == '/') {
                        newLine += '//';
                        inSingleLineComment = true;
                        i += 2;
                    } else if (nextChar == '*') {
                        newLine += '/*';
                        inMultiLineComment = true;
                        i += 2;
                    } else {
                        newLine += char;
                        i++;
                    }
                }
                
                else if (char == '"' || char == '\'') {
                    inString = true;
                    stringDelimiter = char;
                    newLine += char;
                    i++;
                }
                
                else if (isIdentifierStart(char)) {
                    
                    var identifierStart = i;
                    var identifier = "";
                    while (i < length && isIdentifierPart(line.charAt(i))) {
                        identifier += line.charAt(i);
                        i++;
                    }
                    var identifierEnd = i;
                    
                    var j = identifierStart - 1;
                    
                    while (j >= 0 && StringTools.isSpace(line, i)) {
                        j--;
                    }
                    var inTypeContext = false;
                    if (j >= 0 && line.charAt(j) == ':') {
                        inTypeContext = true;
                    } else {
                        
                        var wordEnd = j;
                        while (j >= 0 && isIdentifierPart(line.charAt(j))) {
                            j--;
                        }
                        var wordStart = j + 1;
                        var word = line.substr(wordStart, wordEnd - wordStart +1);
                        if (word == "extends" || word == "implements") {
                            inTypeContext = true;
                        }
                    }
                    newLine += identifier;
                    if (inTypeContext) {
                        
                        while (i < length && StringTools.isSpace(line, i)) {
                            newLine += line.charAt(i);
                            i++;
                        }
                        
                        if (i < length && line.charAt(i) == '<') {
                            
                            var angleBracketCount = 1;
                            i++; 
                            while (i < length && angleBracketCount > 0) {
                                var c = line.charAt(i);
                                if (c == '<') {
                                    angleBracketCount++;
                                } else if (c == '>') {
                                    angleBracketCount--;
                                } else if (c == '"' || c == '\'') {
                                    
                                    var strDelimiter = c;
                                    i++;
                                    while (i < length) {
                                        var sc = line.charAt(i);
                                        if (sc == strDelimiter) {
                                            if (line.charAt(i - 1) != '\\') {
                                                break;
                                            }
                                        }
                                        i++;
                                    }
                                }
                                i++;
                            }
                            
                        }
                    }
                    
                } else {
                    newLine += char;
                    i++;
                }
            }
        }
        return newLine;
    }
    
    static function isIdentifierStart(c:String):Bool {
        var code = c.charCodeAt(0);
        return (code >= 65 && code <= 90) ||   
               (code >= 97 && code <= 122) ||  
               c == '_';
    }
    
    static function isIdentifierPart(c:String):Bool {
        var code = c.charCodeAt(0);
        return (code >= 48 && code <= 57) ||   
               (code >= 65 && code <= 90) ||   
               (code >= 97 && code <= 122) ||  
               c == '_';
    }

    public static function processLineForFunctionCall(line:String):String {
        var newLine = "";
        var i = 0;
        var length = line.length;
    
        var inSingleLineComment = false;
        var inMultiLineComment = false;
        var inString = false;
        var stringDelimiter = '';
    
        while (i < length) {
            var char = line.charAt(i);
            
            if (inString) {
                newLine += char;
                if (char == stringDelimiter) {
                    if (i == 0 || line.charAt(i - 1) != '\\') {
                        inString = false;
                    }
                }
                i++;
            }
            else if (inSingleLineComment) {
                newLine += char;
                i++;
            }
            else if (inMultiLineComment) {
                newLine += char;
                if (char == '*' && i + 1 < length && line.charAt(i + 1) == '/') {
                    newLine += '/';
                    inMultiLineComment = false;
                    i += 2;
                }
                else {
                    i++;
                }
            }
            else {
                if (char == '/' && i + 1 < length) {
                    var nextChar = line.charAt(i + 1);
                    if (nextChar == '/') {
                        newLine += '//';
                        inSingleLineComment = true;
                        i += 2;
                    }
                    else if (nextChar == '*') {
                        newLine += '/*';
                        inMultiLineComment = true;
                        i += 2;
                    }
                    else {
                        newLine += char;
                        i++;
                    }
                }
                else if (char == '"' || char == '\'') {
                    inString = true;
                    stringDelimiter = char;
                    newLine += char;
                    i++;
                }
                else if (line.substr(i, 8) == 'function' &&
                         (i == 0 || !isLetterOrDigit(line.charAt(i - 1))) &&
                         (i + 8 >= length || !isLetterOrDigit(line.charAt(i + 8)))) {
                    i += 8;
                    while (i < length && StringTools.isSpace(line, i)) {
                        i++;
                    }
                    if (i < length && line.charAt(i) == '(') {
                        i++; 
                        var arguments = '';
                        var parenCount = 1;
                        while (i < length && parenCount > 0) {
                            var argChar = line.charAt(i);
                            arguments += argChar;
                            if (argChar == '(') {
                                parenCount++;
                            } else if (argChar == ')') {
                                parenCount--;
                            }
                            i++;
                        }
                        newLine += '(' + arguments + ') ->';
                    }
                    else {
                        newLine += 'function';
                    }
                }
                else {
                    newLine += char;
                    i++;
                }
            }
        }
        return newLine;
    }

    public static function processLineForCastSyntax(line:String):String {
        var newLine = "";
        var i = 0;
        var length = line.length;
    
        while (i < length) {
            
            if (line.substr(i, 6) == "(cast ") {
                newLine += "cast(";
                i += 6; 
    
                
                var expr = "";
                var parenCount = 1; 
                while (i < length) {
                    var char = line.charAt(i);
                    if (char == "(") {
                        parenCount++;
                    } else if (char == ")") {
                        parenCount--;
                        if (parenCount == 0) {
                            
                            break;
                        }
                    } else if (char == ":" && parenCount == 1) {
                        i++; 
                        break;
                    }
                    expr += char;
                    i++;
                }
    
                
                while (i < length && StringTools.isSpace(line, i)) {
                    i++;
                }
    
                
                var type = "";
                while (i < length && parenCount > 0) {
                    var char = line.charAt(i);
                    if (char == "(") {
                        parenCount++;
                    } else if (char == ")") {
                        parenCount--;
                        if (parenCount == 0) {
                            i++; 
                            break;
                        }
                    }
                    type += char;
                    i++;
                }
    
                
                newLine += expr + ", " + type + ")";
            }
            
            else if (line.substr(i, 5) == "cast " && (i == 0 || !isLetterOrDigit(line.charAt(i - 1)))) {
                newLine += "cast(";
                i += 5; 
    
                
                var expr = "";
                var parenCount = 0;
                while (i < length) {
                    var char = line.charAt(i);
                    if (char == "(") {
                        parenCount++;
                    } else if (char == ")") {
                        parenCount--;
                    } else if (char == ":" && parenCount == 0) {
                        i++; 
                        break;
                    }
                    expr += char;
                    i++;
                }
    
                
                while (i < length && StringTools.isSpace(line, i)) {
                    i++;
                }
    
                
                var type = "";
                while (i < length) {
                    var char = line.charAt(i);
                    if (char == "(") {
                        parenCount++;
                    } else if (char == ")") {
                        parenCount--;
                        if (parenCount < 0) {
                            i++; 
                            break;
                        }
                    } else if (StringTools.isSpace(line, i) && parenCount == 0) {
                        break;
                    }
                    type += char;
                    i++;
                }
    
                
                newLine += expr + ", " + type + ")";
            }
            
            else {
                newLine += line.charAt(i);
                i++;
            }
        }
        return newLine;
    }
    
    
    static function isLetterOrDigit(c:String):Bool {
        var code = c.charCodeAt(0);
        return (code >= 48 && code <= 57) ||   
               (code >= 65 && code <= 90) ||   
               (code >= 97 && code <= 122);    
    }
}
