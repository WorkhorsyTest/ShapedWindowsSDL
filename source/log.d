// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL

module log;

import std.stdio : stdout;
import std.stdio : stderr;

void log(S...)(S args) {
	stdout.write(args); stdout.flush();
}

void logln(S...)(S args) {
	stdout.writeln(args); stdout.flush();
}

void logf(Char, A...)(in Char[] fmt, A args) {
	stdout.writef(fmt, args); stdout.flush();
}

void logfln(Char, A...)(in Char[] fmt, A args) {
	stdout.writefln(fmt, args); stdout.flush();
}

void warn(S...)(S args) {
	stderr.write(args); stderr.flush();
}

void warnln(S...)(S args) {
	stderr.writeln(args); stderr.flush();
}

void warnf(Char, A...)(in Char[] fmt, A args) {
	stderr.writef(fmt, args); stderr.flush();
}

void warnfln(Char, A...)(in Char[] fmt, A args) {
	stderr.writefln(fmt, args); stderr.flush();
}
