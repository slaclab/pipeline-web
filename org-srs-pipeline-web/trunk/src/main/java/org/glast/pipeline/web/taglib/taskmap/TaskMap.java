package org.glast.pipeline.web.taglib.taskmap;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.SQLException;
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
    
    public void doTag() throws JspException, IOException
    {
        try
        {
            HttpSession session = ((PageContext) getJspContext()).getSession();
            Object dataSourceName = Config.get(session,Config.SQL_DATA_SOURCE);
            if (dataSourceName == null) dataSourceName = session.getServletContext().getInitParameter("javax.servlet.jsp.jstl.sql.dataSource");
            InitialContext initialContext = new InitialContext();
            DataSource dataSource = (DataSource) initialContext.lookup("java:comp/env/"+dataSourceName);
            Connection connection = dataSource.getConnection();
            try
            {
                JspWriter writer = getJspContext().getOut();
                writer.println("<map name=\"taskMap"+task+"\">");
                Task t = new Task(task, connection);
                String dotCommand = session.getServletContext().getInitParameter("dotCommand");
                GraphViz gv = new GraphViz(dotCommand);
                StringWriter sw = new StringWriter();
                t.draw(sw);
                ByteArrayOutputStream bytes = gv.getGraph(sw.toString(),GraphViz.Format.CMAP);
                writer.println(bytes.toString());
                writer.println("</map>");
                writer.println("<img src=\"TaskImageServlet?task="+task+"\" usemap=\"taskMap"+task+"\"/>");
            }
            finally
            {
                connection.close();
            }
        }
        catch (NamingException x)
        {
            throw new JspException("Error creating task map",x);
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