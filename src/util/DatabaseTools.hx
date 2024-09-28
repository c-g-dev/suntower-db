package util;

import js.html.AnchorElement;
import js.html.URL;
import js.html.Blob;
import js.Browser;
import data.Parser;
import data.Data;
import data.Data.SheetData;
import system.db.Database;

class DatabaseTools {
    public static function saveSchema(db: Database): Void {
			@:privateAccess var clonedData = DataCloner.cloneData(db.data);
			for (eachSheet in clonedData.sheets) {
				eachSheet.lines = [];
			}
			var serialized = Parser.save(clonedData);
			var blob:Blob = new Blob([serialized], { type: "application/json" });
			var url:String = URL.createObjectURL(blob);
	
			var a:AnchorElement = cast Browser.document.createElement('a');
			a.href = url;
			a.download = "schema.cdb";
			a.click();
    }
}

class DataCloner {
	public static function cloneData(original: Data): Data {
		return {
			sheets: original.sheets.map(cloneSheetData),
			customTypes: original.customTypes.map(cloneCustomType),
			compress: original.compress
		};
	}
	
	private static function cloneSheetData(original: SheetData): SheetData {
		return {
			sheetType: original.sheetType,
			name: original.name,
			columns: original.columns.map(cloneColumn),
			lines: original.lines.map(cloneDynamic),
			props: cloneSheetProps(original.props),
			separators: original.separators.map(cloneSeparator),
			linesData: original.linesData != null ? original.linesData.map(cloneDynamic) : null
		};
	}
	
	private static function cloneColumn(original: Column): Column {
		return {
			name: original.name,
			type: original.type,
			typeStr: original.typeStr,
			opt: original.opt,
			display: original.display,
			kind: original.kind,
			scope: original.scope,
			documentation: original.documentation,
			editor: original.editor
		};
	}
	
	private static function cloneSheetProps(original: SheetProps): SheetProps {
		return {
			displayColumn: original.displayColumn,
			displayIcon: original.displayIcon,
			hide: original.hide,
			isProps: original.isProps,
			hasIndex: original.hasIndex,
			hasGroup: original.hasGroup,
			level: original.level != null ? cloneLevelsProps(original.level) : null,
			dataFiles: original.dataFiles,
			editor: original.editor
		};
	}
	
	private static function cloneLevelsProps(original: LevelsProps): LevelsProps {
		return {
			tileSets: cloneDynamic(original.tileSets)
		};
	}
	
	private static function cloneSeparator(original: Separator): Separator {
		return {
			index: original.index,
			id: original.id,
			title: original.title,
			level: original.level,
			path: original.path
		};
	}
	
	private static function cloneCustomType(original: CustomType): CustomType {
		return {
			name: original.name,
			cases: original.cases.map(cloneCustomTypeCase)
		};
	}
	
	private static function cloneCustomTypeCase(original: CustomTypeCase): CustomTypeCase {
		return {
			name: original.name,
			args: original.args.map(cloneColumn)
		};
	}

	private static function cloneDynamic(d:Dynamic):Dynamic {
		return haxe.Json.parse(haxe.Json.stringify(d)); // Uses JSON serialization to clone
	}
}