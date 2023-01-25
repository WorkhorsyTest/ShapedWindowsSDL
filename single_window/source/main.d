// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL

import core_dependencies;
import vectors;
import log;
import helpers;
import helpers_sdl;
import Random;


struct Block {
	float angle = 0;
	float radius = 0;
	float width = 100;
	Vec2f pos;
	SDL_Color color;
}

int main() {
	//import Colors;
	import std.math : sin, cos;
	import std.algorithm.comparison : clamp;
	import core.thread.osthread : Thread;
	import core.time : dur;
	//static import GC;
	static import core.memory;

	InitSharedLibraries();
	InitSDL();
	Random.Init();

	SDL_DisplayMode display_mode;
	SDL_GetCurrentDisplayMode(0, &display_mode);
	int screen_w = display_mode.w;
	int screen_h = display_mode.h;
	logfln("w:%s, h:%s", screen_w, screen_h);

	// Setup window and renderer
	SDL_Window* window = SDL_CreateShapedWindow(
		"Malware Mayhem",
		SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		screen_w, screen_h,
		SDL_WINDOW_HIDDEN | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SKIP_TASKBAR | SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_POPUP_MENU
	);

	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

	// Make window shaped like image
	auto graphic_dlang = LoadGraphic(renderer, "./images/Dlang_big.png");
	auto graphic_sdl = LoadGraphic(renderer, "./images/SDL_big.png");

	SDL_Surface* back1 = CreateSurface(screen_w, screen_h, SDL_Color(0, 0, 0, 0));
	SDL_Surface* back2 = CreateSurface(screen_w, screen_h, SDL_Color(0, 0, 0, 0));

	// Move window to center and show
	SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	SDL_ShowWindow(window);

	// Clear window
	SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
	SDL_RenderClear(renderer);
	SDL_RenderPresent(renderer);
	//SDL_SetWindowOpacity(window, 0.7);

	Array!Block blocks;
	foreach (_ ; 0 .. 6) {
		auto angle = Random.Float(0.0, 360.0);
		auto radius = Random.Float(0.0, 300.0);
		auto width = Random.Float(50.0, 100.0);
		auto pos = Vec2f(screen_w * Random.Float(0.0, 1.0), screen_h * Random.Float(0.0, 1.0));
		auto color = SDL_Color(
			cast(u8) Random.Integer(0, 255),
			cast(u8) Random.Integer(0, 255),
			cast(u8) Random.Integer(0, 255),
			cast(u8) 255
		);
		blocks ~= Block(angle, radius, width, pos, color);
	}

	bool is_running = true;

	core.memory.GC.collect();
	core.memory.GC.disable();

	s64 start_time, end_time, used_time, sleep_time;
	s64 budget_time = 1_000_000_000 / 60;
	//s64 loops = 0;
	auto pos = Vec2f(0, 0);
	start_time = GetTicksNS();
	bool is_fuck;
	while (is_running) {
		is_fuck = ! is_fuck;
		s64 used_ns = clamp(GetTicksNS() - start_time, 0, s64.max);
		double delta = used_ns / 1_000_000_000.0;
		start_time = GetTicksNS();

		SDL_Event event;
		//logfln("loops:%s, used_ns:%s", loops, used_ns);
		//loops++;
		//s64 count = 0;
		while (SDL_PollEvent(&event)) {
			//logfln("    count: %s", count);
			//count++;
			if (event.type == SDL_QUIT) {
				is_running = false;
			}
		}

		// Rotate block around center
		foreach (ref block ; blocks) {
			block.angle += 2.0 * delta;
			block.pos.x = cos(block.angle) * block.radius + screen_w * 0.5f;
			block.pos.y = sin(block.angle) * block.radius + screen_h * 0.5f;
		}

		logfln("pos: %s", pos);
		pos.x += 20.0 * delta;
		pos.y += 20.0 * delta;

		// Generate window mask
		if (is_fuck) {
			// Clear window mask
			SDL_LockSurface(back1);
			u32* pixels = cast(u32*) back1.pixels;
			foreach (y ; 0 .. back1.h) {
				foreach (x ; 0 .. back1.w) {
					size_t i = (y * back1.w) + x;
					pixels[i] = 0x00000000;
				}
			}
			SDL_UnlockSurface(back1);

			// Copy scprite mask to window mask
			SDL_Rect srcrect = { 0, 0, graphic_sdl.mask.w, graphic_sdl.mask.h };
			SDL_Rect dstrect = { cast(s32) pos.x, cast(s32) pos.y, graphic_sdl.mask.w, graphic_sdl.mask.h };
			SDL_BlitSurface(graphic_sdl.mask, &srcrect, back1, &dstrect);
		} else {
			// Clear window mask
			SDL_LockSurface(back2);
			u32* pixels = cast(u32*) back2.pixels;
			foreach (y ; 0 .. back2.h) {
				foreach (x ; 0 .. back2.w) {
					size_t i = (y * back2.w) + x;
					pixels[i] = 0x00000000;
				}
			}
			SDL_UnlockSurface(back2);

			// Copy scprite mask to window mask
			SDL_Rect srcrect = { 0, 0, graphic_dlang.mask.w, graphic_dlang.mask.h };
			SDL_Rect dstrect = { cast(s32) pos.x, cast(s32) pos.y, graphic_dlang.mask.w, graphic_dlang.mask.h };
			SDL_BlitSurface(graphic_dlang.mask, &srcrect, back2, &dstrect);
		}

		// Set window to use window mask
		SDL_WindowShapeMode shape_mode;
		shape_mode.mode = ShapeModeDefault;
		shape_mode.mode = ShapeModeColorKey;
		shape_mode.parameters.colorKey = SDL_Color(0, 0, 0, 0);
		if (is_fuck) {
			if (SDL_SetWindowShape(window, back1, &shape_mode) != 0) {
				throw new Exception(format!("Failed to set window shape: %s")(GetSDLError()));
			}
		} else {
			if (SDL_SetWindowShape(window, back2, &shape_mode) != 0) {
				throw new Exception(format!("Failed to set window shape: %s")(GetSDLError()));
			}
		}
		//SDL_UpdateWindowSurface(window);

		// Clear window
		SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
		SDL_RenderClear(renderer);

		// Draw background
		if (is_fuck) {
			SDL_Rect dstrect = { cast(s32) pos.x, cast(s32) pos.y, graphic_sdl.surface.w, graphic_sdl.surface.h };
			SDL_RenderCopy(renderer, graphic_sdl.texture, null, &dstrect);
		} else {
			SDL_Rect dstrect = { cast(s32) pos.x, cast(s32) pos.y, graphic_dlang.surface.w, graphic_dlang.surface.h };
			SDL_RenderCopy(renderer, graphic_dlang.texture, null, &dstrect);
		}

		// Draw blocks
		foreach (ref block ; blocks) {
			SDL_Rect rect = {
				cast(s32) (block.pos.x - (block.width / 2)),
				cast(s32) (block.pos.y - (block.width / 2)),
				cast(s32) block.width,
				cast(s32) block.width
			};
			SDL_SetRenderDrawColor(renderer, block.color.r, block.color.g, block.color.b, block.color.a);
			SDL_RenderFillRect(renderer, &rect);
		}

		SDL_RenderPresent(renderer);

		core.memory.GC.enable();
		core.memory.GC.collect();
		core.memory.GC.disable();

		end_time = GetTicksNS();
		used_time = clamp(end_time - start_time, 0, s64.max);
		sleep_time = clamp(budget_time - used_time, 0, s64.max);
		if (used_time > 2_000_000) logfln("!!! used_time:%s, sleep_time:%s, delta:%s", used_time, sleep_time, delta);
		Thread.sleep(dur!("nsecs")(sleep_time));
	}

	core.memory.GC.enable();

	foreach (graphic ; [graphic_dlang, graphic_sdl]) {
		SDL_DestroyTexture(graphic.texture);
		SDL_FreeSurface(graphic.surface);
	}
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();
	return 0;
}