module tests;

import bindbc.sdl;
import controller:Client;
import server:Server;
import model:Surface;
import loader = bindbc.loader.sharedlib;
import std.stdio;

private SDLSupport ret;

@("check if file saved and opened successfully")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    s.UpdateSurfacePixel(100, 200);
    bool saveResult = s.save("testFile");
    assert(saveResult);

    bool openResult = s.open("testFile");
    assert(openResult);
}
