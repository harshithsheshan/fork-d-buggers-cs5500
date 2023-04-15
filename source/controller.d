module controller;

public import model;
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
        writeln("(",mSocket,")", buffer[0 .. received]);
        //writeln("Buffer printed");
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
            //writeln("Recieved buffer",fromServer);
            auto str = to!string(fromServer);
            //writeln("Printing raw",str);
            auto parts = str.split(' ');
            if(true){
                if (str.startsWith("_i"))
                {

                    if (parts[1] == "open"){
                        //writeln("received request to open ", parts[1]);
                        s.open();
                    }
                    else {
                        auto xPos = to!int(parts[1]);
                        auto yPos = to!int(parts[2]);
                        auto r = to!ubyte(parts[3]);
                        auto g = to!ubyte(parts[4]);
                        auto b = to!ubyte(parts[5]);
                        auto brushSize = to!int(parts[6]);
                        //writeln("performing : at %d %d %u %u %u %d".format(xPos,yPos,r,g,b,brushSize));
                        this.perform(xPos,yPos,r,g,b,brushSize);
                    }
                }
                else {
                    if (parts[0] != mSocket.localAddress.toString()){
                        auto pos = fromServer.indexOf("\0");
                        writeln(fromServer[0 .. pos]);
                    }
                }
            }
        }
    }

    void perform(int xPos, int yPos, ubyte r, ubyte g, ubyte b, int brushSize){
        //writeln("Got instructions for pixel %d %d".format(xPos,yPos));
        //s.draw(xPos,yPos,0,0);
        if (brushSize == -1){
            s.UpdateSurfacePixelFromServer(xPos,yPos,r,g,b);
        } else {
            s.drawOther(xPos,yPos,r,g,b,brushSize);
        }

    }

    void sendInsToServer(int xPos, int yPos, ubyte r, ubyte g, ubyte b, int brushSize){
        // Format the integers into a string with the correct format
        auto intString = format("%d %d %u %u %u %d ", xPos, yPos, r, g, b, brushSize);
        // Concatenate the "_i" prefix with the formatted integers
        auto buffer = "_i " ~ intString;
        while(buffer.length < 80){
            buffer ~= " ";
        }
        //write("auto instruction:",buffer);
        mSocket.send(buffer);
    }

    void sendOpenToServer(){
        auto buffer = "_i open ";
        mSocket.send(buffer);
    }

    void sendChatToServer(bool clientRunning){
        write(">");
        while(clientRunning){
            foreach (line; stdin.byLine){
                write("(me)>");
                // Send the packet of information
                mSocket.send( mSocket.localAddress.toString()~" : "~ line ~"\0");
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

        s.drawMenu();
		int size = s.getMenuSize();

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
                if (e.type == SDL_QUIT){
                    runApplication= false;
                }
                else if (e.type == SDL_MOUSEBUTTONDOWN){
                    int xPos = e.button.x;
					int yPos = e.button.y;

					if (yPos < 8*size){
						if (yPos < 7*size){
                            if (xPos < 17*size){
                                s.save();
								//writeln("save");
							} else if (xPos < 35*size && xPos >= 18*size){
                                s.open();
                                this.sendOpenToServer();
							} else if (xPos < 45*size && xPos >= 36*size){
								auto change = s.undo();
                                foreach(pixelChange p; change.queue) {
                                    ubyte[] color = p.color;
                                    //writeln("undo ",p.x,p.y, color[0], color[1], color[2]);
                                    this.sendInsToServer(p.x,p.y,color[0],color[1],color[2],-1);
                                }
								//writeln("undo");
							} else if (xPos < 53*size && xPos >= 46*size){
								auto change = s.redo();
                                ubyte[] color = change.nextColor;
                                foreach(pixelChange p; change.queue) {
                                    this.sendInsToServer(p.x,p.y,color[0],color[1],color[2],-1);
                                }
								//writeln("redo");
							} else if (xPos < 61*size && xPos >= 54*size){
								s.brushDecrease();
								//writeln("decrease");
							} else if (xPos < 69*size && xPos >= 62*size){
								s.brushIncrease();
								//writeln("increase");
							} else if (xPos >= 71*size){
								if ((xPos-(71*size)) % (8*size) < 6*size) {
									ubyte[] color = s.GetPixelColor(xPos,yPos);
									s.changeColor(color[0], color[1], color[2]);
									//writeln("color ", (xPos-(71*size)) / (8*size));
								}
							}
						}
					} else {
						drawing=true;
						s.draw(xPos,yPos,1);
                        auto rgb = s.GetSetColor();
                        auto brushSize = s.getBrushSize();
                        this.sendInsToServer(xPos,yPos,rgb[0],rgb[1],rgb[2],brushSize);
					}
                }else if (e.type == SDL_MOUSEBUTTONUP){
                    if (drawing){
						s.posIncrease();
					}
                    drawing=false;
                }else if (e.type == SDL_MOUSEMOTION && drawing){
                    // retrieve the position
                    int xPos = e.button.x;
                    int yPos = e.button.y;
                    // Loop through and update specific pixels
                    // NOTE: No bounds checking performed --
                    //       think about how you might fix this :)
                    s.draw(xPos,yPos,0);
                    // TODO Add colour and brush size
                    auto rgb = s.GetSetColor();
                    auto brushSize = s.getBrushSize();
                    this.sendInsToServer(xPos,yPos,rgb[0],rgb[1],rgb[2],brushSize);
                } else if (e.type == SDL_KEYDOWN) {
                    if ((e.key.keysym.mod & KMOD_CTRL) != 0) {
                        if (e.key.keysym.sym == SDLK_s) {
                            // Requesting user for file name
                            //writeln("Please enter file name:");
                            //s.save(readln.chomp());
                            s.save();
                        } else if(e.key.keysym.sym == SDLK_o) {
                            // Requesting user for file name
                            //writeln("Please enter file name:");
                            //s.open(readln.chomp());
                            s.open();
                            this.sendOpenToServer();
                        }
                    }
                }
            }

            // Blit the surace (i.e. update the window with another surfaces pixels
            //                       by copying those pixels onto the window).
            SDL_BlitSurface(s.imgSurface,null,SDL_GetWindowSurface(v.window),null);
            // Update the window surface
            SDL_UpdateWindowSurface(v.window);

        }


    }

}
