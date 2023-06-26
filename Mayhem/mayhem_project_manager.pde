class mayhem_project_manager
{
  playback_timing_list current_link_list;
  rgb_bmp_manager current_bmp;
  audio_file_manager current_audio;
  
  
  mayhem_project_manager(PApplet theParent)
  {
    //Create objects
    current_link_list = new playback_timing_list();
    current_bmp = new rgb_bmp_manager();
    current_audio = new audio_file_manager(theParent);
  }
  
  void load_project(String filen)
  {
    //Load Propject File
    //Load Timing List
    //Load Bitmap
    //Load MP3
  }
  
  void save_project(String filen)
  {
  }
  
  
  void load_project_file(String filen)
  {
  }
  
  void save_project_file(String filen)
  {
  }
  
  
  void new_project()
  {
  }
  
  StringList get_project_list()
  {
  }
  
  void start_playback()
  {
  }
  
  void pause_playback()
  {
  }
  
  void position_playback()
  {
  }
  
  //Do this 30 times/sec
  void update()
  {
    //Get Playback Position
    //Chekc if parameter existed in the last 1/30 sec
      //Look up Bitmap x-Pos
      //Look up parameters
      //If not FX
        //get bitmap Strip
        //Push Bitmap Strip to DMX Handler with Parameters 
      //else
        //Set FX
        
    //Update DMX_manager  
  }

}
