package platform;

import haxe.io.Eof;
import sys.FileStat;
import sys.FileSystem;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;

class VFileSystem {

    public static function exists(path:String):Bool {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            return InMemoryFileSystem.exists(vPath);
        } else {
            return FileSystem.exists(path);
        }
    }

    public static function rename(path:String, newPath:String):Void {
        var isVirtual = (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE));
        var isNewVirtual = (newPath != null && StringTools.startsWith(newPath, InMemoryFileSystem.VIRTUAL_DRIVE));

        if (isVirtual && isNewVirtual) {
            
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            var vNewPath = newPath.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            InMemoryFileSystem.rename(vPath, vNewPath);
        } else if (!isVirtual && !isNewVirtual) {
            
            FileSystem.rename(path, newPath);
        } else {
            throw 'Cannot rename between virtual and non-virtual filesystems';
        }
    }

    public static function fullPath(relPath:String):String {
        if (relPath != null && StringTools.startsWith(relPath, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = relPath.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            return InMemoryFileSystem.VIRTUAL_DRIVE + InMemoryFileSystem.fullPath(vPath);
        } else {
            return FileSystem.fullPath(relPath);
        }
    }

    public static function absolutePath(relPath:String):String {
        if (relPath != null && StringTools.startsWith(relPath, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = relPath.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            return InMemoryFileSystem.VIRTUAL_DRIVE + InMemoryFileSystem.absolutePath(vPath);
        } else {
            return FileSystem.absolutePath(relPath);
        }
    }

    public static function isDirectory(path:String):Bool {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            return InMemoryFileSystem.isDirectory(vPath);
        } else {
            return FileSystem.isDirectory(path);
        }
    }

    public static function createDirectory(path:String):Void {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            InMemoryFileSystem.createDirectory(vPath);
        } else {
            FileSystem.createDirectory(path);
        }
    }

    public static function deleteFile(path:String):Void {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            InMemoryFileSystem.deleteFile(vPath);
        } else {
            FileSystem.deleteFile(path);
        }
    }

    public static function deleteDirectory(path:String):Void {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            InMemoryFileSystem.deleteDirectory(vPath);
        } else {
            FileSystem.deleteDirectory(path);
        }
    }

    public static function readDirectory(path:String):Array<String> {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            return InMemoryFileSystem.readDirectory(vPath);
        } else {
            return FileSystem.readDirectory(path);
        }
    }

    public static function stat(path:String):FileStat {
        if (path != null && StringTools.startsWith(path, InMemoryFileSystem.VIRTUAL_DRIVE)) {
            var vPath = path.substr(InMemoryFileSystem.VIRTUAL_DRIVE.length);
            
            var stat = InMemoryFileSystem.stat(vPath);
            return FileSystem.stat(""); 
        } else {
            return FileSystem.stat(path);
        }
    }
}

class VNode {
    public var name:String;
    public var isDirectory:Bool;
    public var content:Bytes; 
    public var children:Map<String, VNode>; 

    public function new(name:String, isDirectory:Bool) {
        this.name = name;
        this.isDirectory = isDirectory;
        if (isDirectory) {
            children = new Map<String, VNode>();
        } else {
            content = Bytes.alloc(0);
        }
    }
}


class InMemoryFileSystem {
    public static final VIRTUAL_DRIVE = "VIRTUAL::";
    private static var root:VNode = new VNode("", true); 
    private static var cwd:String = "/"; 

    
    public static function resolvePath(path:String):Array<String> {
        var components:Array<String>;
        if (path == null || path == "") {
            components = [];
        } else {
            var segments = path.split("/");
            if (path.charAt(0) == '/') {
                
                components = [];
            } else {
                
                components = cwd.split("/").filter(function(s) return s != "");
            }

            for (segment in segments) {
                if (segment == "" || segment == ".") {
                    continue;
                } else if (segment == "..") {
                    if (components.length > 0) {
                        components.pop();
                    }
                } else {
                    components.push(segment);
                }
            }
        }
        return components;
    }

    
    public static function getNode(path:String):VNode {
        var components = resolvePath(path);
        var node = root;
        for (name in components) {
            if (!node.isDirectory) {
                throw 'Not a directory: ' + name;
            }
            node = node.children.get(name);
            if (node == null) {
                return null;
            }
        }
        return node;
    }

    
    public static function exists(path:String):Bool {
        try {
            var node = getNode(path);
            return node != null;
        } catch (e:Dynamic) {
            return false;
        }
    }

    
    public static function rename(path:String, newPath:String):Void {
        var sourceComponents = resolvePath(path);
        var destComponents = resolvePath(newPath);

        if (sourceComponents.length == 0 || destComponents.length == 0) {
            throw 'Cannot rename root directory';
        }

        
        var sourceParent = root;
        for (i in 0...sourceComponents.length - 1) {
            var name = sourceComponents[i];
            sourceParent = sourceParent.children.get(name);
            if (sourceParent == null || !sourceParent.isDirectory) {
                throw 'Invalid source path';
            }
        }
        var srcName = sourceComponents[sourceComponents.length - 1];
        var srcNode = sourceParent.children.get(srcName);
        if (srcNode == null) {
            throw 'Invalid source path';
        }

        
        var destParent = root;
        for (i in 0...destComponents.length - 1) {
            var name = destComponents[i];
            var child = destParent.children.get(name);
            if (child == null) {
                throw 'Destination path not accessible';
            }
            if (!child.isDirectory) {
                throw 'Destination path not accessible';
            }
            destParent = child;
        }
        var destName = destComponents[destComponents.length - 1];

        
        if (destParent.children.exists(destName)) {
            throw 'Destination already exists';
        }

        
        sourceParent.children.remove(srcName);
        srcNode.name = destName;
        destParent.children.set(destName, srcNode);
    }

    
    public static function fullPath(relPath:String):String {
        var components = resolvePath(relPath);
        return "/" + components.join("/");
    }

    
    public static function absolutePath(relPath:String):String {
        
        return fullPath(relPath);
    }

    
    public static function isDirectory(path:String):Bool {
        var node = getNode(path);
        if (node == null) {
            throw 'Invalid path';
        }
        return node.isDirectory;
    }

    
    public static function createDirectory(path:String):Void {
        var components = resolvePath(path);
        var node = root;
        for (name in components) {
            var child = node.children.get(name);
            if (child == null) {
                
                child = new VNode(name, true);
                node.children.set(name, child);
            } else if (!child.isDirectory) {
                throw 'Cannot create directory, file exists: ' + name;
            }
            node = child;
        }
    }

    
    public static function deleteFile(path:String):Void {
        var components = resolvePath(path);
        if (components.length == 0) {
            throw 'Invalid file path';
        }
        var node = root;
        for (i in 0...components.length - 1) {
            var name = components[i];
            node = node.children.get(name);
            if (node == null || !node.isDirectory) {
                throw 'Invalid path';
            }
        }
        var fileName = components[components.length - 1];
        var fileNode = node.children.get(fileName);
        if (fileNode == null || fileNode.isDirectory) {
            throw 'Invalid file path';
        }
        node.children.remove(fileName);
    }

    
    public static function deleteDirectory(path:String):Void {
        var components = resolvePath(path);
        if (components.length == 0) {
            throw 'Cannot delete root directory';
        }
        var node = root;
        for (i in 0...components.length - 1) {
            var name = components[i];
            node = node.children.get(name);
            if (node == null || !node.isDirectory) {
                throw 'Invalid directory path';
            }
        }
        var dirName = components[components.length - 1];
        var dirNode = node.children.get(dirName);
        if (dirNode == null || !dirNode.isDirectory) {
            throw 'Invalid directory path';
        }
        /*if (dirNode.children.keys().iterator().hasNext()) {
            throw 'Directory not empty';
        }*/
        node.children.remove(dirName);
    }

    
    public static function readDirectory(path:String):Array<String> {
        var node = getNode(path);
        if (node == null || !node.isDirectory) {
            throw 'Invalid directory path';
        }
        var result = [];
        for (name in node.children.keys()) {
            result.push(name);
        }
        return result;
    }

    public static function stat(s:String) {
        return {
            mtime: 0.0
        }
    }
}


class InMemoryFile {
    /**
        Retrieves the content of the file specified by `path` as a String.

        If the file does not exist or can not be read, an exception is thrown.

        `VFileSystem.exists` can be used to check for existence.

        If `path` is null, the result is unspecified.
    **/
    public static function getContent(path:String):String {
        if (path == null) throw 'Invalid path';
        var node = InMemoryFileSystem.getNode(path);
        if (node == null || node.isDirectory) {
            throw 'File does not exist or is a directory';
        }
        return node.content.toString();
    }

    /**
        Stores `content` in the file specified by `path`.

        If the file cannot be written to, an exception is thrown.

        If `path` or `content` are null, the result is unspecified.
    **/
    public static function saveContent(path:String, content:String):Void {
        if (path == null || content == null) throw 'Invalid arguments';
        var node = getOrCreateFileNode(path);
        node.content = Bytes.ofString(content);
    }

    /**
        Retrieves the binary content of the file specified by `path`.

        If the file does not exist or can not be read, an exception is thrown.

        `VFileSystem.exists` can be used to check for existence.

        If `path` is null, the result is unspecified.
    **/
    public static function getBytes(path:String):Bytes {
        if (path == null) throw 'Invalid path';
        var node = InMemoryFileSystem.getNode(path);
        if (node == null || node.isDirectory) {
            throw 'File does not exist or is a directory';
        }
        return node.content;
    }

    /**
        Stores `bytes` in the file specified by `path` in binary mode.

        If the file cannot be written to, an exception is thrown.

        If `path` or `bytes` are null, the result is unspecified.
    **/
    public static function saveBytes(path:String, bytes:Bytes):Void {
        if (path == null || bytes == null) throw 'Invalid arguments';
        var node = getOrCreateFileNode(path);
        node.content = bytes;
    }

    /**
        Returns an `VFileInput` handle to the file specified by `path`.
    **/
    public static function read(path:String, binary:Bool = true):InMemoryFileInput {
        if (path == null) throw 'Invalid path';
        var node = InMemoryFileSystem.getNode(path);
        if (node == null || node.isDirectory) {
            throw 'File does not exist or is a directory';
        }
        return new InMemoryFileInput(node, binary);
    }

    /**
        Returns an `VFileOutput` handle to the file specified by `path`.
    **/
    public static function write(path:String, binary:Bool = true):InMemoryFileOutput {
        if (path == null) throw 'Invalid path';
        var node = getOrCreateFileNode(path);
        
        node.content = Bytes.alloc(0);
        return new InMemoryFileOutput(node, binary, true);
    }

    /**
        Similar to `write`, but appends to the file if it exists
        instead of overwriting its contents.
    **/
    public static function append(path:String, binary:Bool = true):InMemoryFileOutput {
        if (path == null) throw 'Invalid path';
        var node = getOrCreateFileNode(path);
        return new InMemoryFileOutput(node, binary, false, true);
    }

    /**
        Similar to `append`. While `append` can only seek or write
        starting from the end of the file's previous contents, `update` can
        seek to any position, so the file's previous contents can be
        selectively overwritten.
    **/
    public static function update(path:String, binary:Bool = true):InMemoryFileOutput {
        if (path == null) throw 'Invalid path';
        var node = getOrCreateFileNode(path);
        return new InMemoryFileOutput(node, binary, false, false, true);
    }

    /**
        Copies the contents of the file specified by `srcPath` to the file
        specified by `dstPath`.
    **/
    public static function copy(srcPath:String, dstPath:String):Void {
        if (srcPath == null || dstPath == null) throw 'Invalid arguments';
        var srcBytes = getBytes(srcPath);
        saveBytes(dstPath, srcBytes);
    }

    
    private static function getOrCreateFileNode(path:String):VFileSystem.VNode {
        var components = InMemoryFileSystem.resolvePath(path);
        @:privateAccess var node = InMemoryFileSystem.root;
        for (i in 0...components.length - 1) {
            var name = components[i];
            var child = node.children.get(name);
            if (child == null) {
                
                child = new VFileSystem.VNode(name, true);
                node.children.set(name, child);
            } else if (!child.isDirectory) {
                throw 'Path component is not a directory: ' + name;
            }
            node = child;
        }
        var fileName = components[components.length - 1];
        var fileNode = node.children.get(fileName);
        if (fileNode == null) {
            
            fileNode = new VFileSystem.VNode(fileName, false);
            node.children.set(fileName, fileNode);
        } else if (fileNode.isDirectory) {
            throw 'Cannot operate on a directory: ' + path;
        }
        return fileNode;
    }
}


class InMemoryFileInput extends Input {
    private var content:Bytes;
    private var position:Int;
    private var length:Int;

    public function new(node:VFileSystem.VNode, binary:Bool) {
        this.content = node.content;
        this.position = 0;
        this.length = content.length;
    }
    
    override public function readByte():Int {
        if (position >= length) {
            throw new Eof();
        }
        return content.get(position++);
    }
    
    override public function readBytes(buf:Bytes, pos:Int, len:Int):Int {
        if (position >= length) {
            throw new Eof();
        }
        var available = length - position;
        var toRead = Std.int(Math.min(len, available));
        buf.blit(pos, content, position, toRead);
        position += toRead;
        return toRead;
    }

    public function seek(pos:Int):Void {
        if (pos < 0 || pos > length) {
            throw 'Invalid position';
        }
        this.position = pos;
    }

    public function tell():Int {
        return position;
    }
}


class InMemoryFileOutput extends Output {
    private var node:VNode;
    private var position:Int;
    private var buffer:Bytes;

    public function new(node:VNode, binary:Bool, overwrite:Bool = false, append:Bool = false, update:Bool = false) {
        this.node = node;
        if (overwrite) {
            
            this.buffer = Bytes.alloc(0);
            this.position = 0;
        } else if (append) {
            
            this.buffer = node.content;
            this.position = buffer.length;
        } else if (update) {
            
            this.buffer = node.content;
            this.position = 0;
        } else {
            
            this.buffer = Bytes.alloc(0);
            this.position = 0;
        }
    }
    
    override public function writeByte(c:Int):Void {
        if (position >= buffer.length) {
            
            var newBuffer = Bytes.alloc(position + 1);
            newBuffer.blit(0, buffer, 0, buffer.length);
            buffer = newBuffer;
        }
        buffer.set(position++, c);
    }
    
    override public function writeBytes(s:Bytes, pos:Int, len:Int):Int {
        if (position + len > buffer.length) {
            
            var newBuffer = Bytes.alloc(position + len);
            newBuffer.blit(0, buffer, 0, buffer.length);
            buffer = newBuffer;
        }
        buffer.blit(position, s, pos, len);
        position += len;
        return len;
    }

    public function seek(pos:Int):Void {
        if (pos < 0) throw 'Invalid position';
        this.position = pos;
    }

    public function tell():Int {
        return this.position;
    }
    
    override public function close():Void {
        node.content = buffer;
    }
}

