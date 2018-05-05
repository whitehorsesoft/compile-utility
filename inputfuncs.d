module whs.inputfuncs;

import whs.compileutil;
import whs.diskfuncs;

void inputLoop(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config) {
  import std.stdio: write, readln, writeln;
  import std.string: strip;

  string inputStr;
  do {
    write("'f' for files, 'fl' for flags, 'q' to exit: ");
    inputStr = readln.strip;
  }
  while (inputParser!(TData, TError, TErrMsg, TFileId, TFlagId)(config, inputStr));

  writeln(config.finalOutput);
}

private:
bool inputParser(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config, string inputStr) {
  switch(inputStr) {
    default:
      return false;
    case "f":
      fileLoop!(TData, TError, TErrMsg, TFileId, TFlagId)(config);
      return true;
    case "fl":
      tagLoop!(TData, TError, TErrMsg, TFileId, TFlagId)(config);
      return true;
  }
}

void fileLoop(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config) {
  import std.stdio: writeln, readln;
  import std.string: strip;

  string inputStr;
  do {
    writeln(config.listFiles);
    writeln("Enter file number to toggle or 'q' to quit");
    inputStr = readln.strip;
  }
  while (fileParser!(TData, TError, TErrMsg, TFileId, TFlagId)(config, inputStr));
}

bool fileParser(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config, string inputStr) {
  import std.algorithm: count;
  import std.regex: matchFirst;
  import std.conv: to;

  if (matchFirst(inputStr, r"\D")) return false;

  int inputInt = inputStr.to!int;
  if (0 > inputInt || inputInt >= config.files.count) return false;
  else {
    config.toggleFile(inputInt);
    config.save;
    return true;
  }
}

void tagLoop(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config) {
  import std.stdio: writeln, readln;
  import std.string: strip;

  string inputStr;
  do {
    writeln(config.listFlags);
    writeln("Enter a flag to toggle or 'q' to quit");
    inputStr = readln.strip;
  } while (tagParser!(TData, TError, TErrMsg, TFileId, TFlagId)(config, inputStr));
}

bool tagParser(TData, TError, TErrMsg, TFileId, TFlagId)(IConfig!(TData, TError, TErrMsg, TFileId, TFlagId) config, string inputStr) {
  // -q is not a compiler flag, at least for ldc
  if (inputStr == "q") return false;

  config.toggleFlag(inputStr);
  config.save;
  return true;
}

