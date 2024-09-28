package plugin.util;

class PluginParsingHelper {
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
