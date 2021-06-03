import java.util.*; 
import ch.bildspur.artnet.*;

public enum downsample {
    NEAREST_NEIGHBOR,
    AVERAGE,
    MAX_VAL,  
    WEIGHTED,
}

class fx_artnet_link
{
  class fx_artnet_entry
  {
    int y_pos;
    int artnet_id;
    int r_adr;
    int g_adr;
    int b_adr;
    int br;
    
    fx_artnet_entry(int pos, int id, int bright,int r,int g, int b)
    {
      y_pos = pos;
      artnet_id = id;
      r_adr = r;
      g_adr = g;
      b_adr = b;
      br = bright;
    }
  };

  public List<fx_artnet_entry> lightlist = new ArrayList<fx_artnet_entry>();
  
 
  ArtNetClient artnet;
  byte[] dmxData = new byte[512];
  downsample dsmode;
  int dssize;
  
fx_artnet_link(downsample ds_mode,int ds_size)
{
  //LIST OF LIGHTS IN RELATIOSHIP TO REAL LIGHTS (Maybe convert this with a scale function so we can put just in max height and location in ft?)
   lightlist.add(new fx_artnet_entry((int)map(0,0,14,0,255),0,0,1,2,3));
   lightlist.add(new fx_artnet_entry((int)map(1,0,14,0,255),0,7,8,9,10));
   lightlist.add(new fx_artnet_entry((int)map(2,0,14,0,255),0,14,15,16,17));
   lightlist.add(new fx_artnet_entry((int)map(3,0,14,0,255),0,21,22,23,24));
   lightlist.add(new fx_artnet_entry((int)map(4,0,14,0,255),0,28,29,30,31));
   lightlist.add(new fx_artnet_entry((int)map(5,0,14,0,255),0,35,36,37,38));
   lightlist.add(new fx_artnet_entry((int)map(6,0,14,0,255),0,42,43,44,45));
   lightlist.add(new fx_artnet_entry((int)map(7,0,14,0,255),0,49,50,51,52));
   lightlist.add(new fx_artnet_entry((int)map(8,0,14,0,255),0,56,57,58,59));
   lightlist.add(new fx_artnet_entry((int)map(9,0,14,0,255),0,63,64,65,66));
   lightlist.add(new fx_artnet_entry((int)map(10,0,14,0,255),0,70,71,72,73));
   lightlist.add(new fx_artnet_entry((int)map(11,0,14,0,255),0,77,78,79,80));  
   lightlist.add(new fx_artnet_entry((int)map(12,0,14,0,255),0,84,85,86,87));
   lightlist.add(new fx_artnet_entry((int)map(13,0,14,0,255),0,91,92,93,94));     
   
  //INIT
  clearData();
  dsmode = ds_mode;
  dssize = ds_size;
  artnet = new ArtNetClient(null);
  artnet.start();
}

void clearData()
{
  for (int ii=0;ii<512;ii++)
  {
    dmxData[ii] = 0;
  }
}

void fx_artnet_update(PGraphics gfx)
{
    //clearData();
    
    //Go through list of pixels
    for (int jj=0;jj<lightlist.size();jj++)
    {
      int pos_y = lightlist.get(jj).y_pos;
      if (pos_y> gfx.height-1)
        pos_y = gfx.height-1;
      
      
      color col = color(0,0,0);
      int start = pos_y - dssize/2;
      if (start < 0)
         start = 0;
      int stop = pos_y + dssize/2 + 1;
      if (stop > gfx.height)
         stop = gfx.height;  
      int cnt = 0;
      int avg_r = 0;
      int avg_g = 0;
      int avg_b = 0;
      
      switch(dsmode)
      {
          case NEAREST_NEIGHBOR:
          {
            col = gfx.get(0,pos_y);
            break;
          }
          case AVERAGE:
          {
            for (int ii=start; ii<stop;ii++)
            {
              color avgcol =  gfx.get(0,ii);
              avg_r = avg_r + ((avgcol >> 16) & 0xFF); //<>//
              avg_g = avg_g + ((avgcol >> 16) & 0xFF);
              avg_b = avg_b + ((avgcol >> 16) & 0xFF);              
              cnt++;
            }
            avg_r = avg_r / cnt;
            avg_g = avg_g / cnt;
            avg_b = avg_b / cnt;
            col = color((byte)avg_r,(byte)avg_g,(byte)avg_b);
            break;
          }
          case MAX_VAL:
          {
            int max_val = 0;
            for (int ii=start; ii<stop;ii++)
            {
              color avgcol =  gfx.get(0,ii);
              if (((avgcol >> 16) & 0xFF) > max_val)
              {
                max_val =( (avgcol >> 16) & 0xFF);
                col = avgcol;
              }
              if (((avgcol >> 8) & 0xFF) > max_val)
              {
                max_val = ((avgcol >> 8) & 0xFF);
                col = avgcol;
              }
              if ((avgcol & 0xFF) > max_val)
              {
                max_val = (avgcol & 0xFF);
                col = avgcol;
              }
            }
            break;
          }   
          case WEIGHTED:
          {
            break;
          }
      }
      
      //Transfer Color Values into DMX Array
      dmxData[lightlist.get(jj).br] = (byte)255;
      dmxData[lightlist.get(jj).r_adr] = (byte)((col >> 16) & 0xFF);
      dmxData[lightlist.get(jj).g_adr] = (byte)((col >> 8) & 0xFF);
      dmxData[lightlist.get(jj).b_adr] = (byte)(col & 0xFF);
    }
    
    //Send DMX Array
    //println("ANU");
    
    //Test
    //for (int hh=0;hh<512;hh++)
    //  dmxData[hh] = byte(hh);
    
    artnet.broadcastDmx(0, 0, dmxData);
}

int POOFER_BASE = 384;
int POOFER_MODE = 12;
int POOFER_TRIGGER = 15;
int POOFER_EFFECT = 11;
int POOFER_T1 = 16;
int POOFER_T2 = 17;
int POOFER_T3 = 18;

int POOF_MODE_MANUAL = 0;
int POOF_MODE_SINGLE = 1;
int POOF_MODE_SMALL_BIG = 2;
int POOF_MODE_PULSE = 3;


//Reserving Adress 500-512 for Puffer Control
void puffer_control(int mode)
{
  println("Puffer Mode:"+mode);
  //Transfer Poofer Values into DMX Array
  dmxData[POOFER_BASE] = (byte)255;
  dmxData[POOFER_BASE+POOFER_EFFECT] = (byte)9;
  dmxData[POOFER_BASE+POOFER_MODE] = (byte)mode;
  dmxData[POOFER_BASE+POOFER_T1] = (byte)8;
  dmxData[POOFER_BASE+POOFER_T2] = (byte)32;
  dmxData[POOFER_BASE+POOFER_T3] = (byte)48;
  dmxData[POOFER_BASE+POOFER_TRIGGER] = (byte)255;
  
  //Send DMX Array
 // artnet.broadcastDmx(0, 0, dmxData);
}

void puffer_manual(boolean on)
{
  println("Puffer Manual:"+on);
  dmxData[POOFER_BASE] = (byte)255;
  dmxData[POOFER_BASE+POOFER_MODE] = (byte)POOF_MODE_MANUAL;
  if (on == true)
  {
    dmxData[POOFER_BASE+POOFER_TRIGGER] = (byte)255;
  }
  else
  {
    dmxData[POOFER_BASE+POOFER_TRIGGER] = (byte)0;
  }
  //Send DMX Array
 // artnet.broadcastDmx(0, 0, dmxData);
}

void puffer_reset()
{
  println("Puffer Reset:");
  dmxData[POOFER_BASE+POOFER_TRIGGER] = (byte)0;
}
