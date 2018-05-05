module whs.diskfuncs;

import whs.compileutil;
import std.stdio;
import std.string;
import std.regex;
import std.conv;
import std.algorithm;
import std.format;
import std.array;
import std.json;

  import std.file;
  import std.path;
  import std.string:strip;

void load(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config) {
  // get all files in current dir
    auto fileList = dirEntries("", SpanMode.shallow)
      .filter!(e => e.isFile)
      .array;

    // mark files with saved information
    TData fileJSONs = getSavedFiles;

    config.populate(fileList, fileJSONs);
}

void save(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config) {
  auto serializedJSON = config.serialized.result;
  auto file = File("saved_info.json", "w");
  file.writeln(serializedJSON.toString);
}

JSONValue getSavedFiles() {
  if (!"saved_info.json".exists)
    return JSONValue("na");

  string result;
  auto file = File("saved_info.json", "r");
  result = strip(file.readln);
  return parseJSON(result);
}
