import processing.core.*;
import processing.sound.*;

public class Audio {
  private PApplet that;
  private SoundFile audio;
  private String id;
  private float volume;
  private boolean fadeIn, fadeOut;
  private final static float STEP = (float) 0.2;
  
  public Audio(PApplet sketch, String name, String path) {
    this.that = sketch;
    this.audio = new SoundFile(sketch, path);
    this.audio.loop(1, 0); // set the audio to loop but muted
    this.id = name;
    this.volume = 0;
    this.fadeIn = false;
    this.fadeOut = false;
  }
  
  public void fadeIn() {
    this.fadeIn = true;
    this.fadeOut = false;
    PApplet.println(this.id + " is fading IN");
  }
  
  public void fadeOut() {
    this.fadeOut = true;
    this.fadeIn = false;
    PApplet.println(this.id + " is fading OUT");
  }
  
  public void update() {
    if (this.fadeIn) {
      this.volume += STEP;
      this.audio.amp(Math.min(this.volume, 1));
      if (this.volume >= 1) {
        this.fadeIn = false;
        this.volume = 1;
        PApplet.println(this.id + " sets to full volume");
      }
    }
    if (this.fadeOut) {
      this.volume -= STEP;
      this.audio.amp(Math.max(this.volume, 0));
      if (this.volume <= 0) {
        this.fadeOut = false;
        this.volume = 0;
        PApplet.println(this.id + " is muted");
      }
    }
  }
  
  public void toggle() {
    if (this.volume == 0) {
      this.fadeIn();
    } else if (this.volume == 1) {
      this.fadeOut();
    }
  }
}
