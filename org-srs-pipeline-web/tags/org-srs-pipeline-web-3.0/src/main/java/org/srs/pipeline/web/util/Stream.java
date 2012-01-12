/*
 * Stream.java
 */

package org.srs.pipeline.web.util;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
      
import java.util.List;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import oracle.jdbc.pool.OracleDataSource;

/**
 *
 * @author dflath
 */
public class Stream
{
   // primitives from db record:
   private int streamPK;
   private int parentStreamPK;
   private int streamId;
   private int taskPK;
   private String status;
   private String taskName;
   
   // high-level constructs:
   private Stream parentStream;
   private Process creatingProcess;
   private List<Stream> subStreamList = new ArrayList<Stream>();
   private List<ProcessInstance> processInstanceList = new ArrayList<ProcessInstance>();

   protected void init(ResultSet rs, Connection conn, Stream parentStream) throws SQLException {
      streamPK = rs.getInt("STREAM");
      parentStreamPK = rs.getInt("PARENTSTREAM");
      streamId = rs.getInt("STREAMID");
      taskPK = rs.getInt("TASK");
      status = rs.getString("STREAMSTATUS");
      taskName = rs.getString("TASKNAME");
     
      this.parentStream = parentStream;
      
      // create sub-streams:
      while(rs.next()) {
//         if (rs.getInt("PARENTSTREAM") == this.streamPK)
            subStreamList.add(new Stream(rs,conn,this));
//         else {
//            parentStream.getSubStreamList().add(new Stream(rs,conn,this));
//         }
      }

      // create processes:
      PreparedStatement stmt = conn.prepareStatement("select PI.ProcessInstance, PI.Stream, PI.ProcessingStatus, P.Process, P.ProcessName, P.ProcessType from ProcessInstance PI, Process P where PI.Stream = ? and PI.Process = P.Process");
      try {
         stmt.setInt(1, streamPK);
         ResultSet processInstanceCursor = stmt.executeQuery();
         while (processInstanceCursor.next())
            processInstanceList.add(new ProcessInstance(this, processInstanceCursor));
      } finally {
         stmt.close();
      }
   }
   
   protected Stream(ResultSet rs, Connection conn, Stream parentStream) throws SQLException {
      init(rs, conn, parentStream);
   }
   
   /** Creates a new instance of Stream */
   public Stream(int stream_pk, Connection conn) throws SQLException
   {
      PreparedStatement stmt = conn.prepareStatement("select S.Stream, S.ParentStream, S.StreamId, S.Task, S.StreamStatus, T.TaskName from Stream S, Task T where S.Task = T.Task start with Stream=? connect by prior Stream = ParentStream");
      try {
         stmt.setInt(1, stream_pk);
         ResultSet rs = stmt.executeQuery();
         if (rs.next()) {
           init(rs, conn, null);
         } else {
            throw(new RuntimeException("Invalid stream primary key[" + stream_pk + "]!"));
         }
                  
         // Create Dependencies...
         calculateDependencies(conn);
         
      } finally {
         stmt.close();
      }
   }
   
   // field accessors:
   public Stream getParentStream() { return parentStream; }
   public int getId() { return streamId; }
   public String getStatus() { return status; }
   public String getTaskName() { return taskName; }
   public String getName() { return getTaskName() + "." + getId(); }
   public List<Stream> getSubStreamList() { return subStreamList; } // TODO:  Should this return an iterator?
   public List<ProcessInstance> getProcessInstanceList() { return processInstanceList; } // TODO:  Should this return an iterator?
   public int getDbStream() { return streamPK; }
   public int getDbParentStream() { return parentStreamPK; }
   public int getDbTask() { return taskPK; }
   
   public Stream findStream(int _dbStream) {
      // check if it's me:
      if (getDbStream() == _dbStream)
         return this;

      // not me, check children:
      for (Stream _stream : getSubStreamList()) {
         Stream t = _stream.findStream(_dbStream);
         if (t != null)
            return t;
      }
      
      // couldn't find it:
      return null;
   }
   
   public ProcessInstance findProcessInstance(int _dbProcessInstance) {
      // try to find the process at this stream level:
      for (ProcessInstance _processInstance : getProcessInstanceList()) {
         if (_processInstance.getProcessInstancePK() == _dbProcessInstance) {
            return _processInstance;
         }
      }
      
      // process is not at this stream level, check sub streams recursively:
      for (Stream _stream : getSubStreamList()) {
         ProcessInstance pi = _stream.findProcessInstance(_dbProcessInstance);
         // don't want to kill recursion early, there may be more subStreams to check:
         if (pi != null) 
            return pi;
      }
      
      // we never found it.
      return null;
   }
   
   public void calculateDependencies(Connection conn) throws SQLException {
      try {
         // find process dependencies:
         for (ProcessInstance pi : getProcessInstanceList()) {
            pi.buildProcessInstanceStatusDependencyList(conn);
            pi.buildProcessInstanceCompletionDependencyList(conn);
            pi.buildSubStreamCreationList(conn);
         }
      } finally {}
            
      // recurse down subStream chain:
      for (Stream s : getSubStreamList())
         s.calculateDependencies(conn);
   }
   
   public void print() { print(0); }
   public void print(int depth) {
      String indent = "";
      for (int i=0; i<depth; i++) {
         indent += "    ";
      }
      System.out.println(indent + "Stream(" + getTaskName() + "." + getId() + ") is:");
      indent += "  ";
      System.out.println(indent + "Status(" + getStatus() + ")");

      // tell Processes to print:
      if (getProcessInstanceList().size() > 0) {
         System.out.println(indent + "Process Instances:");
         for (ProcessInstance pi : getProcessInstanceList()) {
            pi.print(depth + 1);
         }
      }
      
      // tell sub Streams to print:
      if (getSubStreamList().size() > 0) {
         System.out.println(indent + "Sub-Streams:");
         for (Stream stream : getSubStreamList()) {
            stream.print(depth + 1);
         }
      }
   }

   int draw(Writer writer, String indent, int cluster, Map<Stream, ProcessInstance> subStreamCreatorMap) throws IOException 
   {
      String indentIn = indent; // save original indent for header and footer
      indent += "\t"; // indent body of this subgraph one more tab

      // draw stream:
      writer.write(indentIn + "subgraph cluster" + cluster + " {\n"); // header (subgraph id)
      writer.write(indent + "label=\"" + getName() + "\";\n"); // title
      writer.write(indent + "color=blue;\n"); // for the border
//      writer.write(indent + "URL=\"stream.jsp?stream="+streamPK+"\";\n");
      
      // draw processes:
      for (ProcessInstance pi : getProcessInstanceList()) {
         // name and label the node:
//         writer.write(indent + pi.getProcessInstancePK() + " [label=\"" + pi.getName() + "\", URL=\"process.jsp?process="+pi.getProcessInstancePK()+"\" ];\n");
         writer.write(indent + pi.getProcessInstancePK() + " [label=\"" + pi.getName() + "\"];\n");
         // connect, with edges, processes we depend upon:
         for (Map.Entry<ProcessInstance, String> e: pi.getProcessInstanceStatusDependencyMap().entrySet()) {
            ProcessInstance dpi = e.getKey();
            writer.write(indent + dpi.getProcessInstancePK() + "->" + pi.getProcessInstancePK() + " [label=\"" + e.getValue() + "\",fontsize=8];\n");
         }
         // connect, with edges, processes we depend on the completion of:
         for (ProcessInstance dpi : pi.getProcessInstanceCompletionDependencyList()) {
            writer.write(indent + dpi.getProcessInstancePK() + "->" + pi.getProcessInstancePK() + " [label=\"DONE\",fontsize=8];\n");
         }      
         
         // add a map entry for eatch SubStream this process can create streams for:
         for (Stream s : pi.getSubStreamCreationList()) {
            subStreamCreatorMap.put(s, pi);
         }
      }

      // draw subStreams:
      for (Stream t : getSubStreamList()) {
         cluster = t.draw(writer, indent, ++cluster, subStreamCreatorMap);
      }
                        
      writer.write(indentIn + "}\n"); // footer
      if (subStreamCreatorMap.containsKey(this)) {
         int someProcInst = getProcessInstanceList().get(0).getProcessInstancePK();
         writer.write(indentIn + subStreamCreatorMap.get(this).getProcessInstancePK() + " -> " + someProcInst + "[lhead=cluster"+ cluster +", style=dashed, color=red];\n");
         subStreamCreatorMap.remove(this);
      }

      return cluster;
   }
   
   public void draw(Writer writer) throws IOException {
      try {
         String indent = "\t";
         
         // write the header:
         writer.write("digraph G {\n");
         writer.write(indent + "compound=true;\n");
//         writer.write(indent + "rankdir=\"LR\";\n");

         // enter the recursive drawing routine:
         Map<Stream, ProcessInstance> subStreamCreatorMap = new HashMap<Stream, ProcessInstance>();
         draw(writer, indent, 0, subStreamCreatorMap);

         // write the footer:
         writer.write("}\n");
      } finally {
         writer.close();
      }
   }
   
   public static void main(String args[]) throws Exception, SQLException, IOException {
      OracleDataSource ds = new OracleDataSource();
      ds.setURL("jdbc:oracle:thin:@glast-oracle02.slac.stanford.edu:1521:GLASTDEV");
      String user = System.getProperty("db.username","GLAST_DP_TEST");
      String password = System.getProperty("db.username","BT33%Q9]MU");
      Connection conn =  ds.getConnection(user,password);
      conn.setAutoCommit(false);

      Stream testStream = new Stream(276, conn);
      
      // print it:
      testStream.print();
      
      FileWriter fw = new FileWriter("c:\\testStream.dot");
      
      testStream.draw(fw);
      fw.close();
   }
}
