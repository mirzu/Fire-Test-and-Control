// a class to create multiple particle emmiters.

class ParticleCollection {
  
  // Serial setup
  import processing.serial.*;
  Serial myPort;  // Create object from Serial class
  
  ArrayList emitters;
  ArrayList buttons;
  PImage img;
  int emittersCount;
  boolean[] firing = new boolean[4];
  int messageArray[] = new int[4];
  boolean[] button = new boolean[4]; 
  boolean[] buttonWasPressed = new boolean[4]; 
  
  ParticleCollection(ArrayList locations, ArrayList directions, PImage img_) {
    emitters = new ArrayList();
    buttons = new ArrayList();
    img = img_;
    for(int i = 0; i < locations.size(); i++){
      
      PVector loc = (PVector) locations.get(i);
      
      // add a new emitter and button for each location. 
      emitters.add(new ParticleSystem(0, (PVector) locations.get(i),img));
      buttons.add(new ImageButtons( (int) loc.x, (int) loc.y, img.height, img.width, img, img, img));
    }
  }
  
  void run() {
    
    // runtime for the emitter and button. 
    for (int i = emitters.size()-1; i >=0; i--) {
      // get our players.
      ParticleSystem e = (ParticleSystem) emitters.get(i);
      ImageButtons b = (ImageButtons) buttons.get(i);
      
      
      e.run();
      b.update();
      b.display();
      
      if(b.pressed() == true) {
        button[i] = true;
        buttonWasPressed[i] = true;
      } else {
        button[i] = false;
      }
        
      // add particles to emitter. 
      for (int p = 0; p < 2; p++) {
       e.addParticle();
      }  
    }
    
    for (int i = buttons.size()-1; i>=0; i--) {
      if (button[i] == true) {
        firing[i] = true;
      } else if (button[i] == false && buttonWasPressed[i] == true) {
        firing[i] = false;
        buttonWasPressed[i] = false;
      }
    }
   
    // if our firing variable is set fire that emitter.
    do_fire();
    
  }
  
  // Method to add a force vector to all particles currently in the system
  void add_force(PVector dir) {
    for (int i = emitters.size()-1; i >= 0; i--) {
      ParticleSystem p = (ParticleSystem) emitters.get(i);
      p.add_force(dir);
    }
  
  }
 
  // Method to add a direction to an emitter
  void addDir(int emitter, PVector dir) {
    ParticleSystem p = (ParticleSystem) emitters.get(emitter);
    p.addDir(dir);
  }
  
  // Public Method for client to add a force to a particular emitter.
  void startFiring(int emitter) {
    if (emitter >= 4){
      return;
    }
   firing[emitter] = true; 
  }
  // Public Method for client to add a force to a particular emitter.
  void stopFiring(int emitter) {
    if (emitter >= 4){
      return;
    }
   firing[emitter] = false; 
  }
  
  // Method to add a force vector to a particular emitter only. 
  void do_fire() {

    for (int i = 0; i < firing.length; i++) {
      if (firing[i] == true){ 
        ParticleSystem p = (ParticleSystem) emitters.get(i);
        p.fire();
      }
    }
    
    for (int i = 0; i<4; i++) {
      messageArray[i] = (firing[i] == true) ? 1 : 0;  
    }  
  }
  
  String getMessage() {    
    String message = "0 0 0 0";
    message = messageArray[0] + " " + messageArray[1] + " " + messageArray[2] + " " + messageArray[3] + '\r';
    return message;
  }  

}  
