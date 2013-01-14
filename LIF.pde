//Leaky integrate and fire neuron

wave Vmem; 
wave In;

//interface constants
float Vrest;
float Vreset;
int Vtraceheight, vx, vy;
int Vtracewidth;
int Itraceheight, ix, iy;
int Itracewidth;
int threshHeight;
int restHeight;
int resetHeight;
PFont f;
int texY;
int texX;
int texSpace;
//simulation values
float time=0;
float I;
float V;
int InputMode;
void setup(){
  frameRate(15);
  size(640,480);
  //setup dimensions
  Vtraceheight=int(height*0.7);
  Vtracewidth=int(width*0.8);
  vx=width-Vtracewidth;
  vy=1;
  Itraceheight=int(height*0.15);
  Itracewidth=Vtracewidth;
  ix=vx;
  iy=vy+Vtraceheight+40;
  threshHeight=int(Vtraceheight* (1.8/3.0) );
  restHeight=int(Vtraceheight* (2.6/3.0) );
  resetHeight=Vtraceheight;
  texY= iy;
  texX=40;
  texSpace=25;
  
  //font stuff
  f = loadFont("Ubuntu-20.vlw");
  textFont(f);
  ellipseMode(CENTER);
  
  
  Vmem = new wave(0, 2,Vtracewidth+vx);
  In = new wave(color(0,119,168), 2,Itracewidth+ix);
  
  smooth();
  InputMode=2;
  V=0;
}

void draw(){
  background(255);
  //axis stuff
  strokeWeight(2);
  stroke(200,0,0);
  line(vx,threshHeight,vx+Vtracewidth,threshHeight);
  fill(200,0,0);
  textAlign(RIGHT);
  text("Threshold",vx+Vtracewidth-5,threshHeight);
  
  stroke(128);
  line(vx,restHeight,vx+Vtracewidth,restHeight);
  fill(0);
  text("Rest",vx+Vtracewidth-5,restHeight);
  line(vx,resetHeight,vx+Vtracewidth,resetHeight);
  line(vx,resetHeight,vx,0);
  text("Reset",vx+Vtracewidth-5,resetHeight);
  
  line(ix,iy+Itraceheight,ix+Itracewidth,iy+Itraceheight);
  line(ix,iy+Itraceheight,ix,iy);
  text("Input",ix+Itracewidth-5,iy+Itraceheight);
  
  textAlign(LEFT);
  //buttons
  text("Mouse",texX,texY);
  text("Sine",texX,texY+texSpace);
  text("Square",texX,texY+texSpace*2);
  text("Random",texX,texY+texSpace*3);
  
  text("Leaky", 20, texSpace);
  text("Integrate", 20, texSpace*2);
  text("-and-",20, texSpace*3);
  text("Fire", 20, texSpace*4);
  
  noFill();
  ellipse(texX-10,texY-7,10,10);
  ellipse(texX-10,texY-7+texSpace,10,10);
  ellipse(texX-10,texY-7+texSpace*2,10,10);
  ellipse(texX-10,texY-7+texSpace*3,10,10);
  fill(0,119,168);
  switch (InputMode) {
    case 1: ellipse(texX-10,texY-7,10,10); break;
    case 2: ellipse(texX-10,texY-7+texSpace,10,10); break;
    case 3: ellipse(texX-10,texY-7+texSpace*2,10,10); break;
    case 4: ellipse(texX-10,texY-7+texSpace*3,10,10); break;
  }
  
  //get input
  I=getInput()*1.6;
  // compute LIF
  V+=(I-V)/5; //differential equation
  if (V>=1){
    //Action potential!
    Vmem.addpoint(vx,vy);
    V=(float(restHeight)-resetHeight)/threshHeight;
  }
  
  strokeWeight(3);
  //w.addpoint(10,height-random(1)*mouseY);
  
  In.addpoint(ix,iy+Itraceheight-I*Itraceheight/1.6);
  In.display();
  In.timestep();
  
  Vmem.addpoint(vx,restHeight-V*(restHeight-threshHeight)+1);
  Vmem.display();
  Vmem.timestep();
}

float getInput(){
  if (InputMode==1){//mouse position
    return (height-mouseY)/float(height)*1.1;
  }else if (InputMode==2){
    time++;
    return (sin(2*PI*time/70.0)+1)/2;
  }else if (InputMode==3){
    time++;
    return round((sin(2*PI*time/100.0)+1)/2);
  }else if (InputMode==4){
    time++;
    return random(1.1);
  }
  
  return 0;
}
void mousePressed() {
  if (mouseX<ix && mouseY>texY-20){
    if (mouseY < texY+10){
      InputMode=1;    
    } else if (mouseY < texY+texSpace+10){
      InputMode=2;
    } else if (mouseY < texY+texSpace*2+10){
      InputMode=3;
    } else if (mouseY < texY+texSpace*3+10){
      InputMode=4;
    }
  } 
}

class wave {
  color c;
  ArrayList<Float> xs;
  ArrayList<Float> ys;
  int xmax;
  float ts;
  
  //constructor
  wave(color tempc, float timestep, int xxmax) {
    c = tempc;
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
    xmax = xxmax;
    ts = timestep;
  }
  void display() {
    stroke(c);
    noFill();
    beginShape();
    for (int i = 0; i<xs.size(); i++){
      curveVertex(xs.get(i),ys.get(i));
    }
    endShape();
  }
  void setcolor(color cc){
    c=cc;
  }
  void addpoint(float x, float y){
    xs.add(x);
    ys.add(y);
  }
  void timestep(){//shifting
    for (int i = 0; i<xs.size(); i++){
      xs.set(i,xs.get(i)+ts);
    }
    if (xs.size()>0){//trimming
      while (xs.get(0) > xmax + ts){
        xs.remove(0);
        ys.remove(0);
      }
    }
  }
}