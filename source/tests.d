//module tests;
//
//import bindbc.sdl;
//import controller:SDLApp;
//import surface:Surface;
//import loader = bindbc.loader.sharedlib;
//
//@("check if file saved successfully")
//unittest{
//    auto app = new SDLApp();
//    auto imgSurface = new Surface();
//    imgSurface.UpdateSurfacePixel(100, 200);
//    bool saveResult = imgSurface.save("testFile");
//    assert(saveResult);
//}