package ;

/*
 * Copyright (c) 2015, Nicolas Cannasse
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
 * IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
import platform.VFileSystem.InMemoryFileSystem;
import data.Parser;
import system.Autosave.AutosaveConfig;
import util.MessagingCenter;
import data.Data;
import thx.csv.*;

using StringTools;

typedef Prefs = {
	windowPos : { x : Int, y : Int, w : Int, h : Int, max : Bool },
	curFile : String,
	curSheet : Int,
	?autosave : AutosaveConfig,
	recent : Array<String>,
}

typedef HistoryElement = { d : String, o : String };

class Model {

	public var base : system.db.Database;
	var prefs : Prefs;
	var imageBank : Dynamic<String>;
	var openedList : Map<String,Bool>;
	var existsCache : Map<String,{ t : Float, r : Bool }>;

	var curSavedData : HistoryElement;
	var history : Array<HistoryElement>;
	var redo : Array<HistoryElement>;

	function new() {
		openedList = new Map();
		prefs = {
			windowPos : { x : 50, y : 50, w : 800, h : 600, max : false },
			curFile : null,
			curSheet : 0,
			recent : [],
		};
		existsCache = new Map();
		loadPrefs();
		if(Reflect.hasField(prefs, "autosave") || prefs.autosave == null){
			prefs.autosave = { enabled : true, interval : (60 * 10), folder: null, maxNum: 5 };
		}
	}

	function quickExists(path) {
		var c = existsCache.get(path);
		if( c == null ) {
			c = { t : -1e9, r : false };
			existsCache.set(path, c);
		}
		var t = haxe.Timer.stamp();
		if( c.t < t - 10 ) { // cache result for 10s
			c.r = platform.VFileSystem.exists(path);
			c.t = t;
		}
		return c.r;
	}

	public function getImageData( key : String ) : String {
		return Reflect.field(imageBank, key);
	}

	public function getAbsPath( file : String ) {
		
		return file.startsWith(InMemoryFileSystem.VIRTUAL_DRIVE) || file.charAt(0) == "/" || file.charAt(1) == ":" ? file : new haxe.io.Path(prefs.curFile).dir.split("\\").join("/") + "/" + file;
	}

	public inline function getSheet( name : String ) {
		return base.getSheet(name);
	}

	public function saveTo( path: String, history = true ) {
		var sdata = quickSave();
		if( history && (curSavedData == null || sdata.d != curSavedData.d || sdata.o != curSavedData.o) ) {
			this.history.push(curSavedData);
			this.redo = [];
			if( this.history.length > 100 || sdata.d.length * (this.history.length + this.redo.length) * 2 > 300<<20 ) this.history.shift();
			curSavedData = sdata;
		}
		var tmp = platform.VSys.getEnv("TMP");
		if( tmp == null ) tmp = platform.VSys.getEnv("TMPDIR");
		var tmpFile = tmp+"/"+path.split("\\").join("/").split("/").pop()+".lock";
		try platform.VFile.saveContent(tmpFile,"LOCKED by CDB") catch( e : Dynamic ) {};
		try {
			platform.VFile.saveContent(path, sdata.d);
		} catch( e : Dynamic ) {
			// retry once after EBUSY
			haxe.Timer.delay(function() {
				platform.VFile.saveContent(path, sdata.d);
			},500);
		}
		try platform.VFileSystem.deleteFile(tmpFile) catch( e : Dynamic ) {};
	}


	public function save( history = true ) {
		var sdata = quickSave();
		if( history && (curSavedData == null || sdata.d != curSavedData.d || sdata.o != curSavedData.o) ) {
			this.history.push(curSavedData);
			this.redo = [];
			if( this.history.length > 100 || sdata.d.length * (this.history.length + this.redo.length) * 2 > 300<<20 ) this.history.shift();
			curSavedData = sdata;
		}
		if( prefs.curFile == null )
			return;
		var tmp = platform.VSys.getEnv("TMP");
		if( tmp == null ) tmp = platform.VSys.getEnv("TMPDIR");
		var tmpFile = tmp+"/"+prefs.curFile.split("\\").join("/").split("/").pop()+".lock";
		try platform.VFile.saveContent(tmpFile,"LOCKED by CDB") catch( e : Dynamic ) {};
		try {
			platform.VFile.saveContent(prefs.curFile, sdata.d);
		} catch( e : Dynamic ) {
			// retry once after EBUSY
			haxe.Timer.delay(function() {
				platform.VFile.saveContent(prefs.curFile, sdata.d);
			},500);
		}
		try platform.VFileSystem.deleteFile(tmpFile) catch( e : Dynamic ) {};
	}

	function saveImages() {
		if( prefs.curFile == null )
			return;
		var img = prefs.curFile.split(".");
		img.pop();
		var path = img.join(".") + ".img";
		if( imageBank == null )
			platform.VFileSystem.deleteFile(path);
		else
			platform.VFile.saveContent(path, untyped haxe.Json.stringify(imageBank, null, "\t"));
	}

	function quickSave() : HistoryElement {
		return {
			d : base.save(),
			o : haxe.Serializer.run(openedList),
		};
	}

	function quickLoad(sdata:HistoryElement) {
		base.load(sdata.d);
		openedList = haxe.Unserializer.run(sdata.o);
	}

	public function compressionEnabled() {
		return base.compress;
	}

	public function error( msg ) {
		js.Browser.alert(msg);
	}

	function load(noError = false) {
		history = [];
		redo = [];
		base = new system.db.Database();
		try {
			base.load(platform.VFile.getContent(prefs.curFile));
			if( prefs.curSheet > base.sheets.length )
				prefs.curSheet = 0;
			else while( prefs.curSheet > 0 && base.sheets[prefs.curSheet].getProps().hide )
				prefs.curSheet--;
		} catch( e : Dynamic ) {
			if( !noError ) error(Std.string(e));
			prefs.curFile = null;
			prefs.curSheet = 0;
			base = new system.db.Database();
		}
		try {
			var img = prefs.curFile.split(".");
			img.pop();
			imageBank = haxe.Json.parse(platform.VFile.getContent(img.join(".") + ".img"));
		} catch( e : Dynamic ) {
			imageBank = null;
		}
		curSavedData = quickSave();
		MessagingCenter.notify("fileChanged", null);
	}

	function cleanImages() {
		if( imageBank == null )
			return;
		var used = new Map();
		for( s in base.sheets )
			for( c in s.getColumns() ) {
				switch( c.type ) {
				case TImage:
					for( obj in s.getScopedLines() ) {
						var v = Reflect.field(obj, c.name);
						if( v != null ) used.set(v, true);
					}
				default:
				}
			}
		for( f in Reflect.fields(imageBank) )
			if( !used.get(f) )
				Reflect.deleteField(imageBank, f);
	}

	function loadPrefs() {
		try {
			prefs = haxe.Unserializer.run(js.Browser.getLocalStorage().getItem("prefs"));
			if( prefs.recent == null ) prefs.recent = [];
		} catch( e : Dynamic ) {
		}
	}

	function savePrefs() {
		js.Browser.getLocalStorage().setItem("prefs", haxe.Serializer.run(prefs));
	}

	@:access(system.db.Sheet)
	function exportSheetJSON(_s: system.db.Sheet, _filePath:String) {

		// export the main sheet and potential subsheets...
		var name = _s.getName();
		var toExport = [_s.sheet];
		for (s in _s.base.sheets)
			if (s.getName().startsWith('${_s.getName()}@')) // gather all subsheets
				toExport.push(s.sheet);

		platform.VFile.saveContent(_filePath, haxe.Json.stringify(toExport, null, "    "));
	}

	@:access(system.db.Sheet)
	@:access(system.db.Database)
	function importSheetJSON(_s:system.db.Sheet, _filePath:String) {

		// TODO: do import validation!!!
		var shs:Array<Dynamic> = cast haxe.Json.parse(platform.VFile.getContent(_filePath));
		for (s in shs) {
			// rename the imported sheet to match the current selected sheet.
			s.name = s.name.replace(s.name.split('@')[0], _s.getName());

			// now fix the types
			for( c in cast(s.columns, Array<Dynamic>) ) {
				c.type = Parser.getType(c.typeStr);
				c.typeStr = null;
			}

			// gather existing sheets
			var index:Null<Int> = null;
			var existing = null;
			for (i in 0..._s.base.sheets.length) {
				var e = _s.base.sheets[i];
				if (e.getName()==s.name) {
					existing = e;
					index = i;
					break;
				}
			}

			// now replace / add
			if (existing != null)
				_s.base.deleteSheet(existing);
			_s.base.addSheet(s, index);
		}

		_s.base.updateSheets();
		_s.base.sync();
		this.save();
	}

	function exportSheetCSV(_s:system.db.Sheet, _filePath:String) {
		var lines = [[ for (c in _s.getColumns()) c.name]];		

		for (l in _s.getScopedLines()) {
			var ol = [];
			for (c in _s.getColumns()) {
				switch (c.type) {
					case TId, TString, TFile: 
						ol.push(Reflect.field(l, c.name));
					default:
						ol.push(haxe.Json.stringify(Reflect.field(l, c.name)));
				}
			}
			lines.push(ol);
		}
		platform.VFile.saveContent(_filePath, Csv.encode(lines));
	}

	@:access(system.db.Sheet)
	function importSheetCSV(_s:system.db.Sheet, _filePath:String) {
		var d = Csv.decode(platform.VFile.getContent(_filePath));
		var header = d.shift(); // get rid off first line

		var colMapSheet = new Map<String, Column>();
		for (c in _s.getColumns())
			colMapSheet.set(c.name, c);

		var lines = [];
		for (l in d) {
			var line = {};
			for (i in 0...l.length) {
				var c = colMapSheet.get(header[i]);
				if (c == null)
					continue;

				var val = l[i];
				switch (c.type) {
					case TId, TString, TFile: 
						Reflect.setField(line, c.name, val);
					default:
						Reflect.setField(line, c.name, haxe.Json.parse(val));
				}
			}
			lines.push(line);
		}

		_s.sheet.lines = lines;
		_s.sync();
		_s.base.updateSheets();
		_s.base.sync();
		this.save();
	}

}