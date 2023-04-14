module model;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import std.file;
import std.stdio;
import std.array;
import std.string;
import std.container : Array;

class Surface{

    SDL_Surface* imgSurface;
    const string DEFAULT_FILENAME = "savedImage";

    //SDL_Window* window;
    int height;
    int width;

    int menuSize = 5;
    auto queuePos = Array!ulong();
    auto queue = Array!int();
    int pos = 0;
    int brushSize=4;
    ubyte blue = 255;
    ubyte green = 255;
    ubyte red = 255;

    this(int height = 480,int width = 645) {
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
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0] = blue;
        // Change the 'green' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1] = green;
        // Change the 'red' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2] = red;
        SDL_UnlockSurface(imgSurface);
    }

    void UpdateSurfacePixelFromServer(int xPos, int yPos,ubyte r, ubyte g, ubyte b){
        // When we modify pixels, we need to lock the surface first
        SDL_LockSurface(imgSurface);
        // Make sure to unlock the surface when we are done.
        // Retrieve the pixel arraay that we want to modify
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        // Change the 'blue' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0] = b;
        // Change the 'green' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1] = g;
        // Change the 'red' component of the pixels
        pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2] = r;
        SDL_UnlockSurface(imgSurface);
    }


    // Check a pixel color
    // Some OtherFunction()
    auto GetPixelColor(int xPos,int yPos){
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        ubyte pixel_b = pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+0];
        ubyte pixel_g = pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+1];
        ubyte pixel_r = pixelArray[yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel+2];
        auto rgb = [pixel_r,pixel_g,pixel_b];
        return rgb;
    }


    auto getMenuSize(){
        return menuSize;
    }
    auto GetSetColor(){
        return [red,green,blue];
    }
    auto getBrushSize(){
        return brushSize;
    }

    void changeColor(ubyte r, ubyte g, ubyte b){
        red = r;
        green = g;
        blue = b;
    }

    void drawBox(int x, int y, int offset){
        for (int i = 0; i < menuSize; i++) {
            for (int j = 0; j < menuSize; j++) {
                UpdateSurfacePixel((x*menuSize)+i+(offset*menuSize), (y*menuSize)+j);
            }
        }
    }

    void drawBar(int x){
        for (int i = 0; i < menuSize; i++) {
            for (int j = 0; j < (menuSize*8); j++) {
                UpdateSurfacePixel((x*menuSize)+i, j);
            }
        }
    }

    void drawMenu(){

        // fill screen white
        for (int i=0; i < width; i++){
            for (int j=0; j < height; j++){
                UpdateSurfacePixel(i, j);
            }
        }

        changeColor(0,0,0);

        // draw menu bar divider line
        for (int i=0; i < width; i++){
            for (int j = 0; j < menuSize; j++) {
                UpdateSurfacePixel(i, (7*menuSize)+j);
            }
        }

        // writing save button
        int offset = 0;
        // s
        drawBox(2, 2, offset);
        drawBox(3, 2, offset);
        drawBox(2, 3, offset);
        drawBox(1, 3, offset);
        drawBox(3, 4, offset);
        drawBox(1, 5, offset);
        drawBox(2, 5, offset);

        // a
        drawBox(6, 2, offset);
        drawBox(7, 2, offset);
        drawBox(5, 3, offset);
        drawBox(7, 3, offset);
        drawBox(5, 4, offset);
        drawBox(7, 4, offset);
        drawBox(6, 5, offset);
        drawBox(7, 5, offset);

        // v
        drawBox(9, 2, offset);
        drawBox(11, 2, offset);
        drawBox(9, 3, offset);
        drawBox(11, 3, offset);
        drawBox(9, 4, offset);
        drawBox(11, 4, offset);
        drawBox(10, 5, offset);

        // 3
        drawBox(14, 2, offset);
        drawBox(15, 2, offset);
        drawBox(13, 3, offset);
        drawBox(15, 3, offset);
        drawBox(13, 4, offset);
        drawBox(14, 4, offset);
        drawBox(14, 5, offset);
        drawBox(15, 5, offset);

        // writing undo
        offset = offset+17;
        drawBar(offset);
        drawBox(2, 3, offset);
        drawBox(3, 2, offset);
        drawBox(3, 3, offset);
        drawBox(3, 4, offset);
        drawBox(4, 1, offset);
        drawBox(4, 3, offset);
        drawBox(4, 5, offset);
        drawBox(5, 3, offset);
        drawBox(6, 3, offset);

        // writing redo
        offset = offset+8;
        drawBar(offset);
        drawBox(2, 3, offset);
        drawBox(5, 2, offset);
        drawBox(3, 3, offset);
        drawBox(5, 4, offset);
        drawBox(4, 1, offset);
        drawBox(4, 3, offset);
        drawBox(4, 5, offset);
        drawBox(5, 3, offset);
        drawBox(6, 3, offset);

        // writing decrease
        offset = offset+8;
        drawBar(offset);
        drawBox(2, 3, offset);
        drawBox(3, 3, offset);
        drawBox(4, 3, offset);
        drawBox(5, 3, offset);
        drawBox(6, 3, offset);

        // writing decrease
        offset = offset+8;
        drawBar(offset);
        drawBox(2, 3, offset);
        drawBox(3, 3, offset);
        drawBox(4, 3, offset);
        drawBox(5, 3, offset);
        drawBox(6, 3, offset);
        drawBox(4, 1, offset);
        drawBox(4, 2, offset);
        drawBox(4, 4, offset);
        drawBox(4, 5, offset);

        ubyte[] colors = [255,255,255,127,127,127,0,0,0,255,0,0,0,255,0,0,0,255,255,255,0,160,32,240,255,165,0,150,75,0];

        offset = offset+8;
        int tmpOffset = offset;
        for (int tmp=0; tmp < colors.length/3; tmp++){
            drawBar(tmpOffset);
            tmpOffset = tmpOffset + 8;
        }

        for (int tmp=0; tmp < colors.length/3; tmp++){
            changeColor(colors[tmp*3], colors[tmp*3+1], colors[tmp*3+2]);
            for (int i=1; i < 8; i++){
                for (int j=0; j < 7; j++){
                    drawBox(i, j, offset);
                }
            }
            offset = offset + 8;
        }

        changeColor(0,0,0);

    }

	void undo(){
		if (pos > 0){
      ubyte[] color = GetSetColor();
			ulong r1 = queuePos[pos-1];
			ulong r2 = queue.length;
			if (pos < queuePos.length) {
				r2 = queuePos[pos];
			}
			for(ulong i=r2-5; i > r1+3; i=i-5){
				changeColor(cast(ubyte)queue[i+2], cast(ubyte)queue[i+3], cast(ubyte)queue[i+4]);
				UpdateSurfacePixel(queue[i], queue[i+1]);
			}
			pos--;
			changeColor(color[0], color[1], color[2]);
		}
	}

	void redo(){
		if (pos < queuePos.length){
      ubyte[] color = GetSetColor();
			ulong r1 = 0;
			ulong r2 = 0;
			if (pos > 0) {
				r1 = queuePos[pos];
			}
			if (pos+1 == queuePos.length){
				r2 = queue.length;
			} else {
				r2 = queuePos[pos+1];
			}
			changeColor(cast(ubyte)queue[r1], cast(ubyte)queue[r1+1], cast(ubyte)queue[r1+2]);
			for(ulong i=r1+3; i < r2; i=i+5){
				UpdateSurfacePixel(queue[i], queue[i+1]);
			}
			pos++;
			changeColor(color[0], color[1], color[2]);
		}
	}

    void posIncrease(){
        pos++;
    }

    void cleanQueue(){
        if (queuePos.length > pos){
            queue.removeBack(queue.length-queuePos[pos]);
            queuePos.removeBack(queuePos.length-pos);
        }
    }

	void draw(int xPos, int yPos, int mouseDown){
		if (mouseDown == 1){
			cleanQueue();
			queuePos.insertBack(queue.length);
			queue.insertBack([red, green, blue]);
		}
		for(int w=-brushSize; w < brushSize; w++){
			for(int h=-brushSize; h < brushSize; h++){
				if (yPos+h >= menuSize*8 && yPos+h < height && xPos+w >= 0 && xPos+w < width){
					ubyte[] color = GetPixelColor(xPos+w,yPos+h);
					if(color[0] != red || color[1] != green || color[2] != blue){
                        queue.insertBack(xPos+w);
                        queue.insertBack(yPos+h);
                        queue.insertBack(GetPixelColor(xPos+w,yPos+h));
						UpdateSurfacePixel(xPos+w,yPos+h);
					}
				}
			}
		}
	}

    void drawOther(int xPos, int yPos, ubyte r, ubyte g, ubyte b, int size){
        for (int w=-size; w < size; w++){
            for (int h=-size; h < size; h++){
                if (yPos+h >= menuSize*8 && yPos+h < height && xPos+w >= 0 && xPos+w < width){
                    ubyte[] color = GetPixelColor(xPos+w,yPos+h);
                    if (color[0] != r || color[1] != g || color[2] != b){
                        UpdateSurfacePixelFromServer(xPos+w,yPos+h,r,g,b);
                    }
                }
            }
        }
    }

    int brushIncrease(){
        return brushSize++;
    }

    int brushDecrease(){
        if (brushSize > 1){
            return brushSize--;
        }
        return brushSize;
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