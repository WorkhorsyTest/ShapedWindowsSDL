// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


import core_dependencies;
import vectors;
import log;
import Random;
import helpers;
import helpers_sdl;

int screen_w;
int screen_h;


struct Block {
	float angle = 0;
	float radius = 0;
	float width = 100;
	Vec2f pos;
	SDL_Color color;
}



struct WindowSprite {
	Vec2f pos = Vec2f(0, 0);
	float angle = 0;
	SDL_Window* window;
	SDL_Renderer* renderer;
	Graphic graphic;

	this(const char* image_path) {
		//import std.string : toStringz;

		window = SDL_CreateShapedWindow(
			image_path,
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			100, 100,
			SDL_WINDOW_HIDDEN | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SKIP_TASKBAR | SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_POPUP_MENU
		);

		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

		graphic = LoadGraphic(renderer, image_path);

		SetWindowSizeAndShape(window, graphic);
	}

	float left() {
		return this.pos.x - (this.graphic.surface.w / 2.0);
	}

	float bottom() {
		return this.pos.y - (this.graphic.surface.h / 2.0);
	}

	void Show() {
		// Show
		SDL_ShowWindow(window);

		// Clear
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
		SDL_RenderClear(renderer);
		SDL_RenderPresent(renderer);

		// Set opacity
		SDL_SetWindowOpacity(window, 0.7);
	}

	void Draw() {
		// Clear
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
		SDL_RenderClear(renderer);

		// Draw
		SDL_RenderCopy(renderer, graphic.texture, null, null);
	}

	void Present() {
		SDL_RenderPresent(renderer);
	}

	void Free() {
		SDL_DestroyTexture(graphic.texture);
		SDL_FreeSurface(graphic.surface);
		SDL_DestroyRenderer(renderer);
		SDL_DestroyWindow(window);
	}
}

Vec2f GetRandomScreenSidePos(out int previous_side) {
	previous_side = Random.UniqueInteger(0, 4, previous_side);

	auto target = Vec2f(0, 0);
	final switch (previous_side) {
		// Top side
		case 0:
			target.x = Random.Float(0, screen_w);
			target.y = 0;
			break;
		// Bottom side
		case 1:
			target.x = Random.Float(0, screen_w);
			target.y = screen_h;
			break;
		// Right side
		case 2:
			target.x = screen_w;
			target.y = Random.Float(0, screen_h);
			break;
		// Left side
		case 3:
			target.x = 0;
			target.y = Random.Float(0, screen_h);
			break;
	}

	return target;
}

static immutable char* sprite1_path = "./images/Dlang_big.png\0".ptr;
static immutable char* sprite2_path = "./images/SDL_big.png\0".ptr;
static Block[50] blocks;

version (D_BetterC) {
	extern(C) int main() {
		return _main();
	}
} else {
	int main() {
		return _main();
	}
}

extern(C) int _main() {
	import core.stdc.stdio : printf;
	version (D_BetterC) {
		printf("Hello from betterC\n");
	}

	import std.math : sin, cos;
	import std.algorithm.comparison : clamp;
	import core.thread.osthread : Thread;
	import core.time : dur;
	static import core.memory;

	InitSharedLibraries();
	InitSDL();
	Random.Init();

	// Set GC and FPS
	//const bool is_active_gc = true;
	const s64 target_fps = 60;
	const s64 budget_time = 1_000_000_000 / target_fps;

	// Get screen size
	SDL_DisplayMode display_mode;
	SDL_GetCurrentDisplayMode(0, &display_mode);
	screen_w = display_mode.w;
	screen_h = display_mode.h;

	// Setup windows
	auto sprite1 = WindowSprite(sprite1_path);
	auto sprite2 = WindowSprite(sprite2_path);

	// Clear and show windows
	sprite1.Show();
	sprite2.Show();

	
	foreach (i ; 0 .. blocks.length) {
		auto angle = Random.Float(0.0, 360.0);
		auto radius = Random.Float(0.0, 300.0);
		auto width = Random.Float(20.0, 50.0);
		auto pos = Vec2f(screen_w * Random.Float(0.0, 1.0), screen_h * Random.Float(0.0, 1.0));
		auto color = SDL_Color(
			cast(u8) Random.Integer(0, 255),
			cast(u8) Random.Integer(0, 255),
			cast(u8) Random.Integer(0, 255),
			cast(u8) 255
		);
		blocks[i] = Block(angle, radius, width, pos, color);
	}

	bool is_running = true;

	version (D_BetterC) { } else {
		core.memory.GC.collect();
		core.memory.GC.disable();
	}

	s64 start_time, end_time, used_time, sleep_time;
	start_time = GetTicksNS();
	Vec2f previous_dest = Vec2f(0, 0);
	int previous_side;

	while (is_running) {
		s64 used_ns = clamp(GetTicksNS() - start_time, 0, s64.max);
		double delta = used_ns / 1_000_000_000.0;
		start_time = GetTicksNS();
		//printf("start_time:%ld, used_ns:%ld, delta:%f\n", start_time, used_ns, delta);

		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			if (event.type == SDL_QUIT) {
				is_running = false;
			}
		}

		// Rotate block around center
		foreach (ref block ; blocks) {
			block.angle += 2.0 * delta;
			block.pos.x = cos(block.angle) * block.radius + 200.0 * 0.5f;
			block.pos.y = sin(block.angle) * block.radius + 200.0 * 0.5f;
		}

		// Rotate D
		//logfln("window1_pos: %s, %s", window1_pos, delta);
		float r = 300.0;
		sprite1.angle += 2.0 * delta;
		sprite1.pos.x = cos(sprite1.angle) * r + (screen_w / 2.0);
		sprite1.pos.y = sin(sprite1.angle) * r + (screen_h / 2.0);

		// Move SDL from screen side to side
//		logfln("sprite2.pos: %s", sprite2.pos);
		if (MoveTowards(sprite2.pos, previous_dest, delta * 300.0)) {
			previous_dest = GetRandomScreenSidePos(previous_side);
		}
		SDL_SetWindowPosition(sprite1.window, cast(s32) sprite1.left, cast(s32) sprite1.bottom);
		SDL_SetWindowPosition(sprite2.window, cast(s32) sprite2.left, cast(s32) sprite2.bottom);

		// Draw window backgrounds
		sprite1.Draw();
		sprite2.Draw();

		// Draw blocks
		foreach (ref block ; blocks) {
			SDL_Rect rect = {
				cast(s32) (block.pos.x - (block.width / 2.0)),
				cast(s32) (block.pos.y - (block.width / 2.0)),
				cast(s32) block.width,
				cast(s32) block.width
			};
			SDL_SetRenderDrawColor(sprite1.renderer, block.color.r, block.color.g, block.color.b, block.color.a);
			SDL_SetRenderDrawColor(sprite2.renderer, block.color.r, block.color.g, block.color.b, block.color.a);
			SDL_RenderFillRect(sprite1.renderer, &rect);
			SDL_RenderFillRect(sprite2.renderer, &rect);
		}

		// Show windows
		sprite1.Present();
		sprite2.Present();

		// Run GC if in active mode
		version (D_BetterC) { } else {
			core.memory.GC.enable();
			core.memory.GC.collect();
			core.memory.GC.disable();
		}

		// Sleep for the remainder of our frame budget
		end_time = GetTicksNS();
		used_time = clamp(end_time - start_time, 0, s64.max);
		sleep_time = clamp(budget_time - used_time, 0, s64.max);
		/*if (used_time > 2_000_000)*/ printf("!!! used_time:%ld, sleep_time:%ld, delta:%f\n", used_time, sleep_time, delta);
		version (D_BetterC) {
			import core.sys.posix.unistd;
			usleep(cast(useconds_t) (sleep_time / 1_000)); // convert nanoseconds to microseconds
		} else {
			Thread.sleep(dur!("nsecs")(sleep_time));
		}
	}

	version (D_BetterC) { } else {
		core.memory.GC.enable();
	}

	sprite1.Free();
	sprite2.Free();
	SDL_Quit();

	return 0;
}
