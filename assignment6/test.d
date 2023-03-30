import app;
@("Test the functioning of UpdateSurfacePixel test.d")
unittest{
		
		auto app = new app.SDLApp();
		app.s.UpdateSurfacePixel(20,20);
		assert(app.s.GetPixelColor(20,20)[0]==255);
		assert(app.s.GetPixelColor(20,20)[1]==128);
		assert(app.s.GetPixelColor(20,20)[2]==32);
}