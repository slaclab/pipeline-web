package org.glast.pipeline.client;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * An exception suitable for throwing back to a remote client
 * @author tonyj
 */
public class RemoteException extends RuntimeException
{
   private String stacktrace;
   /** Creates a new instance of RemoteException */
   public RemoteException(Throwable t)
   {
      super(t.getMessage());
      StringWriter writer = new StringWriter();
      PrintWriter pw = new PrintWriter(writer);
      t.printStackTrace(pw);
      pw.close();
      stacktrace = writer.toString();
   }

   public void printStackTrace(PrintWriter s)
   {
      s.print(stacktrace);
   }
}
