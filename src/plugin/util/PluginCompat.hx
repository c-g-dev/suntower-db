package plugin.util;

import js.Browser;
import js.lib.Promise;

class PluginCompat {
    public var window:js.html.Window;
	public var document:js.html.HTMLDocument;


    public function new() {
       this.window = Browser.window;
       this.document = Browser.document;
    }

    public function promise(cb: Dynamic): Promise<Dynamic> {
        return new Promise(cb);
    }

    public function promiseResolve(data: Dynamic): Promise<Dynamic> {
        return Promise.resolve(data);
    }

    public function promiseReject(data: Dynamic): Promise<Dynamic> {
        return Promise.reject(data);
    }

    public function dyn(obj: Dynamic): Dynamic {
        return obj;
    }
}

var PLUGIN = new PluginCompat();