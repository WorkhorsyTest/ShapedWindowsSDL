// Copyright (c) 2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Licensed under a MIT style license
// https://github.com/WorkhorsyTest/ShapedWindowsSDL


import core_dependencies;
import helpers;
import log;

immutable u32 PIXEL_FORMAT = SDL_PIXELFORMAT_ARGB8888;

string GetSDLError() {
	import std.string : fromStringz;
	return cast(string) fromStringz(SDL_GetError());
}

@safe pure nothrow u32 MASK_A() {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return 0x000000FF;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return 0xFF000000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return 0x000000FF;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return 0xFF000000;
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u32 MASK_R() {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return 0xFF000000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return 0x00FF0000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return 0x0000FF00;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return 0x000000FF;
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u32 MASK_G() {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return 0x00FF0000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return 0x0000FF00;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return 0x00FF0000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return 0x0000FF00;
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u32 MASK_B() {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return 0x00FF0000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return 0x000000FF;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return 0xFF000000;
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return 0x0000FF00;
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u8 toAlpha(const u32 color) {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return cast(u8) ((color << (3 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return cast(u8) ((color << (0 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return cast(u8) ((color << (3 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return cast(u8) ((color << (0 * 8)) >> 24);
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u8 toRed(const u32 color) {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return cast(u8) ((color << (0 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return cast(u8) ((color << (1 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return cast(u8) ((color << (2 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return cast(u8) ((color << (3 * 8)) >> 24);
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u8 toGreen(const u32 color) {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return cast(u8) ((color << (1 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return cast(u8) ((color << (2 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return cast(u8) ((color << (1 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return cast(u8) ((color << (2 * 8)) >> 24);
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow u8 toBlue(const u32 color) {
	static if (PIXEL_FORMAT == SDL_PIXELFORMAT_RGBA8888) {
		return cast(u8) ((color << (2 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ARGB8888) {
		return cast(u8) ((color << (3 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_BGRA8888) {
		return cast(u8) ((color << (0 * 8)) >> 24);
	} else static if (PIXEL_FORMAT == SDL_PIXELFORMAT_ABGR8888) {
		return cast(u8) ((color << (1 * 8)) >> 24);
	} else {
		import std.string : format;
		static assert(0, `Unexpected SDL_PIXEL_FORMAT "%X"`.format(PIXEL_FORMAT));
	}
}

@safe pure nothrow Color toColor(const u32 color) {
	return Color(
		toRed(color),
		toGreen(color),
		toBlue(color),
		toAlpha(color)
	);
}

// NOTE: This returns the color as u32 formatted in rgba8888 regardless of global PIXEL_FORMAT
@safe pure nothrow u32 toRGBA(const Color color) {
	return cast(u32) (
		(color.r << (3 * 8)) |
		(color.g << (2 * 8)) |
		(color.b << (1 * 8)) |
		(color.a << (0 * 8))
	);
}


u32 toU32(SDL_Color color, SDL_PixelFormat* pixel_format) {
	if (pixel_format.format == SDL_PIXELFORMAT_RGBA8888) {
		return cast(u32) (
			(color.r << (3 * 8)) |
			(color.g << (2 * 8)) |
			(color.b << (1 * 8)) |
			(color.a << (0 * 8))
		);
	} else if (pixel_format.format == SDL_PIXELFORMAT_ARGB8888) {
		return cast(u32) (
			(color.a << (3 * 8)) |
			(color.r << (2 * 8)) |
			(color.g << (1 * 8)) |
			(color.b << (0 * 8))
		);
	} else if (pixel_format.format == SDL_PIXELFORMAT_BGRA8888) {
		return cast(u32) (
			(color.b << (3 * 8)) |
			(color.g << (2 * 8)) |
			(color.r << (1 * 8)) |
			(color.a << (0 * 8))
		);
	} else if (pixel_format.format == SDL_PIXELFORMAT_ABGR8888) {
		return cast(u32) (
			(color.a << (3 * 8)) |
			(color.b << (2 * 8)) |
			(color.g << (1 * 8)) |
			(color.r << (0 * 8))
		);
	} else {
		import std.string : format;
		throw new Exception(`Unexpected SDL_PixelFormat "%X"`.format(pixel_format));
	}
}

string GetColorStringRGBA(const Color color) {
	return format!("%02X%02X%02X%02X")(color.r, color.g, color.b, color.a);
}

string GetPixelFormatName(u32 pixel_format) {
	switch (pixel_format) {
		case SDL_PIXELFORMAT_RGBA8888: return "SDL_PIXELFORMAT_RGBA8888";
		case SDL_PIXELFORMAT_ARGB8888: return "SDL_PIXELFORMAT_ARGB8888";
		case SDL_PIXELFORMAT_BGRA8888: return "SDL_PIXELFORMAT_BGRA8888";
		case SDL_PIXELFORMAT_ABGR8888: return "SDL_PIXELFORMAT_ABGR8888";
		default: return "unknown";
	}
}


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

/*
SDL_Surface* EnsureSurfacePixelFormat(SDL_Surface* surface) {
	// Just return if the pixel format is already the expected
	if (IsSurfacePixelFormatExpected(surface)) {
		return surface;
	}

	// Convert the surface into a new one that is the expected pixel format
	SDL_Surface* new_surface = SDL_ConvertSurfaceFormat(surface, PIXEL_FORMAT, 0);
	if (new_surface == null) {
		throw new Exception(format!("Failed to convert surface to expected format: %s")(GetSDLError()));
	}
	SDL_FreeSurface(surface);

	// Make sure the new surface is the expected pixel format
	if (! IsSurfacePixelFormatExpected(new_surface)) {
		throw new Exception(format!("Failed to convert surface to expected format: %s")(GetSDLError()));
	}
	return new_surface;
}
*/
SDL_Surface* CreateSurface(const int W, const int H, const SDL_Color color) {
	SDL_Surface* surface = SDL_CreateRGBSurface(0, W, H, 32, MASK_R, MASK_G, MASK_B, MASK_A);
	if (surface == null) {
		throw new Exception(format!("Failed to create surface: %s")(GetSDLError()));
	}
	//surface = EnsureSurfacePixelFormat(surface);

	// Fill the surface with the color
	SDL_Rect rect = { 0, 0, surface.w, surface.h };
	u32 color_uint32 = toU32(color, surface.format);
	if (SDL_FillRect(surface, &rect, color_uint32) != 0) {
		throw new Exception(format!("Failed to fill surface with color: %s")(GetSDLError()));
	}

	return surface;
}

SDL_Surface* GenerateMask(SDL_Surface* src_surface, SDL_Color visible_color) {
	auto clear = SDL_Color(0, 0, 0, 0);
	SDL_Surface* dest_surface = CreateSurface(src_surface.w, src_surface.h, clear);
	u32* src_pixels = cast(u32*) src_surface.pixels;
	u32* dest_pixels = cast(u32*) dest_surface.pixels;
	u32 visible_color_u32 = toU32(visible_color, dest_surface.format);
	u32 clear_color_u32 = toU32(clear, dest_surface.format);
	for (int y=0; y<src_surface.h; ++y) {
		for (int x=0; x<src_surface.w; ++x) {
			size_t i = (y * src_surface.w) + x;
			u8 a, r, g, b;
			SDL_GetRGBA(src_pixels[i], src_surface.format, &r, &g, &b, &a);
			u32 color = a > 0 ? visible_color_u32 : clear_color_u32;
			dest_pixels[i] = color;
		}
	}

	return dest_surface;
}

struct Graphic {
	string _image_path;
	SDL_Surface* surface;
	SDL_Surface* mask;
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
		throw new Exception(format!("Failed to load surface: %s")(GetSDLError()));
	}

	graphic.mask = GenerateMask(graphic.surface, SDL_Color(255, 255, 255, 255));

	// Create a new texture from the surface
	graphic.texture = SDL_CreateTextureFromSurface(renderer, graphic.surface);
	if (graphic.texture == null) {
		throw new Exception(format!("Failed to load texture: %s")(GetSDLError()));
	}

	// Get surface image transparency color
	graphic.shape_mode = GetWindowShapeModeFromColorAlpha(graphic.surface);

	return graphic;
}

void InitSharedLibraries() {
	string[] errors;

	SDLSupport sdl_ver = loadSDL();
	logfln("SDL: %s", sdl_ver);
	// FIXME: Having this giant final switch is ugly and brittle
	if (sdl_ver != sdlSupport) {
		final switch (sdl_ver) {
			case SDLSupport.noLibrary:
				errors ~= "Failed to find the library SDL2.";
				break;
			case SDLSupport.badLibrary:
				errors ~= "Failed to load the library SDL2.";
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
	logfln("SDL_Image: %s", sdl_img_ver);
	// FIXME: Having this giant final switch is ugly and brittle
	if (sdl_img_ver != sdlImageSupport) {
		final switch (sdl_img_ver) {
			case SDLImageSupport.noLibrary:
				errors ~= "Failed to find the library SDL2 Image.";
				break;
			case SDLImageSupport.badLibrary:
				errors ~= "Failed to load the library SDL2 Image.";
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
	foreach (error ; errors) {
		warnln(error);
	}
	if (errors.length > 0) {
		import std.array : join;
		throw new Exception(join(errors, "\n"));
	}
}

void InitSDL() {
	import std.conv : to;

	// Init all of SDL
	int flags = SDL_INIT_EVENTS | SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER;
	if (SDL_Init(flags) != 0) {
		throw new Exception(format!("Failed to initialize SDL: %s")(GetSDLError()));
	}
}



void SetWindowSizeAndShape(SDL_Window* window, Graphic graphic) {
	SDL_SetWindowSize(window, graphic.surface.w, graphic.surface.h);
	SDL_SetWindowShape(window, graphic.surface, &graphic.shape_mode);
}
