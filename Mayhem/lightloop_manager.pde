//Manage multiple light loops
//
//Enable/disable them based on keys by adding them to the processing list
//Poll current pixel strip
//Blend them together (Use blend() function for different blend types...Need to figrue out what we do with the alpha cannel....)
//Support Classes:
//lightloop_list -> A list of all the possible effects and their key mapping.

class lightloop_manager
{
  class lightloop_list
  {
      public String fx_name; 
      public lightloop loop;
      public int key_num;
      
      lightloop_list(int keynum, String name)
      {
        fx_name = name;
        loop = new lightloop(name);
        key_num = keynum;
      }
  };

  public PImage llImageStrip;
  public PImage llStrip;
  List<lightloop_list> lightlooplist = new ArrayList<lightloop_list>();
  int fxindex = 0;
  
  void create_lighloop_list()
  {
    lightlooplist.add(new lightloop_list(48,"ll_test1"));
    lightlooplist.add(new lightloop_list(49,"ll_test2"));
  }

  
  lightloop_manager()
  {
    llImageStrip = createImage(1, 256, RGB);
    llStrip = createImage(1, 256, RGB);
    create_lighloop_list();
  }
  
  lightloop find_by_key(int keynum)
  {
    for (int jj=0;jj<lightlooplist.size();jj++)
    {
      if (lightlooplist.get(jj).key_num == keynum)
        return lightlooplist.get(jj).loop;
    }
    return null;
  }
  
void lightloop_manager_process(int currentBeatCount,PGraphics gfx)
  {
    lightloop ll;
    
    //go through all effects
    for (int jj=0;jj<lightlooplist.size();jj++)
    {
        ll = lightlooplist.get(jj).loop;
        if (ll != null)
        {
          llStrip = ll.getImageData(currentBeatCount,0,0,0,0);    
          llImageStrip.blend(llStrip, 0, 0, 1, 256, 0, 0, 1, 256, LIGHTEST);
        }
    }
    gfx.image(llImageStrip,0,0);
  }
  
  void lightloop_manager_keydown(int keynum,int velocity)
  {
    lightloop ll = find_by_key(keynum);
    if (ll != null)
    {
      ll.lightloop_key(LIGHTLOOP_STATE.LIGHTLOOP_TRIGGERED,velocity);
    }
  }
  
  void lightloop_manager_keyup(int keynum,int velocity)
  {
    lightloop ll = find_by_key(keynum);
    if (ll != null)
    {
      ll.lightloop_key(LIGHTLOOP_STATE.LIGHTLOOP_STOPPED,velocity);
    }
  }
}
