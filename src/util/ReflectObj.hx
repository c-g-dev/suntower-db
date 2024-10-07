package util;

import Type.ValueType;

var ReflectObj = {
    hasField: function(o:Dynamic, field:String):Bool { return Reflect.hasField(o, field); },
    field: function(o:Dynamic, field:String):Dynamic { return Reflect.field(o, field); },
    setField: function(o:Dynamic, field:String, value:Dynamic):Void { Reflect.setField(o, field, value); },
    getProperty: function(o:Dynamic, field:String):Dynamic { return Reflect.getProperty(o, field); },
    setProperty: function(o:Dynamic, field:String, value:Dynamic):Void { Reflect.setProperty(o, field, value); },
    callMethod: function(o:Dynamic, func:haxe.Constraints.Function, args:Array<Dynamic>):Dynamic { return Reflect.callMethod(o, func, args); },
    fields: function(o:Dynamic):Array<String> { return Reflect.fields(o); },
    isFunction: function(f:Dynamic):Bool { return Reflect.isFunction(f); },
    compare: function(a:Dynamic, b:Dynamic):Int { return Reflect.compare(a, b); },
    compareMethods: function(f1:Dynamic, f2:Dynamic):Bool { return Reflect.compareMethods(f1, f2); },
    isObject: function(v:Dynamic):Bool { return Reflect.isObject(v); },
    isEnumValue: function(v:Dynamic):Bool { return Reflect.isEnumValue(v); },
    deleteField: function(o:Dynamic, field:String):Bool { return Reflect.deleteField(o, field); },
    copy: function(o:Dynamic):Dynamic { return Reflect.copy(o); },
    makeVarArgs: function(f:Array<Dynamic>->Dynamic):Dynamic { return Reflect.makeVarArgs(f); }
};

var TypeObj = {
    getClass: function(o:Dynamic):Class<Dynamic> { return Type.getClass(o); },
    getEnum: function(o:Dynamic):Enum<Dynamic> { return Type.getEnum(o); },
    getSuperClass: function(c:Class<Dynamic>):Class<Dynamic> { return Type.getSuperClass(c); },
    getClassName: function(c:Class<Dynamic>):String { return Type.getClassName(c); },
    getEnumName: function(e:Enum<Dynamic>):String { return Type.getEnumName(e); },
    resolveClass: function(name:String):Class<Dynamic> { return Type.resolveClass(name); },
    resolveEnum: function(name:String):Enum<Dynamic> { return Type.resolveEnum(name); },
    createInstance: function(cl:Class<Dynamic>, args:Array<Dynamic>):Dynamic { return Type.createInstance(cl, args); },
    createEmptyInstance: function(cl:Class<Dynamic>):Dynamic { return Type.createEmptyInstance(cl); },
    createEnum: function(e:Enum<Dynamic>, constr:String, ?params:Array<Dynamic>):Dynamic { return Type.createEnum(e, constr, params); },
    createEnumIndex: function(e:Enum<Dynamic>, index:Int, ?params:Array<Dynamic>):Dynamic { return Type.createEnumIndex(e, index, params); },
    getInstanceFields: function(c:Class<Dynamic>):Array<String> { return Type.getInstanceFields(c); },
    getClassFields: function(c:Class<Dynamic>):Array<String> { return Type.getClassFields(c); },
    getEnumConstructs: function(e:Enum<Dynamic>):Array<String> { return Type.getEnumConstructs(e); },
    typeof: function(v:Dynamic):ValueType { return Type.typeof(v); },
    enumEq: function(a:Dynamic, b:Dynamic):Bool { return Type.enumEq(a, b); },
    enumConstructor: function(e:Dynamic):String { return Type.enumConstructor(e); },
    enumParameters: function(e:Dynamic):Array<Dynamic> { return Type.enumParameters(e); },
    enumIndex: function(e:Dynamic):Int { return Type.enumIndex(e); },
    allEnums: function(e:Enum<Dynamic>):Array<Dynamic> { return Type.allEnums(e); }
};