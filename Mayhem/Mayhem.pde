import controlP5.*;
import java.util.*;
import java.lang.*;
import processing.sound.*;
import java.io.File;
import java.io.FilenameFilter;
import themidibus.*; //Import the library

//Audio-Related Variables
AudioIn in_l;
AudioIn in_r;
Amplitude rms_l;
Amplitude rms_r;
FFT fft_l;
FFT fft_r;
int bands = 128;
int audio_channel_left = 0;
int audio_channel_right = 0;
MidiBus myBus; // The MidiBus
    

//UI
ControlP5 cp5;
Textlabel bpm_label;
Textlabel fxLabelFPS;
Bang fire_bang;
Slider fire_length_T1;
Slider fire_length_T2;
Slider fire_length_T3;
CheckBox loop_gfx;
CheckBox sync_gfx;
CheckBox sync_poof;
CheckBox decay_gfx;
List puffmode;

//Hard-coded Constant
long puffer_dely_ns = 10 * 1000 * 1000;//500ms...

//General Variables
int mayhem_version_maj = 0;
int mayhem_version_min = 8;
int sizex = 800;
int sizey = 600;
int buttonx = 20;
int buttony = 20;
int fxheight = 256;
boolean started = false;
int currentPuffMode = 0;

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
     

     
  fire_length_T1 = cp5.addSlider("T1")
     .setPosition(80,0+30)
     .setSize(100,20)
     .setRange(1,255)
     .setValue(8)
     ;
     
  fire_length_T2 = cp5.addSlider("T2")
     .setPosition(80,0+30+24)
     .setSize(100,20)
     .setRange(1,255)
     .setValue(16)
     ;
     
   fire_length_T3 = cp5.addSlider("T3")
     .setPosition(80,0+30+48)
     .setSize(100,20)
     .setRange(1,255)
     .setValue(32)
     ;
     
    sync_poof  = cp5.addCheckBox("syncpoof")
            .setPosition(200,78)
            .setSize(15, 15)
            .addItem("Sync Poof to Beat", 1)
            ;  
     
  puffmode = Arrays.asList("Manual", "Small/Big", "Pulse","Single");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("PuffMode")
     .setPosition(220, 0+30)
     .setSize(buttonx*4,buttony*10)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(puffmode)
     .setValue(1)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ; 
     
  loop_gfx = cp5.addCheckBox("loop")
                .setPosition(5, 370)
                .setSize(15, 15)
                .addItem("Loop", 0)
                ;
    
   sync_gfx  = cp5.addCheckBox("syncgfx")
                .setPosition(60, 370)
                .setSize(15, 15)
                .addItem("Sync Lights to Beat", 1)
                ;  
          
     decay_gfx  = cp5.addCheckBox("decay")
                .setPosition(180, 370)
                .setSize(15, 15)
                .addItem("Decay", 1)
                ;  
                
  List<String> fxnames = new ArrayList<String>();
  FxList.getNames(fxnames);
  cp5.addScrollableList("FxList")
     .setPosition(5, 400)
     .setSize(buttonx*6,buttony*10)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(fxnames)
     .setValue(0)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ; 
     
  List<String> filenames = new ArrayList<String>(); 
  String[] jpegFiles =  listFileNames(sketchPath()+"/data",jpgFilefilter);
  if (jpegFiles != null)
  {  
    filenames = Arrays.asList(jpegFiles);
  }
  
  cp5.addScrollableList("FileList")
     .setPosition(380, 5)
     .setSize(buttonx*8,buttony*20)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(filenames)
     .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
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
  
       cp5.addButton("saveParams")
           .setBroadcast(false)
           .setValue(128)
           .setLabel("Save Parameters")
           .setPosition(col,top+220)
           .setSize(buttonx*4,buttony)
           .setBroadcast(true);     
           
          cp5.addButton("burstButton")
            .setBroadcast(false)
           .setValue(128)
           .setLabel("Burst")
           .setPosition(col,top+250)
           .setSize(buttonx*4,buttony)
           .setBroadcast(true);     
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
  rect(5,100,fxheight+1,fxheight+1);
  
  //Call the FX scheduler
  //Update Auddio parameters
  scheduler.setAudio(rms_l,rms_r);
  scheduler.setFFT(fft_l,fft_r);
  //Set Filename
  //scheduler.setFilename("Untitled.jpg");   //Test only
  //Call Scheduler
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

FilenameFilter jpgFilefilter = new FilenameFilter()
{
         public boolean accept(File dir, String name) 
         {
            String lowercaseName = name.toLowerCase();
            if (lowercaseName.endsWith(".jpg")) {
               return true;
            } 
            else 
            {
               return false;
            }
         }
      };
      
// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir,FilenameFilter filter) 
{
  File file = new File(dir);
  if (file.isDirectory()) 
  {
    String names[] = file.list(filter);
    return names;
  } 
  else 
  {
    // If it's not a directory
    return null;
  }
}



void setup() 
{
  logger = new fx_logger();
  size(800,600);    
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
  fullGfx = createGraphics(fxheight, fxheight);
  setup_ui();
  
    //Setup audio Stuff
  in_l = new AudioIn(this,audio_channel_left);
  in_l.start();
  
  in_r = new AudioIn(this,audio_channel_right);
  in_r.start();
  
  rms_l = new Amplitude(this);
  rms_l.input(in_l); 

  rms_r = new Amplitude(this);
  rms_r.input(in_r);   
  
    // Create the FFT analyzer and connect the playing soundfile to it.
  fft_l = new FFT(this, bands);
  fft_l.input(in_l);
  
  
    // Create the FFT analyzer and connect the playing soundfile to it.
  fft_r = new FFT(this, bands);
  fft_r.input(in_r);
  
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, "USB MIDI Interface", "USB MIDI Interface"); 
  
  logger.log("SETUP DONE");
  started = true;
}

void draw() 
{
  background(64);
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
  
  //Bail out on manaul control so we don't interfere..
  if (currentPuffMode == 0)
    return;
    
  if ((puffer_trigger == true) && (puffer_on == false))
  {
    //Calulate the point in time we need to send the signals
    //If we are too close to the next full beat dealy by 4 beats....
    buffer_trigger_start_time = next_beat_zero_time - puffer_dely_ns;
    if (now_time > buffer_trigger_start_time)
      buffer_trigger_start_time = buffer_trigger_start_time + (4*beatDetect.getBeatGap());
      
    puffer_trigger_end_time = buffer_trigger_start_time + ((long)fire_length_T1.getValue() * 1000 * 1000);
    puffer_trigger = false;
  }
  
  //Check if we need to fire the buffer
  if ((now_time > buffer_trigger_start_time) && (now_time<puffer_trigger_end_time))
  {
    puffer_on = true;
    //Send DMX Command for Puffer Here..
    if (currentPuffMode == 0)
    {
      scheduler.firePooferManual(true);
    }
    else
    {
      //Spawn thread for poofer control
      thread("poofTimerThread");
    }
    fill(0,255,0);
  }
  else
  {
    puffer_on = false;
    //Send DMX Command for Puffer Here...
    if (currentPuffMode == 0)
    {
      scheduler.firePooferManual(false);
    }    
    fill(64,64,64);
    refill_duration = (long)((float)(puffer_trigger_end_time - buffer_trigger_start_time) * refill_multiplier);
    
    
    //Buffer is refilling
    if ((now_time > puffer_trigger_end_time) && (now_time < (puffer_trigger_end_time + refill_duration)))
    {
      fill(255,0,0);
    }
    //if (now_time > (puffer_trigger_end_time + refill_duration))
    //{     
    //   scheduler.firePooferReset();
    //}
  }
  circle(320, 30+12, 12); 
}

public enum poofer_states {
    POOFER_START,
    POOFER_T1,
    POOFER_T2,  
    POOFER_T3,
    POOFER_END
}

  //High Resolution Java Thread for Pooofer
void poofTimerThread() 
{
  boolean exit = false;
  int t1 = (int)fire_length_T1.getValue();
  int t2 = (int)fire_length_T2.getValue(); 
  int t3 = (int)fire_length_T3.getValue(); 
  int mode = currentPuffMode;
  int count = 0;
  long currenttime = millis();
  poofer_states pooferState = poofer_states.POOFER_START;
  
  println("POOF THREAD START");
  
  //check for exit condition
  while (exit == false)
  {
    //Go through State machine and compare times
    switch(pooferState)
    {
      case POOFER_START:
        //reset poofer
        pooferState = poofer_states.POOFER_T1;
        scheduler.firePooferManual(true);
        break;
      case POOFER_T1:
        if (millis()>= currenttime + t1*1000)
        {
          pooferState = poofer_states.POOFER_T2;
          scheduler.firePooferManual(false);
        }
        break;
      case POOFER_T2:
        if (millis()>= currenttime + t1*1000 + t2 * 1000)
        {
          pooferState = poofer_states.POOFER_T3;
          scheduler.firePooferManual(true);
        }
        break;
      case POOFER_T3:
        if (millis()>= currenttime + t1*1000 + t2 * 1000 + t3 * 1000)
        {
          if (mode == 2)
          {
            pooferState = poofer_states.POOFER_END;
            scheduler.firePooferManual(false);
          }
          else
          {
            if (count == t3)
            {
              pooferState = poofer_states.POOFER_END;
              scheduler.firePooferManual(false);
            }
            else
            {
              pooferState = poofer_states.POOFER_T2;
              scheduler.firePooferManual(false);
              currenttime = millis();
            }
            count++;
          }
        }
        break;
      case POOFER_END:
        scheduler.firePooferManual(false);
        exit = true;
        break;
    }
  }


  println("POOF THREAD EXIT");
}

//Key Processing
void keyPressed() 
{
  if (key == 'b') 
  {
     beatdetect();
  }
  if (key == 'f')
  {
    puffer_trigger = true;
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
    if (currentPuffMode == 0)
    {
      scheduler.firePooferManual(true);
      fill(0,255,0);
      circle(340, 30+12, 12); 
    }
    
    
  }
  else
  {
    fire_bang.setTriggerEvent(Bang.PRESSED);
    println("FIRE UP");
    if (currentPuffMode == 0)
    {
      scheduler.firePooferManual(false);
      fill(64,64,64);
      circle(340, 30+12, 12); 
    }
  }
  
}

public void syncgfx(float[] a)
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

public void PuffMode(int theValue)
{
  currentPuffMode = theValue;
}

public void FileList(int theValue)
{
  scheduler.setFilename((String)(cp5.get(ScrollableList.class, "FileList").getItem(theValue).get("text")));
}

void saveParams(int theValue)
{
  do_save();
}

void do_save()
{
      scheduler.saveData();
}

void do_burst()
{
  scheduler.setParam("BURST",1);
}


void burstButton(int theValue)
{
   do_burst();
}


void noteOn(int channel, int pitch, int velocity) 
{
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  
  scheduler.sendNote(true,channel,pitch,velocity);
  
  if (pitch == 48)
  {
      scheduler.firePooferManual(true);
      fill(0,255,0);
      circle(340, 30+12, 12); 
  }  
}

void noteOff(int channel, int pitch, int velocity) 
{
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  scheduler.sendNote(false,channel,pitch,velocity);
  
  if (pitch == 48)
  {
      scheduler.firePooferManual(false);
      fill(64,64,64);
      circle(340, 30+12, 12); 
  }
}

void controllerChange(int channel, int number, int value)
{
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}
