package org.glast.pipeline.web.taglib.taskmap;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.glast.pipeline.web.util.*;
/**
 * Task for displaying task image map
 * @author tonyj
 */
public class TaskMap extends SimpleTagSupport
{
    private int task;
    private String gvOrientation;
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
                GraphVizProperties gvProperties = new GraphVizProperties();
                gvProperties.addProperty(GraphVizProperties.RankDir.valueOf(gvOrientation));
                StringWriter sw = new StringWriter();
                t.draw(sw, gvProperties);
                ByteArrayOutputStream bytes = gv.getGraph(sw.toString(),GraphViz.Format.CMAP);
                JspWriter writer = getJspContext().getOut();
                writer.println("<map name=\"taskMap"+task+"\">");
                writer.println(bytes.toString());
                writer.println("</map>");
                writer.println("<img src=\"TaskImageServlet?task="+task+"&gvOrientation="+gvOrientation+"\" usemap=\"#taskMap"+task+"\" border=\"0\"/>");
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
    
    public void setGvOrientation(String gvOrientation) {
       this.gvOrientation = gvOrientation;
    }
    
}