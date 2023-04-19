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

/// Surface is the model class that model the canvas details like height, width, pixel values, brush size and related methods that help operate on model.
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

	/// contructor for the class
    public:
    this(int height = 530,int width = 745){
        // Create a surface...
        this.width = width;
        this.height = height;
        imgSurface = SDL_CreateRGBSurface(0,width,height,32,0,0,0,0);
        drawMenu();

    }

	/// contructor for the class
    ~this(){
        // Free a surface...
        SDL_FreeSurface(imgSurface);

    }

    /**
    * This is a helper function to retrieve the surface.
    * Returns:
    *       SDL_Surface* = the surface
    */
    auto getSurface(){
        return imgSurface;
    }

    /**
    * This is a helper function to retrieve the height of the surface.
    * Returns:
    *       int = the height of the surface
    */
    auto getHeight(){
        return this.height;
    }

    /**
    * This is a helper function to retrieve the width of the surface.
    * Returns:
    *       int = the width of the surface
    */
    auto getWidth(){
        return this.width;
    }

    /// Helper function to retrieve the relative number of pixels used to build the menu bar
    /**
    * This is a helper function to retrieve the relative number of pixels used to build the menu bar.
    * Returns:
    *       int = the relative number of pixels used to build the menu bar
    */
    auto getMenuSize(){
        return menuSize;
    }

    /**
    * This is a helper function to retrieve the offsets between sections of the menu bar.
    * Returns:
    *       int[] = the offsets between sections of the menu bar
    */
    auto getMenuOffsets(){
        return offsetPos;
    }

    /**
    * This is a helper function to retrieve the color of one of the preset colors at a given index.
    * Params:
    *       idx = the index of the preset color to retrieve
    *
    * Returns:
    *       ubyte[] = the color of the preset color at the given index
    */
    auto getPresetColor(int idx){
        return presetColors[idx*3..(idx*3)+3];
    }

    /**
    * This is a helper function to retrieve the color the board is currently set to.
    * Returns:
    *       ubyte[] = the color the board is currently set to
    */
    auto GetSetColor(){
        return [red,green,blue];
    }

    /**
    * This is a helper function to retrieve the user's current brush size.
    * Returns:
    *       int = the brush size
    */
    auto getBrushSize(){
        return brushSize;
    }

    /**
    * This is a helper function to increase the brush size by 1.
    * Returns:
    *       int = the new brush size
    */
    int brushIncrease(){
        return brushSize++;
    }

    /**
    * This is a helper function to decrease the brush size by 1 if it is greater than 1.
    * Returns:
    *       int = the new brush size
    */
    int brushDecrease(){
        if (brushSize > 1){
            return brushSize--;
        }
        return brushSize;
    }

    /**
    * This is a helper function to update a pixel value after it is provided expanded consitions.
    * Params:
    *       xPos = x position of pixel
    *       yPos = y position of pixel
    *       r = red value of pixel
    *       g = green value of pixel
    *       b = blue value of pixel
    */
    void updateSurfacePixelHelper(int xPos, int yPos, ubyte r, ubyte g, ubyte b) {
        SDL_LockSurface(imgSurface);
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int pixelArrayPos = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        pixelArray[pixelArrayPos..pixelArrayPos+3] = [b,g,r];
        SDL_UnlockSurface(imgSurface);
    }

    /**
    * This is a function to update a pixel value after it is provided a position and using the set color.
    * Params:
    *       xPos = x position of pixel
    *       yPos = y position of pixel
    */
    void updateSurfacePixel(int xPos, int yPos){
        updateSurfacePixelHelper(xPos,yPos,red,green,blue);
    }

    /**
    * This is a function to retrieve the color of a pixel at a given position.
    * Params:
    *       xPos = x position of pixel
    *       yPos = y position of pixel
    *
    * Returns:
    *        ubyte[] = array of 3 ubyte values representing the color of the pixel
    */
    auto getPixelColor(int xPos,int yPos){
        ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
        int pixelArrayPos = yPos*imgSurface.pitch + xPos*imgSurface.format.BytesPerPixel;
        return pixelArray[pixelArrayPos..pixelArrayPos+3].dup().reverse;
    }

    /**
    * This is a function to change the currently set color.
    * Params:
    *        color = the color to change to
    */
    void changeColor(ubyte[] color){
        red = color[0];
        green = color[1];
        blue = color[2];
    }

    /**
    * This function is used to create the initial design of the board GUI when it is initialized.
    */
    void drawMenu(){

        /// Helper function that is used to draw simple boxes for easy menu bar creation
        void drawBox(int x, int y){
            for (int i = 0; i < menuSize; i++) {
                for (int j = 0; j < menuSize; j++) {
                    updateSurfacePixel((x*menuSize)+i, (y*menuSize)+j);
                }
            }
        }

        /// Helper function that is used to draw simple bars for easy menu bar creation
        void drawBar(int x){
            for (int i = 0; i < menuSize; i++) {
                for (int j = 0; j < (menuSize*8); j++) {
                    updateSurfacePixel((x*menuSize)+i, j);
                }
            }
        }
		
		// fill screen white
		for(int i=0; i < width; i++){
			for(int j=0; j < height; j++){
				updateSurfacePixel(i, j);
			}
		}

		changeColor([0,0,0]);

		// draw menu bar divider line
		for(int i=0; i < width; i++){
			for (int j = 0; j < menuSize; j++) {
				updateSurfacePixel(i, (7*menuSize)+j);
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

    /**
    * This is a function to undo the last action in the queue according to the current position in the queue.
    * Returns:
    *        action = an action struct that contains the action that was undone
    */
    action undo(){
		if (actionQueuePos > 0){
            ubyte[] color = GetSetColor();
			auto change = actionQueue[actionQueuePos-1].queue;
			foreach(pixelChange p; change) {
				changeColor(p.color);
				updateSurfacePixel(p.x, p.y);
			}
			actionQueuePos--;
			changeColor(color);
			return actionQueue[actionQueuePos];
		}
		return action([0,0,0], Array!pixelChange());
	}

    /**
    * This is a function to redo the next action in the queue according to the current position in the queue.
    * Returns:
    *        action = an action struct that contains the action that was redone
    */
    action redo(){
		if (actionQueuePos < actionQueue.length){
            ubyte[] color = GetSetColor();
			auto change = actionQueue[actionQueuePos].queue;
			changeColor(actionQueue[actionQueuePos].nextColor);
			foreach(pixelChange p; change) {
				updateSurfacePixel(p.x, p.y);
			}
			actionQueuePos++;
			changeColor(color);
			return actionQueue[actionQueuePos-1];
		}
		return action([0,0,0], Array!pixelChange());
	}

    /**
    * This is a helper function to draw at a specific position with a specific color.
    * Params:
    *        xPos = x position of the pixel
    *        yPos = y position of the pixel
    *        r = red value of the color
    *        g = green value of the color
    *        b = blue value of the color
    *
    * Returns:
    *        Array!pixelChange = an array of all the pixels that were changed and their original color
    */
    auto drawHelper(int xPos, int yPos, ubyte r, ubyte g, ubyte b, int size){
        auto changes = Array!pixelChange();
        for (int w=-size; w < size; w++){
            for (int h=-size; h < size; h++){
                if (yPos+h >= menuSize*8 && yPos+h < height && xPos+w >= 0 && xPos+w < width){
                    ubyte[] color = getPixelColor(xPos+w,yPos+h);
                    if (color[0] != r || color[1] != g || color[2] != b){
                        changes.insertBack(pixelChange(xPos+w,yPos+h,color));
                        updateSurfacePixelHelper(xPos+w,yPos+h,r,g,b);
                    }
                }
            }
        }
		return changes;
    }
    
    /**
    * This is a function to draw at a specific position with the default color.
    * Params:
    *       xPos = x position of the pixel to be drawn
    *       yPos = y position of the pixel to be drawn
    *       mouseDown = true if this is drawing from a mousedown (start of action) else false
    */
	void draw(int xPos, int yPos, bool mouseDown){
		if (mouseDown){
			if (actionQueue.length > actionQueuePos){
				actionQueue.removeBack(actionQueue.length-actionQueuePos);
			}
			actionQueue.insertBack(action([red, green, blue], Array!pixelChange()));
            actionQueuePos++;
		}
		foreach(pixelChange p; drawHelper(xPos, yPos, red, green, blue, brushSize)) {
			actionQueue[actionQueuePos-1].queue.insertBack(p);
		}
	}

	/**
    * This is function to save the image in BMP format with the file name given by the user.
    * Params:
    *       fileName = name of file to be saved
    *
    * Returns:
    *        bool = true if saved successfully else false
    */
    bool save(string fileName)
    {
        const(char)* fileNameWithExt = toStringz(fileName ~ ".bmp");
        SDL_Surface* newSurface = SDL_CreateRGBSurface(0,width,height-40,32,0,0,0,0);
        SDL_LockSurface(newSurface);
        ubyte* pixelArray = cast(ubyte*)newSurface.pixels;
        for (int i=0; i < width; i++){
            for (int j=0; j < height-(menuSize*8); j++){
                int pixelArrayPos = j*newSurface.pitch + i*newSurface.format.BytesPerPixel;
                pixelArray[pixelArrayPos..pixelArrayPos+3] = getPixelColor(i,j+(menuSize*8)).reverse;
            }
        }
        SDL_UnlockSurface(newSurface);
		int saveResult = SDL_SaveBMP(newSurface, fileNameWithExt);
		// Checking for any error in saving file
        if (saveResult == 1) {
            writeln("Error occured while saving surface: ", SDL_GetError());
            return false;
        }
        return true;
    }

	/**
    * This is function to open the image in BMP format with the file name given by the user
    * Params:
    *       fileName = name of file to be opened
    *
    * Returns:
    *        bool = true if opened successfully else false
    */
	bool open(string fileName)
    {
		const(char)* fileNameWithExt = toStringz(fileName ~ ".bmp");
        SDL_Surface* newImage = SDL_LoadBMP(fileNameWithExt);

		// Checking for any error in opening file
        if (newImage == null) {
            writeln("Error occured while opening imaage ", SDL_GetError());
            return false;
        }
        ubyte* pixelArray = cast(ubyte*)newImage.pixels;
        for (int i=0; i < width; i++){
            for (int j=(menuSize*8); j < height; j++){
                int pixelArrayPos = (j-(menuSize*8))*newImage.pitch + i*newImage.format.BytesPerPixel;
                ubyte[] color = pixelArray[pixelArrayPos..pixelArrayPos+3].dup().reverse;
                updateSurfacePixelHelper(i,j,color[0],color[1],color[2]);
            }
        }
        return true;
    }

}
