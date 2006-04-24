package org.glast.pipeline.upload;

import java.io.File;
import java.io.FileReader;
import java.io.Reader;
import java.sql.Connection;
import java.sql.DriverManager;

/**
 *
 * @author tonyj
 * @version $Id: Main.java,v 1.1 2005-11-14 18:23:46 tonyj Exp $
 */
public class Main
{
   /**
    * @param args the command line arguments
    */
   public static void main(String[] args) throws Exception
   {
      String userName = System.getProperty("user.name");
      
      Reader in = new FileReader(new File("c:\\tonytest.xml"));
      
      Class.forName("oracle.jdbc.driver.OracleDriver");
      
      String url = "jdbc:oracle:thin:@slac-oracle02.slac.stanford.edu:1521:SLACDEV";
      String username = "GLAST_DP_TEST";
      String password = "BT33%Q9]MU";
      
      Connection connection = DriverManager.getConnection(url,username,password);
      connection.setAutoCommit(false);
      
      Importer importer = new Importer();
      importer.execute(connection,userName,in);
      
      connection.commit();
      connection.close();
   }
}