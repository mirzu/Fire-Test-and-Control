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
OscP5 iphone;
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

joint torso;
joint head;
hand leftHand;
hand rightHand;

Random generator;
float defaultWind = 0.021;
float forcex = 0;
float forcey = 0;

//need to have a font
PFont font;

void setup() {
  
  // osc listener
  oscP5 = new OscP5(this, 12345);
  iphone = new OscP5(this, 10000);
  
  synapse = new NetAddress("127.0.0.1",12346);
  
  refreshSynapse();
  
  // Serial Setup
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  //println(Serial.list()); // list available serial ports
  
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
  //println(gridx * 6); 
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
  oscP5.plug(this,"torso", "/torso_pos_body");
  oscP5.plug(this,"head", "/head_pos_body");
  
  for(int i = 0; i < 5; i++){
    println("Duck");
    String path = "/osc/button" + Integer.toString(i);
    println(path);
    iphone.plug(this,"iphoneButton", path);
  }
   
  head = new joint(new PVector(0,0), "head");
  torso = new joint(new PVector(0,0), "torso");
  leftHand = new hand(new PVector(0,0), "left");
  rightHand = new hand(new PVector(0,0), "right");
  
   //font = loadFont("AndaleMono-14.v1w");
   //textFont(font); 
}

void draw() {
  background(75);
  fill(255);
  ellipse(width/2, height/2, 30, 30);
  
  rightHand.display();
  leftHand.display();
  torso.display();
  head.display();
  
  if (iphonebutton > 0){
    println("iphonebutton: "+iphonebutton);
    emitters.fire(iphonebutton-1);
  }
  
  //println( "mouse x: " + mouseX + ", mouse y:" + mouseY); 
  // Calculate a "wind" force based on mouse horizontal position
  float dx = (mouseX - width/2) / 1000.0;
  float dy = (mouseY - height/2) / 1000.0;
  PVector mouseLoc = new PVector(mouseX, mouseY);
  
  PVector wind = new PVector(forcex,forcey,0);
 
  emitters.add_force(wind);
  emitters.run();

}

int lhx;
int lhy;
int rhx;
int rhy;
int maxLhx;
int maxLhy;
int maxRhx;
int maxRhy;

int iphonebutton;

public void iphoneButton(int value){
  println(value);
 iphonebutton = value;
}

public void torso(float x, float y, float z) {
  //println("### plug event method. received a message /lefthand_pos_body.");
  //println("x:" + x + " y:" + y + " z:" + z);
  torso.move(new PVector(x, -y)); 
}

public void head(float x, float y, float z) {
  //println("### plug event method. received a message /lefthand_pos_body.");
  //println("x:" + x + " y:" + y + " z:" + z);
  head.move(new PVector(x, -y)); 
}

public void lefthand(float x, float y, float z) {
  //println("### plug event method. received a message /lefthand_pos_body.");
  //println("x:" + lhx + " y:" + lhy + " z:" + lhz);
  leftHand.move(new PVector(x, -y)); 
}

public void righthand(float x, float y, float z) {
  //println("### plug event method. received a message /righthand_pos_body.");
  //println("x:" + x + " y:" + y + " z:" + z);
  rightHand.move(new PVector(x, -y)); 
}

void oscEvent(OscMessage msg) {
    //msg.print();
    int curentTime = millis();
    
    if (curentTime > (lastSynapseRefresh + 2000)){
      refreshSynapse();
      lastSynapseRefresh = millis();
    }
}

public void refreshSynapse() {
  OscMessage  triggerHead = new OscMessage("/head_trackjointpos");
  triggerHead.add(1);
  oscP5.send(triggerHead, synapse);
  
  OscMessage  triggerTorso = new OscMessage("/torso_trackjointpos");
  triggerTorso.add(1);
  oscP5.send(triggerTorso, synapse);
  
  OscMessage  triggerLeft = new OscMessage("/lefthand_trackjointpos");
  triggerLeft.add(1);
  oscP5.send(triggerLeft, synapse);
  
  OscMessage triggerRight  = new OscMessage("/righthand_trackjointpos");
  triggerRight.add(1);
  oscP5.send(triggerRight, synapse);
}

class joint {
  PVector position;
  float range = 10;
  int diameter = 25;
  String side;
  PVector torsoPos = new PVector(0,0,0);
  PVector centerLine = new PVector(0,10,0);
  
  joint (PVector setPosition, String setSide) {
   side = setSide;
   position = setPosition; 
  }
  
  void move(PVector moveTo) {
    position = moveTo;
    position.div(range);
  }
  
  PVector position() {
    return position;
  }
  
  void getTorso(PVector getTorso) {
    torsoPos = getTorso; 
  }
  
  void display() {
    float a = PVector.angleBetween(centerLine, position);
    //println(degrees(a));
    
    pushMatrix();
    translate(width/2, height/2);
    ellipse(position.x, position.y, diameter, diameter);
    
    popMatrix();
  }
}

class hand extends joint {
  float maxX= 1;
  float maxY = 1;
  float minX = 1;
  float minY = 1;
  PVector distance = new PVector(0,0,0);

  hand (PVector setPosition, String setSide) {
   super(setPosition, setSide);
  }
  
  void display() {
    //println(position.mag());
    
    if(position.x > maxX) {
      maxX = position.x;
    }
    if(position.y > maxY) {
      maxY = position.y;
    }
    if(position.x < minX) {
      minX = position.x;
    }
    if(position.y < minY) {
      minY = position.y;
    }
    
    if (side == "right" && position.x != 0){
      if (position.x >= maxX-range && position.x <= maxX+range){
        emitters.fire(2);
      }
      if (position.y >= minY-range && position.y <= minY+range){
        emitters.fire(3);
      }  
    }
    
    if (side == "left" && position.x != 0){
      //println(minY);
      if (position.x >= minX-range && position.x <= minX+range){
        emitters.fire(1);
      }
      if (position.y >= minY-range && position.y <= minY+range){
        emitters.fire(0);
      } 
  
    }
   
    super.display();
    float a = position.mag();
    if (side == "left") {
      text( "x:" + position.x + " y:"+ position.y +  "mag: " + a + " side: " + side, 5, 10  );
    }     
    pushMatrix();
    translate(width/2, height/2);
    popMatrix();  
  }
}
