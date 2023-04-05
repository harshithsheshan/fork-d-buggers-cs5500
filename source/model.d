module surface;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import std.file;
import std.stdio;
import std.array;

class Surface{

    SDL_Surface* imgSurface;
    //SDL_Window* window;
    int height;
    int width;
  this(int height = 480,int width = 640) {
    // Create a surface...
    this.width = width;
    this.height = height;
    imgSurface = SDL_CreateRGBSurface(0,width,height,32,0,0,0,0);

  }
  ~this(){
    // Free a surface...
        SDL_FreeSurface(imgSurface);

  }

  auto getHeight(){
    return this.height;
  }

  auto getWidth(){
    return this.width;
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

    void save()
    {
        const(char)* file = "DownloadedImage.bmp";
        if (SDL_SaveBMP(imgSurface, file) == 1) {
            writeln("Error occured while saving surface: ", SDL_GetError());
        }
    }

}