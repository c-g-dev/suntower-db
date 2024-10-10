package util;

class InlineTimer {
    static var times:Map<String, Float> = new Map();

    public static function hasTimedOut(key:String, ms:Int):Bool {
        
        var currentTime = Date.now().getTime();

        
        if (!times.exists(key)) {
            times.set(key, currentTime);
            return false;
        } else {
            
            var lastTime = times.get(key);
            
            if ((currentTime - lastTime) >= ms) {
                
                times.set(key, currentTime);
                return true;
            } else {
                return false;
            }
        }
    }
}