class Surface{
  	
	
	SDL_Window* window;
  this() {
  	// Create a surface...
  	window = SDL_CreateWindow("D SDL Painting",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        640,
                                        480, 
                                        SDL_WINDOW_SHOWN);

  }
  ~this(){
  	// Free a surface...
	
		SDL_DestroyWindow(window);
  }
}