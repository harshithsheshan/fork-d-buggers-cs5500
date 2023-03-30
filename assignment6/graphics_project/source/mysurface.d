/// Run with: 'dub'
module mysurface;
// Import D standard libraries
import std.stdio;
import std.string;
import std.conv;
import std.exception;


// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

class Surface{
  	
	SDL_Surface* imgSurface;
	SDL_Window* window;
  this() {
  	// Create a surface...
  	window = SDL_CreateWindow("D SDL Painting",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        640,
                                        480, 
                                        SDL_WINDOW_SHOWN);
  	imgSurface = SDL_CreateRGBSurface(0,640,480,32,0,0,0,0);

  }
  ~this(){
  	// Free a surface...
		SDL_FreeSurface(imgSurface);
		SDL_DestroyWindow(window);
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
