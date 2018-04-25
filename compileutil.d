module whs.compileutil;

/* if no command line args, run main
if no main, run lib
if command line args, display 
# ldc ./simplesocket.d ./main -w -wi -unittest
or
# ldc -main -w -wi -unittest -run ./compileutil.d
*/

struct FileEntry {
  bool isChosen;
  bool isMain;
  string fileName;
}

class Config {
  import std.file;
  import std.path;

  FileEntry[] files;
  string flags;

  void loadFiles() {
    import std.algorithm;
    import std.path;
    import std.array;

    files = dirEntries("", SpanMode.shallow)
      .filter!(e => e.isFile)
      .map!(e => getFileEntry(e))
      .array;
  }

  FileEntry getFileEntry(DirEntry dirEntry) {
    // auto fileName = baseName(stripExtension(dirEntry.name));
    auto fileName = baseName(dirEntry.name);
    auto isMain = (fileName == "main");
    FileEntry dFile;
    dFile.isMain = isMain;
    dFile.fileName = fileName;
    return dFile;
  }
}
