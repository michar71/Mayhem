// Convert either RGB or HSB ro Red, Green Blue, White, Luminance for DMX LED lights
//In Pure mode we plend saturation from color pixels to the white pixels
//In Max mode we mix RGB together with white for maximum brightness

enum DMX_RGBWL_MODES
{
  MODE_MAX,    //Maximum brightness by mixing RGB and white together
  MODE_PURE,   //Better Color Rendition but lerss light
}

class dmx_rgbwl
{
    DMX_RGBWL_MODES mode = DMX_RGBWL_MODES.MODE_MAX;
    
    
  class rgbwl
  {
    int r;
    int g;
    int b;
    int w;
    int l;
    
   rgbwl(int ri, int gi, int bi , int wi, int li)
   {
     r = ri;
     g = gi;
     b = bi;
     w = wi;
     l = li;
   }
   
   int red() 
   {
     return r;
   }
   int green() 
   {
     return g;
   }
   int blue() 
   {
     return b;
   }
   int white() 
   {
     return w;
   }  
   int luminance()
   {
       return l;
   }
  }


  rgbwl rgb2rgbw(int r, int g, int b)
  {
    int ro = r;
    int go = g;
    int bo = b;
    int wo = 0;
    int lo = 0;
    if (mode == DMX_RGBWL_MODES.MODE_PURE)
    {
      colorMode(RGB, 255, 255, 255);
      color col = color(r,g,b);   
      lo = (int)brightness(col);
      wo = 255 - (int)saturation(col);
    }
    else
    {
      colorMode(RGB, 255, 255, 255);
      color col = color(r,g,b);    
      lo = (int)brightness(col);
      wo = (int)brightness(col);
    }
    
    rgbwl res =new rgbwl(ro,go,bo,wo,lo);
    return res;
  }

  rgbwl hsb2rgbw(int h, int s, int b)
  {
    int ro = 0;
    int go = 0;
    int bo = 0;
    int wo = 0;
    int lo = 0;
    if (mode == DMX_RGBWL_MODES.MODE_PURE)
    {
      colorMode(HSB, 255, 255, 255);
      color col = color(h,s,b);
      ro = (int)red(col);
      go = (int)green(col);
      bo = (int)blue(col);     
      lo = b;
      wo = 255 - s;
      colorMode(RGB, 255, 255, 255);
    }
    else
    {
      colorMode(HSB, 255, 255, 255);
      color col = color(h,s,b);
      ro = (int)red(col);
      go = (int)green(col);
      bo = (int)blue(col);     
      lo = b;
      wo = b;
      colorMode(RGB, 255, 255, 255);
    }
    
    rgbwl res =new rgbwl(ro,go,bo,wo,lo);
    return res;
  }
}
