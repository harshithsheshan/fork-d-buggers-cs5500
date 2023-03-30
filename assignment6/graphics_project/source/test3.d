
import mysdlapp;
@("Test the functioning of GetPixelColor in test3.d")
unittest{
		
		SDLApp app = new SDLApp();
		assert(app.s.GetPixelColor(0,0)[0]==0);
		assert(app.s.GetPixelColor(0,0)[1]==0);
		assert(app.s.GetPixelColor(0,0)[2]==0);
}