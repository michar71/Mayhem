
import controlP5.*;
import java.util.*;
import java.lang.*;

ControlP5 cp5;
Textlabel bpm_label;
Bang fire_bang;
Slider fire_length;
//Hard-coded Constant
long puffer_dely_ns = 500 * 1000 * 1000;//500ms...

//General Variables
int mayhem_version_maj = 0;
int mayhem_version_min = 2;
int sizex = 800;
int sizey = 600;
int buttonx = 20;
int buttony = 20;
boolean started = false;


//Beatcounter stuff
long  ns_gap = 10000;
float refill_multiplier = 2.5;
long [] ns_array = {0,0,0,0,0};
int bpm = 120;
int last_bpm = 120;
boolean threadON = false;
int beat = 0;
int beatmode = 0;
long lastNanos, currentNanos;
boolean puffer_trigger = false;
boolean puffer_on = false;
long buffer_trigger_start_time = 0;
long puffer_trigger_end_time = 0;
long next_beat_zero_time = 0; //Next time beat 0 will trigger...
long refill_duration = 0;

void setup_ui()
{
  cp5 = new ControlP5(this);
  
  // create a new button with name 'buttonA'
  cp5.addBang("Beat")
     .setValue(0)
     .setPosition(0+5,0+5)
     .setSize(buttonx*3,buttony)
     .setLabel("")
     ;
     
  bpm_label = cp5.addTextlabel("bpm")
                    .setText("BPM: XXX")
                    .setPosition(140+20,0+5+5)
                    ;
                    
  fire_bang = cp5.addBang("FIRE")
     .setValue(0)
     .setPosition(0+5,0+30)
     .setSize(buttonx*3,buttony)
     .setLabel("")
     ;    
     
  List puffmode = Arrays.asList("Manual","Single", "Small/Big", "Pulse");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("PuffMode")
     .setPosition(80, 0+30)
     .setSize(buttonx*3,buttony*10)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(puffmode)
     .setValue(1)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ; 
     
  fire_length = cp5.addSlider("Puff Duration")
     .setPosition(160,0+30)
     .setSize(100,20)
     .setRange(1,10000)
     .setValue(1000)
     ;
       
}

void drawbeatmarker(int beat,int mode)
{
  for (int ii =0;ii<4;ii++)
  {
    if (mode == 0)
    {
    if (ii == beat)
     fill(255,0,0);
    else
     fill(128);
    }
    else
    {
     if (ii <= beat)
       fill(0,255,0);
    else
     fill(128);
    }
    circle(80+(ii*20), 15, 8); 
  }
}


void draw_light_control()
{
  fill(0);
  stroke(128);
  rect(5,100,256+2,256+2);
}

void setup() 
{
  size(800,600,P2D);    
  surface.setTitle("Mayhem V "+mayhem_version_maj+"."+mayhem_version_min);

  background(64);
  setup_ui();
  started = true;

}

void draw() 
{
  background(64);
  drawbeatmarker(beat,beatmode);
  puffer_trigger_process();
  if (last_bpm != bpm)
  {
    last_bpm = bpm;  
    fill(64);
    rect(140+20,0+5+5,100,10);
    fill(255);
    bpm_label.setValue("BPM:"+bpm);
  }
  
  draw_light_control();
}

void beatdetect()
{
  if (started == true)
  {
    if (beatmode == 0)
    {
      threadON=false;
      beatmode = 1;
      ns_array[0] = System.nanoTime();
      beat=0;
    }
    else
    {
      beat++;
      ns_array[beat] = System.nanoTime();
      if (beat==4)
      { 
        beatmode = 0;
        ns_gap = (ns_array[1] - ns_array[0]) + (ns_array[2] - ns_array[1]) + (ns_array[3] - ns_array[2] + (ns_array[4] - ns_array[3]));
        ns_gap = ns_gap / 4;
        bpm = (int)((60.0*1000.0*1000.0*1000.0)/ns_gap);
        println(ns_gap);
        println("BPM"+bpm);
        println(ns_array[0]+" "+ns_array[1]+" "+ns_array[2]+" "+ns_array[3]+" " +ns_array[4]+" ");
        lastNanos = System.nanoTime();
        threadON=true;
        beat=0;
        frameRate((int)(bpm/4));
        thread("myThreadTimer");
      }
    }
  }
}

//we always fire the Buffer Trigger on the first beat that comes next
//we subtract a negative offset for the delay so we subtreact that
//We calulate the end time
//The mode is controlled on the DMX controller so we send that whenever it changes

void puffer_trigger_process()
{
  long now_time = System.nanoTime();
  if ((puffer_trigger == true) && (puffer_on == false))
  {
    //Calulate the point in time we need to send the signals
    //If we are too close to the next full beat dealy by 4 beats....
    buffer_trigger_start_time = next_beat_zero_time - puffer_dely_ns;
    if (now_time > buffer_trigger_start_time)
      buffer_trigger_start_time = buffer_trigger_start_time + (4*ns_gap);
      
    puffer_trigger_end_time = buffer_trigger_start_time + ((long)fire_length.getValue() * 1000 * 1000);
    puffer_trigger = false;
  }
  
  //Check if we need to fire the buffer
  if ((now_time > buffer_trigger_start_time) && (now_time<puffer_trigger_end_time))
  {
    puffer_on = true;
    //Send DMX Command for Puffer Here..
    fill(0,255,0);
  }
  else
  {
    puffer_on = false;
    //Send DMX Command for Puffer Here...
    fill(64,64,64);
    refill_duration = (long)((float)(puffer_trigger_end_time - buffer_trigger_start_time) * refill_multiplier);
    
    
    //Buffer is refilling
    if ((now_time > puffer_trigger_end_time) && (now_time < (puffer_trigger_end_time + refill_duration)))
    {
      fill(255,0,0);
    }
  }
  circle(340, 30+12, 12); 
}

//Key Processing
void keyPressed() 
{
  if (key == 'b') 
  {
     beatdetect();
  }
}


//High Resolution Java Thread for Timer
void myThreadTimer() 
{
  println("THREAD START");
  
  while(threadON == true)
  {
      //println(threadON);
      currentNanos = System.nanoTime();
      if ( currentNanos-lastNanos >= ns_gap ) 
      {
        lastNanos = currentNanos;
          beat++;
          if (beat > 3)
          {
            beat = 0;
            next_beat_zero_time = currentNanos + (ns_gap*5);
          }
      }
      delay(1);
  }
  println("THREAD EXIT");
}



public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}

// function colorA will receive changes from 
// controller with name colorA
public void Beat(int theValue) 
{
  if (started)
    beatdetect();
}

public void FIRE(int theValue)
{
  //In manual mode we just set the puffer_on value directly....
  
  if (fire_bang.getTriggerEvent() == Bang.PRESSED)
  {
    fire_bang.setTriggerEvent(Bang.RELEASE);
    puffer_trigger = true;
    println("FIRE DOWN");
  }
  else
  {
    fire_bang.setTriggerEvent(Bang.PRESSED);
    println("FIRE UP");
  }
  
}
