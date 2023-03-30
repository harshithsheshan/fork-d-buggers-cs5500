/// Run with: 'dub'
public import sdlapp;
public import surface;

// Import D standard libraries
import std.stdio;
import std.string;
import std.conv;
import std.exception;


// Load the SDL2 library

void main(){
  SDLApp myApp = new SDLApp();
	myApp.MainApplicationLoop();
	
}