// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL

module log;

import std.stdio : stdout;
import std.stdio : stderr;

enum bool is_printing = true;

void log(S...)(S args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stdout.write(args); stdout.flush();
	}
	}
}

void logln(S...)(S args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stdout.writeln(args); stdout.flush();
	}
	}
}

void logf(Char, A...)(in Char[] fmt, A args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stdout.writef(fmt, args); stdout.flush();
	}
	}
}

void logfln(Char, A...)(in Char[] fmt, A args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stdout.writefln(fmt, args); stdout.flush();
	}
	}
}

void warn(S...)(S args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stderr.write(args); stderr.flush();
	}
	}
}

void warnln(S...)(S args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stderr.writeln(args); stderr.flush();
	}
	}
}

void warnf(Char, A...)(in Char[] fmt, A args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stderr.writef(fmt, args); stderr.flush();
	}
	}
}

void warnfln(Char, A...)(in Char[] fmt, A args) {
	static if(is_printing) {
	version (D_BetterC) { } else {
		stderr.writefln(fmt, args); stderr.flush();
	}
	}
}
