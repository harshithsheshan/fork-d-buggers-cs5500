module view;

public import model;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

/**
 * The `View` class represents a window for displaying graphics using SDL2.
 * It provides an interface for creating and managing an SDL2 window.
 *
 */
class View
{
    /**
     * A pointer to the underlying SDL window.
     *
     * This variable is managed by the `View` class and should not be
     * modified directly.
     */
    SDL_Window* window;

    /**
     * Constructs a new `View` object with the given `Surface`.
     *
     * This function creates an SDL2 window with the same dimensions as the
     * given `Surface`.
     *
     * Params:
     *     `s` : The `Surface` object to use as the basis for the window size.
     */
    this(Surface s)
    {
        window = SDL_CreateWindow("D SDL Painting",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        s.getWidth(),
        s.getHeight(),
        SDL_WINDOW_SHOWN);
    }

    /**
     * Destructs the `View` object and frees any resources it owns.
     *
     * This function destroys the underlying SDL2 window.
     */
    ~this()
    {
        SDL_DestroyWindow(window);
    }
}

    