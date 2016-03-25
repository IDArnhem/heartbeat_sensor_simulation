/**
 * Heartbeat sensor simulator. Use if you want to design for a heart 
 * sensor but you do not have one.
 *
 * Supersimple way of detecting heartbeats in an audio stream
 * and send an OSC message out to another piece of software. This is a 
 * simple way of building your designs without having to get or build a 
 * heartbeat sensor.
 *
 * (cc) 2016 Luis Rodil-Fernandez for students of IDA.
 */
import ddf.minim.*;
import ddf.minim.analysis.*;
import netP5.*;
import oscP5.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;

long heartbeatCount;

OscP5 oscd;
NetAddress destination;

float eRadius;

void setup()
{
  size(200, 200, P3D);
  smooth();

  minim = new Minim(this);
  song = minim.loadFile("heartbeat.mp3");
  song.play();

  beat = new BeatDetect();
  
  ellipseMode(RADIUS);
  eRadius = 20;

  heartbeatCount = 0;
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscd = new OscP5(this, 12345);
  
  /* destination is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. destination is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  destination = new NetAddress("127.0.0.1", 12345);
}

void drawHeart() {
  smooth();
  noStroke();
  beginShape();
    vertex(50, 15); 
    bezierVertex(50, -5, 90, 5, 50, 40); 
    vertex(50, 15); 
    bezierVertex(50, -5, 10, 5, 50, 40); 
  endShape();
}

void drawCircle() {
  ellipse(width/2, height/2, eRadius, eRadius);
}

void onHeartbeatDetected() {
  // change radius of circle as a simple visualization
  eRadius = 80;
  
  // create a message to indicate whomever is listening that we have detected a heartbeat.
  OscMessage msg = new OscMessage("/heartbeat");
  // send the message
  oscd.send(msg, destination); 
  
  heartbeatCount++;
  println("Heartbeats detected " + heartbeatCount);
}

void draw()
{
  background(0); // paint black background

  beat.detect(song.mix); // run the beat-detector on the audio stream so that it can analize it
  
  // check if a heartbeat was detected in the audio stream
  if ( beat.isOnset() ) { 
    onHeartbeatDetected();
  }

  // draw heart
  float a = map(eRadius, 20, 80, 60, 255);
  fill(60, 255, 0, a);
  pushMatrix();
    scale(80/eRadius);
    drawHeart();
    translate(width/2, height/2);
  popMatrix();
 
  // decrease radius (of heart visualization) for next drawing loop
  eRadius *= 0.95;
}