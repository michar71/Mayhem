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
      for (int ii=49;ii<72;ii++)
      {
          if (notelist.get(ii).state_on == true)
          {
            int h = (int)map(ii,49,71,0,255);
            int s = 255;
            int v = notelist.get(ii).state_velocity;
            int b = 0;
            if (v<=64)            
              b = (int)map(notelist.get(ii).state_velocity,0,64,0,16);
            else if (v<=96)            
              b = (int)map(notelist.get(ii).state_velocity,0,96,17,32);
            else
              b = (int)map(notelist.get(ii).state_velocity,97,127,33,255);
            println(h+"/"+s+"/"+b);
      
            col = color(h,s,b);
          }
      }

      //Add Decay
      gfx.tint(0,64);
      gfx.image(gfx,0,0);

      gfx.stroke(col);
      for (int ii=74;ii<97;ii++)
      {
          if (notelist.get(ii).state_on == true)
          {
            gfx.line(0,map(ii,74,96,0,fxHeight) - map(notelist.get(ii).state_velocity,0,64,0,64),0,map(ii,74,96,0,fxHeight) + map(notelist.get(ii).state_velocity,0,64,0,64)); 
          }
            
      } 
      colorMode(RGB,255);
     gfx.colorMode(RGB,255);
     return true;
  }
  

}
