/**
 * Fire Test Bed.
 * by Michal Minecki
 *
 * with Particle Code
 * by Daniel Shiffman.  
 * 
 * A Basic Particle System that also activates serial output to
 * an arduino. 
 *
 */
 
// osc setup
import oscP5.*;
import netP5.*;

OscP5 oscP5;

// Serial setup
import processing.serial.*;

Serial myPort;  // Create object from Serial class
int val;        // Data received from the serial port

ParticleCollection emitters;
ArrayList locations;
ArrayList directions;

Random generator;
float defaultWind = 0.021;
float forcex = 0;
float forcey = 0;

// it's late 
int quickTest = 0;

// synapse address
NetAddress myRemoteLocation;

void setup() {
  
  // osc listener
  oscP5 = new OscP5(this, 12345);
  
  myRemoteLocation = new NetAddress("127.0.0.1",12346);
  
  // Serial Setup
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  println(Serial.list()); // list available serial ports
  
  // window setup. 
  size(640, 480);
  colorMode(RGB, 255, 255, 255, 100);

  // Using a Java random number generator for Gaussian random numbers
  generator = new Random();
   
  // Create an alpha masked image to be applied as the particle's texture
  PImage msk = loadImage("texture.gif");
  PImage img = new PImage(msk.width,msk.height);
  for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = color(255, 218, 3);
  img.mask(msk);
  
   // set up the origins. 
  locations = new ArrayList();
 
  int locx = width/4; 
  int locy = height/4;
  
  locations.add(new PVector( locx, locy ));
  locations.add(new PVector( locx * 3, locy ));
  locations.add(new PVector( locx, locy * 3 ));
  locations.add(new PVector( locx * 3, locy * 3 ));
   
  // set up the fire directions
  directions = new ArrayList();
  directions.add(new PVector(-0.5, -0.5));
  directions.add(new PVector(0.5, -0.5));
  directions.add(new PVector(-0.5, 0.5));
  directions.add(new PVector(0.5, 0.5));
    
  emitters = new ParticleCollection(locations, directions, img);
  
  for(int i = 0; i < directions.size(); i++){
    emitters.addDir(i, (PVector) directions.get(i));
  }  
  
  smooth();
  
  oscP5.plug(this,"lefthand","/lefthand_pos_body");
  oscP5.plug(this,"righthand","/righthand_pos_body");
  translate(width/2, height/2);
}

void draw() {
  background(75);
  fill(255);
  ellipse(width/2, height/2, 30, 30);

  // Calculate a "wind" force based on mouse horizontal position
  float dx = (mouseX - width/2) / 1000.0;
  float dy = (mouseY - height/2) / 1000.0;
  PVector mouseLoc = new PVector(mouseX, mouseY);
  
  if (quickTest > 0) {
    emitters.fire(3);
  } 
  
  /*
  if (mousePressed) {
    forcex = dx;
    forcey = dy;
    println(dx + "," + dy);
  } else { 
    forcex = defaultWind;
    forcey = 0;
  }
  */
  PVector wind = new PVector(forcex,forcey,0);
 
  emitters.add_force(wind);
  emitters.run();

}

public void lefthand(float lhx, float lhy, float lhz) {
  println("### plug event method. received a message /lefthand_pos_body.");
  println("x:" + lhx + " y:" + lhy + " z:" + lhz);
}

public void righthand(float rhx, float rhy, float rhz) {
  println("### plug event method. received a message /lefthand_pos_body.");
  println("x:" + rhx + " y:" + rhy + " z:" + rhz);
}

void oscEvent(OscMessage msg) {
  
  if (msg.checkAddrPattern("/lefthand_pos_body")) {
   println("getting position");
  }
  
    OscMessage  triggerLeft = new OscMessage("/lefthand_trackjointpos");
    triggerLeft.add(1);
    oscP5.send(triggerLeft, myRemoteLocation);
    
    OscMessage triggerRight  = new OscMessage("/righthand_trackjointpos");
    triggerRight.add(1);
    oscP5.send(triggerRight, myRemoteLocation);
    
    println("win");
    //quickTest = 1; 
   
  
   msg.print();
  
}

