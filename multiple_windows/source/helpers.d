// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


import core_dependencies;
import vectors;

/+
string format(string fmt = "%s", ARGS...)(auto ref ARGS args) {
	string result;
	static import std.string;
	result = std.string.format(fmt, args);
	return result;
}
+/
s64 GetTicksNS() {
	version (D_BetterC) {
		//import core.stdc.time;
		import core.sys.posix.time;
		timespec start;
		clock_gettime(CLOCK_REALTIME, &start);
		return start.tv_nsec;
	} else {
		import core.time : MonoTime, ticksToNSecs;
		return ticksToNSecs(MonoTime.currTime.ticks);
	}
}

void Pythagorean(const Vec2f src, const Vec2f dest, ref float a, ref float b, ref float c) {
	import std.math : fabs, sqrt;

	a = fabs(src.x - dest.x);
	b = fabs(src.y - dest.y);
	c = sqrt((a*a) + (b*b));
	float ax = 0;
	float bx = 0;
	ax = (src.x > dest.x ? -a : a);
	bx = (src.y > dest.y ? -b : b);
	a = ax;
	b = bx;
}

bool MoveTowards(ref Vec2f src, const Vec2f dest, const float MOVEMENT_PX) {
	import std.math : fabs;

	float a = 0;
	float b = 0;
	float c = 0;
	Pythagorean(src, dest, a, b, c);

	float unit = c / MOVEMENT_PX;
	float is_near_x = (fabs(a) >= MOVEMENT_PX);
	float is_near_y = (fabs(b) >= MOVEMENT_PX);

	// Move closer to X
	if (is_near_x) {
		float x_speed = a / unit;
		src.x += x_speed;
	// Move to X
	} else {
		src.x = dest.x;
	}

	// Move closer to Y
	if (is_near_y) {
		float y_speed = b / unit;
		src.y += y_speed;
	// Move to Y
	} else {
		src.y = dest.y;
	}

	bool is_at_dest = src.x == dest.x && src.y == dest.y;
	return is_at_dest;
}
