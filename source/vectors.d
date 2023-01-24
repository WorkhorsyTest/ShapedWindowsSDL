// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


// FIXME: Replace with a standard Vector library from https://code.dlang.org/
struct Vec2(T) {
	T x;
	T y;

	bool opEquals(const Vec2!T other) const {
		return
			this.x == other.x &&
			this.y == other.y;
	}

	Vec2 opUnary(string op)() const if (op == "-") {
		return Vec2(-x, -y);
	}

	// this op rhs
	Vec2 opBinary(string op)(const T rhs) const {
		static if (op == "+") {
			return Vec2(x + rhs, y + rhs);
		} else static if (op == "-") {
			return Vec2(x - rhs, y - rhs);
		} else static if (op == "/") {
			return Vec2(x / rhs, y / rhs);
		} else static if (op == "*") {
			return Vec2(x * rhs, y * rhs);
		} else {
			import std.string : format;
			static assert(0, `Unexpected op "%s"`.format(op));
		}
	}

	// lhs op this
	Vec2 opBinaryRight(string op)(const T lhs) const {
		static if (op == "+") {
			return Vec2(lhs + x, lhs + y);
		} else static if (op == "-") {
			return Vec2(lhs - x, lhs - y);
		} else static if (op == "/") {
			return Vec2(lhs / x, lhs / y);
		} else static if (op == "*") {
			return Vec2(lhs * x, lhs * y);
		} else {
			import std.string : format;
			static assert(0, `Unexpected op "%s"`.format(op));
		}
	}

	// this op= rhs
	void opOpAssign(string op)(const T rhs) {
		static if (op == "+") {
			x += rhs;
			y += rhs;
		} else static if (op == "-") {
			x -= rhs;
			y -= rhs;
		} else static if (op == "/") {
			x /= rhs;
			y /= rhs;
		} else static if (op == "*") {
			x *= rhs;
			y *= rhs;
		} else {
			import std.string : format;
			static assert(0, `Unexpected op "%s"`.format(op));
		}
	}

	void opOpAssign(string op)(const Vec2!T rhs) {
		static if (op == "+") {
			x += rhs.x;
			y += rhs.y;
		} else static if (op == "-") {
			x -= rhs.x;
			y -= rhs.y;
		} else static if (op == "/") {
			x /= rhs.x;
			y /= rhs.y;
		} else static if (op == "*") {
			x *= rhs.x;
			y *= rhs.y;
		} else {
			import std.string : format;
			static assert(0, `Unexpected op "%s"`.format(op));
		}
	}
}

alias Vec2f = Vec2!float;
