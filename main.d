module whs.main;

void main(string[] args) {
  import whs.compileutil;
  import whs.diskfuncs: load;
  import whs.inputfuncs: inputLoop;
  import std.stdio: writeln;

  auto config = new Config();
  config.load;

  if (args.length == 1) {
    writeln(config.finalOutput);
  }
  else {
    inputLoop(config);
  }
}

