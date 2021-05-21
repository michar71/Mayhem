/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/

class fx_rainbow extends fx_linear_base
{
    float offset = 0;
    
    
    color wheel(float hue,float freq)
    {
      float r;
      float g;
      float b;
      float p = (1.0/256.0) * (hue+1);
      float pr = (current_red/255);
      float pg = (current_green/255);
      float pb = (current_blue/255);

      r = ((maxBrightness/2)+((maxBrightness/2)* sin(freq*p*TWO_PI)));
      g = ((maxBrightness/2)+((maxBrightness/2)* sin(freq*p*TWO_PI+(TWO_PI/3.0))));
      b = ((maxBrightness/2)+((maxBrightness/2)* sin(freq*p*TWO_PI+(TWO_PI/3.0*2.0))));
      
      r = r * pr;
      g = g * pg;
      b = b * pb;

      return color(r,g,b);
    }
  
  
    fx_rainbow(int height)
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
      float sp = current_speed/200;
      float f = current_scale/200;
      println("SP:"+sp);
      println("F:"+f);
      offset = offset + sp;

      for (int i = 0; i < gfx.height; i++)
      {
            gfx.stroke(wheel(i+offset,f));
            gfx.line(0,i,0,i+1);
      }

      return true;
  }
}
