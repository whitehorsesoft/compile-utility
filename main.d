/* if no command line args, run main
if no main, run lib
if command line args, display 
# ldc ./simplesocket.d ./main -w -wi -unittest
or
# ldc -main -w -wi -unittest -run ./compileutil.d
*/

module whs.main;

import whs.compileutil;
import whs.inputfuncs;
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

