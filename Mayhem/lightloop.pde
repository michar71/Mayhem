import java.util.*;

//Lightloop class encapsulates one light loop dataset
//It gets a config file form the data folder and expects a bitmap/jpeg pssed over via the config file.
//Images are 256 Pxiels height. If Heigher the addational Pixels on top will be mapped to control channels

enum LIGHTLOOP_STATE
{
  LIGHTLOOP_EMPTY,
  LIGHTLOOP_READY,       //Lightloop is ready but not active 
  LIGHTLOOP_TRIGGERED,   //Key was depressed This state is set exactly once
  LIGHTLOOP_ACTIVE,      //Effect is currnetly active
  LIGHTLOOP_STOPPED,   //Key was depressed This state is set exactly once
  LIGHTLOOP_FADEOUT,     //Key has been depressed
  LIGHTLOOP_ERROR
}

enum LIGHTLOOP_ERRORS
{
  LIGHTLOOP_NO_ERROR,
  LIGHTLOOP_CONFIG_NO_FOUND,
  LIGHTLOOP_IMAGE_NOT_FOUND,
  LIGHTLOOP_WRONG_IMAGE_FORMAT,
  LIGHTLOOP_ERROR_WRITING_FILE
}

class lightloop
{
  private String configFileName;
  private int totalNumSteps;   //X-Pixels....
  private int currentStep;
  private int Hue_Mod;
  private int Sturation_Mod;
  private int Brightness_Mod;
  private LIGHTLOOP_STATE state;
  private PImage imageData;
  private PImage currentImageStrip;
  private int fade_counter_in;
  private int fade_counter_out;
  
  //Settings stored in XML file
  protected boolean loopable;           //Effect is Loopable
  protected boolean fadeable;           //Effect is fadeable
  protected boolean beatSync;           //Sync effect on beat
  protected boolean measureSync;        //Sync Effect on Measure
  protected boolean phaseInOutFromKeys; //Override Phase In/Out time if we use a Keyboard by Attack Strength
  protected int stepsPerBeat;           //Number of Substeps per beat. Generally we are limited to 6 Steps/sec so this will be subsampled
  protected int phaseInSpeed;           //Number of Steps for the Phase In of the effect
  protected int phaseOutSpeed;        //Number of Steps for the Phase Out of the effect
  protected String imageFileName;       //Image Filename
  protected String filename;
  protected long starttime;

  
lightloop(String configName)
  {
    //Try to load config
    configFileName = configName;
    imageData = createImage(1, 256, RGB);
    
    setDefaults();
    
    //Hmm... What do we do if this fails
    if (LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR != loadConfig(configFileName))
      state = LIGHTLOOP_STATE.LIGHTLOOP_ERROR;
  }
    
  String createFilename(String configName)
  {
    return configName + ".json";
  }
  
  
  LIGHTLOOP_STATE getState()
  {
    return state;
  }
  
  LIGHTLOOP_ERRORS loadConfig(String configName)
  {
    JSONArray values;
    
    //Create Filename
    filename = createFilename(configName);
    //Try to open Config 
    //Check if file exists
    File f = dataFile(filename);
    boolean exist = f.isFile();
    if (exist == false)
    {
        return LIGHTLOOP_ERRORS.LIGHTLOOP_CONFIG_NO_FOUND;
    }

    //Load data from file  
     values = loadJSONArray(filename);
      
      //Loop through values
      for (int i = 0; i < values.size(); i++) 
      {   
        JSONObject setting = values.getJSONObject(i); 
        String param = setting.getString("param");
        
         if (param.toUpperCase() == "LOOPABLE")
         {
           loopable = setting.getBoolean("LOOPABLE");
         }
         else if (param.toUpperCase() == "FADEABLE")
         {
           fadeable = setting.getBoolean("FADEABLE");
         }
         else if (param.toUpperCase() == "BEATSYNC")
         {
           beatSync = setting.getBoolean("BEATSYNC");
         } 
         else if (param.toUpperCase() == "MEASURESYNC")
         {
           measureSync = setting.getBoolean("MEASURESYNC");
         } 
         else if (param.toUpperCase() == "PHASEINOUTFROMKEYS")
         {
           phaseInOutFromKeys = setting.getBoolean("PHASEINOUTFROMKEYS");
         }      
         else if (param.toUpperCase() == "STEPSPERBEAT")
         {
           stepsPerBeat = setting.getInt("STEPSPERBEAT");
         }    
         else if (param.toUpperCase() == "PHASEINSPEED")
         {
           phaseInSpeed = setting.getInt("PHASEINSPEED");
         }  
         else if (param.toUpperCase() == "PHASEOUTSPEED")
         {
           phaseOutSpeed = setting.getInt("PHASEOUTSPEED");
         }  
         else if (param.toUpperCase() == "IMAGEFILE")
         {
           imageFileName = setting.getString("IMAGEFILE");
           
           //Try to load the image...
           if (LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR == loadImageData(imageFileName))
           {
             state = LIGHTLOOP_STATE.LIGHTLOOP_READY;
           }
           
         } 
      }
    
    return LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR;
  }
  
  
  LIGHTLOOP_ERRORS loadImageData(String imageDataName)
  {
      //Check if file exists
      File f = dataFile(imageDataName);
      boolean exist = f.isFile();
      //if yes initiate file load
      if (exist == true)
      {
        //Load file
        imageData = loadImage(imageDataName);
        
        if (imageData.height < 256)
        {
          return LIGHTLOOP_ERRORS.LIGHTLOOP_WRONG_IMAGE_FORMAT;
        }

         //Store x-size
         totalNumSteps = imageData.width;
      }
      else
      {
        return LIGHTLOOP_ERRORS.LIGHTLOOP_IMAGE_NOT_FOUND;
      }
   
    return LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR;
  }
  
  
  LIGHTLOOP_ERRORS saveConfig(String configName,String ImageFileName)
  {
      int ii=0;
      JSONArray values;
       //create filename
      String filename = createFilename(configName);
      filename = dataPath(filename);

      
      //Save Data to file (We iterate through the current property list)
      values = new JSONArray();

      //Create JSON Entries      
      JSONObject setting1 = new JSONObject(); 
      setting1.setString("param", "LOOPABLE");
      setting1.setBoolean("val", loopable);
      values.setJSONObject(ii, setting1);
      ii++;

      JSONObject setting2 = new JSONObject(); 
      setting2.setString("param", "FADEABLE");
      setting2.setBoolean("val", fadeable);
      values.setJSONObject(ii, setting2);
      ii++;

      JSONObject setting3 = new JSONObject(); 
      setting3.setString("param", "BEATSYNC");
      setting3.setBoolean("val", beatSync);
      values.setJSONObject(ii, setting3);
      ii++;

      JSONObject setting4 = new JSONObject(); 
      setting4.setString("param", "MEASURESYNC");
      setting4.setBoolean("val", measureSync);
      values.setJSONObject(ii, setting4);
      ii++;    
      
      JSONObject setting5 = new JSONObject(); 
      setting5.setString("param", "PHASEINOUTFROMKEYS");
      setting5.setBoolean("val", phaseInOutFromKeys);
      values.setJSONObject(ii, setting5);
      ii++;  
      
      JSONObject setting6 = new JSONObject(); 
      setting6.setString("param", "STEPSPERBEAT");
      setting6.setInt("val", stepsPerBeat);
      values.setJSONObject(ii, setting6);
      ii++;  

      JSONObject setting7 = new JSONObject(); 
      setting7.setString("param", "PHASEINSPEED");
      setting7.setInt("val", phaseInSpeed);
      values.setJSONObject(ii, setting7);
      ii++;  

      JSONObject setting8 = new JSONObject(); 
      setting8.setString("param", "PHASEOUTSPEED");
      setting8.setInt("val", phaseOutSpeed);
      values.setJSONObject(ii, setting8);
      ii++;  

      JSONObject setting9 = new JSONObject(); 
      setting9.setString("param", "IMAGEFILE");
      setting9.setString("val", ImageFileName);
      values.setJSONObject(ii, setting9);
      
      saveJSONArray(values, filename); 
      return LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR;
  }
  
  void setDefaults()
  {
    configFileName = "";
    totalNumSteps = -1;   //X-Pixels....
    currentStep = 0;
    Hue_Mod = 0;
    Sturation_Mod = 0;
    Brightness_Mod = 0;
    state = LIGHTLOOP_STATE.LIGHTLOOP_EMPTY;
    
    loopable = true;           
    fadeable = true;           
    beatSync = true;           
    measureSync = true;        
    phaseInOutFromKeys = true; 
    stepsPerBeat = 1;          
    phaseInSpeed = 10;           
    phaseOutSpeed = 10;       
    imageFileName = ""; 
    starttime = 0;

    currentImageStrip = createImage(1, 256, RGB);
  }
  
  //Get the current 256x1 image strip for the current beat/measure/timestep/time)
  //This involves fading and effects
  
  //Sample (x-pos) = measure * 4 + beat
  //Measure starts to count at start of effect (Key down) after sync has been achived (Sync on beat or measure...)
  //timestep is the delta time since last call
  //total time is counted from start of effect
  
  //For effects with heigher resolution than beats time and timestep need to be used.
  //Fade in/out should be based on time to give smooth transition even if the image does not change
  
  PImage getImageData( int beat, int measure, int timestep, long time,float bpm)
  {
    //If we are at the last step....
    if (currentStep >= totalNumSteps)
    {
        //check if this sample is loopable or terminate
         if (loopable)
         {
           currentStep = 0;
         }
         else
         {
           currentStep = 0;
           starttime = 0;
           state = LIGHTLOOP_STATE.LIGHTLOOP_READY;
         }
    }

    //Calulate X-Pos  
    //THIS IS JUST A TEST !!!!
    //Actual calulation might be more complicated....
    currentStep++;
    
    if (fade_counter_in>0)
      fade_counter_in--;
      
    if (fade_counter_out>0)
      fade_counter_out--;
    
    //Slice out lower 256 pixel line
    if (null != imageData)
    {
      //Slice out column (256 Pixels from the bottom)
      int alpha = 255;
      
      //Calculate Alpha
      if (fade_counter_in != 0)
      {
        alpha = (int)map(fade_counter_in,phaseInSpeed,0, 0 ,255);
      }
      else if (fade_counter_out != 0)
      {
        alpha = (int)map(fade_counter_out,phaseOutSpeed,0, 0 ,255);
      }
      
      tint(0,0,0,alpha);    // Display with opacity
      currentImageStrip.copy(imageData, currentStep, imageData.height - 256, 1, 256, 0, 0, 1, 256); //<>//
      noTint();
      return currentImageStrip; 
    }
    else
    {
      return null;
    }
  }
  
  void lightloop_key(LIGHTLOOP_STATE currstate,int velocity)
  {
    if (currstate == LIGHTLOOP_STATE.LIGHTLOOP_TRIGGERED)
    {
      //Do what needs to be done
      state = LIGHTLOOP_STATE.LIGHTLOOP_ACTIVE;
      starttime = System.nanoTime();
      //Setup Fade-In Effect
      if (fadeable)
      {
        if (phaseInOutFromKeys)
        {
          fade_counter_in = velocity;
          phaseInSpeed = velocity;
        }
        else
        {
          fade_counter_in = phaseInSpeed;
        }
      }
      else
      {
        fade_counter_in = 0;
      }
    }
    else if (currstate == LIGHTLOOP_STATE.LIGHTLOOP_STOPPED)
    {
      //Setup Fade-In Effect
      if (fadeable)
      {
        if (phaseInOutFromKeys)
        {
          fade_counter_out = velocity;
          phaseOutSpeed = velocity;
          state = LIGHTLOOP_STATE.LIGHTLOOP_FADEOUT;
        }
        else
        {
          fade_counter_out = phaseInSpeed;
          state = LIGHTLOOP_STATE.LIGHTLOOP_FADEOUT;
        }
      }
      else
      {
        fade_counter_out = 0;
        state = LIGHTLOOP_STATE.LIGHTLOOP_READY;
      }
    }
  }
  
  
  int getControlChannelData(int channel)
  {
    return 0;
  }
  
  LIGHTLOOP_ERRORS attachImage(PImage image)
  {
    if (image.height < 256)
    {
      return LIGHTLOOP_ERRORS.LIGHTLOOP_WRONG_IMAGE_FORMAT;
    }
    imageData = image;
    totalNumSteps = imageData.width;
    return LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR;
  }
  
}
