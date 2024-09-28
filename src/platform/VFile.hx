package platform;

import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.FileSeek;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;

class VFile {
    /**
        Retrieves the content of the file specified by `path` as a String.

        If the file does not exist or cannot be read, an exception is thrown.

        `VFileSystem.exists` can be used to check for existence.

        If `path` is null, the result is unspecified.
    **/
    public static function getContent(path:String):String {
        if (path == null) throw 'Invalid path';
        return File.getContent(path);
    }

    /**
        Stores `content` in the file specified by `path`.

        If the file cannot be written to, an exception is thrown.

        If `path` or `content` are null, the result is unspecified.
    **/
    public static function saveContent(path:String, content:String):Void {
        if (path == null || content == null) throw 'Invalid arguments';
        File.saveContent(path, content);
    }

    /**
        Retrieves the binary content of the file specified by `path`.

        If the file does not exist or cannot be read, an exception is thrown.

        `VFileSystem.exists` can be used to check for existence.

        If `path` is null, the result is unspecified.
    **/
    public static function getBytes(path:String):Bytes {
        if (path == null) throw 'Invalid path';
        return File.getBytes(path);
    }

    /**
        Stores `bytes` in the file specified by `path` in binary mode.

        If the file cannot be written to, an exception is thrown.

        If `path` or `bytes` are null, the result is unspecified.
    **/
    public static function saveBytes(path:String, bytes:Bytes):Void {
        if (path == null || bytes == null) throw 'Invalid arguments';
        File.saveBytes(path, bytes);
    }

    /**
        Returns a `VFileInput` handle to the file specified by `path`.
    **/
    public static function read(path:String, binary:Bool = true):VFileInput {
        if (path == null) throw 'Invalid path';
        var input = File.read(path, binary);
        return new VFileInput(input);
    }

    /**
        Returns a `VFileOutput` handle to the file specified by `path`.
    **/
    public static function write(path:String, binary:Bool = true):VFileOutput {
        if (path == null) throw 'Invalid path';
        var output = File.write(path, binary);
        return new VFileOutput(output);
    }

    /**
        Similar to `write`, but appends to the file if it exists
        instead of overwriting its contents.
    **/
    public static function append(path:String, binary:Bool = true):VFileOutput {
        if (path == null) throw 'Invalid path';
        var output = File.append(path, binary);
        return new VFileOutput(output);
    }

    /**
        Similar to `append`. While `append` can only seek or write
        starting from the end of the file's previous contents, `update` can
        seek to any position, so the file's previous contents can be
        selectively overwritten.

        Note: Haxe's standard library does not have a direct `update` method,
        so we will open the file for update mode using `File.update`.
    **/
    public static function update(path:String, binary:Bool = true):VFileOutput {
        if (path == null) throw 'Invalid path';
        var output = File.update(path, binary);
        return new VFileOutput(output);
    }

    /**
        Copies the contents of the file specified by `srcPath` to the file
        specified by `dstPath`.
    **/
    public static function copy(srcPath:String, dstPath:String):Void {
        if (srcPath == null || dstPath == null) throw 'Invalid arguments';
        File.copy(srcPath, dstPath);
    }
}

class VFileInput extends Input {
    private var input:FileInput;

    public function new(input:FileInput) {
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
    private var output:FileOutput;

    public function new(output:FileOutput) {
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