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
    
    fx_artnet_entry(int pos, int id, int r,int g, int b)
    {
      y_pos = pos;
      artnet_id = id;
      r_adr = r;
      g_adr = g;
      b_adr = b;
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
   lightlist.add(new fx_artnet_entry(128,0,1,2,3));
  
  
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
    clearData();
    
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
      dmxData[lightlist.get(jj).r_adr] = (byte)((col >> 16) & 0xFF);
      dmxData[lightlist.get(jj).g_adr] = (byte)((col >> 8) & 0xFF);
      dmxData[lightlist.get(jj).b_adr] = (byte)(col & 0xFF);
    }
    
    //Send DMX Array
    artnet.broadcastDmx(0, 0, dmxData);
}

}
