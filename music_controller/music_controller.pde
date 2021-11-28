import processing.serial.*;
import processing.sound.*;
import java.util.HashMap;

/*** Serial settings ***/
Serial port1, port2;
final short LF = 10; // ASCII linefeed '\n'

/*** Audio settings ***/
final String audioFiles[] = new String[] {
  "../tracks/piano1-lying.wav", "../tracks/piano1-sitting.wav", "../tracks/piano1-standing.wav", "../tracks/piano1-walking.wav",
  "../tracks/piano2-lying.wav", "../tracks/piano2-sitting.wav", "../tracks/piano2-standing.wav", "../tracks/piano2-walking.wav",
  "../tracks/drum-sitting.wav", "../tracks/drum-standing.wav", "../tracks/drum-walking.wav",
  "../tracks/violin1-standing.wav", "../tracks/violin1-walking.wav",
  "../tracks/violin2-standing.wav", "../tracks/violin2-walking.wav",
  "../tracks/trumpet.wav",
};

HashMap<String, Audio> tracks = new HashMap<String, Audio>(2 * audioFiles.length);
String drumTrackId = null;

/*** Mats ***/
Mat mat1, mat2;

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
    { "piano1-standing", "violin1-standing" }, // STANDING
    { "piano1-walking", "violin1-walking" }, // WALKING
    { "piano1-sitting" }, // SITTING
    { "piano1-lying" }, // LYING
  });
  mat2 = new Mat(port2, new String[][] {
    {}, // OFF
    { "piano2-standing", "violin2-standing" }, // STANDING
    { "piano2-walking", "violin2-walking" }, // WALKING
    { "piano2-sitting" }, // SITTING
    { "piano2-lying" }, // LYING
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
    case 'q': tracks.get("piano1-lying").toggle(); break;
    case 'w': tracks.get("piano1-sitting").toggle(); break;
    case 'e': tracks.get("piano1-standing").toggle(); break;
    case 'r': tracks.get("piano1-walking").toggle(); break;
    case 'u': tracks.get("piano2-lying").toggle(); break;
    case 'i': tracks.get("piano2-sitting").toggle(); break;
    case 'o': tracks.get("piano2-standing").toggle(); break;
    case 'p': tracks.get("piano2-walking").toggle(); break;
    case 'a': tracks.get("violin1-standing").toggle(); break;
    case 's': tracks.get("violin1-walking").toggle(); break;
    case 'k': tracks.get("violin2-standing").toggle(); break;
    case 'l': tracks.get("violin2-walking").toggle(); break;
    case 'z': tracks.get("drum-sitting").toggle(); break;
    case 'x': tracks.get("drum-standing").toggle(); break;
    case 'c': tracks.get("drum-walking").toggle(); break;
    case 'm': tracks.get("trumpet").toggle(); break;
    case '0': for (Audio audio : tracks.values()) audio.fadeOut();
  }
}

void serialEvent(Serial p) {
  try {
    if (p.available() <= 0) return;
    
    // process incoming message from Serial
    final String inMsg = p.readString();
    final JSONObject jsonMsg = parseJSONObject(inMsg);
    
    if (jsonMsg == null) {
      println("Invalid JSON format: " + inMsg);
      return;
    }
    
    final int bodyPosture = jsonMsg.getInt("bodyPosture");
    
    Mat current = null;
    
    if (p == mat1.getPort()) {
      current = mat1;
      println("Mat 1: " + bodyPosture);
    } else if (p == mat2.getPort()) {
      current = mat2;
      println("Mat 2: " + bodyPosture);
    }
    
    if (current == null) return;
    
    // determine which tracks to play based on current input from Arduino
    final String[] prevPlaying = current.getPlaying();
    if (current.update(bodyPosture)) {
      for (String trackId : prevPlaying) tracks.get(trackId).fadeOut();
      final String[] toPlay = current.getPlaying();
      for (String trackId : toPlay) tracks.get(trackId).fadeIn();
    }
    
    // the drum track is played based on states of both mats
    playDrumTrack();
    
    // trumpet bonus track when both mats are in the WALKING state
    if (mat1.getState() == 2 && mat2.getState() == 2) {
      if (tracks.get("trumpet").getVolume() < 1)
        tracks.get("trumpet").fadeIn();
    } else {
      if (tracks.get("trumpet").getVolume() > 0)
        tracks.get("trumpet").fadeOut();
    }
      
  } catch (RuntimeException err) {
    err.printStackTrace();
  }
}

void playDrumTrack() {
  String trackId = null;
  
  if (mat1.getState() == 1 || mat2.getState() == 1) trackId = "drum-standing";
  else if (mat1.getState() == 3 || mat2.getState() == 3) trackId = "drum-sitting";
  
  if (trackId == drumTrackId) return;
  
  if (drumTrackId != null) tracks.get(drumTrackId).fadeOut();
  
  if (trackId != null) tracks.get(trackId).fadeIn();
  
  drumTrackId = trackId;
}
