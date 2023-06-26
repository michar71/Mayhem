//This class manages a list of time marks from a song i relationship to 
//the location in an RGB image, brightness, decay and other parameters.

class playback_timing_list
{
  class playback_timing_entry implements Comparable<playback_timing_entry> 
  {
      public long sample_time;
      public int bitmap_x_pos;
      public int brightness; //0..100 [percent]
      public int decay;      //0..100 [percent decay between frames]
      public String note;

      
      playback_timing_entry(long  sample_time, int bitmap_x_pos, int brightness, int decay,String note)
      {
        this.sample_time = sample_time;
        this.bitmap_x_pos = bitmap_x_pos;
        this.brightness = brightness;
        this.decay = decay;
        this.note = note;
      }
      
     // Override the compareTo() method
      public int compareTo(playback_timing_entry c)
      {
          if (sample_time > c.sample_time) {
              return 1;
          }
          else if (sample_time < c.sample_time) {
              return -1;
          }
          else {
              return 0;
          }
      }      
  };

  public TreeSet<playback_timing_entry> timing_list = new TreeSet<playback_timing_entry>();

  
  playback_timing_list()
  {
    clear_timing_list();
  }
  
  void clear_timing_list()
  {
    timing_list.clear();
  }
  
  void add_entry(long sample_time,int bitmap_x_pos,int brightness,int decay,String note)
  {
    playback_timing_entry entry = new playback_timing_entry(sample_time, bitmap_x_pos, brightness, decay, note);
    timing_list.add(entry);
  }
  
  void remove_entry(long position)
  {
    //Find entry
    playback_timing_entry entry = new playback_timing_entry(position, 0, 0, 0, "");
    //remove entry
    timing_list.remove(entry);
  }
  
  void remove_section(long start, long end)
  {
    TreeSet<playback_timing_entry> delete_list = new TreeSet<playback_timing_entry>();
    //find section of elements
    playback_timing_entry entry1 = new playback_timing_entry(start-1, 0, 0, 0, "");
    playback_timing_entry entry2 = new playback_timing_entry(end, 0, 0, 0, "");
    
    delete_list =  (TreeSet<playback_timing_entry>)timing_list.subSet(entry1,entry2);
    
    // Creating an Iterator
    Iterator iterate;
    iterate = delete_list.iterator();

    // Iterating through the subset
    while (iterate.hasNext()) 
    {
      timing_list.remove(iterate.next());
    }        
  }
  
  void copy_section(long  start, long  end, long  newStart)
  {
    TreeSet<playback_timing_entry> add_list = new TreeSet<playback_timing_entry>(); //<>//
    TreeSet<playback_timing_entry> copy_list = new TreeSet<playback_timing_entry>();
    //find section of elements
    playback_timing_entry entry1 = new playback_timing_entry(start-1, 0, 0, 0, "");
    playback_timing_entry entry2 = new playback_timing_entry(end, 0, 0, 0, "");
    
    
    copy_list =  (TreeSet<playback_timing_entry>)timing_list.subSet(entry1,entry2);
    
    // Creating an Iterator
    Iterator iterate;
    iterate = copy_list.iterator();

    // Iterating through the subset
    while (iterate.hasNext()) 
    {
      playback_timing_entry copy_entry = new playback_timing_entry(0,0,0,0,"");
      copy_entry = (playback_timing_entry)iterate.next();      
      copy_entry.sample_time = newStart + (copy_entry.sample_time -start);
      add_list.add(copy_entry);
    }   
    timing_list.addAll(add_list);
  }
  
  void retime_section(long  start, long  duration, long  new_start)
  {
  }
  
  boolean check_entry(long position)
  {
    //Find entry
    playback_timing_entry entry = new playback_timing_entry(position, 0, 0, 0, "");    
    return timing_list.contains(entry);
  }

  
  playback_timing_entry get_entry_by_sample_time(long pos)
  {
      playback_timing_entry entry = new playback_timing_entry(pos, 0, 0, 0, "");
      
      //Check if this entry exists
      if (check_entry(pos))
      {
        //retrieve entry... this is dumb, there must be an easier way to get to it....
        entry.sample_time = entry.sample_time -1;
        return (playback_timing_entry)timing_list.higher(entry);
      }
      return null;
  }
  
  int get_posx_by_sample_time(long pos)
  {
    playback_timing_entry entry = get_entry_by_sample_time(pos);
    if (entry == null)
      return -1;
    else
      return entry.bitmap_x_pos;
  }
  


  boolean load_list_from_file(String fname)
  {
    //Generate filename
    JSONArray values;
    String filename = fname + ".json";
    
    //Check if file exists
    File f = dataFile(filename);
    boolean exist = f.isFile();
    if (exist == false)
    {
        save_list_to_file(fname);
        return false;
    }
  
    //Load data from file  
    clear_timing_list();
    values = loadJSONArray(filename);
    for (int i = 0; i < values.size(); i++) 
    {   
      JSONObject setting = values.getJSONObject(i); 
      
      
      String note = setting.getString("note");
      int posx = setting.getInt("posx");
      int sample = setting.getInt("sample");
      int decay = setting.getInt("decay");
      int br = setting.getInt("br");
      add_entry(sample,posx,br,decay,note);
    }
    return true;
  }
    
  boolean save_list_to_file(String fname)
  {
    playback_timing_entry entry = new playback_timing_entry(0, 0, 0, 0, "");
    JSONArray values;
     //create filename
    String filename = fname + ".json";
    filename = dataPath(filename);
  
    
    //Save Data to file (We iterate through the current property list)
    values = new JSONArray();
    
    // Creating an Iterator
    Iterator iterate;
    iterate = timing_list.iterator();
    int i = 0;

    // Iterating through the subset
    while (iterate.hasNext()) 
    {
        JSONObject setting = new JSONObject();
        setting.setString("note",entry.note);
        setting.setInt("posx",entry.bitmap_x_pos);
        setting.setInt("sample",(int)entry.sample_time);
        setting.setInt("decay",entry.decay);
        setting.setInt("br",entry.brightness);
        values.setJSONObject(i, setting);
        i++;
    } 
    saveJSONArray(values, filename); 
    return true;
  }
    
}
