module view;

public import model;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

class View{
    SDL_Window* window;
    this(Surface s){
    window = SDL_CreateWindow("D SDL Painting",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        s.getWidth(),
                                        s.getHeight(), 
                                        SDL_WINDOW_SHOWN);
    }


    ~this(){
        SDL_DestroyWindow(window);
    }
}
    