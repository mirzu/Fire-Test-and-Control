// a class to create multiple particle emmiters.

class ParticleCollection {
  
  ArrayList emitters;
  ArrayList buttons;
  PImage img;
  int emittersCount;
  int[] keys = new int[4]; 
  
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
    
    // deal with key press for each of the individual fire keys.
    if(keyPressed == true){
      int emitter = 0;
      if (key == '1'){
        keys[0] = 1;
      }
      if (key == '2'){
        keys[1] = 1;
      } 
      if (key == '3'){
        keys[2] = 1;
      }
      if (key == '4'){
        keys[3] = 1;
      }
      
      // fire the emmiter indexed at the key
      for (int i = 0; i < keys.length; i++) { 
        if (keys[i] == 1) {
         fire(i);
        }
      } 
    } else {
     for (int i = 0; i < keys.length; i++) { 
       keys[i] = 0;
     }
     myPort.write('0');
    }
    
    
    for (int i = emitters.size()-1; i >=0; i--) {
      // get our players.
      ParticleSystem e = (ParticleSystem) emitters.get(i);
      ImageButtons b = (ImageButtons) buttons.get(i);
      
      
      // runtime for the emitter and button. 
      e.run();
      b.update();
      b.display();
      if(b.pressed() == true) {
        fire(i);
      }
      
      // add particles to emitter. 
      for (int p = 0; p < 2; p++) {
       e.addParticle();
      }  
    } 
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
  // Method to add a force vector to a particular emitter only. 
  void fire(int emitter) {
   if (emitter > 4){
     return;
   }
   ParticleSystem p = (ParticleSystem) emitters.get(emitter);
   p.fire();
   if (emitter == 0) {
     myPort.write("yy");
   }
   if (emitter == 1) {
     myPort.write('W');
   }
   if (emitter == 2) {
     myPort.write('E');
   }
   if (emitter == 3) {
     myPort.write('R');
   }
  } 
  
}  
