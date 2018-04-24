module whs.compileutil;

// void main() {
//   import std.stdio;
//   import std.algorithm;
//   import std.array;
//   import std.file;
//   import std.path;
// 
//   writeln(std.file.dirEntries("", "*.d", SpanMode.shallow)
//     .filter!(a => a.isFile)
//     .map!(a => std.path.baseName(a.name))
//     .array
//   );
//   
//   auto config = new Config;
//   auto g = config.files;
// }

/* if no command line args, run main
if no main, run lib
if command line args, display 
# ldc ./simplesocket.d ./main -w -wi -unittest
or
# ldc -main -w -wi -unittest -run ./compileutil.d
*/

interface ISaveable {
  void save();
  void load();
}

interface IFile {
  bool isMain();
  string name();
}

class DFile : IFile {
  bool isMain() {
    return false;
  }

  string name() {
    return "";
  }
}

interface IConfig : ISaveable {
  int[IFile] files() const @property;
  string flags() const @property;
  string config() const @property;
}

class Config {
  int[IFile] files() const @property
  out (result) {
    assert(result !is null);
  } body {
    auto tempFile = new DFile();
    int[IFile] res = [tempFile : 1];
    return res;
  }
}

unittest {
  assert(new Config().files !is null);
}
