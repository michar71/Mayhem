/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/

class fx_image_scroll extends fx_linear_base
{
    String currentfile = "";
    PGraphics scrollImage;
    int xSize = 0;
    int currentXPos = 0;

  
  
    fx_image_scroll(int height)
    {
      super(height);
      name = "Random Sparkles";
      params.put("SCALE",100);
      params.put("SPEED",100);
      params.put("DIR",0);
      params.put("POS_X",0);
      params.put("POS_Y",0);
      params.put("COL_R",maxBrightness);
      params.put("COL_G",maxBrightness);
      params.put("COL_B",maxBrightness);
      loadData();
    }
  
  
    public boolean run_linear_ani(int currentBeatCount, PGraphics gfx)
    {
      //Check if we have a new filename
      if (filenamestr != currentfile)
      {
          //Check if file exists
          File f = dataFile(filenamestr);
          boolean exist = f.isFile();
          //if yes initiate file load
          if (exist == true)
          {
            currentfile = filenamestr;
            PImage bigImage = loadImage(currentfile);
             //Load file
             
             //Scale Y
             scrollImage = createGraphics(bigImage.width, fxHeight,P2D);
             scrollImage.beginDraw();
             scrollImage.copy(bigImage, 0, 0, bigImage.width, bigImage.height, 0, 0,bigImage.width,fxHeight);
             scrollImage.endDraw();
             //Store x-size
             xSize = bigImage.width;
             currentXPos = xSize;
          }
      }
      if (xSize != 0)
      {
        //copy line to buffer  
        gfx.copy(scrollImage, currentXPos, 0, 0, fxHeight, 0, 0, 1, fxHeight);
        
              //Deal with loop
        currentXPos--;
        if (currentXPos == -1)
          currentXPos = xSize;
        
      }
       
      return true;
  }
  
  
}
