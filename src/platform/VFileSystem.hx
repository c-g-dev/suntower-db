package platform;

import sys.FileStat;
import sys.FileSystem;
import haxe.io.Bytes;

class VFileSystem {

    public static function exists(path:String):Bool {
        return FileSystem.exists(path);
    }


    public static function rename(path:String, newPath:String):Void {
        FileSystem.rename(path, newPath);
    }


    public static function fullPath(relPath:String):String {
        return FileSystem.fullPath(relPath);
    }


    public static function absolutePath(relPath:String):String {
        return FileSystem.absolutePath(relPath);
    }


    public static function isDirectory(path:String):Bool {
        return FileSystem.isDirectory(path);
    }


    public static function createDirectory(path:String):Void {
        FileSystem.createDirectory(path);
    }


    public static function deleteFile(path:String):Void {
        FileSystem.deleteFile(path);
    }


    public static function deleteDirectory(path:String):Void {
        FileSystem.deleteDirectory(path);
    }


    public static function readDirectory(path:String):Array<String> {
        return FileSystem.readDirectory(path);
    }


    public static function stat(path:String):FileStat {
        return FileSystem.stat(path);
    }
}