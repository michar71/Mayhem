
/*
SIZE = Amplifier

Run FFT
Map Range on height
Map Lower Frequencies on Brightness
Map Height on Color
*/

class fx_linear_fft extends fx_linear_base
{
    // Declare a smooth factor to smooth out sudden changes in amplitude.
    // With a smooth factor of 1, only the last measured amplitude is used for the
    // visualisation, which can lead to very abrupt changes. As you decrease the
    // smooth factor towards 0, the measured amplitudes are averaged across frames,
    // leading to more pleasant gradual changes
    float smoothingFactor = 0.4;
    int bands = 128;
    int bandlimit = 64;
    int bandrange = (bands-1)-bandlimit;
    
    // Used for storing the smoothed amplitude valu
    float[] sum_l = new float[bands];
    float[] sum_r = new float[bands];
    float barHeight;

    fx_linear_fft(int height)
    {
      super(height);
      name = "Spectrum";
      params.put("SCALE",1);
      params.put("SPEED",2);
      loadData();
    }
  
  
    public boolean run_linear_ani(int currentBeatCount, PGraphics gfx)
    {
      int scale =   (int)(current_scale*2);
      barHeight = fxHeight/float(bandrange);
      
      println(scale);
      println(barHeight);
      
      // Perform the analysis
      if (left_FFT != null)
        left_FFT.analyze();
      if (right_FFT != null)
        right_FFT.analyze();
      
      gfx.stroke(0,scale/90);
      gfx.line(0,0,0,fxHeight);
      gfx.colorMode(HSB, 255);
      
      for (int i = 1; i < bandrange; i++) 
      {
        // Smooth the FFT spectrum data by smoothing factor
        if (left_FFT != null)
          sum_l[i] += (left_FFT.spectrum[i] - sum_l[i]) * smoothingFactor;
        else if(right_FFT != null)
          sum_l[i] += (right_FFT.spectrum[i] - sum_l[i]) * smoothingFactor;  

        float val = pow(log(i),2)/2;
        
        //Left Channel
        gfx.stroke((val*sum_l[i]*scale),255,sum_l[1]*scale*8);
        gfx.line(0,i*barHeight,0,i*barHeight + barHeight); 
        
     }   
     gfx.colorMode(RGB,255);
     
     return true;
    }
}
