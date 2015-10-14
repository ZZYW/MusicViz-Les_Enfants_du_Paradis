
//drag-able camera
import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import peasy.test.*;

//music library Minim
import ddf.minim.analysis.*;
import ddf.minim.*;


Minim       minim;//declare Minim
AudioPlayer myMusic;//the audio piece we are going to use
FFT         fft; //we are going to use FFT to analyze the sound

PeasyCam cam; //declare drag-able camera

int bandNumber = 100;//how many bands are we going to display


float[] startRotations = new float[bandNumber]; //declare array, each band has a start rotation.
color[] colors = new color[bandNumber]; //declare array, each band has its color
float[] runTimeRotations = new float[bandNumber]; //declare array, each band has a runtime rotating animation
float[] radiuses = new float[bandNumber];

void setup()
{

  size(1200, 600, P3D);  //use P3D renderer
  pixelDensity(2); //new feature, for Processing 3 only, gives a higher resolution

  minim = new Minim(this); //initialize our Minim object "minim"
  // specify that we want the audio buffers of the AudioPlayer
  // to be 1024 samples long because our FFT needs to have 
  // a power-of-two buffer size and this is a good size.
  myMusic = minim.loadFile("Les_Enfants_du_Paradis.mp3", 1024);  
  myMusic.play();
  // create an FFT object that has a time-domain buffer 
  // the same size as myMusic's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( myMusic.bufferSize(), myMusic.sampleRate() );
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fft.logAverages( 22, 2);


  //initialze our PeasyCam object cam
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5000);


  int radiusGeneratorNoiseSeed = 0;
  //use a for loop to assign values to our arrays
  for (int i=0; i<bandNumber-1; i++) {
    startRotations[i] = random(0, TWO_PI); //start rotation will be a random number between 0 and TWO_PI
    int start_point = 40;
    colors[i] = color(random(start_point, 255), 0, random(start_point, 255)); //random color
    runTimeRotations[i] = 0; //assign 0 to all runTimeRotation, the value will increment once each frame
    radiuses[i] = map( noise(radiusGeneratorNoiseSeed), 0, 1, 300, 500);

    println( radiuses[i]);
    radiusGeneratorNoiseSeed+=1;
  }
}




void draw()
{
  //instead of using background(), we use a huge opaque box to be the background, 
  //bacause of its transpaency, the stuff we draw on screen will not 
  //be erased completely, leaving a trail effect.
  fill(0, 4);
  box(3000);


  // perform a forward FFT on the samples in myMusic's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( myMusic.mix );


  //draw all bands
  for (int i=0; i<bandNumber; i++) {
    pushMatrix();
    if (fft.getBand(i)>20 &&fft.getBand(i) < 50) {
      strokeWeight(5);
    } else if (fft.getBand(i)>=50) {
      strokeWeight(15);
    } else {
      strokeWeight(1);
    }
    noFill();
    //offset bands on Z axis
    translate(0, 0, (bandNumber*5)/2 - i*5);
    //rotate bands in same speed but from different start point
    rotate(startRotations[i] + runTimeRotations[i]);
    stroke(colors[i]);
    arc(0, 0, radiuses[i]-i*3, radiuses[i]-i*3, 0, map(fft.getBand(i), 0, 100, 0, TWO_PI));
    popMatrix();
    //increment run time rotation
    runTimeRotations[i]+=0.01;
  }


  //center sphere
  {
    pushMatrix();
    fill(255, 255, 0);
    noStroke();
    sphere(fft.getBand(3)/2);
    popMatrix();
  }



  //drawBands();
}

//draw bands in a boring way.
void drawBands() {
  int w = 20;
  for (int i=0; i<fft.specSize (); i++) {
    strokeWeight(w-1);
    stroke(255);
    line(i*w, height, i*w, height-fft.getBand(i));
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(6);
    text(i, i*w, height-20);
  }
  strokeWeight(0.5);
  stroke(0, 255, 0);

  for (int o=10; o<100; o+=10) {
    line(0, height-o, width, height-o);
  }
}