module whs.main;

import whs.compileutil;
import std.stdio;

void main() {
  auto config = new Config();
  config.loadFiles;
  foreach(file; config.files) {
    writeln(file.fileName);
  }
}
