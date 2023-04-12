module controller;

public import surface;
public import view;
import std.stdio;
import std.string;
import std.conv;
import std.exception;
import std.socket;
import core.thread.osthread;
import std.algorithm;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

class Client{
    Socket mSocket;
    this(string host = "localhost", ushort port=50001){
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
        if (ret != sdlSupport){
            writeln("error loading SDL library");

            foreach ( info; loader.errors){
                writeln(info.error,':', info.message);
            }
        }
        if (ret == SDLSupport.noLibrary){
            writeln("error no library found");
        }
        if (ret == SDLSupport.badLibrary){
            writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
        }
        if (SDL_Init(SDL_INIT_EVERYTHING) !=0){
            writeln("SDL_Init: ", fromStringz(SDL_GetError()));
        }
        writeln("Starting client...attempt to create socket");
        // Create a socket for connecting to a server
        // Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
        // Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
        //       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
        mSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        // Socket needs an 'endpoint', so we determine where we
        // are going to connect to.
        // NOTE: It's possible the port number is in use if you are not
        //       able to connect. Try another one.
        mSocket.connect(new InternetAddress(host, port));
        writeln("Client conncted to server");
        // Our client waits until we receive at least one message
        // confirming that we are connected
        // This will be something like "Hello friend\0"
        // Handle initialization...
        // SDL_Init
        char[80] buffer;
        auto received = mSocket.receive(buffer);
        writeln("(incoming from server) ", buffer[0 .. received]);
        writeln("Buffer printed");
        s = new Surface();
        v = new View(s);
    }
    ~this(){
        // Handle SDL_QUIT
        mSocket.close();
        SDL_Quit();
        writeln("Ending application--good bye!");
    }

    // Member variables like 'const SDLSupport ret'
    // liklely belong here.

    const SDLSupport ret;
    Surface s;
    View v;

    void receiveChatFromServer(){
        while(true){
            // Note: It's important to recreate or 'zero out' the buffer so that you do not
            // 			 get previous data leftover in the buffer.
            char[80] buffer;
            auto fromServer = buffer[0 .. mSocket.receive(buffer)];
            writeln("Recieved buffer",fromServer);
            auto str = to!string(fromServer);
            writeln("Printing raw",str);

            if(true){
                if (str.startsWith("_i"))
                {
                    writeln("Debug has _i");
                    // Split the string into words using whitespace as the delimiter
                    auto parts = str.split(' ');
                    //writeln("printing split", parts[0 .. $]);
                    // Move to the second part of the split (the first integer)
                    //writeln("parts: ", parts[0 .. $]);
                    //parts.popFront();
                    // Extract the first integer
                    auto xPos = to!int(parts[1]);
                    // Move to the third part of the split (the second integer)
                    //parts.popFront();
                    //parts.popFront();
                    // Extract the second integer
                    auto yPos = to!int(parts[2]);
                    write("Debug extracted x and y");
                    this.perform(xPos,yPos);
                }
                else {
                    writeln("(from server)>",fromServer);
                }
            }
        }
    }

    void perform(int xPos, int yPos){
        writeln("Got instructions for pixel %d %d".format(xPos,yPos));
        int brushSize=4;
        for(int w=-brushSize; w < brushSize; w++){
            for(int h=-brushSize; h < brushSize; h++){
                s.UpdateSurfacePixel(xPos+w,yPos+h);
            }
        }
        SDL_BlitSurface(s.imgSurface,null,SDL_GetWindowSurface(v.window),null);
        // Update the window surface
        SDL_UpdateWindowSurface(v.window);
        // Delay f_ior 16 milliseconds
        // Otherwise the program refreshes too quickly
        SDL_Delay(16);
    }

    void sendInsToServer(int xPos, int yPos){
        // Format the integers into a string with the correct format
        auto intString = format("%d %d ", xPos, yPos);
        // Concatenate the "_i" prefix with the formatted integers
        auto buffer = "_i " ~ intString;
        write("auto instruction:",buffer);
        mSocket.send(buffer);
    }

    void sendChatToServer(bool clientRunning){
        write(">");
        while(clientRunning){
            foreach (line; stdin.byLine){
                write(">");
                // Send the packet of information
                mSocket.send(line);
            }
            // Now we'll immedietely block and await data from the server
        }

    }

    /// Purpose of this function is to receive data from the server as it is broadcast out. void receiveChatFromServer(){
    /// The client socket connected to a server

    void run(){
        writeln("Preparing to run client");
        writeln("(me)",mSocket.localAddress(),"<---->",mSocket.remoteAddress(),"(server)");
        // Buffer of data to send out
        // Choose '80' bytes of information to be sent/received

        bool clientRunning = true;

        // Spin up the new thread that will just take in data from the server

        new Thread({
            receiveChatFromServer();
        }).start();

        new Thread({
            sendChatToServer(clientRunning);
        }).start();


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
                    this.sendInsToServer(xPos,yPos);
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
