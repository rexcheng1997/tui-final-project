import cc.arduino.*;
import org.firmata.*;

import processing.sound.*;

import processing.serial.*;
 
Serial myPort;

int numplayers = 1;

SoundFile soundfiles[] = new SoundFile[numplayers];
boolean track[] = new boolean[numplayers];
boolean trackStateChanged[] = new boolean[numplayers];
 
void setup()
{
  // In the next line, you'll need to change this based on your USB port name
  myPort = new Serial(this, "/dev/cu.usbmodem14101", 9600);
  myPort.bufferUntil('\n');
  
  // Put in the name of your sound file below, and make sure it is in the same directory
  soundfiles[0] = new SoundFile(this, "chinese_flute.mp3");
}

void serialEvent(Serial myPort) {
  // Data from the Serial port is read in serialEvent()
  //  using readString()
  
  if (myPort.available() > 0) {
    String input = trim(myPort.readString());
    boolean val;
    println("String is " + input);
    
    if (input != null) {
      for (int i = 0; i < min(input.length(), numplayers); i++) {
	// TODO: Intercept the boolean to play or stop music here
        val = (input.charAt(i) != '0');
        trackStateChanged[i] = (val != track[i]); // True if changed
        track[i] = val;
      }
    }
  }
}

void checkAndReplayAudio(SoundFile soundfile, int i) {
  println(trackStateChanged[i] + " " + track[i]);
  if (trackStateChanged[i]) {
    if (track[i]) {
      soundfile.stop();
      soundfile.play();
    } else {
      soundfile.stop();
    }
    // Reset the track to assume not changed if no readings come in
    trackStateChanged[i] = false;
  }
}

void draw() {
  serialEvent(myPort);
  
  for (int i = 0; i < numplayers; i++) {
    checkAndReplayAudio(soundfiles[i], i);
  }
  
  delay(5000);
}

void stop() {
  for (int i = 0; i < numplayers; i++) {
    soundfiles[i].stop();
  }
}
