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
// synapse address
NetAddress synapse;

// refresh for kinect 
int lastSynapseRefresh = 0;

// Serial setup
import processing.serial.*;

Serial myPort;  // Create object from Serial class
int Serialval;  // Data received from the serial port

ParticleCollection emitters;
ArrayList locations;
ArrayList directions;

hand leftHand;
hand rightHand;

Random generator;
float defaultWind = 0.021;
float forcex = 0;
float forcey = 0;

void setup() {
  
  // osc listener
  oscP5 = new OscP5(this, 12345);
  
  synapse = new NetAddress("127.0.0.1",12346);
  
  refreshSynapse();
  
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
  
  int gridx = width/8;
  int gridy = height/8;
  
  locations.add(new PVector( gridx * 2, gridy ));
  locations.add(new PVector( gridx * 3, gridy * 2 ));
  locations.add(new PVector( gridx * 5, gridy * 2 ));
  locations.add(new PVector( gridx* 6, gridy ));
  println(gridx * 6); 
  // set up the fire directions
  directions = new ArrayList();
  directions.add(new PVector(-0.25, -0.75));
  directions.add(new PVector(-0.25, -0.75));
  directions.add(new PVector(0.25, -0.75));
  directions.add(new PVector(0.25, -0.75));
    
  emitters = new ParticleCollection(locations, directions, img);
  
  for(int i = 0; i < directions.size(); i++){
    emitters.addDir(i, (PVector) directions.get(i));
  }
  smooth();
  
  oscP5.plug(this,"lefthand","/lefthand_pos_body");
  oscP5.plug(this,"righthand","/righthand_pos_body");
  
  leftHand = new hand(new PVector(0,0));
  rightHand = new hand(new PVector(0,0));
}

void draw() {
  background(75);
  fill(255);
  ellipse(width/2, height/2, 30, 30);
  
  rightHand.display();
  leftHand.display();
  //println( "mouse x: " + mouseX + ", mouse y:" + mouseY); 
  // Calculate a "wind" force based on mouse horizontal position
  float dx = (mouseX - width/2) / 1000.0;
  float dy = (mouseY - height/2) / 1000.0;
  PVector mouseLoc = new PVector(mouseX, mouseY);
  
  PVector wind = new PVector(forcex,forcey,0);
 
  emitters.add_force(wind);
  emitters.run();

}

public void lefthand(float x, float y, float z) {
  //println("### plug event method. received a message /lefthand_pos_body.");
  //println("x:" + lhx + " y:" + lhy + " z:" + lhz);
  leftHand.move(new PVector(x, y)); 
}

int lhx;
int lhy;
int rhx;
int rhy;
int maxLhx;
int maxLhy;
int maxRhx;
int maxRhy;

public void righthand(float x, float y, float z) {
  //println("### plug event method. received a message /righthand_pos_body.");
  //println("x:" + x + " y:" + y + " z:" + z);
  rightHand.move(new PVector(x, y)); 
}

void oscEvent(OscMessage msg) {
    
    int curentTime = millis();
    
    if (curentTime > (lastSynapseRefresh + 2000)){
      refreshSynapse();
      lastSynapseRefresh = millis();
    }
}

public void refreshSynapse() {
  OscMessage  triggerLeft = new OscMessage("/lefthand_trackjointpos");
  triggerLeft.add(1);
  oscP5.send(triggerLeft, synapse);
  
  OscMessage triggerRight  = new OscMessage("/righthand_trackjointpos");
  triggerRight.add(1);
  oscP5.send(triggerRight, synapse);
}

class hand {
  PVector position;
  int diameter = 25;
  
  hand (PVector setPosition) {
   position = setPosition;  
  }
  
  void move(PVector moveTo) {
    position = moveTo;
  }
  
  void display() {
    pushMatrix();
    translate(width/2, height/2);
    ellipse(position.x, position.y, diameter, diameter);
    popMatrix();
  }
}
