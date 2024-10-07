package system;

class SharedRepo {
    static var KV_PAIRS: Map<String, Dynamic> = [];

    public static function get(key: String): Dynamic {
        return KV_PAIRS.get(key);
    }   

    public static function set(key: String, value: Dynamic): Void {
        KV_PAIRS.set(key, value);
    }

    public static function exists(s:String): Bool {
        return KV_PAIRS.exists(s);
    }
}