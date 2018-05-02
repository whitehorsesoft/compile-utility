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
  config.load;

  string inputStr;
  do {
    write("input msg here ");
    inputStr = readln.strip;
  }
  while (inputParser(config, inputStr));

  writeln(finalOutput(config));
}

private:
bool inputParser(Config config, string inputStr) {
  switch(inputStr) {
    default:
      return false;
    case "f":
      fileLoop(config);
      return true;
    case "fl":
      tagLoop(config);
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
  if (matchFirst(inputStr, r"\D")) return false;

  int inputInt = inputStr.to!int;
  if (0 > inputInt || inputInt >= config.files.count) return false;
  else {
    if (config.files[inputInt].isChosen) {
      config.files[inputInt].isChosen = false;
    }
    else {
      config.files[inputInt].isChosen = true;
    }
    config.save;
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

void tagLoop(Config config) {
  string inputStr;
  do {
    writeln(listFlags(config));
    writeln("Enter a flag to toggle or 'q' to quit");
    inputStr = readln.strip;
  } while (tagParser(config, inputStr));
}

bool tagParser(Config config, string inputStr) {
  // -q is not a compiler flag, at least for ldc
  if (inputStr == "q") return false;

  if (config.flags.any!(f => f == inputStr)) {
    config.flags = config.flags.remove!(f => f == inputStr);
  }
  else {
    config.flags ~= inputStr;
  }

  config.save;
  return true;
}

string listFlags(Config config) {
  return config.flags.join(" ");
}

string finalOutput(Config config) {
  // if main module present, disallow -main flag
  if (config.files.any!(f => f.isMain)) {
    config.flags.remove!(f => f == "main");
  }
  // if main module not present, make sure -main flag is present
  else if(!config.flags.any!(f => f == "main")) {
    config.flags ~= "main";
  }

  // start to build output string
  string output = "ldc";
  
  if (config.files.count > 0) {
    output ~= " ";

    string tempFiles = config.files
      .filter!(f => f.isChosen)
      .map!(f => "./" ~ f.fileName)
      .join(" ");
    output ~= tempFiles;
  }

  if (config.flags.count > 0) {
    output ~= " ";
    
    output ~= config.flags
      .map!(f => "-" ~ f)
      .join(" ");
  }

  return output;
}
