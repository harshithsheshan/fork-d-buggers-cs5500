
module sdlapp;
public import surface;
import std.stdio;
import std.string;
import std.conv;
import std.exception;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;


class SDLApp{

	SDL_Surface* imgSurface;

 	this(){
 		// Handle initialization...
 		// SDL_Init
 		version(Windows){
        	writeln("Searching for SDL on Windows");
			ret = loadSDL("SDL2.dll");
		}
    	version(OSX){
        	writeln("Searching for SDL on Mac");
        	ret = loadSDL();
    	}
    	version(linux){ 
        	writeln("Searching for SDL on Linux");
			ret = loadSDL();
		}

		// Error if SDL cannot be loaded
    	if(ret != sdlSupport){
        	writeln("error loading SDL library");
        
        	foreach( info; loader.errors){
            	writeln(info.error,':', info.message);
        	}
    	}
    	if(ret == SDLSupport.noLibrary){
        	writeln("error no library found");    
    	}
    	if(ret == SDLSupport.badLibrary){
        	writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
    	}
 		if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
        writeln("SDL_Init: ", fromStringz(SDL_GetError()));
    	}
    imgSurface = SDL_CreateRGBSurface(0,640,480,32,0,0,0,0);
 	}

 	~this(){
 		// Handle SDL_QUIT
 		SDL_FreeSurface(imgSurface);
 		SDL_Quit();
		writeln("Ending application--good bye!");
 	}
  // Update a pixel ...
  // SomeFunction()
  void UpdateSurfacePixel(int xPos, int yPos){
		// When we modify pixels, we need to lock the surface first
		SDL_LockSurface(imgSurface);
		// Make sure to unlock the surface when we are done.
		// Retrieve the pixel arraay that we want to modify
		ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
		// Change the 'blue' component of the pixels
		pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0] = 255;
		// Change the 'green' component of the pixels
		pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1] = 128;
		// Change the 'red' component of the pixels
		pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2] = 32;
		SDL_UnlockSurface(imgSurface);
	}
  	
  // Check a pixel color
  // Some OtherFunction()
  auto GetPixelColor(int xPos,int yPos){
  		ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
  		ubyte pixel_r = pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0];
  		ubyte pixel_g = pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1];
  		ubyte pixel_b = pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2];
  		auto rgb = [pixel_r,pixel_g,pixel_b];
  		return rgb;
  }
 }