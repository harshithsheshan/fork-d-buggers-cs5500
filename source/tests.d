
module tests;

import bindbc.sdl;
import controller;
import server;
import model;
import loader = bindbc.loader.sharedlib;
import std.stdio;
import std.socket;
import core.thread.osthread;
import std.conv;
import std.algorithm;
import core.thread.osthread;
import std.range : repeat;
import std.exception;
import std.string;
private SDLSupport ret;
import std.container : Array;

@("check constructor")
unittest{
    ret = loadSDL();
    auto s = new Surface(400, 400);
    assert(s.getHeight() == 400);
    assert(s.getWidth() == 400);
}

@("check default constructor")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    assert(s.getHeight() == 530);
    assert(s.getWidth() == 745);
}

@("check getMenuSize, getMenuOffsets, getPresetColor")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    // Check that the menu size and offsets are correct
    assert(s.getMenuSize() == 5);
    assert(s.getMenuOffsets().length == 6);
    
    // Check that the preset colors are correct
    assert(s.getPresetColor(0) == [255, 255, 255]);
    assert(s.getPresetColor(1) == [127, 127, 127]);
    assert(s.getPresetColor(2) == [0, 0, 0]);
    assert(s.getPresetColor(3) == [255, 0, 0]);
    assert(s.getPresetColor(4) == [0, 255, 0]);
    assert(s.getPresetColor(5) == [0, 0, 255]);
    assert(s.getPresetColor(6) == [255, 255, 0]);
    assert(s.getPresetColor(7) == [160, 32, 240]);
    assert(s.getPresetColor(8) == [255, 165, 0]);
    assert(s.getPresetColor(9) == [150, 75, 0]);
}

@("check getSetColor and changeColor")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    // Check that the default color is black
    assert(s.GetSetColor() == [0, 0, 0]);

    // Check that the color can be changed
    s.changeColor([255, 0, 0]);
    assert(s.GetSetColor() == [255, 0, 0]);
}

@("check drawMenu")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    s.drawMenu();
    // Check that the menu is drawn correctly
    auto menuOffset = s.getMenuOffsets();
    foreach (offset; menuOffset) {
        assert(s.getPixelColor(offset, 0) == [0, 0, 0]);
    }
}

@("check getBrushSize, brushIncrease, brushDecrease")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    // Check that the default brush size is 4
    assert(s.getBrushSize() == 4);
    // Check that the brush size can be increased
    s.brushIncrease();
    assert(s.getBrushSize() == 5);
    s.brushIncrease();
    assert(s.getBrushSize() == 6);
    // Check that the brush size can be decreased
    s.brushDecrease();
    assert(s.getBrushSize() == 5);

    // Check that the brush size cannot be decreased below 1
    foreach (i; 0..5) {
        s.brushDecrease();
    }
    assert(s.getBrushSize() == 1);
}

@("check updateSurfacePixel and getPixelColor")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    // Check that a pixel can be updated
    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    s.updateSurfacePixel(100, 200);
    assert(s.getPixelColor(100, 200) == [0, 0, 0]);

    // Check that color can be changed and the pixel updated
    s.changeColor([255, 0, 0]);
    s.updateSurfacePixel(100, 200);
    assert(s.getPixelColor(100, 200) == [255, 0, 0]);

    // Check that updateSurfacePixelHelper works
    s.updateSurfacePixelHelper(100, 200, 0, 255, 0);
    assert(s.getPixelColor(100, 200) == [0, 255, 0]);

}

@("check undo single action")
unittest{
    ret = loadSDL();
    Surface s = new Surface();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    s.draw(100, 200, true);
    assert(s.getPixelColor(100, 200) == [0, 0, 0]);

    assert(s.getPixelColor(300, 200) == [255, 255, 255]);
    s.draw(300, 200, false);
    assert(s.getPixelColor(300, 200) == [0, 0, 0]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    assert(s.getPixelColor(300, 200) == [255, 255, 255]);
}

@("check undo multiple action")
unittest{
    ret = loadSDL();
    Surface s = new Surface();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    s.draw(100, 200, true);
    assert(s.getPixelColor(100, 200) == [0, 0, 0]);

    assert(s.getPixelColor(300, 200) == [255, 255, 255]);
    s.draw(300, 200, true);
    assert(s.getPixelColor(300, 200) == [0, 0, 0]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [0, 0, 0]);
    assert(s.getPixelColor(300, 200) == [255, 255, 255]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    assert(s.getPixelColor(300, 200) == [255, 255, 255]);
}

@("check undo overwritng pixel value")
unittest{
    ret = loadSDL();
    Surface s = new Surface();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    s.draw(100, 200, true);
    assert(s.getPixelColor(100, 200) == [0, 0, 0]);
    s.changeColor([255, 0, 0]);
    s.draw(100, 200, true);
    assert(s.getPixelColor(100, 200) == [255, 0, 0]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [0, 0, 0]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
}

@("check undo with empty queue")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    // Copy the value of every pixel in the surface
    auto pixels = Array!pixelChange();
    foreach (i; 0..s.getWidth()) {
        foreach (j; 0..s.getHeight()) {
            pixels.insertBack(pixelChange(i, j, s.getPixelColor(i, j)));
        }
    }

    s.undo();
    // Check that the pixels are unchanged
    for (int i = 0; i < pixels.length; i++) {
        assert(s.getPixelColor(pixels[i].x, pixels[i].y) == pixels[i].color);
    }

}

@("check redo")
unittest{
    ret = loadSDL();
    Surface s = new Surface();

    // Undo steps

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);
    s.draw(100, 200, true);
    assert(s.getPixelColor(100, 200) == [0, 0, 0]);
    s.changeColor([255, 0, 0]);
    s.draw(100, 200, true);
    assert(s.getPixelColor(100, 200) == [255, 0, 0]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [0, 0, 0]);

    s.undo();

    assert(s.getPixelColor(100, 200) == [255, 255, 255]);

    // Redo steps
    s.redo();
    assert(s.getPixelColor(100, 200) == [0, 0, 0]);
    s.redo();
    assert(s.getPixelColor(100, 200) == [255, 0, 0]);


}

@("check redo with last position in queue")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    s.draw(100, 200, true);
    // Copy the value of every pixel in the surface
    auto pixels = Array!pixelChange();
    foreach (i; 0..s.getWidth()) {
        foreach (j; 0..s.getHeight()) {
            pixels.insertBack(pixelChange(i, j, s.getPixelColor(i, j)));
        }
    }

    s.redo();
    // Check that the pixels are unchanged
    for (int i = 0; i < pixels.length; i++) {
        assert(s.getPixelColor(pixels[i].x, pixels[i].y) == pixels[i].color);
    }

}

@("check draw")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    // Check that a a brushSize x brushSize square is drawn
    int x = 100;
    int y = 200;
    s.draw(x, y, true);
    for (int w=-s.getBrushSize(); w < s.getBrushSize(); w++){
        assert(s.getPixelColor(x+w, y-s.getBrushSize()-1) == [255, 255, 255]);
        for (int h=-s.getBrushSize(); h < s.getBrushSize(); h++){
            assert(s.getPixelColor(x-s.getBrushSize()-1, y+h) == [255, 255, 255]);
            assert(s.getPixelColor(x+w, y+h) == [0, 0, 0]);
            assert(s.getPixelColor(x+s.getBrushSize(), y+h) == [255, 255, 255]);
        }
        assert(s.getPixelColor(x+w, y+s.getBrushSize()) == [255, 255, 255]);
    }

    // Check that you can overwrite the square with a different color
    s.changeColor([255, 0, 0]);
    s.draw(x, y, true);
    for (int w=-s.getBrushSize(); w < s.getBrushSize(); w++){
        assert(s.getPixelColor(x+w, y-s.getBrushSize()-1) == [255, 255, 255]);
        for (int h=-s.getBrushSize(); h < s.getBrushSize(); h++){
            assert(s.getPixelColor(x-s.getBrushSize()-1, y+h) == [255, 255, 255]);
            assert(s.getPixelColor(x+w, y+h) == [255, 0, 0]);
            assert(s.getPixelColor(x+s.getBrushSize(), y+h) == [255, 255, 255]);
        }
        assert(s.getPixelColor(x+w, y+s.getBrushSize()) == [255, 255, 255]);
    }

    // Check that brushSize and color changes affect the size and color of the square
    s.brushIncrease();
    s.changeColor([255, 0, 0]);
    x = 300;
    y = 400;
    s.draw(x, y, true);
    for (int w=-s.getBrushSize(); w < s.getBrushSize(); w++){
        assert(s.getPixelColor(x+w, y-s.getBrushSize()-1) == [255, 255, 255]);
        for (int h=-s.getBrushSize(); h < s.getBrushSize(); h++){
            assert(s.getPixelColor(x-s.getBrushSize()-1, y+h) == [255, 255, 255]);
            assert(s.getPixelColor(x+w, y+h) == [255, 0, 0]);
            assert(s.getPixelColor(x+s.getBrushSize(), y+h) == [255, 255, 255]);
        }
        assert(s.getPixelColor(x+w, y+s.getBrushSize()) == [255, 255, 255]);
    }
}

@("check if file saved and opened successfully")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    s.updateSurfacePixel(100, 200);
    bool saveResult = s.save("testFile");
    auto savedPixelColor = s.getPixelColor(100, 200);
    assert(saveResult);

    // when you open it update the surface pixel data with the opened file's pixel data
    bool openResult = s.open("testFile");
    auto openedPixelColor = s.getPixelColor(100, 200);
    assert(openResult);

    // this shows that the opened image has same pixel values as the saved one
    assert(savedPixelColor == openedPixelColor);

}

@("test networked chat")
unittest{
    string host = "localhost";
    ushort port = 50010;
    Server server = new Server(host,port);
    Socket clientS = new Socket(AddressFamily.INET, SocketType.STREAM);
    clientS.connect(new InternetAddress(host, port));
    auto newClientSocket = server.mListeningSocket.accept();
    newClientSocket.send("Hello friend ");

    char[80] buffer;
    auto received = clientS.receive(buffer);
    server.mListeningSocket.close();
    clientS.close();

    server.destroy();
    string msg = to!string(buffer);
    assert(msg.canFind("Hello friend"));

}


@("testing instruction sent to client successfully")
unittest{
    string host = "localhost";
    ushort port = 50011;
    Server server = new Server(host,port);
    Socket clientS = new Socket(AddressFamily.INET, SocketType.STREAM);
    clientS.connect(new InternetAddress(host, port));
    auto newClientSocket = server.mListeningSocket.accept();
    newClientSocket.send("Hello friend ");

    char[80] buffer;
    auto received = clientS.receive(buffer);
    server.mListeningSocket.close();
    clientS.close();

    server.destroy();
    string msg = to!string(buffer);
    assert(msg.canFind("Hello friend"));

}

