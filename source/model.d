module model;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;
import std.file;
import std.stdio;
import std.array;
import std.string;
import std.container : Array;
import std.algorithm : reverse;

/// struct that represents a single pixel change
struct pixelChange {
	int x;
	int y;
	ubyte[] color;
}

/// struct that represents a single action by the user from mouse down to mouse up
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
    auto offsetPos = Array!int();
    ubyte[] presetColors = [255,255,255,127,127,127,0,0,0,255,0,0,0,255,0,0,0,255,255,255,0,160,32,240,255,165,0,150,75,0];
    int brushSize=4;
    ubyte blue = 255;
    ubyte green = 255;
    ubyte red = 255;
    auto actionQueue = Array!action();
    int actionQueuePos = 0;

    public:
    this(int height = 530,int width = 745){
        // Create a surface...
        this.width = width;
        this.height = height;
        imgSurface = SDL_CreateRGBSurface(0,width,height,32,0,0,0,0);
        drawMenu();

    }
    ~this(){
        // Free a surface...
        SDL_FreeSurface(imgSurface);

    }

    /// Helper function to retrieve the surface
    auto getSurface(){
        return imgSurface;
    }

    /// Helper function to retrieve the height of the surface
    auto getHeight(){
        return this.height;
    }

    /// Helper function to retrieve the width of the surface
    auto getWidth(){
        return this.width;
    }

    /// Helper function to retrieve the relative number of pixels used to build the menu bar
    auto getMenuSize(){
        return menuSize;
    }

    /// Helper function to retrieve the offsets between sections of the menu bar
    auto getMenuOffsets(){
        return offsetPos;
    }

    /// Helper function to retrieve the color of one of the preset colors at a given index
    auto getPresetColor(int idx){
        return presetColors[idx*3..(idx*3)+3];
    }

    /// Helper function to retrieve the color the board is currently set to
    auto GetSetColor(){
        return [red,green,blue];
    }

    /// Helper function to retrieve the user's current brush size
    auto getBrushSize(){
        return brushSize;
    }

    /// Helper function to increase the brush size by 1
    int brushIncrease(){
        return brushSize++;
    }

    /// Helper function to decrease the brush size by 1 if it is greater than 1
    int brushDecrease(){
        if (brushSize > 1){
            return brushSize--;
        }
        return brushSize;
    }

    /// Helper function to increase the position in the undo/redo queue by 1
    void posIncrease(){
		actionQueuePos++;
	}

    /// Helper function to update a pixel value after it is provided expanded consitions
    void UpdateSurfacePixelHelper(int xPos, int yPos, ubyte r, ubyte g, ubyte b) {
        SDL_LockSurface(imgSurface);
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int pixelArrayPos = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        pixelArray[pixelArrayPos..pixelArrayPos+3] = [b,g,r];
        SDL_UnlockSurface(imgSurface);
    }

    /// Function to update a pixel value after it is provided a position and using the set color
    void UpdateSurfacePixel(int xPos, int yPos){
        UpdateSurfacePixelHelper(xPos,yPos,red,green,blue);
    }

    /// Function to retrieve the color of a pixel at a given position
    auto GetPixelColor(int xPos,int yPos){
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int pixelArrayPos = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        return pixelArray[pixelArrayPos..pixelArrayPos+3].dup().reverse;
    }

    /// Function to change the currently set color
    void changeColor(ubyte[] color){
        red = color[0];
        green = color[1];
        blue = color[2];
    }

    /// Function that is used to create the initial design of the board GUI when it is initialized
    void drawMenu(){

        /// Helper function that is used to draw simple boxes for easy menu bar creation
        void drawBox(int x, int y){
            for (int i = 0; i < menuSize; i++) {
                for (int j = 0; j < menuSize; j++) {
                    UpdateSurfacePixel((x*menuSize)+i, (y*menuSize)+j);
                }
            }
        }

        /// Helper function that is used to draw simple bars for easy menu bar creation
        void drawBar(int x){
            for (int i = 0; i < menuSize; i++) {
                for (int j = 0; j < (menuSize*8); j++) {
                    UpdateSurfacePixel((x*menuSize)+i, j);
                }
            }
        }
		
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
		int l = 0+offset;
		drawBox(l+2, 2);
		drawBox(l+3, 2);
		drawBox(l+2, 3);
		drawBox(l+1, 3);
		drawBox(l+3, 4);
		drawBox(l+1, 5);
		drawBox(l+2, 5);

		// a
		l = l+4;
		drawBox(l+2, 2);
		drawBox(l+3, 2);
		drawBox(l+1, 3);
		drawBox(l+3, 3);
		drawBox(l+1, 4);
		drawBox(l+3, 4);
		drawBox(l+2, 5);
		drawBox(l+3, 5);

		// v
		l = l+4;
		drawBox(l+1, 2);
		drawBox(l+3, 2);
		drawBox(l+1, 3);
		drawBox(l+3, 3);
		drawBox(l+1, 4);
		drawBox(l+3, 4);
		drawBox(l+2, 5);

		// e
		l = l+4;
		drawBox(l+2, 2);
		drawBox(l+3, 2);
		drawBox(l+1, 3);
		drawBox(l+3, 3);
		drawBox(l+1, 4);
		drawBox(l+2, 4);
		drawBox(l+2, 5);
		drawBox(l+3, 5);

		// writing open button
		offset = offset+17;
		drawBar(offset);

		// o
		l = 1+offset;
		drawBox(l+2, 2);
		drawBox(l+3, 2);
		drawBox(l+1, 3);
		drawBox(l+4, 3);
		drawBox(l+1, 4);
		drawBox(l+4, 4);
		drawBox(l+2, 5);
		drawBox(l+3, 5);

		// p
		l = l+5;
		drawBox(l+1, 2);
		drawBox(l+2, 2);
		drawBox(l+1, 3);
		drawBox(l+3, 3);
		drawBox(l+1, 4);
		drawBox(l+2, 4);
		drawBox(l+1, 5);

		// e
		l = l+4;
		drawBox(l+2, 2);
		drawBox(l+3, 2);
		drawBox(l+1, 3);
		drawBox(l+3, 3);
		drawBox(l+1, 4);
		drawBox(l+2, 4);
		drawBox(l+2, 5);
		drawBox(l+3, 5);

		// n
		l = l+4;
		drawBox(l+1, 2);
		drawBox(l+2, 2);
		drawBox(l+3, 2);
		drawBox(l+1, 3);
		drawBox(l+4, 3);
		drawBox(l+1, 4);
		drawBox(l+4, 4);
		drawBox(l+1, 5);
		drawBox(l+4, 5);

		// writing undo
        offsetPos.insertBack(offset*menuSize);
		offset = offset+20;
		drawBar(offset);
		drawBox(2+offset, 3);
		drawBox(3+offset, 2);
		drawBox(3+offset, 3);
		drawBox(3+offset, 4);
		drawBox(4+offset, 1);
		drawBox(4+offset, 3);
		drawBox(4+offset, 5);
		drawBox(5+offset, 3);
		drawBox(6+offset, 3);

		// writing redo
        offsetPos.insertBack(offset*menuSize);
		offset = offset+8;
		drawBar(offset);
		drawBox(2+offset, 3);
		drawBox(5+offset, 2);
		drawBox(3+offset, 3);
		drawBox(5+offset, 4);
		drawBox(4+offset, 1);
		drawBox(4+offset, 3);
		drawBox(4+offset, 5);
		drawBox(5+offset, 3);
		drawBox(6+offset, 3);

		// writing decrease
        offsetPos.insertBack(offset*menuSize);
		offset = offset+8;
		drawBar(offset);
		drawBox(2+offset, 3);
		drawBox(3+offset, 3);
		drawBox(4+offset, 3);
		drawBox(5+offset, 3);
		drawBox(6+offset, 3);

		// writing decrease
        offsetPos.insertBack(offset*menuSize);
		offset = offset+8;
		drawBar(offset);
		drawBox(2+offset, 3);
		drawBox(3+offset, 3);
		drawBox(4+offset, 3);
		drawBox(5+offset, 3);
		drawBox(6+offset, 3);
		drawBox(4+offset, 1);
		drawBox(4+offset, 2);
		drawBox(4+offset, 4);
		drawBox(4+offset, 5);

        // writing the boxes with different color options
        offsetPos.insertBack(offset*menuSize);
		offset = offset+8;
        offsetPos.insertBack(offset*menuSize);
		int tmpOffset = offset;
		for(int tmp=0; tmp < presetColors.length/3; tmp++){
			drawBar(tmpOffset);
			tmpOffset = tmpOffset + 8;
		}

		for(int tmp=0; tmp < presetColors.length/3; tmp++){
			changeColor(getPresetColor(tmp));
			for(int i=1+offset; i < 8+offset; i++){
				for(int j=0; j < 7; j++){
					drawBox(i, j);
				}
			}
			offset = offset + 8;
		}

		changeColor([0,0,0]);
	}

    /// Function to undo the last action in the queue according to the current position in the queue
	action undo(){
		if (actionQueuePos > 0){
            ubyte[] color = GetSetColor();
			auto change = actionQueue[actionQueuePos-1].queue;
			foreach(pixelChange p; change) {
				changeColor(p.color);
				UpdateSurfacePixel(p.x, p.y);
			}
			actionQueuePos--;
			changeColor(color);
			return actionQueue[actionQueuePos];
		}
		return action([0,0,0], Array!pixelChange());
	}

    /// Function to redo the next action in the queue according to the current position in the queue
	action redo(){
		if (actionQueuePos < actionQueue.length){
            ubyte[] color = GetSetColor();
			auto change = actionQueue[actionQueuePos].queue;
			changeColor(actionQueue[actionQueuePos].nextColor);
			foreach(pixelChange p; change) {
				UpdateSurfacePixel(p.x, p.y);
			}
			actionQueuePos++;
			changeColor(color);
			return actionQueue[actionQueuePos-1];
		}
		return action([0,0,0], Array!pixelChange());
	}

    /// Helper function to draw at a specific position with a specific color
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

    // Function to draw at a specific position with the default color
	void draw(int xPos, int yPos, int mouseDown){
		if (mouseDown == 1){
			if (actionQueue.length > actionQueuePos){
				actionQueue.removeBack(actionQueue.length-actionQueuePos);
			}
			actionQueue.insertBack(action([red, green, blue], Array!pixelChange()));
		}
		foreach(pixelChange p; drawHelper(xPos, yPos, red, green, blue, brushSize)) {
			actionQueue[actionQueuePos].queue.insertBack(p);
		}
	}

    /// This is function to save the image in BMP format with the file name given by the user
    bool save(string fileName)
    {
        const(char)* fileNameWithExt = toStringz(fileName ~ ".bmp");
		int saveResult = SDL_SaveBMP(imgSurface, fileNameWithExt);
		// Checking for any error in saving file
        if (saveResult == 1) {
            writeln("Error occured while saving surface: ", SDL_GetError());
            return false;
        }
        return true;
    }

	/// This is function to open the image in BMP format with the file name given by the user
	bool open(string fileName)
    {
		const(char)* fileNameWithExt = toStringz(fileName ~ ".bmp");
        SDL_Surface* newImage = SDL_LoadBMP(fileNameWithExt);

		// Checking for any error in opening file
        if (newImage == null) {
            writeln("Error occured while opening imaage ", SDL_GetError());
            return false;
        }
        imgSurface = newImage;
        return true;
    }

}
