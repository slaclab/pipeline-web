// GraphViz.java - a simple API to call dot from Java programs

/*$Id: GraphViz.java,v 1.5 2006-08-03 20:24:23 tonyj Exp $*/
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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

/**
 * <dl>
 * <dt>Purpose: GraphViz Java API
 * <dd>
 *
 * <dt>Description:
 * <dd> With this Java class you can simply call dot
 *      from your Java programs
 * </dl>
 *
 *
 * @author Laszlo Szathmary (<a href="szathml@delfin.unideb.hu">szathml@delfin.unideb.hu</a>)
 * @author Modified for glast by Dan Falth, Tony Johnson
 * @version $Id: GraphViz.java,v 1.5 2006-08-03 20:24:23 tonyj Exp $
 */
public class GraphViz
{
    private String dotCommand = "dot";
    public enum Format 
    { 
        GIF("-Tgif"), IMAP("-Timap"), ISMAP("-Tismap"), CMAP("-Tcmap"),;
        private String option;
        Format(String option)
        {
            this.option = option;
        }
        String getOption()
        {
            return option;
        }
    };
    
    public GraphViz(String dotCommand)
    {
        String dotHome = System.getenv("DOT_HOME");
        if (dotHome != null)
        {
            this.dotCommand = dotHome+File.pathSeparator+"dot";
        }
        else if (dotCommand != null)
        {
            this.dotCommand = dotCommand;
        }
    }
    
    
    /**
     * Returns the graph as an image in binary format.
     * @param dot_source Source of the graph to be drawn.
     * @return A byte array containing the image of the graph.
     */
    public ByteArrayOutputStream getGraph(String dotFile) throws IOException
    {
        return getGraph(dotFile, Format.GIF);
    }
    public ByteArrayOutputStream getGraph(String dotFile, Format format) throws IOException
    {
        try
        {
            ProcessBuilder builder = new ProcessBuilder(dotCommand, format.getOption());
            java.lang.Process process = builder.start();
            PushThread push = new PushThread(dotFile,process.getOutputStream());
            push.start();
            PullThread pull = new PullThread(process.getInputStream());
            pull.start();
            PullThread error = new PullThread(process.getErrorStream());
            error.start();
            int rc = process.waitFor();
            pull.join();
            error.join();
            push.join();
            if (error.getData().size() > 0) throw new IOException("Error from dot: "+new String(error.getData().toByteArray()));
            error.reportException();
            pull.reportException();
            push.reportException();
            if (rc != 0) throw new IOException("Unexpected return code from dot "+rc);
            return pull.getData();
        }
        catch (InterruptedException x)
        {
            throw new InterruptedIOException("Interrupt while waiting for dot");
        }
    }
    private class PushThread extends Thread
    {
        private final String file;
        private final Writer out;
        private IOException x;
        PushThread(String file, OutputStream out)
        {
            this.out = new OutputStreamWriter(out);
            this.file = file;
        }
        public void run()
        {
            try
            {
                out.write(file);
                out.close();
            }
            catch (IOException x)
            {
                this.x = x;
            }
        }
        void reportException() throws IOException
        {
            if (x != null) throw x;
        }
    }
    private class PullThread extends Thread
    {
        private final ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        private final InputStream in;
        private IOException x;
        PullThread(InputStream in)
        {
            this.in = in;
        }
        public void run()
        {
            try
            {
                byte[] buffer = new byte[1024];
                for (;;)
                {
                    int l = in.read(buffer);
                    if (l<0) break;
                    bytes.write(buffer,0,l);
                }
                bytes.close();
                in.close();
            }
            catch (IOException x)
            {
                this.x = x;
            }
        }
        void reportException() throws IOException
        {
            if (x != null) throw x;
        }
        ByteArrayOutputStream getData()
        {
            return bytes;
        }
    }
}
