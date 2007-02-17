package org.glast.pipeline.web.taglib.taskmap;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.jstl.core.Config;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import javax.sql.DataSource;
import org.glast.pipeline.web.util.*;
/**
 * A tag for uploading xml files to the pipeline database
 * @author tonyj
 */
public class TaskMap extends SimpleTagSupport
{
    private int task;
    private static final Logger logger = Logger.getLogger(TaskMap.class.getPackage().getName());
    
    public void doTag() throws JspException, IOException
    {
        try
        {
            HttpSession session = ((PageContext) getJspContext()).getSession();
            Connection connection = ConnectionManager.getConnection((PageContext) getJspContext(), null);
            try
            {
                Task t = new Task(task, connection);
                String dotCommand = session.getServletContext().getInitParameter("dotCommand");
                GraphViz gv = new GraphViz(dotCommand);
                StringWriter sw = new StringWriter();
                t.draw(sw);
                ByteArrayOutputStream bytes = gv.getGraph(sw.toString(),GraphViz.Format.CMAP);
                JspWriter writer = getJspContext().getOut();
                writer.println("<map name=\"taskMap"+task+"\">");
                writer.println(bytes.toString());
                writer.println("</map>");
                writer.println("<img src=\"TaskImageServlet?task="+task+"\" usemap=\"taskMap"+task+"\"/>");
            }
            catch (IOException x)
            {
                // Can happen if GraphViz is not installed, so just log and ignore
                logger.log(Level.SEVERE,"Error while creating task image map",x);
            }
            finally
            {
                connection.close();
            }
        }
        catch (SQLException x)
        {
            throw new JspException("Error creating task map",x);
        }
    }
    
    public void setTask(int task)
    {
        this.task = task;
    }
    
}