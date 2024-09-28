package plugin.util;

import system.lvl.LayerData;

@:forward
abstract RowObject(Dynamic) from Dynamic to Dynamic {
	public static var STATE_CACHE:Array<{layerData:LayerData, idx:Int, rowObject:RowObject}> = [];

	function new(rowObject:Dynamic) {
		this = rowObject;
	}

	public static function fromLayerData(layerData:LayerData, idx:Int):RowObject {
		@:privateAccess var obj = new RowObject(Reflect.field(layerData.level.obj, layerData.name)[idx]);
		STATE_CACHE.push({layerData: layerData, idx: idx, rowObject: new RowObject(obj)});
		return obj;
	}

	public static function fromTransient(obj:Dynamic):RowObject {
		return new RowObject(obj);
	}

	public function molt():RowObject {
		for (eachRow in STATE_CACHE) {
			if (eachRow.rowObject == this) {
				@:privateAccess eachRow.rowObject = new RowObject(Reflect.field(eachRow.layerData.level.obj, eachRow.layerData.name)[eachRow.idx]);
				return eachRow.rowObject;
			}
		}
		return this;
	}

	public function commit(?remove:Bool = true):Void {
		for (eachRow in STATE_CACHE) {
			if (eachRow.rowObject == this) {
				@:privateAccess Reflect.field(eachRow.layerData.level.obj, eachRow.layerData.name)[eachRow.idx] = this;
				if (remove) {
					STATE_CACHE.remove(eachRow);
				}
			}
		}
	}
}
