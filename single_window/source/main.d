// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL

import core_dependencies;
import vectors;
import log;
import helpers;
import helpers_sdl;
import Random;


struct MainWindow {
	SDL_Window* window;
	SDL_Renderer* renderer;

	void Setup() {
		window = SDL_CreateWindow(
			"main window",
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			300, 300,
			SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_RESIZABLE
		);

		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

		// Move window to center and show
		SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	}

	void Free() {
		SDL_DestroyRenderer(renderer); renderer = null;
		SDL_DestroyWindow(window); window = null;
	}

	void Show() {
		SDL_ShowWindow(window);
		SDL_SetWindowInputFocus(window);
	}

	void Draw() {
		SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
		SDL_RenderClear(renderer);
	}

	void Present() {
		SDL_RenderPresent(renderer);
	}
}

struct FullScreenSprite {
	SDL_Window* window;
	SDL_Renderer* renderer;
	SDL_Surface* mask;
	SDL_WindowShapeMode shape_mode;

	void Setup() {
		//import std.string : toStringz;
		SDL_DisplayMode display_mode;
		SDL_GetCurrentDisplayMode(0, &display_mode);
		logfln("w:%s, h:%s", display_mode.w, display_mode.h);

		// Setup window and renderer
		window = SDL_CreateShapedWindow(
			"Full screen window",
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			display_mode.w, display_mode.h,
			SDL_WINDOW_HIDDEN | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SKIP_TASKBAR | SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_POPUP_MENU
		);

		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

		mask = CreateSurface(display_mode.w, display_mode.h, SDL_Color(0, 0, 0, 0));

		// Move window to center and show
		SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
		//SDL_SetWindowOpacity(window, 0.7);
	}

	void Free() {
		SDL_FreeSurface(mask); mask = null;
		SDL_DestroyRenderer(renderer); renderer = null;
		SDL_DestroyWindow(window); window = null;
	}

	void Show() {
		SDL_ShowWindow(window);
	}

	void DrawBackground() {
		SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
		SDL_RenderClear(renderer);
	}

	void Present() {
		SDL_RenderPresent(renderer);
	}

	void ClearMask() {
		SDL_LockSurface(mask);
		u32* pixels = cast(u32*) mask.pixels;
		foreach (y ; 0 .. mask.h) {
			foreach (x ; 0 .. mask.w) {
				size_t i = (y * mask.w) + x;
				pixels[i] = 0x00000000;
			}
		}
		SDL_UnlockSurface(mask);
	}

	void ApplyMask() {
		shape_mode.mode = ShapeModeDefault;
		shape_mode.mode = ShapeModeColorKey;
		shape_mode.parameters.colorKey = SDL_Color(0, 0, 0, 0);
		if (SDL_SetWindowShape(window, mask, &shape_mode) != 0) {
			throw new Exception(format!("Failed to set window shape: %s")(GetSDLError()));
		}
	}
}

struct ScreenSprite {
	auto pos = Vec2f(0, 0);
	string _image_path;
	Graphic graphic;
	FullScreenSprite* _parent;

	this(FullScreenSprite* parent, string image_path) {
		_parent = parent;
		_image_path = image_path;
		graphic = LoadGraphic(_parent.renderer, _image_path);
	}

	void Free() {
		_parent = null;
		graphic.Free(); graphic = Graphic.init;
	}

	void Logic(const double delta) {
		//logfln("pos: %s", pos);
		pos.x += 20.0 * delta;
		pos.y += 20.0 * delta;
	}

	void DrawMask() {
		SDL_Rect srcrect = { 0, 0, graphic.mask.w, graphic.mask.h };
		SDL_Rect dstrect = { cast(s32) pos.x, cast(s32) pos.y, graphic.mask.w, graphic.mask.h };
		SDL_BlitSurface(graphic.mask, &srcrect, _parent.mask, &dstrect);
	}

	void Draw() {
		SDL_Rect dstrect = { cast(s32) pos.x, cast(s32) pos.y, graphic.surface.w, graphic.surface.h };
		SDL_RenderCopy(_parent.renderer, graphic.texture, null, &dstrect);
	}
}

struct WindowSprite {
	Vec2f pos = Vec2f(0, 0);
	float angle = 0;
	SDL_Window* window;
	SDL_Renderer* renderer;
	Graphic graphic;
	string _image_path;
	Vec2f previous_dest = Vec2f(0, 0);
	int previous_side;

	this(string image_path) {
		//import std.string : toStringz;

		_image_path = image_path;
		window = SDL_CreateShapedWindow(
			cast(char*) _image_path.ptr,
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			100, 100,
			SDL_WINDOW_HIDDEN | SDL_WINDOW_BORDERLESS | SDL_WINDOW_SKIP_TASKBAR | SDL_WINDOW_ALWAYS_ON_TOP | SDL_WINDOW_POPUP_MENU
		);

		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

		graphic = LoadGraphic(renderer, _image_path);

		SetWindowSizeAndShape(window, graphic);
	}

	void Free() {
		graphic.Free(); graphic = Graphic.init;
		SDL_DestroyRenderer(renderer); renderer = null;
		SDL_DestroyWindow(window); window = null;
	}

	float left() {
		return this.pos.x - (this.graphic.surface.w / 2.0);
	}

	float bottom() {
		return this.pos.y - (this.graphic.surface.h / 2.0);
	}

	void Logic(const double delta) {
		// Move SDL from screen side to side
		if (MoveTowards(pos, previous_dest, delta * 300.0)) {
			previous_dest = GetRandomScreenSidePos(previous_side);
		}
		SDL_SetWindowPosition(window, cast(s32) left, cast(s32) bottom);
	}

	void Show() {
		SDL_ShowWindow(window);
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
}

Vec2f GetRandomScreenSidePos(out int previous_side) {
	previous_side = Random.UniqueInteger(0, 4, previous_side);

	SDL_DisplayMode display_mode;
	SDL_GetCurrentDisplayMode(0, &display_mode);

	auto target = Vec2f(0, 0);
	final switch (previous_side) {
		// Top side
		case 0:
			target.x = Random.Float(0, display_mode.w);
			target.y = 0;
			break;
		// Bottom side
		case 1:
			target.x = Random.Float(0, display_mode.w);
			target.y = display_mode.h;
			break;
		// Right side
		case 2:
			target.x = display_mode.w;
			target.y = Random.Float(0, display_mode.h);
			break;
		// Left side
		case 3:
			target.x = 0;
			target.y = Random.Float(0, display_mode.h);
			break;
	}

	return target;
}

int main() {
	import std.algorithm.comparison : clamp;
	import core.thread.osthread : Thread;
	import core.time : dur;
	static import core.memory;

	InitSharedLibraries();
	InitSDL();
	Random.Init();

	auto full_screen_sprite = FullScreenSprite();
	full_screen_sprite.Setup();
	// Make window shaped like image
	auto dlang = ScreenSprite(&full_screen_sprite, "./images/Dlang_big.png\0");
	auto sdl = WindowSprite("./images/SDL_big.png\0");
	auto main_window = MainWindow();
	main_window.Setup();

	// Clear and show windows
	full_screen_sprite.Show();
	sdl.Show();
	main_window.Show();

	sdl.Draw();
	full_screen_sprite.DrawBackground();
	main_window.Draw();

	bool is_running = true;

	core.memory.GC.collect();
	core.memory.GC.disable();

	s64 start_time, end_time, used_time, sleep_time;
	s64 budget_time = 1_000_000_000 / 60;
	start_time = GetTicksNS();
	while (is_running) {
		s64 used_ns = clamp(GetTicksNS() - start_time, 0, s64.max);
		double delta = used_ns / 1_000_000_000.0;
		start_time = GetTicksNS();

		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				// Quit the game if the main window is closed
				case SDL_WINDOWEVENT:
					if (event.window.event == SDL_WINDOWEVENT_CLOSE &&
						event.window.windowID == SDL_GetWindowID(main_window.window)) {
						is_running = false;
					}
					break;
				// Quit the game normally
				case SDL_QUIT:
					is_running = false;
					break;
				// Quit the game if ESC is pressed
				case SDL_KEYUP:
					if (event.key.keysym.sym == SDLK_ESCAPE) {
						is_running = false;
					}
					break;
				default:
					break;
			}
		}

		// Run logic
		dlang.Logic(delta);
		sdl.Logic(delta);

		// Clear window mask
		full_screen_sprite.ClearMask();
		dlang.DrawMask();
		full_screen_sprite.ApplyMask();

		// Draw on window
		full_screen_sprite.DrawBackground();
		dlang.Draw();
		sdl.Draw();
		main_window.Draw();

		// Present window
		full_screen_sprite.Present();
		sdl.Present();
		main_window.Present();

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

	sdl.Free();
	dlang.Free();
	full_screen_sprite.Free();
	main_window.Free();

	SDL_Quit();
	return 0;
}