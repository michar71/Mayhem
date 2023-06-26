/*
Manages the bitmap buffer
- We operate on a pImage as it is faster to manipulate
- We create a buffer pImage every time we add/delete columns

*/

import java.util.*; 

class rgb_bmp_manager
{
  public PImage img;
  public int FX_Row_Count;
  public IntDict FX_Rows;
  
  rgb_bmp_manager()
  {
  }
  
//Geeral BMP Stuff
void new_bmp(String filen,int bmp_height)
{
  //create a new bitmap
  img = createImage(100,bmp_height,RGB);
  FX_Rows = new IntDict();
  //save it
  img.save(filen);
}


void save_bmp(String filen)
{
  img.save(filen);
}

boolean load_bmp(String filen,int fxrows)
{
  //Load Bitmap
  img = loadImage(filen);
  FX_Rows = new IntDict();
  
  if ((img == null) || (img.width == -1) || (img.height == -1))
  {
    FX_Row_Count = -1;
    return false;
  }
  else
  {
    set_fx_row_count(fxrows);
    return true;
  }
}


//Returns a 1-pixel width bitmap with the effect control pixels at the top removed
PImage get_bmp_column(int x_pos)
{
  PImage retval;
  retval = createImage(1,img.height-FX_Row_Count,RGB);
  retval.copy(img,x_pos,img.height-FX_Row_Count,1,img.height-FX_Row_Count,0,0,1,retval.height);
  return retval;
}

void set_bmp_column(int pos, PImage bitmapdata)
{
  img.copy(img,0,0,bitmapdata.width,bitmapdata.height,pos,img.height-FX_Row_Count,bitmapdata.width,img.height-FX_Row_Count);
}


//FX Tracks
void define_effect_track(int row, String effect)
{
  FX_Rows.set(effect, row);
}

color get_effect_val(String effect,int x_pos)
{
  color val;
  int row = FX_Rows.get(effect);
  val = img.get(x_pos,row);
  return val;
}

void set_fx_row_count(int row)
{
  FX_Row_Count = row;
}

//BMP Manipulation
void delete_columns(int pos,int size)
{
  //Get x size
  int newwidth = img.width - size;

  //create new pImage
  PImage copyImg;
  copyImg = createImage(newwidth,img.height,RGB);
  //Copy first part
  copyImg.copy(img,0,0,pos,img.height,0,0,pos,img.height);
  //copy second part
  copyImg.copy(img,pos+size,0,img.width-pos-size,img.height,pos,0,img.width-pos-size,img.height);
  //destroy img
  img = null;
  //recreate at new size
  img = createImage(newwidth,copyImg.height,RGB);
  //copy temporary image
  img.copy(copyImg,0,0,copyImg.width,copyImg.height,0,0,copyImg.width,copyImg.height);
}

void insert_columns(int pos, int size, color fillcol)
{
  //Get x size
  int newwidth = img.width + size;

  //create new pImage
  PImage copyImg;
  copyImg = createImage(newwidth,img.height,RGB);
  //Copy first part
  copyImg.copy(img,0,0,pos,img.height,0,0,pos,img.height);
  //copy second part
  copyImg.copy(img,pos+size,0,img.width-pos,img.height,pos+size,0,img.width-pos,img.height);
  //Fill new Dats
  noStroke();
  fill(fillcol);
  rect(pos,0,size,img.height);
  //destroy img
  img = null;
  //recreate at new size
  img = createImage(newwidth,copyImg.height,RGB);
  //copy temporary image
  img.copy(copyImg,0,0,copyImg.width,copyImg.height,0,0,copyImg.width,copyImg.height);
}



}
