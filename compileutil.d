module whs.compileutil;

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
    // get all files in current dir
    files = dirEntries("", SpanMode.shallow)
      .filter!(e => e.isFile)
      .map!(e => getFileEntry(e))
      .array;

    auto fileJSONs = getSavedFiles;
    if (fileJSONs.toString == `"na"`) return;

    for(auto i = 0; i < files.length; i++) {
      auto tempFiles = fileJSONs["files"]
        .array
        .filter!(f => f["fileName"].str == files[i].fileName)
        .array;
      if (tempFiles.count > 0) {
        if (tempFiles[0]["isChosen"].integer == 1) {
          files[i].isChosen = true;
        }
      }
    }
  }

  JSONValue getSavedFiles() {
    if (!"chosen_files.json".exists)
      return JSONValue("na");

    string result;
    auto file = File("chosen_files.json", "r");
    result = strip(file.readln);
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
    
    auto file = File("chosen_files.json", "w");
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

