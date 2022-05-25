//example from class today - J. Stephen Lee
//fixed the code to rotate each ring of cubes independently

//fit to iPad screen
//allow mouseX rotation on y axis (mouse horizontal movement)
//allow mouseY rotation on x axis (mouse vertical movement)
//- Richard Bourne
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;

// Variables that define the "zones" of the spectrum
// For example, for bass, we only take the first 4% of the total spectrum
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

// So there remains 64% of the possible spectrum which will not be used.
// These values are generally too high for the human ear anyway.

// Score values for each area
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

// Previous values, to soften the reduction
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

int low_range;
int mid_range;
int high_range;
// Softening value default 25
// 軟化取樣率 取樣率過大 會導致特效氾濫 失去視覺強調效果
float scoreDecreaseRate = 25;


int number;

int nbCubes;
Cubes [] cubes;
LightingBall lighting_ball;
// cubes [] cubes = new cubes[10];


void setup() {
  size(960, 768, P3D);
  

  //Load the minimal library
  minim = new Minim(this);
  //Load the song
  song = minim.loadFile("Actually.mp3");
  // println(song.bufferSize());
  // println(song.sampleRate());

  //Create the FFT object to analyze the song
  fft = new FFT(song.bufferSize(), song.sampleRate());

//  println("specSize : ",fft.specSize());
  nbCubes = (int)(fft.specSize()*specHi);


  nbCubes = 3;
//  println(nbCubes);
  cubes = new Cubes[nbCubes];
  // colorMode(HSB, 360, 100, 100);

  low_range = (int)(fft.specSize()*specLow);
  mid_range = (int)(fft.specSize()*specMid);
  high_range = (int)(fft.specSize()*specHi);
//  println("low_range : ",low_range);
//  println("mid_range : ",mid_range);
//  println("high_range : ",high_range);


  float sizer = 10;
  float offset = 300;
  float increment = .001;//方塊旋轉 目前用不到
  // int number = song.bufferSize();

  cubes[0]=new Cubes(sizer,250 ,increment ,low_range);
  cubes[1]=new Cubes(sizer,300 ,increment ,mid_range-low_range);
  cubes[2]=new Cubes(sizer,350 ,increment ,high_range-mid_range);

  lighting_ball = new LightingBall(low_range,mid_range,high_range);

  song.play(0);

}
void mousePressed() {
  if (song.isPlaying()) {
    song.pause();// pause the soundfile
  } else {
    song.play();// resume
  }
}

void draw() {


  //Advance the song. We draw() for each "frame" of the song...
  fft.forward(song.mix);
  
  //Calculate "scores" (power) for three sound categories
  //First save the old values
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
  //Reset values
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;

 
 
  //Calculate the new "scores"
  //低頻譜 聲量
  float[] low_spec= new float[low_range];
  for(int i = 0; i < low_range; i++)
  {
    //println("Low score : ",fft.getBand(i));
    low_spec[i] = fft.getBand(i);
    scoreLow += fft.getBand(i);
  }
  // println("low_spec_length : ",low_spec.length);
  //低~中 頻譜 聲量
  float[] low_to_mid_spec= new float[mid_range-low_range];
  for(int i = low_range; i < mid_range; i++)
  {
    // println("Low-to-Mid score : ",fft.getBand(i));
    low_to_mid_spec[i-low_range] = fft.getBand(i);
    scoreMid += fft.getBand(i);
  }
  //中~高 頻譜 聲量
  float[] mid_to_high_spec= new float[high_range - mid_range];
  for(int i = mid_range; i < high_range; i++)
  {
    // println("Mid-to-Hight score : ",fft.getBand(i));
    mid_to_high_spec[i-mid_range] = fft.getBand(i);
    scoreHi += fft.getBand(i);
  }
  //Slow down the descent.
  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }
  
  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }
  
  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }
  
  //Volume for all frequencies at this time, with higher sounds more prominent(突出).
  //This makes the animation go faster for [higher pitched sounds](高音調), which are more noticeable
  float scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;
  lighting_ball.get_band(scoreGlobal);
  
  //Subtle background color
  background(scoreLow/100, scoreMid/100, scoreHi/100);


  translate(width/2,height/3,-100);

  

  //Cube for each frequency band
  //nbCubes = (int)(fft.specSize()*specHi);
  for(int i = 0; i < nbCubes; i++)
  {
    //Value of the frequency band
    float bandValue = fft.getBand(i);
    // println(i," band : ",bandValue);
    //The color is represented as follows: red for bass, green for midrange and blue for high.
    //紅色 > 低音
    //綠色 > 中音
    //藍色 > 高音
    //The opacity is determined by the volume of the band and the overall volume.
    cubes[i].get_band(bandValue);
    
    //取得低中高頻譜
    
    cubes[i].get_spec(low_spec,low_to_mid_spec,mid_to_high_spec);
  }

  float rotate_X = width/2;
  float rotate_y = height/6;
  rotateY((rotate_X+width*.3)/(width/4));
  rotateX((rotate_y+height*.3)/(height/4));
  
  lighting_ball.make_medium();
  for (int i=0; i<nbCubes; i++  ) {
    lights();
    translate(0,0,-50);
    cubes[i].run(i);
    if(i == 1)
      lighting_ball.display();
  }


  
}

// void mousePressed(){
//   save('pix.jpg')
// }
