package platform;

import platform.VFileSystem.InMemoryFile;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.FileSeek;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;

class VFile {

    public static function getContent(path:String):String {
        if (path == null) throw 'Invalid path';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            return InMemoryFile.getContent(vPath);
        } else {
            return File.getContent(path);
        }
    }

    public static function saveContent(path:String, content:String):Void {
        if (path == null || content == null) throw 'Invalid arguments';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            InMemoryFile.saveContent(vPath, content);
        } else {
            File.saveContent(path, content);
        }
    }

    public static function getBytes(path:String):Bytes {
        if (path == null) throw 'Invalid path';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            return InMemoryFile.getBytes(vPath);
        } else {
            return File.getBytes(path);
        }
    }

    public static function saveBytes(path:String, bytes:Bytes):Void {
        if (path == null || bytes == null) throw 'Invalid arguments';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            InMemoryFile.saveBytes(vPath, bytes);
        } else {
            File.saveBytes(path, bytes);
        }
    }

    public static function read(path:String, binary:Bool = true):VFileInput {
        if (path == null) throw 'Invalid path';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            var input = InMemoryFile.read(vPath, binary); // Returns InMemoryFileInput
            return new VFileInput(input);
        } else {
            var input = File.read(path, binary);
            return new VFileInput(input);
        }
    }

    public static function write(path:String, binary:Bool = true):VFileOutput {
        if (path == null) throw 'Invalid path';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            var output = InMemoryFile.write(vPath, binary);
            return new VFileOutput(output);
        } else {
            var output = File.write(path, binary);
            return new VFileOutput(output);
        }
    }

    public static function append(path:String, binary:Bool = true):VFileOutput {
        if (path == null) throw 'Invalid path';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            var output = InMemoryFile.append(vPath, binary);
            return new VFileOutput(output);
        } else {
            var output = File.append(path, binary);
            return new VFileOutput(output);
        }
    }

    public static function update(path:String, binary:Bool = true):VFileOutput {
        if (path == null) throw 'Invalid path';
        if (StringTools.startsWith(path, "VIRTUAL::")) {
            var vPath = path.substr("VIRTUAL::".length);
            var output = InMemoryFile.update(vPath, binary);
            return new VFileOutput(output);
        } else {
            var output = File.update(path, binary);
            return new VFileOutput(output);
        }
    }

    public static function copy(srcPath:String, dstPath:String):Void {
        if (srcPath == null || dstPath == null) throw 'Invalid arguments';

        var isVirtualSrc = StringTools.startsWith(srcPath, "VIRTUAL::");
        var isVirtualDst = StringTools.startsWith(dstPath, "VIRTUAL::");

        if (isVirtualSrc && isVirtualDst) {
            var vSrcPath = srcPath.substr("VIRTUAL::".length);
            var vDstPath = dstPath.substr("VIRTUAL::".length);
            InMemoryFile.copy(vSrcPath, vDstPath);
        } else if (!isVirtualSrc && !isVirtualDst) {
            File.copy(srcPath, dstPath);
        } else if (isVirtualSrc && !isVirtualDst) {
            // Copy from virtual file to real file
            var vSrcPath = srcPath.substr("VIRTUAL::".length);
            var bytes = InMemoryFile.getBytes(vSrcPath);
            File.saveBytes(dstPath, bytes);
        } else if (!isVirtualSrc && isVirtualDst) {
            // Copy from real file to virtual file
            var bytes = File.getBytes(srcPath);
            var vDstPath = dstPath.substr("VIRTUAL::".length);
            InMemoryFile.saveBytes(vDstPath, bytes);
        }
    }
}

class VFileInput extends Input {
    private var input:Dynamic;

    public function new(input:Dynamic) {
        this.input = input;
    }

    override public function readByte():Int {
        return input.readByte();
    }

    override public function readBytes(buf:Bytes, pos:Int, len:Int):Int {
        return input.readBytes(buf, pos, len);
    }

    public function seek(pos:Int, mode:FileSeek):Void {
        input.seek(pos, mode);
    }

    public function tell():Int {
        return input.tell();
    }

    override public function close():Void {
        input.close();
    }
}

class VFileOutput extends Output {
    private var output:Dynamic;

    public function new(output:Dynamic) {
        this.output = output;
    }

    override public function writeByte(c:Int):Void {
        output.writeByte(c);
    }

    override public function writeBytes(s:Bytes, pos:Int, len:Int):Int {
        return output.writeBytes(s, pos, len);
    }

    public function seek(pos:Int, mode: FileSeek):Void {
        output.seek(pos, mode);
    }

    public function tell():Int {
        return output.tell();
    }

    override public function close():Void {
        output.close();
    }
}