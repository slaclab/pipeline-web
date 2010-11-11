package org.glast.pipeline.web.xml;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.glast.datahandling.common.util.sql.PipelineConnectionManager;
import org.glast.datahandling.common.util.sql.PipelineConnectionManager.DatabaseServerAlias;
import org.jdom.CDATA;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.output.Format;
import org.jdom.output.Format.TextMode;
import org.jdom.output.XMLOutputter;

/**
 * Export a pipeline II task to XML using JDOM
 * @author tonyj
 */
public class Exporter
{
   private final PreparedStatement taskStatement;
   private final PreparedStatement subTaskStatement;
   private final PreparedStatement processStatement;
   private final PreparedStatement scriptStatement;
   private final PreparedStatement batchStatement;
   private final PreparedStatement prerequisitesStatement;
   private final PreparedStatement processVariablesStatement;
   private final PreparedStatement taskVariablesStatement;
   private final PreparedStatement dependsStatement;
   private final PreparedStatement createSubTaskStatement;
   private final PreparedStatement xmlClobStatement;
   private final Namespace ns = Namespace.getNamespace("http://glast-ground.slac.stanford.edu/pipeline");
   
   /** Creates a new instance of Exporter */
   public Exporter(Connection conn) throws SQLException
   {
      taskStatement = conn.prepareStatement("select * from task left outer join notation using(task) where task=?");
      subTaskStatement = conn.prepareStatement("select task from task where parenttask=?");
      prerequisitesStatement = conn.prepareStatement("select * from prerequisites where task=?");
      processStatement = conn.prepareStatement("select * from process where task=?");
      scriptStatement = conn.prepareStatement("select * from scriptprocess where process=?");
      batchStatement = conn.prepareStatement("select * from batchprocess where process=?");
      processVariablesStatement = conn.prepareStatement("select * from processvar where process=?");
      taskVariablesStatement = conn.prepareStatement("select * from taskvar where task=?");
      dependsStatement = conn.prepareStatement("select c.processingStatus, case when p.task=t.task then d.processName else t.taskName||'.'||d.processName end dependentProcessName from processstatuscondition c join process d on (c.process=d.process) join task t on (d.task=t.task) join process p on (p.process=c.dependentprocess) where p.process=?");
      createSubTaskStatement = conn.prepareStatement("select taskname from createsubtaskcondition join task on (task=subtask) where process=?");
      xmlClobStatement = conn.prepareStatement("select xmlsource from task where task=? and xmlsource is not null");
   }
   public void close() throws SQLException
   {
      taskStatement.close();
      subTaskStatement.close();
      processStatement.close();
      scriptStatement.close();
      batchStatement.close();
      prerequisitesStatement.close();
      processVariablesStatement.close();
      taskVariablesStatement.close();
      dependsStatement.close();
      createSubTaskStatement.close();
      xmlClobStatement.close();
   }
   public void export(Writer out, long task, boolean forceDump) throws SQLException, IOException
   {
      boolean done = false;
      if (!forceDump)
      {
         done = dumpFromClob(out,task);
      }
      if (!done) dumpFromDatabase(out,task);
   }
   private boolean dumpFromClob(Writer out, long task) throws SQLException, IOException
   {
      xmlClobStatement.setLong(1,task);
      ResultSet rs = xmlClobStatement.executeQuery();
      try
      {
         if (rs.next())
         {
            Reader in = new InputStreamReader(rs.getClob(1).getAsciiStream());
            char[] cbuf = new char[8000];
            for (;;)
            {
               int l = in.read(cbuf);
               if (l<0) break;
               out.write(cbuf,0,l);
            }
            in.close();
            out.flush();
            return true;
         }
         else return false;
      }
      finally
      {
         rs.close();
      }
   }
   private void dumpFromDatabase(Writer out, long task) throws SQLException, IOException
   {
      Document doc = export(task);
      Format format = Format.getPrettyFormat();
      format.setTextMode(TextMode.PRESERVE);
      XMLOutputter outputter = new XMLOutputter(format);
      outputter.output(doc,out);
   }
   private Document export(long task) throws SQLException
   {
      Document doc = new Document();
      Element pipelineElement = new Element("pipeline",ns);
      doc.setRootElement(pipelineElement);
      pipelineElement.setAttribute("schemaLocation",
                "http://glast-ground.slac.stanford.edu/pipeline http://glast-ground.slac.stanford.edu/Pipeline-II/schemas/2.0/pipeline.xsd",
                Namespace.getNamespace("xs", "http://www.w3.org/2001/XMLSchema-instance"));
      
      exportTask(pipelineElement,task);
      return doc;
   }
   private void exportTask(Element pipelineElement,long task) throws SQLException
   {
      taskStatement.setLong(1,task);
      ResultSet rs = taskStatement.executeQuery();
      rs.next();
      
      Element taskElement = new Element("task",ns);
      pipelineElement.addContent(taskElement);
      taskElement.setAttribute("name",rs.getString("taskname"));
      taskElement.setAttribute("type",rs.getString("tasktype"));
      taskElement.setAttribute("version",rs.getString("version")+"."+rs.getString("revision"));
      
      String notation = rs.getString("comments");
      if (!empty(notation))
      {
         Element notationElement = new Element("notation",ns);
         taskElement.addContent(notationElement);
         notationElement.addContent(notation);
      }
      rs.close();
      
      taskVariablesStatement.setLong(1,task);
      rs = taskVariablesStatement.executeQuery();
      exportVariables(taskElement,rs);
      rs.close();
      
      prerequisitesStatement.setLong(1,task);
      rs = prerequisitesStatement.executeQuery();
      if (rs.next())
      {
         Element prerequisitesElement = new Element("prerequisites",ns);
         taskElement.addContent(prerequisitesElement);
         do
         {
            Element prerequisiteElement = new Element("prerequisite",ns);
            prerequisitesElement.addContent(prerequisiteElement);
            prerequisiteElement.setAttribute("name",rs.getString("varname"));
            prerequisiteElement.setAttribute("type",rs.getString("vartype").toLowerCase());
         }
         while (rs.next());
      }
      rs.close();
      
      processStatement.setLong(1,task);
      rs = processStatement.executeQuery();
      while (rs.next())
      {
         long process = rs.getLong("process");
         Element processElement = new Element("process",ns);
         taskElement.addContent(processElement);
         
         processVariablesStatement.setLong(1,process);
         ResultSet rs2 = processVariablesStatement.executeQuery();
         exportVariables(processElement,rs2);
         rs2.close();
         
         String processType = rs.getString("processtype");
         processElement.setAttribute("name",rs.getString("processname"));
         if ("SCRIPT".equals(processType))
         {
            scriptStatement.setLong(1,process);
            rs2 = scriptStatement.executeQuery();
            rs2.next();
            
            Element scriptElement = new Element("script",ns);
            processElement.addContent(scriptElement);
            scriptElement.addContent(new CDATA(rs2.getString("processcode")));
            rs2.close();
         }
         else if ("BATCH".equals(processType))
         {
            batchStatement.setLong(1,process);
            rs2 = batchStatement.executeQuery();
            rs2.next();
            
            Element jobElement = new Element("job",ns);
            processElement.addContent(jobElement);
            
            if (!empty(rs2.getString("maxCPUSeconds"))) jobElement.setAttribute("maxCPU",rs2.getString("maxCPUSeconds"));
            if (!empty(rs2.getString("maxWallClockSeconds"))) jobElement.setAttribute("maxWallClock",rs2.getString("maxWallClockSeconds"));
            if (!empty(rs2.getString("maxMemory"))) jobElement.setAttribute("maxMemory",rs2.getString("maxMemory"));
            if (!empty(rs2.getString("queue"))) jobElement.setAttribute("queue",rs2.getString("queue"));
            if (!empty(rs2.getString("allocationGroup"))) jobElement.setAttribute("allocationGroup",rs2.getString("allocationGroup"));
            if (!empty(rs2.getString("workingDir"))) jobElement.setAttribute("workingDir",rs2.getString("workingDir"));
            if (!empty(rs2.getString("logFile"))) jobElement.setAttribute("logFile",rs2.getString("logFile"));
            if (!empty(rs2.getString("jobName"))) jobElement.setAttribute("jobName",rs2.getString("jobName"));
            if (!empty(rs2.getString("batchOptions"))) jobElement.setAttribute("batchOptions",rs2.getString("batchOptions"));
            if (!empty(rs2.getString("priority"))) jobElement.setAttribute("priority",rs2.getString("priority"));
            boolean codeIsScript = rs2.getInt("codeIsScript")!=0;
            if (codeIsScript) jobElement.addContent(new CDATA("\n"+rs2.getString("processcode")+"\n"));
            else jobElement.setAttribute("executable",rs2.getString("processcode"));
            rs2.close();
         }
         dependsStatement.setLong(1,process);
         rs2 = dependsStatement.executeQuery();
         if (rs2.next())
         {
            Element dependsElement = new Element("depends",ns);
            processElement.addContent(dependsElement);
            do
            {
               Element dependElement = new Element("after",ns);
               dependsElement.addContent(dependElement);
               dependElement.setAttribute("process",rs2.getString("dependentProcessName"));
               dependElement.setAttribute("status",rs2.getString("processingStatus"));
            }
            while (rs2.next());
         }
         rs2.close();
         
         createSubTaskStatement.setLong(1,process);
         rs2 = createSubTaskStatement.executeQuery();
         if (rs2.next())
         {
            Element subtasksElement = new Element("createsSubtasks",ns);
            processElement.addContent(subtasksElement);
            do
            {
               Element subtaskElement = new Element("subtask",ns);
               subtasksElement.addContent(subtaskElement);
               subtaskElement.addContent(rs2.getString("taskName"));
            }
            while (rs2.next());
         }
         rs2.close();
      }
      rs.close();
      
      subTaskStatement.setLong(1,task);
      rs = subTaskStatement.executeQuery();
      List<Long> subTaskIds = new ArrayList<Long>();
      while (rs.next())
      {
         subTaskIds.add(rs.getLong("task"));
      }
      rs.close();
      for (long id : subTaskIds)
      {
         exportTask(taskElement,id);
      }
   }
   private void exportVariables(Element element, ResultSet rs) throws SQLException
   {
      if (rs.next())
      {
         Element variablesElement = new Element("variables",ns);
         element.addContent(variablesElement);
         do
         {
            Element variableElement  = new Element("var",ns);
            variablesElement.addContent(variableElement);
            variableElement.setAttribute("name",rs.getString("varname"));
            variableElement.addContent(rs.getString("value"));
         }
         while (rs.next());
      }
   }
   private boolean empty(String s)
   {
      return s==null || s.length()==0;
   }
   public static void main(String args[]) throws Exception, SQLException, IOException
   {
      PipelineConnectionManager manager = PipelineConnectionManager.instance(DatabaseServerAlias.DEV);      
      Connection conn = manager.getConnection();
      Exporter exporter = new Exporter(conn);
      exporter.export(new OutputStreamWriter(System.out),94908,false);
      conn.close();
   }
}
