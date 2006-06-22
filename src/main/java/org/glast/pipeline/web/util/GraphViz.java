// GraphViz.java - a simple API to call dot from Java programs

/*$Id: GraphViz.java,v 1.3 2006-06-22 21:12:24 dflath Exp $*/
/*
 ******************************************************************************
 *                                                                            *
 *              (c) Copyright 2003 Laszlo Szathmary                           *
 *                                                                            *
 * This program is free software; you can redistribute it and/or modify it    *
 * under the terms of the GNU Lesser General Public License as published by   *
 * the Free Software Foundation; either version 2.1 of the License, or        *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful, but        *
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY *
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public    *
 * License for more details.                                                  *
 *                                                                            *
 * You should have received a copy of the GNU Lesser General Public License   *
 * along with this program; if not, write to the Free Software Foundation,    *
 * Inc., 675 Mass Ave, Cambridge, MA 02139, USA.                              *
 *                                                                            *
 ******************************************************************************
 */
package org.glast.pipeline.web.util;
import java.io.*;

/**
 * <dl>
 * <dt>Purpose: GraphViz Java API
 * <dd>
 * 
 * <dt>Description:
 * <dd> With this Java class you can simply call dot
 *      from your Java programs
 * <dt>Example usage:
 * <dd>
 * <pre>
 *    GraphViz gv = new GraphViz();
 *    gv.addln(gv.start_graph());
 *    gv.addln("A -> B;");
 *    gv.addln("A -> C;");
 *    gv.addln(gv.end_graph());
 *    System.err.println(gv.getDotSource());
 * 
 *    File out = new File("out.gif");
 *    gv.writeGraphToFile(gv.getGraph(gv.getDotSource()), out);
 * </pre>
 * </dd>
 * 
 * </dl>
 * 
 * 
 * @author Laszlo Szathmary (<a href="szathml@delfin.unideb.hu">szathml@delfin.unideb.hu</a>)
 * @version v0.1, 2003/12/04 (Decembre)
 */
public class GraphViz
{
   private String dotCommand = "dot";

   public GraphViz(String dotCommand) {
      String dotHome = System.getenv("DOT_HOME");
      if (dotHome != null) {
         this.dotCommand = dotHome+File.pathSeparator+"dot";
      }
      else if (dotCommand != null) {
         this.dotCommand = dotCommand;
      }
   }
   
   public byte[] getDotImage(String dotSource) throws java.io.IOException {
      File tempDotFile;
      String tempDotFileName;
      try {
         tempDotFile = File.createTempFile("temp_", ".dot");
         FileWriter fout = new FileWriter(tempDotFile);
         fout.write(dotSource);
         fout.close();
      } catch (Exception e) {
         System.err.println("Error: I/O error while writing the dot source to temp file!");
         e.printStackTrace();
         return null;
      }
      return null;
      
   }

    /**
    * Writes the source of the graph in a file, and returns the written file
    * as a File object.
    * @param str Source of the graph (in dot language).
    * @return The file (as a File object) that contains the source of the graph.
    */
   private File writeDotSourceToFile(String str) throws java.io.IOException
   {
      File temp;
      try {
         temp = File.createTempFile("temp_", ".dot");
         FileWriter fout = new FileWriter(temp);
         fout.write(str);
         fout.close();
      } catch (Exception e) {
         System.err.println("Error: I/O error while writing the dot source to temp file!");
         e.printStackTrace();
         return null;
      }
      return temp;
   }

  /**
    * Returns the graph as an image in binary format.
    * @param dot_source Source of the graph to be drawn.
    * @return A byte array containing the image of the graph.
    */
   public byte[] getGraph(String dot_source)
   {
      File dot;
      byte[] img_stream = null;
   
      try {
         dot = writeDotSourceToFile(dot_source);
         if (dot != null)
         {
            img_stream = get_img_stream(dot);
            if (dot.delete() == false) 
               System.err.println("Warning: " + dot.getAbsolutePath() + " could not be deleted!");
            return img_stream;
         }
         return null;
      } catch (java.io.IOException ioe) { return null; }
   }

   /**
    * Writes the graph's image in a file.
    * @param img   A byte array containing the image of the graph.
    * @param file  Name of the file to where we want to write.
    * @return Success: 1, Failure: -1
    */
   public int writeGraphToFile(byte[] img, String file)
   {
      try {
         FileOutputStream fos = new FileOutputStream(file);
         fos.write(img);
         fos.close();
      } catch (java.io.IOException ioe) { return -1; }
      return 1;
   }

   /**
    * Writes the graph's image in a file.
    * @param img   A byte array containing the image of the graph.
    * @param to    A File object to where we want to write.
    * @return Success: 1, Failure: -1
    */
   /*
   public int writeGraphToFile(byte[] img, File to)
   {
      try {
         FileOutputStream fos = new FileOutputStream(to);
         fos.write(img);
         fos.close();
      } catch (java.io.IOException ioe) { return -1; }
      return 1;
   }
*/
   /**
    * It will call the external dotFile program, and return the image imgInputStream
    * binary format.
    * 
    * 
    * @param dotFile Source of the graph (imgInputStream dotFile language).
    * @return The image of the graph imgInputStream .gif format.
    */
   private byte[] get_img_stream(File dotFile)
   {
      File imgFile;
      byte[] imgBuffer = null;

      try {
         imgFile = File.createTempFile("temp_", ".gif");

         Runtime rt = Runtime.getRuntime();
         String cmd;
         
         // dot doesn't like long filenames (with spaces) so quote on windows:
         if (System.getProperties().getProperty("os.name").toUpperCase().contains("WINDOWS"))
            cmd = dotCommand + " -Tgif \""+ dotFile.getAbsolutePath() + "\" -o\"" + imgFile.getAbsolutePath() + "\"";
         else   
            cmd = dotCommand + " -Tgif "+ dotFile.getAbsolutePath() + " -o" + imgFile.getAbsolutePath() + "";
         
         java.lang.Process p = rt.exec(cmd);
         p.waitFor();
         FileInputStream imgInputStream = new FileInputStream(imgFile.getAbsolutePath());
         imgBuffer = new byte[imgInputStream.available()];
         imgInputStream.read(imgBuffer);
         imgInputStream.close();

         if (!imgFile.delete()) 
            System.err.println("Warning: " + imgFile.getAbsolutePath() + " could not be deleted!");
      }
      catch (java.io.IOException ioe) {
         ioe.printStackTrace();
      }
      catch (java.lang.InterruptedException ie) {
         ie.printStackTrace();
      }
      
      return imgBuffer;
   }

}
