
import mysdlapp;
@("Test initialization of SDLApp and Surface test2.d")
unittest{
    SDLApp app = new SDLApp();
    assert(app.s.imgSurface != null);
    assert(app.s.window != null);
}