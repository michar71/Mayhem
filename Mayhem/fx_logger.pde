import java.util.*;
import java.lang.*;
import java.time.*;
  
  class fx_logger{
    boolean ltp = true;
    boolean ltf = false;
    PrintWriter output;
    
    fx_logger()
    {
      if (ltf)
      {
        LocalTime now = LocalTime.now();
       output = createWriter("logs/LOG_"+LocalDate.now().toString()+"_"+now.getHour()+"-"+now.getMinute()+".txt");
      }

      log("");
      log("Log Started Date:"+ LocalDate.now().toString());
      log("--------------------------------");

    }

    void setLoggerParameters(boolean logToPrint,boolean logToFile)
    {
      ltp = logToPrint;
      ltf = logToFile;
    }

    void log(String data)
    {
      if (ltp)
      {
        print(LocalTime.now().toString());
        print(":");
        println(data);
      }

      if (ltf)
      {
        output.print(LocalTime.now().toString());
        output.print(":");
        output.println(data);
        output.flush();
        //No Close? Who know what will hasppen, have to test it....
      }
    }

  }
