package org.glast.pipeline.upload;

import java.io.File;
import java.io.FileReader;
import java.io.Reader;
import java.sql.Connection;
import java.sql.DriverManager;

/**
 *
 * @author tonyj
 * @version $Id: Main.java,v 1.1.2.1 2006-06-11 16:50:22 tonyj Exp $
 */
public class Main
{
   /**
    * @param args the command line arguments
    */
   public static void main(String[] args) throws Exception
   {
      String userName = System.getProperty("user.name");
      
      Reader in = new FileReader(new File(args[0]));
      
      Class.forName("oracle.jdbc.driver.OracleDriver");
      
      String url = System.getProperty("db.url","jdbc:oracle:thin:@glast-oracle01.slac.stanford.edu:1521:GLASTP");
      String username = System.getProperty("db.user","GLAST_DP");
      String password = System.getProperty("db.password","BT33%Q9]MU");
      
      Connection connection = DriverManager.getConnection(url,username,password);
      connection.setAutoCommit(false);
      
      Importer importer = new Importer();
      importer.execute(connection,userName,in);
      
      connection.commit();
      connection.close();
   }
}
