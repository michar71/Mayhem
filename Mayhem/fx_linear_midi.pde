/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/


class fx_linear_midi extends fx_linear_base
{
    int cnt = 0;
  
    fx_linear_midi(int height)
    {
      super(height);
      name = "Midi Control";
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
      color col = color(0);
      
      //clear
      gfx.stroke(0);
      gfx.line(0,0,0,fxHeight);
      gfx.colorMode(HSB, 255);
      colorMode(HSB, 255);
      // Use pitch 74-96 velocity to define the "where to draw a value and how big"
      // We use pitch 48-71 to define color and brightness 
      for (int ii=48;ii<72;ii++)
      {
          if (notelist.get(ii).state_on == true)
          {
            int h = (int)map(ii,48,71,0,255);
            int s = 255;
            int b = (int)map(notelist.get(ii).state_velocity,0,127,0,255);
            println(h+"/"+s+"/"+b);
      
            col = color(h,s,b);
          }
      }
      
      gfx.stroke(col);
      for (int ii=74;ii<97;ii++)
      {
          if (notelist.get(ii).state_on == true)
          {
            gfx.line(0,map(ii,74,96,0,fxHeight) - map(notelist.get(ii).state_velocity,0,127,0,127),0,map(ii,74,96,0,fxHeight) + map(notelist.get(ii).state_velocity,0,127,0,127)); 
          }
            
      } 
      colorMode(RGB,255);
     gfx.colorMode(RGB,255);
     return true;
  }
  

}
