import processing.serial.*;

import processing.opengl.*;
import processing.video.*;

// parameters
public float m = 6;
public float n1 = 1;
public float n2 = 1;
public float n3 = 1;
public float a = 1;
public float b = 1;
public float scale;
public float NP;

Capture video;
int MAX = 20;

Serial myPort;    // The serial port:
int lf = 10;  // ASCII linefeed
int baudRate = 9600; //make sure this matches the baud rate in the arduino program.

int cc, dd;

boolean drawEllipses = false;
boolean draw3D = true;

// from board
boolean switcher = false;
boolean button = false;
int encoder = 0;
int slider = 0;



PFont f;
/*String[] elements = { 
 "0", "1", "2", "3", "4", "5", "6", "7", "8"};*/
//float delta = 2*PI/elements.length;
float count = 0;
int state = 0;
color[][] saved;
PVector[] points;
int index = 0;

final int grey = 180;
final float threshold = 0.1;
final int increment = 1;
final int size = 65;
final float angle = 0.5;
final int timeout = 10;
LinkedList elements;
float now = 0;
float last = 0;
float lastserial = 0;

float myAngle = 0;


void setup() {
  size(1920,1080,OPENGL);
  background(255);
  smooth();
  scale = 40;
  NP = 50;
  hint(DISABLE_DEPTH_TEST);

int myX = 0;
while(myX < 10000) {
myX++;
}
  
  float m = millis();
  while(millis()-m < 2000);
  
  myPort = new Serial(this, Serial.list()[0], baudRate);
  myPort.bufferUntil(lf);

  elements = new LinkedList();
  
  m = millis();
  while(millis()-m < 2000); 
  
  now = millis();
  last = millis();
}


void draw() { 
  now = millis();
  fill(0,16);
  noStroke();
  rect(0,0,width,height);
  float phi, theta;

  translate(width/2, height/2, 0);
  myAngle += 0.01f;
  rotateX(sin(myAngle));
  rotateY(myAngle);

  for (int i=0; i<NP; i++) {
    for(int j=0; j<NP; j++) {
      theta = map(i, 0, NP, -PI/2, +PI/2);
      phi = map(j, 0, NP, -PI/2, +PI/2);
      Eval(theta, phi, -1);
      Eval(theta, phi, 1);
    }
  }
}



void serialEvent(Serial p) {
  int delimIndex = -1;
  String inString;
  String firstString;
  String remainingString;
  String secondString;
  String stepString;

  inString = (myPort.readString());
  if(!inString.substring(0,1).equals("L") || now - lastserial < 150) {
    //println("Skipping sequence...");
    return;
  }
  lastserial = now;
  //println(inString);
  delimIndex = inString.indexOf(',');
  inString = inString.substring(delimIndex+1, inString.length()-2);


  ArrayList<String> tokens = new ArrayList();
  for(int i=0; i<4 ; i++) {
    //println(inString + " + " + i);
    if(i < 3) {
      delimIndex = inString.indexOf(','); //find first comma
      //println("Adding " + inString.substring(0, delimIndex));
      tokens.add(inString.substring(0, delimIndex));
      inString = inString.substring(delimIndex+1, inString.length());
    }
    else {
      tokens.add(inString);
    }
  }

  if(int(tokens.get(0)) == 0)
    switcher = false;
  else
    switcher = true;

  if(int(tokens.get(1)) == 0)
    button = false;
  else
    button = true;

  encoder = int(tokens.get(2));

  slider = int(tokens.get(3));

  //println("Switch is " + switcher + "  button is " + button + "  encoder: " + encoder + "  slider is " + slider);
  
  m = 1 + encoder % 20;
  n3 = exp((float)slider/150);
  //n2 = -n3;
  //n1 = sin(n2*3+n1);
  
}



int blend(int org, int col, int alpha) {
  int r1=(org&0x0000ff);
  int g1=(org&0x00ff00);
  int b1=(org&0xff0000);
  int r2=(col&0x0000ff);
  int g2=(col&0x00ff00);
  int b2=(col&0xff0000);

  int r3=(((alpha*(r1-r2)) >>8 )+r2)&0x000000ff;
  int g3=(((alpha*(g1-g2)) >>8 )+g2)&0x0000ff00;
  int b3=(((alpha*(b1-b2)) >>8 )+b2)&0x00ff0000;

  return (r3)|(g3)|(b3);
}

float r_f(float p) {
  return pow( 
  pow(abs(1/a*cos(m*p/4)),n2) + pow(abs(1/b*sin(m*p/4)),n3),
  -1/n1
    );
}

PVector lastPoint = new PVector();

void Eval(float theta, float phi, float myDirection) {
  float x,y,z;
  x = r_f(theta)*cos(theta)*r_f(phi)*cos(phi)*myDirection;
  y = r_f(theta)*sin(theta)*r_f(phi)*cos(phi);
  z = r_f(phi)*sin(phi);

  //strokeWeight(10);
  //stroke(100);
  //fill(0);
  pushMatrix();
  scale(300);
  if(switcher) {
    strokeWeight(3);
    stroke(255,50);
    point(z,y,x);
  }
  else {
    stroke(255,50);
    line(z,y,x,lastPoint.z,lastPoint.y,lastPoint.x);
  }
  popMatrix();

  lastPoint.x = x;
  lastPoint.y = y;
  lastPoint.z = z;

  //println(x + " " + y + " " + z);
  //aapixel(width/2+(float)(x*scale), height/2+(float)(y*scale),0xff000000,128);
}

