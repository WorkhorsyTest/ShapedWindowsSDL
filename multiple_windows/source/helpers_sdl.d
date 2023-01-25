// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


import core_dependencies;
import helpers;
import log;

/+
string GetSDLError() {
	import std.string : fromStringz;
	return cast(string) fromStringz(SDL_GetError());
}
+/

SDL_WindowShapeMode GetWindowShapeModeFromColorAlpha(SDL_Surface* surface) {
	SDL_WindowShapeMode shape_mode;

	// If there is no alpha mask, use the color of the first pixel
	if (surface.format.Amask == 0) {
		SDL_Color color;
		{
			SDL_LockSurface(surface);
			scope (exit) SDL_UnlockSurface(surface);
			u32* pixels = cast(u32*) surface.pixels;
			u32 pixel = pixels[0];
			SDL_GetRGB(pixel, surface.format, &color.r, &color.g, &color.b);
		}

		shape_mode.mode = ShapeModeColorKey;
		shape_mode.parameters.colorKey = color;
	// Otherwise use alpha mask color
	} else {
		shape_mode.mode = ShapeModeDefault;
	}

	return shape_mode;
}

struct Graphic {
	string _image_path;
	SDL_Surface* surface;
	SDL_Texture* texture;
	SDL_WindowShapeMode shape_mode;
}

Graphic LoadGraphic(SDL_Renderer* renderer, string image_path) {
	//import std.string : toStringz;

	Graphic graphic;
	graphic._image_path = image_path;

	// Create new surface from the image
	graphic.surface = IMG_Load(cast(char*) graphic._image_path.ptr);
	if (graphic.surface == null) {
		//throw new Exception(format!("Failed to load surface: %s")(GetSDLError()));
	}

	// Create a new texture from the surface
	graphic.texture = SDL_CreateTextureFromSurface(renderer, graphic.surface);
	if (graphic.texture == null) {
		//throw new Exception(format!("Failed to load texture: %s")(GetSDLError()));
	}

	// Get surface image transparency color
	graphic.shape_mode = GetWindowShapeModeFromColorAlpha(graphic.surface);

	return graphic;
}

void InitSharedLibraries() {
//	Array!string errors;

	SDLSupport sdl_ver = loadSDL();
//	logfln("SDL: %s", sdl_ver);
	// FIXME: Having this giant final switch is ugly and brittle
	if (sdl_ver != sdlSupport) {
		final switch (sdl_ver) {
			case SDLSupport.noLibrary:
//				errors ~= "Failed to find the library SDL2.";
				break;
			case SDLSupport.badLibrary:
//				errors ~= "Failed to load the library SDL2.";
				break;
			case SDLSupport.sdl200: break;
			case SDLSupport.sdl201: break;
			case SDLSupport.sdl202: break;
			case SDLSupport.sdl203: break;
			case SDLSupport.sdl204: break;
			case SDLSupport.sdl205: break;
			case SDLSupport.sdl206: break;
			case SDLSupport.sdl207: break;
			case SDLSupport.sdl208: break;
			case SDLSupport.sdl209: break;
			case SDLSupport.sdl2010: break;
			case SDLSupport.sdl2012: break;
			case SDLSupport.sdl2014: break;
			case SDLSupport.sdl2016: break;
			case SDLSupport.sdl2018: break;
			case SDLSupport.sdl2020: break;
			case SDLSupport.sdl2022: break;
		}
	}

	SDLImageSupport sdl_img_ver = loadSDLImage();
//	logfln("SDL_Image: %s", sdl_img_ver);
	// FIXME: Having this giant final switch is ugly and brittle
	if (sdl_img_ver != sdlImageSupport) {
		final switch (sdl_img_ver) {
			case SDLImageSupport.noLibrary:
//				errors ~= "Failed to find the library SDL2 Image.";
				break;
			case SDLImageSupport.badLibrary:
//				errors ~= "Failed to load the library SDL2 Image.";
				break;
			case SDLImageSupport.sdlImage200: break;
			case SDLImageSupport.sdlImage201: break;
			case SDLImageSupport.sdlImage202: break;
			case SDLImageSupport.sdlImage203: break;
			case SDLImageSupport.sdlImage204: break;
			case SDLImageSupport.sdlImage205: break;
		}
	}

	// Show any errors
//	foreach (error ; errors) {
//		warnln(error);
//	}
//	if (errors.length > 0) {
//		import std.array : join;
//		throw new Exception(join(errors, "\n"));
//	}
}

void InitSDL() {
	import std.conv : to;

	// Init all of SDL
	int flags = SDL_INIT_EVENTS | SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER;
	if (SDL_Init(flags) != 0) {
		//throw new Exception(format!("Failed to initialize SDL: %s")(GetSDLError()));
	}
}



void SetWindowSizeAndShape(SDL_Window* window, Graphic graphic) {
	SDL_SetWindowSize(window, graphic.surface.w, graphic.surface.h);
	SDL_SetWindowShape(window, graphic.surface, &graphic.shape_mode);
}
