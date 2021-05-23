
/*
SIZE = Amplifier

Run FFT
Map Range on height
Map Lower Frequencies on Brightness
Map Height on Color
*/

class fx_linear_vumeter extends fx_linear_base
{
    // Declare a smooth factor to smooth out sudden changes in amplitude.
    // With a smooth factor of 1, only the last measured amplitude is used for the
    // visualisation, which can lead to very abrupt changes. As you decrease the
    // smooth factor towards 0, the measured amplitudes are averaged across frames,
    // leading to more pleasant gradual changes
    float smoothingFactor = 0.8;
    
    // Used for storing the smoothed amplitude value
    float sum_l;
    float sum_r;
    int offs = 0;

    fx_linear_vumeter(int height)
    {
      super(height);
      name = "VU-Meter";
      params.put("SCALE",1);
      params.put("SPEED",2);
      loadData();
    }
  
  
    public boolean run_linear_ani(int currentBeatCount, PGraphics gfx)
    {
      int scale =   (int)(current_scale/50);
      
      // smooth the rms data by smoothing factor
      //sum_l += (vu_l - sum_l) * smoothingFactor;
      //sum_r += (vu_r - sum_r) * smoothingFactor;
      
      
      if (left_channel != null)
          sum_l = left_channel.analyze();
      if (right_channel != null)
        sum_l = right_channel.analyze();
        
        


      // rms.analyze() return a value between 0 and 1. It's
      // scaled to height/2 and then multiplied by a fixed scale factor
      float rms_scaled_l = sum_l * (fxHeight/2) * scale;
      
      int br = 64 + (int)((sum_l * sum_l)*800);
      
      println(rms_scaled_l);
      println(br);

      gfx.colorMode(HSB,255);
      
      //Left Channel
      gfx.stroke(offs+(rms_scaled_l/24),255,br);
      gfx.line(0,fxHeight,0,fxHeight-rms_scaled_l);
      gfx.stroke(0,0,0);
      gfx.line(0,0,0,fxHeight-rms_scaled_l);      
      
      
      offs = offs + (int)(sum_l * 5);
      if (offs > 255)
        offs = offs - 255;

      gfx.colorMode(RGB,255);
      
      return true;
    }
}
