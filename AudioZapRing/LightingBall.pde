class LightingBall{
    float _size;
    float _z;

    float _band;

    float _offest;

    int low_range;
    int mid_range;
    int high_range;

    ArrayList<LightMedium> medium;


    LightingBall(int low,int mid,int high){
        _size = 10;
        _z = 200;
        low_range = low;
        mid_range = mid;
        high_range = high;
    }
    void get_band(float band){
        _band = band;
    }
    void display(){
        pushMatrix();
            noStroke();
            translate(0,0,_z);
            sphere(map(_band,0,100,10,12));
        popMatrix();
    }

    void make_medium(){
        float[] offset = {250,300,350};
        float[] range =  {low_range,mid_range-low_range,high_range-mid_range};
        medium = new ArrayList<LightMedium>();
        pushMatrix();
            for(int k=0;k<3;k++){
                int number = (int)range[k];
                translate(0,0,-50);
                for (int i=0; i<number; i+=5){
                    float rotate_step = TWO_PI/number;
                    medium.add(new LightMedium(offset[k],rotate_step*i+random(-9,9),-50*(k+1)));
                }
            }
        popMatrix();
        zaps();
    }

    void zaps() {
        int count=0;
        for (LightMedium m : medium) { 
            println(count++);
            println("loc_x : ",m.loc.x);
            println("loc_y : ",m.loc.y);
            println("loc_z : ",m.loc.z);

            if(_band > random(350,450)) m.zapping(m);
        }
    }

}

class LightMedium {
    PVector loc;
    float rotate_step;
    float offset;

    float band;
    LightMedium(float radius,float angle,float zpos){
        float x = radius*cos(angle);
        float y = radius*sin(angle);
        float z = zpos;
        loc = new PVector(x,y,z);
    }

    

    void zapping(LightMedium medium) {

        PVector centor = new PVector(0,0,100);
        PVector target = medium.loc;

        PVector diff = PVector.sub(centor, target);
        float dist = diff.mag();

        diff.normalize();

        strokeWeight(noise(target.x,target.y,target.z)*3);
        colorMode(HSB, 100);
        float numSteps = 25; //電磁訊號強度
        float lx = centor.x;
        float ly = centor.y;   
        float lz = centor.z;
        int i = 0;
        while (i < numSteps && abs (lx - target.x) > 10 || abs(ly - target.y) > 10) {
            float x = lx + (target.x - lx) / numSteps + random(-9, 9);
            float y = ly + (target.y - ly) / numSteps + random(-9, 9);
            float z = lz + (target.z - lz) / numSteps + random(-9, 9);
            // stroke(max(0,min(255,hue(color(x,y,z)) + sin(frameCount*0.05)*50)), 360, 360);
            stroke(random(0,100),50,random(50,100));
            line(lx, ly,lz, x, y,z);
            lx = x;
            ly = y;
            lz = z;
            i++;
        }
        line(lx, ly,lz, target.x, target.y,target.z);
    }
}
