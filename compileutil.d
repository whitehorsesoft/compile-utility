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
  import std.json;

  FileEntry[] files;
  string flags;

  void loadFiles() {
    files = dirEntries("", SpanMode.shallow)
      .filter!(e => e.isFile)
      .map!(e => getFileEntry(e))
      .array;

    auto fileJSONs = getSavedFiles;
    foreach(file; files) {
      auto tempFiles = fileJSONs["files"]
        .array
        .filter!(f => f["fileName"].str == file.fileName)
        .array;
      writeln(tempFiles.count);
      if (tempFiles.count > 0) {
        if (tempFiles[0]["isChosen"].integer == 1) {
          file.isChosen = true;
        }
      }
    }
  }

  JSONValue getSavedFiles() {
    string result;
    auto file = File("chosen_files.txt", "r");
    while (!file.eof) {
      result = strip(file.readln);
    }
    return parseJSON(result);
  }

  void saveFiles() {
    JSONValue[] fileJSONs;
    foreach(file; files) {
      JSONValue tempJSON = ["fileName" : file.fileName];
      if (file.isChosen) {
        tempJSON.object["isChosen"] = JSONValue(1);
      }
      else {
        tempJSON.object["isChosen"] = JSONValue(0);
      }

      fileJSONs ~= tempJSON;
    }

    JSONValue result = ["files" : fileJSONs];
    
    auto file = File("chosen_files", "w");
    file.writeln(result.toString);
  }

  FileEntry getFileEntry(DirEntry dirEntry) {
    auto fileName = baseName(dirEntry.name);
    auto isMain = (fileName == "main");
    FileEntry dFile;
    dFile.isMain = isMain;
    dFile.fileName = fileName;

    if (matchFirst(fileName, r"main\.d")) dFile.isMain = true;
    return dFile;
  }
}
