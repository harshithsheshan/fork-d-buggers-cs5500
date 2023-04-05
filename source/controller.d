module controller;

public import surface;
public import view;
import std.stdio;
import std.string;
import std.conv;
import std.exception;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

class SDLApp{
    this(){
        // Handle initialization...
        // SDL_Init
        version(Windows){
            writeln("Searching for SDL on Windows");
            ret = loadSDL("SDL2.dll");
        }
        version(OSX){
            writeln("Searching for SDL on Mac");
            ret = loadSDL();
        }
        version(linux){ 
            writeln("Searching for SDL on Linux");
            ret = loadSDL();
        }

        // Error if SDL cannot be loaded
        if(ret != sdlSupport){
            writeln("error loading SDL library");
        
            foreach( info; loader.errors){
                writeln(info.error,':', info.message);
            }
        }
        if(ret == SDLSupport.noLibrary){
            writeln("error no library found");    
        }
        if(ret == SDLSupport.badLibrary){
            writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
        }
        if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
        writeln("SDL_Init: ", fromStringz(SDL_GetError()));
        }
    s = new Surface();
    v = new View(s);
    }
    ~this(){
        // Handle SDL_QUIT
        SDL_Quit();
        writeln("Ending application--good bye!");
    }
        
    // Member variables like 'const SDLSupport ret'
    // liklely belong here.

    const SDLSupport ret;
    Surface s; 
    View v;
        
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
                } else if (e.type == SDL_KEYUP) {
                    if (e.key.keysym.sym == SDLK_LCTRL || e.key.keysym.sym == SDLK_RCTRL && e.key.keysym.sym == SDLK_s) {
                        // Requesting user for file name
                        writeln("Please enter file name:");
                        s.save(readln.chomp());
                    }
                }
            }

            // Blit the surace (i.e. update the window with another surfaces pixels
            //                       by copying those pixels onto the window).
            SDL_BlitSurface(s.imgSurface,null,SDL_GetWindowSurface(v.window),null);
            // Update the window surface
            SDL_UpdateWindowSurface(v.window);
            // Delay for 16 milliseconds
            // Otherwise the program refreshes too quickly
            SDL_Delay(16);
        }


    }
        
}
