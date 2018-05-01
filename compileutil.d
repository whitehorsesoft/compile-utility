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
  import std.string:strip;
  import std.algorithm;
  import std.array;
  import std.regex;
  import std.stdio;

  FileEntry[] files;
  string flags;

  void loadFiles() {
    auto saveFiles = getSavedFiles;

    files = dirEntries("", SpanMode.shallow)
      .filter!(e => e.isFile)
      .map!(e => getFileEntry(e, saveFiles))
      .array;
  }

  string[] getSavedFiles() {
    string[] result;
    auto file = File("chosen_files.txt", "r");
    while (!file.eof) {
      result ~= strip(file.readln);
    }
    return result;
  }

  FileEntry getFileEntry(DirEntry dirEntry, string[] savedFiles) {
    auto fileName = baseName(dirEntry.name);
    auto isMain = (fileName == "main");
    FileEntry dFile;
    dFile.isMain = isMain;
    dFile.fileName = fileName;

    if (matchFirst(fileName, r"main\.d")) dFile.isMain = true;
    return dFile;
  }
}
