module model;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import std.file;
import std.stdio;
import std.array;
import std.string;
import std.container : Array;
import std.algorithm : reverse;

struct pixelChange {
	int x;
	int y;
	ubyte[] color;
}


struct action {
	ubyte[] nextColor;
	auto queue = Array!pixelChange();
}

class Surface{

    private:
    SDL_Surface* imgSurface;
    const string DEFAULT_FILENAME = "savedImage";
    int height;
    int width;
    int menuSize = 5;
    int brushSize=4;
    ubyte blue = 255;
    ubyte green = 255;
    ubyte red = 255;
    auto newQueue = Array!action();
    int pos = 0;

    public:
    this(int height = 530,int width = 745){
        // Create a surface...
        this.width = width;
        this.height = height;
        imgSurface = SDL_CreateRGBSurface(0,width,height,32,0,0,0,0);

    }
    ~this(){
        // Free a surface...
        SDL_FreeSurface(imgSurface);

    }

    auto getSurface(){
        return imgSurface;
    }

    auto getHeight(){
        return this.height;
    }

    auto getWidth(){
        return this.width;
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

    int brushIncrease(){
        return brushSize++;
    }

    int brushDecrease(){
        if (brushSize > 1){
            return brushSize--;
        }
        return brushSize;
    }

    void posIncrease(){
		pos++;
	}


    void UpdateSurfacePixelHelper(int xPos, int yPos, ubyte r, ubyte g, ubyte b) {
        SDL_LockSurface(imgSurface);
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int pixelArrayPos = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        pixelArray[pixelArrayPos..pixelArrayPos+3] = [b,g,r];
        SDL_UnlockSurface(imgSurface);
    }

    void UpdateSurfacePixel(int xPos, int yPos){
        UpdateSurfacePixelHelper(xPos,yPos,red,green,blue);
    }


    // Check a pixel color
    // Some OtherFunction()
    auto GetPixelColor(int xPos,int yPos){
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int pixelArrayPos = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        return pixelArray[pixelArrayPos..pixelArrayPos+3].dup().reverse;
    }

    void changeColor(ubyte[] color){
        red = color[0];
        green = color[1];
        blue = color[2];
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
		for(int i=0; i < width; i++){
			for(int j=0; j < height; j++){
				UpdateSurfacePixel(i, j);
			}
		}

		changeColor([0,0,0]);

		// draw menu bar divider line
		for(int i=0; i < width; i++){
			for (int j = 0; j < menuSize; j++) {
				UpdateSurfacePixel(i, (7*menuSize)+j);
			}
		}

		// writing save button
		int offset = 0;
		// s
		int l = 0;
		drawBox(l+2, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+2, 3, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+3, 4, offset);
		drawBox(l+1, 5, offset);
		drawBox(l+2, 5, offset);

		// a
		l = l+4;
		drawBox(l+2, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+3, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+3, 4, offset);
		drawBox(l+2, 5, offset);
		drawBox(l+3, 5, offset);

		// v
		l = l+4;
		drawBox(l+1, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+3, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+3, 4, offset);
		drawBox(l+2, 5, offset);

		// e
		l = l+4;
		drawBox(l+2, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+3, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+2, 4, offset);
		drawBox(l+2, 5, offset);
		drawBox(l+3, 5, offset);

		// writing open button
		offset = offset+17;
		drawBar(offset);
		offset++;

		// o
		l = 0;
		drawBox(l+2, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+4, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+4, 4, offset);
		drawBox(l+2, 5, offset);
		drawBox(l+3, 5, offset);

		// p
		l = l+5;
		drawBox(l+1, 2, offset);
		drawBox(l+2, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+3, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+2, 4, offset);
		drawBox(l+1, 5, offset);

		// e
		l = l+4;
		drawBox(l+2, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+3, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+2, 4, offset);
		drawBox(l+2, 5, offset);
		drawBox(l+3, 5, offset);

		// n
		l = l+4;
		drawBox(l+1, 2, offset);
		drawBox(l+2, 2, offset);
		drawBox(l+3, 2, offset);
		drawBox(l+1, 3, offset);
		drawBox(l+4, 3, offset);
		drawBox(l+1, 4, offset);
		drawBox(l+4, 4, offset);
		drawBox(l+1, 5, offset);
		drawBox(l+4, 5, offset);

		// writing undo
		offset = offset+19;
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
		for(int tmp=0; tmp < colors.length/3; tmp++){
			drawBar(tmpOffset);
			tmpOffset = tmpOffset + 8;
		}

		for(int tmp=0; tmp < colors.length/3; tmp++){
			changeColor(colors[tmp*3..tmp*3+3]);
			for(int i=1; i < 8; i++){
				for(int j=0; j < 7; j++){
					drawBox(i, j, offset);
				}
			}
			offset = offset + 8;
		}

		changeColor([0,0,0]);

	}

	action undo(){
		if (pos > 0){
            ubyte[] color = GetSetColor();
			auto change = newQueue[pos-1].queue;
			foreach(pixelChange p; change) {
				changeColor(p.color);
				UpdateSurfacePixel(p.x, p.y);
			}
			pos--;
			changeColor(color);
			return newQueue[pos];
		}
		return action([0,0,0], Array!pixelChange());
	}

	action redo(){
		if (pos < newQueue.length){
            ubyte[] color = GetSetColor();
			auto change = newQueue[pos].queue;
			changeColor(newQueue[pos].nextColor);
			foreach(pixelChange p; change) {
				UpdateSurfacePixel(p.x, p.y);
			}
			pos++;
			changeColor(color);
			return newQueue[pos-1];
		}
		return action([0,0,0], Array!pixelChange());
	}

    auto drawHelper(int xPos, int yPos, ubyte r, ubyte g, ubyte b, int size){
        auto changes = Array!pixelChange();
        for (int w=-size; w < size; w++){
            for (int h=-size; h < size; h++){
                if (yPos+h >= menuSize*8 && yPos+h < height && xPos+w >= 0 && xPos+w < width){
                    ubyte[] color = GetPixelColor(xPos+w,yPos+h);
                    if (color[0] != r || color[1] != g || color[2] != b){
                        changes.insertBack(pixelChange(xPos+w,yPos+h,color));
                        UpdateSurfacePixelHelper(xPos+w,yPos+h,r,g,b);
                    }
                }
            }
        }
		return changes;
    }

	void draw(int xPos, int yPos, int mouseDown){
		if (mouseDown == 1){
			if (newQueue.length > pos){
				newQueue.removeBack(newQueue.length-pos);
			}
			newQueue.insertBack(action([red, green, blue], Array!pixelChange()));
		}
		foreach(pixelChange p; drawHelper(xPos, yPos, red, green, blue, brushSize)) {
			newQueue[pos].queue.insertBack(p);
		}
	}

    // this is function to save the image in BMP format with the file name given by the user
    //bool save(string fileName)
    bool save(string fileName)
    {
        const(char)* fileNameWithExt = toStringz(fileName ~ ".bmp");
        if (SDL_SaveBMP(imgSurface, fileNameWithExt) == 1) {
            writeln("Error occured while saving surface: ", SDL_GetError());
            return false;
        }
        return true;
    }

    // this is function to save the image in BMP format with the file name given by the user
    //bool open(string fileName)
    bool open(string fileName)
    {
		const(char)* fileNameWithExt = toStringz(fileName ~ ".bmp");
        SDL_Surface* newImage = SDL_LoadBMP(fileNameWithExt);
        if (newImage == null) {
            writeln("Error occured while opening imaage ", SDL_GetError());
            return false;
        }
        imgSurface = newImage;
        return true;
    }

}