//Lightloop class encapsulates one light loop dataset
//It gets a config file form the data folder and expects a bitmap/jpeg pssed over via the config file.
//Images are 256 Pxiels height. If Heigher the addational Pixels on top will be mapped to control channels

enum LIGHTLOOP_STATE
{
  LIGHTLOOP_EMPTY,
  LIGHTLOOP_READY,
  LIGHTLOOP_TRIGGERED,
  LIGHTLOOP_ACTIVE,
  LIGHTLOOP_FADEOUT
}

enum LIGHTLOOP_ERRORS
{
  LIGHTLOOP_NO_ERROR,
  LIGHTLOOP_CONFIG_NO_FOUND,
  LIGHTLOOP_IMAGE_NOT_FOUND,
  LIGHTLOOP_ERROR_WRITING_FILE
}

class lightloop
{
  String configFileName;
  int totalNumSteps;   //X-Pixels....
  int Hue_Mod;
  int Sturation_Mod;
  int Brightness_Mod;
  LIGHTLOOP_STATE state;
  PImage imageData;
  PImage currentImageStrip;
  
  //Settings stored in XML file
  boolean loopable;           //Effect is Loopable
  boolean fadeable;           //Effect is fadeable
  boolean beatSync;           //Sync effect on beat
  boolean MeasureSync;        //Sync Effect on Measure
  boolean phaseInOutFromKeys; //Override Phase In/Out time if we use a Keyboard by Attack Strength
  int stepsPerBeat;           //Number of Substeps per beat. Generally we are limited to 6 Steps/sec so this will be subsampled
  int phaseInSpeed;           //Number of Steps for the Phase In of the effect
  int phaseInOutSpeed;        //Number of Steps for the Phase Out of the effect
  int fadeSpeed;              //Speed 
  String imageFileName;       //Image Filename

  
  void lightloop()
  {
  }
  
  LIGHTLOOP_ERRORS loadConfig(String configName)
  {
    return LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR;
  }
  
  LIGHTLOOP_ERRORS saveConfig(String configName)
  {
    return LIGHTLOOP_ERRORS.LIGHTLOOP_NO_ERROR;
  }
  
  //Get the current 256x1 image strip for the current beat/measure/timestep/time)
  //This involves fading and effects
  PImage getImageData(int beat, int measure, int timestep, long time)
  {
    return null;
  }
  
  boolean attachImage(PImage image)
  {
    return true;
  }
  
}
