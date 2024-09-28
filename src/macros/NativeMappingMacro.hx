package macros;


import format.agal.Data.RegType;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

class NativeMappingMacro {
    static var hasRun: Bool = false;
    public static function init() {

        Context.onAfterTyping((modules) -> {
            if(hasRun)  return;
            var mappingEntries: Array<{ normal: String, native: String }> = [];
            for (type in modules) {
                switch type {
                    case TClassDecl(c): {
                            var typeInfo: ClassType = c.get();
                            var nativeMeta = null;
            

                            for (meta in typeInfo.meta.get()) {
                                if (meta.name == ":native") {
                                    nativeMeta = meta;
                                    break;
                                }
                            }
            
                            if (nativeMeta != null) {

                                var normalClassPath = typeInfo.pack.concat([typeInfo.name]).join(".");
            

                                var nativeClassName: String;
                                switch (nativeMeta.params[0].expr) {
                                    case EConst(CString(s)):
                                        nativeClassName = s;
                                    default:
                                        Context.warning("Unexpected @:native parameter", typeInfo.pos);
                                        continue;
                                }
            

                                mappingEntries.push({ normal: normalClassPath, native: nativeClassName });
                            }
                        
            
                      
                    }
                    default:
                }
            }


              var mapInitializationExpr = macro {
                var m = new Map<String, String>();
                $b{ [
                    for (entry in mappingEntries)
                        macro m.set($v{entry.normal}, $v{entry.native})
                ] }
                m;
            };


            var mapField = {
                name: "map",
                pos: Context.currentPos(),
                doc: null,
                meta: [],
                access: [ haxe.macro.Access.APublic, haxe.macro.Access.AStatic ],
                kind: haxe.macro.FieldType.FVar(null, mapInitializationExpr)
            };


            var newClass: TypeDefinition = {
                name: "Macro_NativeMappings",
                pack: [],
                pos: Context.currentPos(),
                meta: [],
                params: [],
                kind: TypeDefKind.TDClass(null, [], false, false, false),
                isExtern: false,
                fields: [ mapField ],


            };


            Context.defineType(newClass);
            hasRun = true;
        });
        
    }


}

#end