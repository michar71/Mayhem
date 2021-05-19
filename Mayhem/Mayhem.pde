
import controlP5.*;
import java.util.*;
import java.lang.*;
import processing.sound.*;
import processing.serial.*;

ControlP5 cp5;
Textlabel bpm_label;
Textlabel fxLabelFPS;
Bang fire_bang;
Slider fire_length;
CheckBox loop_gfx;
CheckBox sync_gfx;
CheckBox decay_gfx;

//Hard-coded Constant
long puffer_dely_ns = 500 * 1000 * 1000;//500ms...

//General Variables
int mayhem_version_maj = 0;
int mayhem_version_min = 4;
int sizex = 800;
int sizey = 600;
int buttonx = 20;
int buttony = 20;
int fxheight = 256;
boolean started = false;

PGraphics fullGfx;

fx_logger logger;
fx_linear_scheduler scheduler;
fx_linear_list FxList;
fx_beat_Detect beatDetect;

//Beatcounter stuff
float refill_multiplier = 2.5;
float last_bpm = 120;
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
                    
    fxLabelFPS = cp5.addTextlabel("FPS")
                    .setText("---")
                    .setPosition(220,0+5+5);
                    
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
     
  loop_gfx = cp5.addCheckBox("loop")
                .setPosition(5, 370)
                .setSize(15, 15)
                .addItem("Loop", 0)
                ;
    
   sync_gfx  = cp5.addCheckBox("sync")
                .setPosition(60, 370)
                .setSize(15, 15)
                .addItem("Sync to Beat", 1)
                ;  
          
     decay_gfx  = cp5.addCheckBox("decay")
                .setPosition(140, 370)
                .setSize(15, 15)
                .addItem("Decay", 1)
                ;  
                
  List<String> fxnames = new ArrayList<String>();
  FxList.getNames(fxnames);
  cp5.addScrollableList("FxList")
     .setPosition(5, 80)
     .setSize(buttonx*6,buttony*10)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(fxnames)
     .setValue(0)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ; 
         
    int top = 5;  
    int col = 600;
    int colwidth = 100;

    cp5.addSlider("brightn").setBroadcast(false).setValue(255).setRange(0,255).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
    top = top + (2*buttonx);   
    
    cp5.addSlider("speed").setBroadcast(false).setValue(500).setRange(0,1000).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
    top = top + (2*buttonx);     
  
    cp5.addSlider("scale").setBroadcast(false).setValue(500).setRange(0,1000).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
    top = top + (2*buttonx);  
     
    cp5.addSlider("direction").setBroadcast(false).setValue(0).setRange(0,359).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
    top = top + (2*buttonx);  
    
    cp5.addSlider("complexity").setBroadcast(false).setValue(500).setRange(0,1000).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
    top = top + (2*buttonx);  
    

    cp5.addSlider("pos_x").setBroadcast(false).setValue(128).setRange(0,255).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
    top = top + (2*buttonx);  
    
    cp5.addSlider("pos_y").setBroadcast(false).setValue(128).setRange(0,255).setPosition(col,top).setWidth(colwidth).setHeight(buttonx).setBroadcast(true);
 
    top = top + (2*buttonx);  
    

    cp5.addColorWheel("col").setBroadcast(false).setRGB(color(128,0,255)).setPosition(col,top).setWidth(190).setBroadcast(true);
  
                
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
  //Draw the frame
  fill(0);
  stroke(128);
  rect(5,100,fxheight+2,fxheight+2);
  
  //Call the FX scheduler
  scheduler.updateScheduler(System.nanoTime()/1000,next_beat_zero_time/1000,beatDetect.getBeat(),fullGfx);   //HARDCODED ON BEAT FOR TESTING !!@!
  
  //Draw FX Result
  image(fullGfx,5+1,100+1);
}

void updateFramerate()
{
  noStroke();
  fill(0);
  fxLabelFPS.setText("FPS: "+int(frameRate));
}


void setup() 
{
  logger = new fx_logger();
  size(800,600,P2D);    
  surface.setTitle("Mayhem V "+mayhem_version_maj+"."+mayhem_version_min);
  
  logger.setLoggerParameters(true,false);
  logger.log("SETUP");
  background(64);

    
  randomSeed(System.nanoTime());
  //Init list of effects
  FxList = new fx_linear_list(fxheight);
  FxList.setIndex(0);
  scheduler = new fx_linear_scheduler(fxheight,FxList.getCurrent());
  beatDetect = new fx_beat_Detect();
  fullGfx = createGraphics(fxheight, fxheight,P2D);
  setup_ui();
  logger.log("SETUP DONE");
  started = true;
}

void draw() 
{
  background(64);
  //drawbeatmarker(beat,beatmode);
  drawbeatmarker(beatDetect.getBeat(),beatDetect.getBeatMode());
  puffer_trigger_process();
  if (last_bpm != beatDetect.getBPM())
  {
    last_bpm = beatDetect.getBPM();  
    fill(64);
    rect(140+20,0+5+5,100,10);
    fill(255);
    bpm_label.setValue("BPM:"+(int)beatDetect.getBPM());
  }
  
  draw_light_control();
  updateFramerate();
}

void beatdetect()
{
  if (started == true)
  {
    beatDetect.manualBeat();
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
      buffer_trigger_start_time = buffer_trigger_start_time + (4*beatDetect.getBeatGap());
      
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

public void sync(float[] a)
{
  if (a[0] == 0)
    scheduler.SetStepOnBeat(false);
  else
    scheduler.SetStepOnBeat(true);
  
}

public void decay(float[] a)
{
  if (a[0] == 0)
    scheduler.SetDecayOn(false);
  else
    scheduler.SetDecayOn(true);
  
}

void FxList(int n)
{
  scheduler.setNextFx(FxList.findByIndex(n));
}

void myThreadTimer() 
{
  beatDetect.beatTimer();
}


public void brightn(int theValue) 
{
  scheduler.setBrightness(theValue);
}

public void speed(int theValue) 
{
  scheduler.setParam("SPEED",theValue);
}

public void scale(int theValue) 
{
  scheduler.setParam("SCALE",theValue);
}

public void direction(int theValue) 
{
  scheduler.setParam("DIR",theValue);
}


public void complexity(int theValue) 
{
  scheduler.setParam("COMPLEX",theValue);
}


public void pos_x(int theValue) 
{
  scheduler.setParam("POS_X",theValue);
}


public void pos_y(int theValue) 
{
  scheduler.setParam("POS_Y",theValue);
}


public void col(int theValue) 
{
  color col = cp5.get(ColorWheel.class,"col").getRGB();
  scheduler.setParam("COL_B",col & 0xFF);
  scheduler.setParam("COL_G",(col>>8) & 0xFF);
  scheduler.setParam("COL_R",(col>>16) & 0xFF); 
}
