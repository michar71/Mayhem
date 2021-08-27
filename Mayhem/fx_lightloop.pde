
/*
SIZE
MODE
POS_X
POS_Y
COL_R
COL_G
COL_B
*/

class fx_lightloop extends fx_linear_base
{
    lightloop_manager llm = new lightloop_manager();
    fx_lightloop(int height)
    {
      super(height);
      name = "Lightloop";
      //params.put("COL_R",maxBrightness);
      //params.put("COL_G",maxBrightness);
      //params.put("COL_B",maxBrightness);
      //params.put("BURST",0);
      //loadData();
    }
  
  
    public boolean run_linear_ani(int currentBeatCount, PGraphics gfx)
    {
      llm.lightloop_manager_process(currentBeatCount,gfx);
      return true;
  }
  
  
    public void processNote(boolean on, int channel, int pitch, int velocity)
    {
      if (llm != null)
      {
        if (on)
        {
          llm.lightloop_manager_keydown(pitch, velocity);
        }
        else
        {
          llm.lightloop_manager_keyup(pitch, velocity);
        }
      }
    }
}
