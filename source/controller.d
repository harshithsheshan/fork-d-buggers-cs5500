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
import std.concurrency;
import std.range : repeat;

import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

/**
 * The purpose of the Client is to start an SDLApp GUI for each client and handle communication between model/view.
*/
class Client{

    private const SDLSupport ret;
    private Surface s;
    private View v;
    private Socket mSocket;
    private shared bool saveFlag = false;
    private shared bool openFlag = false;
    private shared string filename = "downloadedImage";


    /**
    * This is the client constructor.
    * Params:
    *       host = host for the client
    *       port = port number for the client
    */
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
        s = new Surface();
        v = new View(s);
    }

    /**
    * This is the client destructor.
    */
    ~this(){
        // Handle SDL_QUIT
        mSocket.send("XX");
        mSocket.close();
        SDL_Quit();
        writeln("Ending application--good bye!");
    }
    /**
    * This function returns the Socket object of the client.
    *   Returns:
    *       Socket = Socket assigned to the client.
    */
    Socket getSocket(){
        return mSocket;
    }

    /**
    * This function runs on a new thread and recieves instructions and chat messages
    * sent from the server. Based on the type of message it recieves it then interprets
    * if its a message or an instruction and performs the instructions.
    *
    */
    void receiveChatFromServer(){
        while(true){
            // Note: It's important to recreate or 'zero out' the buffer so that you do not
            // 			 get previous data leftover in the buffer.
            char[80] buffer;
            auto fromServer = buffer[0 .. mSocket.receive(buffer)];
            auto str = to!string(fromServer);
            auto parts = str.split(' ');
            if (true){
                if (str.startsWith("_i"))
                {
                    if (parts[1] == "open"){
                        s.open(parts[2]);
                    }
                    else {
                        auto xPos = to!int(parts[1]);
                        auto yPos = to!int(parts[2]);
                        auto r = to!ubyte(parts[3]);
                        auto g = to!ubyte(parts[4]);
                        auto b = to!ubyte(parts[5]);
                        auto brushSize = to!int(parts[6]);
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

    /**
    * This function is invoked whenever the controller/client recieves an instruction from the server.
    * Based on the information recieved from the server changes are made to the model to maintain sycn
    * between clients.
    * Params:
    *       xPos = x coordinate
    *       yPos = y coordinate
    *       r = Red quotient of updated pixel.
    *       g = Green quotient of updated pixel.
    *       b = Blue quotient of updated pixel.
    *       brushSize = Brush size of the change performed.
    */
    void perform(int xPos, int yPos, ubyte r, ubyte g, ubyte b, int brushSize){
        if (brushSize == -1){
            s.updateSurfacePixelHelper(xPos,yPos,r,g,b);
        } else {
            s.drawHelper(xPos,yPos,r,g,b,brushSize);
        }

    }

    /**
    * This function sends instruction to the server whenever a change is made to the model by the user.
    * Params:
    *       xPos = x coordinate
    *       yPos = y coordinate
    *       ubyte[] =  [r,g,b]
    *       r = Red quotient of updated pixel.
    *       g = Green quotient of updated pixel.
    *       b = Blue quotient of updated pixel.
    *       brushSize = Brush size of the change performed.
    */
    void sendInsToServer(int xPos, int yPos, ubyte[] color, int brushSize){
        // Format the integers into a string with the correct format
        auto intString = format("%d %d %u %u %u %d ", xPos, yPos, color[0], color[1], color[2], brushSize);
        // Concatenate the "_i" prefix with the formatted integers
        auto buffer = format("_i %s%s", intString, repeat('-', 77 - intString.length));
        mSocket.send(buffer);
    }

    /**
    * This function sends the instructions to open a file with the file name given by the
    * user so that all the client open the same file synchronously.
    *
    */
    void sendOpenToServer(string filename){
        auto buffer = "_i open " ~ filename ~ " ";
        mSocket.send(buffer);
    }


    /**
    * This function handles user input in the terminal and performs action depending on the type of action.
    */
    void handleUserInput(){
        write(">");
        while(true){
            foreach (line; stdin.byLine){
                write(">");
                // checking if the save command is initiated
                if (saveFlag) {
                    filename = to!string(line);
                    s.save(filename);
                    saveFlag = false;
                } else if (openFlag) {
                    // checking if the open command is initiated
                    filename = to!string(line);
                    s.open(filename);
                    this.sendOpenToServer(filename);
                    openFlag = false;
                } else {
                    // Send the packet of information as chat
                    mSocket.send(mSocket.localAddress.toString()~" : "~ line ~"\0");
                }
            }
        }

    }

    /**
    * Purpose of this function is to receive data from the server as it is broadcast out.
    */
    void run(){
        writeln("Preparing to run client");
        writeln("(me)",mSocket.localAddress(),"<---->",mSocket.remoteAddress(),"(server)");
        // Buffer of data to send out
        // Choose '80' bytes of information to be sent/received
        // Spin up the new thread that will just take in data from the server
        new Thread({
            receiveChatFromServer();
        }).start();

        // Spin up the new thread that will just handle user input on the handle like chats, filename for save/open command
        new Thread({
            handleUserInput();
        }).start();


        bool runApplication = true;
        // Flag for determining if we are 'drawing' (i.e. mouse has been pressed
        //                                                but not yet released)
        bool drawing = false;

        int size = s.getMenuSize();
        auto offsets = s.getMenuOffsets();

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
                            if (xPos < offsets[0]){
                                // setting the indicator for save command to execute
                                writeln("Please enter file name:");
                                saveFlag = true;
                            } else if (xPos < offsets[1] && xPos >= offsets[0]+size){
                                // setting the indicator for open command to execute
                                writeln("Please enter file name:");
                                openFlag = true;
                            } else if (xPos < offsets[2] && xPos >= offsets[1]+size){
                                // checking if the colour was made.
                                auto change = s.undo();
                                foreach (pixelChange p; change.queue) {
                                    ubyte[] color = p.color;
                                    this.sendInsToServer(p.x,p.y,color,-1);
                                }
                            } else if (xPos < offsets[3] && xPos >= offsets[2]+size){
                                // checking if the colour was made.
                                auto change = s.redo();
                                ubyte[] color = change.nextColor;
                                foreach (pixelChange p; change.queue) {
                                    this.sendInsToServer(p.x,p.y,color,-1);
                                }
                            } else if (xPos < offsets[4] && xPos >= offsets[3]+size){
                                // checking if the button to decrease brush size was clicked.
                                s.brushDecrease();
                            } else if (xPos < offsets[5] && xPos >= offsets[4]+size){
                                // checking if the button to increase brush size was clicked.
                                s.brushIncrease();
                            } else if (xPos > offsets[5]+size){
                                if ((xPos-(offsets[5]+size)) % (8*size) < 7*size) {
                                    s.changeColor(s.getPresetColor((xPos-(offsets[5]+size)) / (8*size)));
                                }
                            }
                        }
                    } else {
                        drawing=true;
                        s.draw(xPos,yPos,1);
                        auto rgb = s.GetSetColor();
                        auto brushSize = s.getBrushSize();
                        this.sendInsToServer(xPos,yPos,rgb,brushSize);
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
                    auto rgb = s.GetSetColor();
                    auto brushSize = s.getBrushSize();
                    this.sendInsToServer(xPos,yPos,rgb,brushSize);
                } else if (e.type == SDL_KEYDOWN) {
                    if ((e.key.keysym.mod & KMOD_CTRL) != 0) {
                        if (e.key.keysym.sym == SDLK_s) {
                            // save command initiation when user press CTRL + S
                            writeln("Please enter file name:");
                            saveFlag = true;
                        } else if (e.key.keysym.sym == SDLK_o) {
                            // save command initiation when user press CTRL + O
                            writeln("Please enter file name:");
                            openFlag = true;
                        }
                    }
                }
            }

            // Blit the surace (i.e. update the window with another surfaces pixels
            //                       by copying those pixels onto the window).
            SDL_BlitSurface(s.getSurface,null,SDL_GetWindowSurface(v.window),null);
            // Update the window surface
            SDL_UpdateWindowSurface(v.window);

        }
    }
}
