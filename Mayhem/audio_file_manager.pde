
import java.util.*; 
import processing.sound.*;

class audio_file_manager
{
  public SoundFile soundfile;
  public Waveform waveform;
  public BeatDetector beatdetector;
  int samples;
  PApplet papplet;

  audio_file_manager(PApplet theParent)
  {
    papplet = theParent;
  }
  
  void load_audio_file(String filen,int winwidth)
  {
    // Load a soundfile
    soundfile = new SoundFile(papplet, filen);
  
    samples = winwidth*256;
    waveform = new Waveform(papplet, samples);
    waveform.input(soundfile);
    
    beatdetector = new BeatDetector(papplet);
    beatdetector.input(soundfile);
    beatdetector.sensitivity(200);
  }
  
  long get_sample_position()
  {
    return soundfile.positionFrame();
  }

  void set_sample_position(int pos)
  {
    soundfile.jumpFrame(pos);
  }

  long get_sample_length()
  {
    return soundfile.frames();
  }
  
  float get_time()
  {
    return soundfile.position();
  }
  
  void play(boolean run)
  {
    if (run)
       soundfile.play();
    else
       soundfile.pause();
  }
  

  boolean isPlaying()
  {
    return soundfile.isPlaying();
  }

  
  Waveform get_analyzer()
  {
    waveform.analyze();
    return waveform;
  }
  
  boolean is_beat()
  {
    return beatdetector.isBeat();
  }
  
}
