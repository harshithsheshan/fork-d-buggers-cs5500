module model;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import std.file;
import std.stdio;
import std.array;
import std.string;

class Surface{

    SDL_Surface* imgSurface;
    const string DEFAULT_FILENAME = "savedImage";

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

    // this is function to save the image in BMP format with the file name given by the user
    //bool save(string fileName)
    bool save()
    {
        const(char)* fileNameWithExt = toStringz(DEFAULT_FILENAME ~ ".bmp");
        if (SDL_SaveBMP(imgSurface, fileNameWithExt) == 1) {
            writeln("Error occured while saving surface: ", SDL_GetError());
            return false;
        }
        return true;
    }

    // this is function to save the image in BMP format with the file name given by the user
    //bool open(string fileName)
    bool open()
    {
        const(char)* fileNameWithExt = toStringz(DEFAULT_FILENAME ~ ".bmp");
        SDL_Surface* newImage = SDL_LoadBMP(fileNameWithExt);
        if (newImage == null) {
            writeln("Error occured while opening imaage ", SDL_GetError());
            return false;
        }
        imgSurface = newImage;
        return true;
    }

}