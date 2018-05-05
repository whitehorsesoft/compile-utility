module whs.main;

import whs.compileutil;
import whs.inputfuncs;
import whs.diskfuncs;
import std.stdio;

void main(string[] args) {
  auto config = new Config();
  config.load;

  if (args.length == 1) {
    writeln(config.finalOutput);
  }
  else {
    inputLoop(config);
  }
}

