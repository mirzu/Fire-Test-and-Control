// a class to create multiple particle emmiters.

class ParticleCollection {
  
  ArrayList emitters;
  ArrayList buttons;
  PImage img;
  int emittersCount;
  
  ParticleCollection(ArrayList locations, PImage img_) {
    emitters = new ArrayList();
    buttons = new ArrayList();
    img = img_;
    for(int i = 0; i < locations.size(); i++){
      
      PVector loc = (PVector) locations.get(i);
      println( img.height);
      // add a new emitter and button for each location. 
      emitters.add(new ParticleSystem(0, (PVector) locations.get(i),img));
      buttons.add(new ImageButtons( (int) loc.x, (int) loc.y, img.height, img.width, img, img, img));
    }
  }
  
  void run() {
    
    for (int i = emitters.size()-1; i >=0; i--) {
      ParticleSystem e = (ParticleSystem) emitters.get(i);
      ImageButtons b = (ImageButtons) buttons.get(i);
      e.run();
      b.update();
      b.display();
      if(b.pressed() == true) {
        println(i);
        fire(i);
      }
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
 
  // Method to add a force vector to a particular emitter only. 
  void fire(int emitter) {
   ParticleSystem p = (ParticleSystem) emitters.get(emitter);
   p.fire();
  } 
  
}  
