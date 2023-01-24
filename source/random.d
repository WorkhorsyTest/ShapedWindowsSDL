// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


module Random;

import std.random : MinstdRand0, uniform;
import std.traits : isIntegral, EnumMembers;

// Globals
private auto g_rand = MinstdRand0(1);


void Init() {
	// Seed random number generator
	import core.stdc.time : time;
	g_rand.seed(cast(uint) time(null));
}

float Float(const float min, const float max) {
	return uniform(min, max, g_rand);
}

T Integer(T)(const T min, const T max)
if (isIntegral!T) {
	return uniform(min, max, g_rand);
}

T Integer(T)(const T max)
if (isIntegral!T) {
	return Random.Integer(0, max);
}

// Returns a random number, that is not the previous number
T UniqueInteger(T)(const T min, const T max, const T previous)
if (isIntegral!T) {
	T retval = 0;

	do {
		retval = Random.Integer(min, max);
	} while(retval == previous);

	return retval;
}
