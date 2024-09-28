package platform;


class VSys {
    public static function getEnv(s:String): String {
        return Sys.getEnv(s);
    }

    public static function systemName(): String {
        return Sys.systemName();
    }

    public static function println(s:String):Void {
        Sys.println(s);
    }

    public static function exit(i:Int):Void {
        Sys.exit(i);
    }

    public static function getCwd(): String {
        return Sys.getCwd();
    }
}