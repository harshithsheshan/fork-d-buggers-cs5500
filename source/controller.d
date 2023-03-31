const SDLSupport ret;
 	Surface s; 
 		
 	void MainApplicationLoop(){
 		bool runApplication = true;
		// Flag for determining if we are 'drawing' (i.e. mouse has been pressed
		//                                                but not yet released)
		bool drawing = false;

		// Main application loop that will run until a quit event has occurred.
		// This is the 'main graphics loop'
		while(runApplication){
		
			SDL_Event e;
			// Handle events
			// Events are pushed into an 'event queue' internally in SDL, and then
			// handled one at a time within this loop for as many events have
			// been pushed into the internal SDL queue. Thus, we poll until there
			// are '0' events or a NULL event is returned.
			while(SDL_PollEvent(&e) !=0){
				if(e.type == SDL_QUIT){
					runApplication= false;
				}
				else if(e.type == SDL_MOUSEBUTTONDOWN){
					drawing=true;
				}else if(e.type == SDL_MOUSEBUTTONUP){
					drawing=false;
				}else if(e.type == SDL_MOUSEMOTION && drawing){
					// retrieve the position
					int xPos = e.button.x;
					int yPos = e.button.y;
					// Loop through and update specific pixels
					// NOTE: No bounds checking performed --
					//       think about how you might fix this :)
					int brushSize=4;
					for(int w=-brushSize; w < brushSize; w++){
						for(int h=-brushSize; h < brushSize; h++){
							s.UpdateSurfacePixel(xPos+w,yPos+h);
						}
					}
				}
			}

			// Blit the surace (i.e. update the window with another surfaces pixels
			//                       by copying those pixels onto the window).
			SDL_BlitSurface(s.imgSurface,null,SDL_GetWindowSurface(s.window),null);
			// Update the window surface
			SDL_UpdateWindowSurface(s.window);
			// Delay for 16 milliseconds
			// Otherwise the program refreshes too quickly
			SDL_Delay(16);
		}