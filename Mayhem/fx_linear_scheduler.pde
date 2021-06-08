

//  Call current FX
// Make sure new FX will only muxed in on major beat
// if Blending is enabled blend between last FX and next one over 1/4 beat. (New FX is delayed by one. Make sure to adjust beatcount...)
// Manage lookahead?

import java.util.*; 
import processing.sound.*;

class fx_linear_scheduler{
    protected fx_linear_base current_fx;
    protected fx_linear_base next_fx;
    protected fx_artnet_link artnet_link;
    
    protected boolean newFx = false;
    protected int fxHeight;
    protected PGraphics fxGfx;
    
    public boolean StepOnBeat = false;
    public boolean TransitionOnBeat = false;
    public boolean useDecay = false;
    
//Class Creator
fx_linear_scheduler(int height,fx_linear_base first_fx)
{
  fxHeight = height;
  current_fx = first_fx;
  next_fx = current_fx;
  newFx = false;
  fxGfx = createGraphics(1, fxHeight);
  artnet_link = new fx_artnet_link(downsample.MAX_VAL,30);
}
    
    
void setNextFx(fx_linear_base fx)
{
  next_fx = fx;
  newFx = true;
}


void SetStepOnBeat(boolean val)
{
   StepOnBeat = val;
}

void SetTransitionOnBeat(boolean val)
{
  TransitionOnBeat = val;
}

void SetDecayOn(boolean val)
{
  useDecay = val;
}

void updateScheduler(long currentTimeUS,long nextBeatUS,int currentBeatCount,PGraphics gfx)
{
  //TODO deal with FX transition here...
  if ((next_fx != current_fx) && (TransitionOnBeat== true))
  {
    if (currentBeatCount == 0)
      current_fx = next_fx;
  }
  else if ((next_fx != current_fx) && (TransitionOnBeat== false))
  {
    current_fx = next_fx;
  }
  
  
  if (true == current_fx.update(currentTimeUS,nextBeatUS,currentBeatCount,StepOnBeat,useDecay,fxGfx))
  {
     //Shift image to right
    gfx.beginDraw();
    gfx.copy(0,0,fxheight,fxheight,1,0,fxheight,fxheight);
    gfx.image(fxGfx,0,0,1,fxheight);
    gfx.endDraw();
    
    //Update Artnet...
   artnet_link.fx_artnet_update(gfx);
  }
  
}

  void setParam(String param, int value)
  {
    current_fx.setParam(param,value);
  }

  int getParam(String param)
  {
    return current_fx.getParam(param);
  }
  
  void setBrightness(int theValue)
  {
    current_fx.setBrightness(theValue);
  }
  
  void setFilename(String filen)
  {
    current_fx.setFilename(filen);
  }
  
  void firePooferManual(boolean on)
  {
    artnet_link.puffer_manual(on);
  }
  
  void firePooferReset()
  {
    artnet_link.puffer_reset();
  }
  
  void firePoofer(int mode)
  {
    artnet_link.puffer_control(mode);
  }

  void setAudio(Amplitude lc, Amplitude rc)
  {
      current_fx.setAudio(lc,rc);
  }

  void setFFT(FFT fftl,FFT fftr)
  {
    current_fx.setFFT(fftl,fftr);
  }
  
  void sendNote(boolean on, int channel, int pitch, int velocity)
  {
       current_fx.sendNote(on,  channel,  pitch,  velocity);
  }
  
  void saveData()
  {
    current_fx.saveData();
  }
  
}
