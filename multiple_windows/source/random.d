// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


module Random;

import std.traits : isIntegral, EnumMembers;
version (D_BetterC) {
	import core.stdc.time;
	import core.stdc.stdlib;
} else {
	import std.random : MinstdRand0, uniform;
}

// Globals
version (D_BetterC) {
	
} else {
	private auto g_rand = MinstdRand0(1);
}


void Init() {
	// Seed random number generator
	version (D_BetterC) {
		time_t t = time(null);
		srand(cast(uint) t);
	} else {
		import core.stdc.time : time;
		g_rand.seed(cast(uint) time(null));
	}
}

float Float(const float min, const float max) {
	version (D_BetterC) {
		float scale = rand() / cast(float) RAND_MAX;
		return min + scale * (max - min);
	} else {
		return uniform(min, max, g_rand);
	}
}

T Integer(T)(const T min, const T max)
if (isIntegral!T) {
	version (D_BetterC) {
		float scale = rand() / cast(float) RAND_MAX;
		return cast(T) (min + scale * (max - min));
	} else {
		return uniform(min, max, g_rand);
	}
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
