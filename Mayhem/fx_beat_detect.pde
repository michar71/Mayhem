import java.util.*;


class fx_beat_Detect{
  private int beat = 0;
  private long [] ns_array = {0,0,0,0,0};
  private float bpm = 120.0;
  private boolean threadON = false;
  private long lastNanos, currentNanos;
  private int beatmode = 0;
  private long  ns_gap = 10000;
  
  fx_beat_Detect()
  {
  }
  
  void manualBeat()
  {
    if (beatmode == 0)
    {
      threadON=false;
      beatmode = 1;
      ns_array[0] = System.nanoTime();
      beat=0;
    }
    else
    {
      beat++;
      ns_array[beat] = System.nanoTime();
      if (beat==4)
      { 
        beatmode = 0;
        ns_gap = (ns_array[1] - ns_array[0]) + (ns_array[2] - ns_array[1]) + (ns_array[3] - ns_array[2] + (ns_array[4] - ns_array[3]));
        ns_gap = ns_gap / 4;
        bpm = (int)((60.0*1000.0*1000.0*1000.0)/ns_gap);
        println(ns_gap);
        println("BPM"+bpm);
        println(ns_array[0]+" "+ns_array[1]+" "+ns_array[2]+" "+ns_array[3]+" " +ns_array[4]+" ");
        lastNanos = System.nanoTime();
        threadON=true;
        beat=0;
        //frameRate((int)(bpm/4));
        thread("myThreadTimer");
      }
    }
  }
  

  
  
  int getBeat()
  {
    return beat;
  }
  
  int getBeatMode()
  {
    return beatmode;
  }
  
  float getBPM()
  {
    return bpm;
  }
  
  long getBeatGap()
  {
    return ns_gap;
  }
  
  //High Resolution Java Thread for Timer
void beatTimer() 
{
  println("THREAD START");
  
  while(threadON == true)
  {
      //println(threadON);
      currentNanos = System.nanoTime();
      if ( currentNanos-lastNanos >= ns_gap ) 
      {
        lastNanos = currentNanos;
          beat++;
          if (beat > 3)
          {
            beat = 0;
            next_beat_zero_time = currentNanos + (ns_gap*4);
          }
      }
      delay(1);
  }
  println("THREAD EXIT");
}
  
}
