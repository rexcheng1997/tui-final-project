import processing.core.*;
import processing.serial.*;

/* Body posture mapping from Arduino */
// 0 - OFF, 1 - STANDING, 2 - WALKING, 3 - SITTING, 4 - LYING
public class Mat {
  private Serial port;
  private int state; // enum mapping for body posture
  private String[][] m; // mapping from body posture to track ids
  
  public Mat(Serial p, String[][] trackIds) {
    this.port = p;
    this.state = 0;
    this.m = trackIds;
  }
  
  public Serial getPort() {
    return this.port;
  }
  
  public int getState() {
    return this.state;
  }
  
  public String[] getPlaying() {
    return this.m[this.state];
  }
  
  public boolean update(int s) {
    if (this.state == s) return false;
    this.state = s;
    return true;
  }
}
