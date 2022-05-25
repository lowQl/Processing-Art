class Cubes {

  float x;
  float y;
  float sizer;
  float offset;
  float increment;
  float theta;

  float band;
  int number;

  float[] low_spec;
  float[] low_to_mid_spec;
  float[] mid_to_high_spec;

  float[] z = new float[1000];
  //constructor 
  Cubes(float tempSizer, float tempOffset, float tempIncrement, int tempNumber) {
    x=0;
    y=0;
    sizer=tempSizer;
    offset=tempOffset;
    increment=tempIncrement;
    number=tempNumber;
    
  }
  void get_spec(float[] low_spec_t,float[] low_to_mid_spec_t,float[] mid_to_high_spec_t){
    low_spec = low_spec_t;
    low_to_mid_spec = low_to_mid_spec_t;
    mid_to_high_spec = mid_to_high_spec_t;
  }
  void get_band(float tempband){
    band = tempband;
  }
  void set_z(){
    //導入FFT 訊號 

    for (int i=0; i<low_spec.length; i++) {
      z[i] = low_spec[i];
    }
  }

  void update_low_z(int index){
    colorMode(HSB, 360, 100, 100);
    float color_step = TWO_PI/low_spec.length;
  //  println("H : ",color_step*index);
    float h = color_step*index;
  //  println("color H : ",map(h,0,6.28,0,360));
    fill(map(h,0,TWO_PI,0,360),50,100);
    // translate(0, 0,low_spec[index]);
    box(sizer,sizer,map(low_spec[index],0,100,sizer,50));
  }
  void update_low_mid_z(int index){
    colorMode(HSB, 360, 100, 100);
    float color_step = TWO_PI/low_to_mid_spec.length;
  //  println("H : ",color_step*index);
    float h = color_step*index;
  //  println("color H : ",map(h,0,6.28,0,360));
    fill(map(h,0,TWO_PI,0,360),50,100);
    // translate(0, 0,low_to_mid_spec[index]);
    box(sizer,sizer,map(low_to_mid_spec[index],0,100,sizer,200));
    
  }

  void update_mid_high_z(int index){
    colorMode(HSB, 360, 100, 100);
    float color_step = TWO_PI/mid_to_high_spec.length;
  //  println("H : ",color_step*index);
    float h = color_step*index;
  //  println("color H : ",map(h,0,6.28,0,360));
    fill(map(h,0,TWO_PI,0,360),50,100);
    box(sizer,sizer,map(mid_to_high_spec[index],0,100,sizer,300));
    // translate(0, 0,mid_to_high_spec[index]);
  }


  void run (int index) {
    
    for (int i=0; i<number; i++) {
      // fill(0, 90, 100);
      pushMatrix();
        // translate(x, y);
        float rotate_step = TWO_PI/number;
        rotate(rotate_step*i);
        translate(offset, 0);
        // rotateX(theta*2);
        // translate(0, 0,z[i]);
        if(i<low_spec.length && index ==0)
          update_low_z(i);
        if(i<low_to_mid_spec.length && index ==1)
          update_low_mid_z(i);
        if(i<mid_to_high_spec.length && index ==2)
          update_mid_high_z(i);
      popMatrix();
    }
    
    
    theta+=increment;
  }
}
