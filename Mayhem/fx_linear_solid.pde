
/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/

class fx_linear_solid extends fx_linear_base
{
    fx_linear_solid(int height)
    {
      super(height);
      name = "Test";
      params.put("COL_R",maxBrightness);
      params.put("COL_G",maxBrightness);
      params.put("COL_B",maxBrightness);
      params.put("BURST",0);
      loadData();
    }
  
  
    public boolean run_linear_ani(int currentBeatCount, PGraphics gfx)
    {
      if (current_burst == 1)
      {  
        gfx.stroke(255,255,255);
        println("BURST");
      }
      else
      {
        if ((current_red< 4) && (current_blue<4) && (current_green < 4))
          gfx.stroke(0,0,0);  
        else
         gfx.stroke(current_red,current_green,current_blue);
        
      }
      
      gfx.line(0,0,0,fxHeight);
      return true;
  }
}
