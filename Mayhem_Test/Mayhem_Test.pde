import java.util.*;
import java.lang.*;

playback_timing_list ptl;


void printlist()
{
     playback_timing_list.playback_timing_entry copy_entry;
      // Creating an Iterator
    Iterator iterate;
    iterate = ptl.timing_list.iterator();

    // Displaying the tree set data
    System.out.println("List Content: ");

    // Iterating through the tailSet
    while (iterate.hasNext()) {
        copy_entry = (playback_timing_list.playback_timing_entry)iterate.next();
        println("ST:" + copy_entry.sample_time + " XP:"+copy_entry.bitmap_x_pos+" N: "+copy_entry.note);
    }
}

void setup() {
  ptl = new playback_timing_list();
  //Add a bunch of entries to the List
  ptl.add_entry(0,100,0,0,"Test 0");
  ptl.add_entry(1,200,0,0,"Test 1");
  ptl.add_entry(2,300,0,0,"Test 2");
  ptl.add_entry(3,400,0,0,"Test 3");
  
  ptl.add_entry(10,500,0,0,"Test 10");
  ptl.add_entry(20,600,0,0,"Test 20");
  ptl.add_entry(15,700,0,0,"Test 15");
  ptl.add_entry(30,800,0,0,"Test 30");
  
  ptl.add_entry(11,900,0,0,"Test 11");
  ptl.add_entry(12,1000,0,0,"Test 12");
  ptl.add_entry(40,1100,0,0,"Test 40");
  ptl.add_entry(30,1200,0,0,"Test 30");
  
  //Print the list
  printlist();
  
  //Remove a few entries
  ptl.remove_entry(2);
  ptl.remove_entry(4);
  ptl.remove_entry(11);
  //Print the list
  printlist();
  
  
  //Copy a few entries
  ptl.copy_section(10, 31, 400);
  //Print ther list
  printlist();
  
  
  //remove a few entries
  ptl.remove_section(10, 31);
  //Print ther list
  printlist();
  
  //Find some existing and non-existing entries
  int posx;
  
  posx = ptl.get_posx_by_sample_time(400);
  println("ST: 400 XPOS:" + posx); 
  posx = ptl.get_posx_by_sample_time(401);
  println("ST: 401 XPOS:" + posx); 
  posx = ptl.get_posx_by_sample_time(402);
  println("ST: 402 XPOS:" + posx); 
}

void draw() {
}
