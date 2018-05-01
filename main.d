module whs.main;

import whs.compileutil;
import std.stdio;
import std.string;

void main() {
  auto config = new Config();
  config.loadFiles;
  configloop(config);
}

void configloop(Config config) {
  int inputInt;
  while (inputInt > -1) {
    writeFiles(config);
    write("Enter file number to toggle: ");
    inputInt = tryGettingInput;
    if (config.files[inputInt].isChosen) {
      config.files[inputInt].isChosen = false;
    }
    else {
      config.files[inputInt].isChosen = true;
    }
    config.saveFiles;
  }
}

void writeFiles(Config config) {
  foreach(file; config.files) {
    auto result = file.fileName;
    if (file.isMain) {
      result = "* " ~ result;
    }

    if (file.isChosen) {
      result = "+" ~ result;
    }
    writeln(result);
  }
}

int tryGettingInput() {
  int inputInt;
  try {
    readf(" %d", inputInt);
  }
  catch(Exception ex) {
    readln;
    writeln("Does not compute, try again.");
    inputInt = tryGettingInput;
  }

  return inputInt;
}
