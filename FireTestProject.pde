/**
 * Smoke Particle System
 * by Daniel Shiffman.  
 * 
 * A basic smoke effect using a particle system. 
 * Each particle is rendered as an alpha masked image. 
 */

ParticleSystem ps;
ParticleSystem pd;
ParticleCollection emitters;
ArrayList locations;

Random generator;
float defaultWind = 0.021;
float force = 0;

void setup() {

  size(640, 480);
  colorMode(RGB, 255, 255, 255, 100);

  // Using a Java random number generator for Gaussian random numbers
  generator = new Random();

  // Create an alpha masked image to be applied as the particle's texture
  PImage msk = loadImage("texture.gif");
  PImage img = new PImage(msk.width,msk.height);
  for (int i = 0; i < img.pixels.length; i++) img.pixels[i] = color(255);
  img.mask(msk);
  
  locations = new ArrayList();
  locations.add(new PVector(width/2,height/2));
  locations.add(new PVector(width/3,height/3));
  
  emitters = new ParticleCollection(locations, img);
  
  smooth();
}

void draw() {
  background(75);

  // Calculate a "wind" force based on mouse horizontal position
  float dx = (mouseX - width/2) / 1000.0;
  float dy = (mouseY - height/2) / 1000.0;
  PVector mouseLoc = new PVector(mouseX, mouseY);
  
  if(keyPressed == true){
    int emitter = 0;
    if (key == '1'){
      emitter = 0; 
    }
    if (key == '2'){
      emitter = 1;
    } 
    emitters.fire(emitter);
  } /* 
  if (mousePressed) {
    force = dx;
  } else { 
    force = defaultWind;
  }
  */
  PVector wind = new PVector(0,force,0);
 
  emitters.add_force(wind);
  emitters.run();

}







