module whs.inputfuncs;

import whs.compileutil;
import std.stdio;
import std.string;
import std.regex;
import std.conv;
import std.algorithm;
import std.format;

void inputLoop() {
  auto config = new Config();
  config.loadFiles;

  string inputStr;
  do {
    write("input msg here ");
    inputStr = readln.strip;
  }
  while (inputParser(config, inputStr));
}

private:
bool inputParser(Config config, string inputStr) {
  switch(inputStr) {
    default:
      return false;
    case "f":
      fileLoop(config);
      return true;
  }
}

void fileLoop(Config config) {
  string inputStr;
  do {
    writeln(listFiles(config));
    writeln("Enter file number to toggle or 'q' to quit");
    inputStr = readln.strip;
  } while (fileParser(config, inputStr));
}

bool fileParser(Config config, string inputStr) {
  int inputInt;
  if (matchFirst(inputStr, r"\D")) return false;

  inputInt = inputStr.to!int;
  if (0 > inputInt || inputInt >= config.files.count) return false;
  else {
    if (config.files[inputInt].isChosen) {
      config.files[inputInt].isChosen = false;
    }
    else {
      config.files[inputInt].isChosen = true;
    }
    config.saveFiles;
    return true;
  }
}

string listFiles(Config config) {
  string[] result;
  for (int i = 0; i < config.files.count; i++) {
    auto file = config.files[i];
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
