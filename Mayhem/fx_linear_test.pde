
/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/

class fx_linear_test extends fx_linear_base
{
    fx_linear_test(int height)
    {
      super(height);
      name = "Test";
      params.put("SCALE",1);
      params.put("SPEED",1);
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
  
      //Test Code...Draw Ascending color dots...
      switch(currentBeatCount)
      {
        default:
        case 0:
          gfx.stroke(current_red,current_green,current_blue);
          break;
        case 1:
          gfx.stroke(255,0,0);
          break;
        case 2:
          gfx.stroke(0,255,0);
          break;
        case 3:
          gfx.stroke(0,0,255);
          break;          
      }
      
      gfx.line(0,cnt,0,cnt+1);
      gfx.line(0,fxHeight-cnt,0,fxHeight-cnt-1);
      
      cnt = cnt + (int)(current_speed/100);
      if (cnt > fxHeight)
        cnt = 0;

      return true;
  }
}
