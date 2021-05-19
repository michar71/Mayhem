import java.util.*; 

class fx_linear_list{
  class fx_member
  {
      public String fx_name; 
      public fx_linear_base fx;
      
      fx_member(fx_linear_base fxs, String name)
      {
        fx_name = name;
        fx = fxs;
      }
  };

  public List<fx_member> fxlist = new ArrayList<fx_member>();
  int fxindex = 0;

fx_linear_list(int fxheight)
{
  //Add the Effects to a list
  fxlist.add(new fx_member((fx_linear_base)new fx_linear_test(fxheight),"Test"));
  fxlist.add(new fx_member((fx_linear_base)new fx_random_sparkles(fxheight),"Random Sparkles"));
  fxlist.add(new fx_member((fx_linear_base)new fx_rainbow(fxheight),"Rainbow")); 
  //This is currently hardcoded....
}

boolean hasNext()
{
  if ((fxindex+1) > fxlist.size()-1)
    return false;
  else 
    return true;
}

boolean hasPrevious()
{
  if ((fxindex-1) < 0)
    return false;
  else 
    return true;
}

fx_linear_base getNext()
{
  if (hasNext())
  {
    fxindex++;
    return fxlist.get(fxindex).fx;
  }
  return null;
}

fx_linear_base getPrevious()
{
  if (hasPrevious())
  {
    fxindex--;
    return fxlist.get(fxindex).fx;
  }
  return null;
}

String getFxName()
{
  return fxlist.get(fxindex).fx_name;
}

boolean setIndex(int index)
{
  if((index > 0) & (index < fxlist.size()-1))
  {
    fxindex = index;
    return true;
  }
  else
  {
    return false;
  }
}

int getIndex()
{
  return fxindex;
}

fx_linear_base getCurrent()
{
    return fxlist.get(fxindex).fx;
}

fx_linear_base findByName(String name)
{
  for (int jj=0;jj<fxlist.size();jj++)
  {
    if (fxlist.get(jj).fx_name.equals(name) == true)
      return fxlist.get(jj).fx;
  }
  return null;
}

fx_linear_base findByIndex(int ii)
{
  if (ii<fxlist.size())
  {
      return fxlist.get(ii).fx;
  }
  return null;
}

void getNames(List fxnames)
{
  for (int ii=0;ii< fxlist.size();ii++)
  {
    fxnames.add(fxlist.get(ii).fx_name);
  }
}

}
