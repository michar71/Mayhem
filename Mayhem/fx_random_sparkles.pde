/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/

class fx_random_sparkles extends fx_linear_base
{
    fx_random_sparkles(int height)
    {
      super(height);
      name = "Random Sparkles";
      params.put("SCALE",1);
      params.put("SPEED",0);
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
      int cnt = (int)random((current_scale/10));
      int pos = 0;
      for (int ii=0;ii<cnt;ii++)
      {
        int r = (int)random(current_red);
        int g = (int)random(current_green);
        int b = (int)random(current_blue);
        gfx.stroke(r,g,b);
        pos = (int)random(fxHeight);
        gfx.line(0,pos,0,pos+1);
      }

      return true;
  }
}
