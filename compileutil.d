module whs.compileutil;
  import std.json: JSONValue;
  import std.file: DirEntry;

struct FileEntry {
  bool isChosen;
  bool isMain;
  string fileName;
}

struct MultiResult(TError, TResult) {
  TError error;
  TResult result;
}

interface IConfig(TData, TError, TErrMsg, TFileId, TFlagId) {
  FileEntry[] files();
  string[] flags();

  MultiResult!(TError, TErrMsg) populate(DirEntry[] fileList, TData dataToParse); // load replacement
  MultiResult!(TError, TData) serialized(); // save replacement
  string finalOutput();
  string listFiles();
  string listFlags();
  MultiResult!(TError, TErrMsg) toggleFile(TFileId fileId);
  MultiResult!(TError, TErrMsg) toggleFlag(TFlagId flagId);
}

class Config : IConfig!(JSONValue, bool, string, int, string) {
  private FileEntry[] _files;
  private string[] _flags;

  FileEntry[] files() @property { return _files; }
  string[] flags() @property { return _flags; }

  MultiResult!(bool, string) populate(DirEntry[] fileList, JSONValue dataToParse) {
    import std.algorithm: map, filter, count;
    import std.array: array;

    try {
      // populate _files
      _files = fileList.map!(f => getFileEntry(f)).array;

      // if no json data, stop here
      if (dataToParse.toString == `"na"`) return MultiResult!(bool, string)(false, "");

      for(auto i = 0; i < _files.length; i++) {
        auto tempFiles = dataToParse["files"]
          .array
          .filter!(f => f["fileName"].str == _files[i].fileName)
          .array;
        if (tempFiles.count > 0) {
          if (tempFiles[0]["isChosen"].integer == 1) {
            _files[i].isChosen = true;
          }
        }
      }

      // load flag settings
      auto tempFlags = dataToParse["flags"]
        .array
        .map!(f => f.str)
        .array;
      _flags = tempFlags;

      return MultiResult!(bool, string)(false, "");
    }
    catch (Exception ex) {
      return MultiResult!(bool, string)(true, ex.msg);
    }
  }
 
  MultiResult!(bool, JSONValue) serialized() {
    import std.json: object;

    try {
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
      result.object["flags"] = JSONValue(flags);
      
      return MultiResult!(bool, JSONValue)(false, result); 
    }
    catch (Exception ex) {
      return MultiResult!(bool, JSONValue)(true, JSONValue("na"));
    }
  }

  string finalOutput() {
    import std.algorithm: count, any, remove, countUntil, map, filter;
    import std.string: join;

    // if no files present, return blank
    if (_files.count < 1) return "";

    // if main module present, disallow -main flag
    if (_files.any!(f => f.isMain)) {
      _flags = _flags.remove!(f => f == "main");
    }
    // if main module not present, make sure -main flag is present
    else if(!_flags.any!(f => f == "main")) {
      _flags ~= "main";
    }

    // if run flag set, pull either main.d or first .d file from file listing
    string fileToRun;

    if (_flags.any!(f => f == "run")) {

      auto i = _files.countUntil!(f => f.isMain);
      if (i >=0 ) {
        fileToRun = _files[i].fileName;
        _files = _files.remove(i);
      }
      else {
        fileToRun = _files[0].fileName;
        _files = _files.remove(0);
      }
    }

    // start to build output string
    string output = "ldc";
    
    if (_files.count > 0) {
      output ~= " ";

      string tempFiles = _files
        .filter!(f => f.isChosen)
        .map!(f => "./" ~ f.fileName)
        .join(" ");
      output ~= tempFiles;
    }

    if (_flags.count > 0) {
      output ~= " ";

      // put 'run' flag at end, if it exists
      auto i = _flags.countUntil!(f => f == "run");
      if (i >= 0) {
        auto tempFlag = _flags[i];
        _flags = _flags.remove(i);
        _flags ~= tempFlag;
      }

      output ~= _flags
        .map!(f => "-" ~ f)
        .join(" ");
    }

    // if run flag exists, fileToRun should be populated, and should be added last
    if (fileToRun.length > 0) {
      output ~= " ./";
      output ~= fileToRun;
    }

    return output;
  }

  string listFiles() {
    import std.algorithm: count;
    import std.string: join;
    import std.format: format;

    string[] result;
    for (int i = 0; i < _files.count; i++) {
      auto file = _files[i];
      auto mainStr = file.isMain ? "*" : "";
      auto chosenStr = file.isChosen ? "+" : " ";

      auto fileLine = format("%s %s%s%s",
        format("%0.2d", i),
        chosenStr,
        mainStr,
        file.fileName
      );
      
      result ~= fileLine;
    }
    return result.join("\n");
  }

  string listFlags() {
    import std.string: join;

    return _flags.join(" ");
  }

  MultiResult!(bool, string) toggleFile(int fileId) {
    _files[fileId].isChosen = !_files[fileId].isChosen;
    return MultiResult!(bool, string)(false, "");
  }

  MultiResult!(bool, string) toggleFlag(string flagId) {
    _flags = _flags.toggleItem(flagId);
    return MultiResult!(bool, string)(false, "");
  }

private:
  FileEntry getFileEntry(DirEntry dirEntry) {
    import std.regex: matchFirst;
    import std.path: baseName;

    auto fileName = baseName(dirEntry.name);
    auto isMain = (fileName == "main");
    FileEntry dFile;
    dFile.isMain = isMain;
    dFile.fileName = fileName;

    if (matchFirst(fileName, r"main\.d")) dFile.isMain = true;
    return dFile;
  }
}

T[] toggleItem(T)(T[] targets, T item) {
  import std.algorithm: any, remove;

  if (targets.any!(t => t == item)) {
    return targets.remove!(t => t == item);
  }
  else {
    return targets ~= item;
  }
}
