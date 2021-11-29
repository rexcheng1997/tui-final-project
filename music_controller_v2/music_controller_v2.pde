import processing.serial.*;
import processing.sound.*;
import java.util.HashMap;

/*** Serial settings ***/
Serial port1, port2;
final short LF = 10; // ASCII linefeed '\n'

/*** Audio settings ***/
final String audioFiles[] = new String[] {
  "../tracks/infinity-pad1.wav", "../tracks/infinity-pad2.wav",
  "../tracks/mellow-poly1.wav", "../tracks/mellow-poly2.wav",
  "../tracks/warm-rain1.wav", "../tracks/warm-rain2.wav",
  "../tracks/melody.wav",
};

HashMap<String, Audio> tracks = new HashMap<String, Audio>(2 * audioFiles.length);
boolean disableSerial = false;

/*** Mats ***/
Mat mat1, mat2;
final String postures[] = new String[] { "OFF", "STANDING", "WALKING", "SITTING", "LYING" };

void setup() {
  // Serial setup
  printArray(Serial.list());
  /* CAUTION: which port to use depends on port connection! */
  port1 = new Serial(this, "/dev/tty.usbmodem14101", 9600);
  port2 = new Serial(this, "/dev/tty.usbmodem14401", 9600);
  port1.bufferUntil(LF);
  port2.bufferUntil(LF);
  
  // Mat setup
  mat1 = new Mat(port1, new String[][] {
    {}, // OFF
    { "infinity-pad1" }, // STANDING
    { "mellow-poly1" }, // WALKING
    { "warm-rain1" }, // SITTING
    { "warm-rain1" }, // LYING
  });
  mat2 = new Mat(port2, new String[][] {
    {}, // OFF
    { "infinity-pad2" }, // STANDING
    { "mellow-poly2" }, // WALKING
    { "warm-rain2" }, // SITTING
    { "warm-rain2" }, // LYING
  });
  
  // Audio setup
  for (int i = 0; i < audioFiles.length; i++) {
    final String name = audioFiles[i].substring(
      audioFiles[i].lastIndexOf('/') + 1,
      audioFiles[i].lastIndexOf('.')
    );
    
    Audio audio = new Audio(this, name, audioFiles[i]);    
    tracks.put(name, audio);
  }
}

void draw() {
  // control how the tracks play here
  for (Audio audio : tracks.values()) {
    audio.update();
  }
  delay(200);
}

void keyPressed() {
  switch (key) {
    case 'q': tracks.get("warm-rain1").toggle(); break;
    case 'w': tracks.get("infinity-pad1").toggle(); break;
    case 'e': tracks.get("mellow-poly1").toggle(); break;
    case 'i': tracks.get("warm-rain2").toggle(); break;
    case 'o': tracks.get("infinity-pad2").toggle(); break;
    case 'p': tracks.get("mellow-poly2").toggle(); break;
    case 'm': tracks.get("melody").toggle(); break;
    case '1':
      if (mat1.enabled) println("*** Disable Mat 1 ***");
      else println("*** Enable Mat 1 ***");
      mat1.enabled = !mat1.enabled;
      break;
    case '2':
      if (mat2.enabled) println("*** Disable Mat 2 ***");
      else println("*** Enable Mat 2 ***");
      mat2.enabled = !mat2.enabled;
      break;
    case '0':
      for (Audio audio : tracks.values()) audio.fadeOut();
      if (!disableSerial) println("*** Disable Serial events ***");
      else println("*** Enable Serial events ***");
      disableSerial = !disableSerial;
  }
}

void serialEvent(Serial p) {
  try {
    if (disableSerial || p.available() <= 0) return;
    
    // process incoming message from Serial
    final String inMsg = p.readString();
    final JSONObject jsonMsg = parseJSONObject(inMsg);
    
    if (jsonMsg == null) {
      println("Invalid JSON format: " + inMsg);
      return;
    }
    
    final int bodyPosture = jsonMsg.getInt("bodyPosture");
    
    Mat current = null;
    
    if (p == mat1.getPort() && mat1.enabled) {
      current = mat1;
      println("Mat 1: " + postures[bodyPosture]);
    } else if (p == mat2.getPort() && mat2.enabled) {
      current = mat2;
      println("Mat 2: " + postures[bodyPosture]);
    }
    
    if (current == null) return;
    
    // determine which tracks to play based on current input from Arduino
    final String[] prevPlaying = current.getPlaying();
    if (current.update(bodyPosture)) {
      for (String trackId : prevPlaying) tracks.get(trackId).fadeOut();
      final String[] toPlay = current.getPlaying();
      for (String trackId : toPlay) tracks.get(trackId).fadeIn();
    }
    
    // bonus track when both mats are in the WALKING state
    if (mat1.getState() == 2 && mat2.getState() == 2) {
      if (tracks.get("melody").getVolume() < 1)
        tracks.get("melody").fadeIn();
    } else {
      if (tracks.get("melody").getVolume() > 0)
        tracks.get("melody").fadeOut();
    }
      
  } catch (RuntimeException err) {
    err.printStackTrace();
  }
}
