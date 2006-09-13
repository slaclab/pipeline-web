package org.glast.pipeline.client;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import javax.management.MBeanServerConnection;
import javax.management.ObjectName;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;

/**
 * A client interface to the pipeline server
 * @author tonyj
 */
public class PipelineClient
{
   private String host;
   private Timestamp started;
   private int port;
   private String token;
   private String version;
   private ObjectName name;
   private JMXServiceURL serviceURL;
  
   public PipelineClient(Connection connection) throws PipelineException
   {
      try
      {
         PreparedStatement stmt = connection.prepareStatement("select HOST,STARTED,PORT,TOKEN,VERSION from ServerStatus",ResultSet.TYPE_FORWARD_ONLY,ResultSet.CONCUR_UPDATABLE);
         try
         {
            ResultSet rs = stmt.executeQuery();
            if (!rs.next()) throw new PipelineServerNotRunningException();

            host = rs.getString(1);
            started = rs.getTimestamp(2);
            port = rs.getInt(3);
            token  = rs.getString(4);
            version = rs.getString(5);

            serviceURL = new JMXServiceURL("service:jmx:rmi:///jndi/rmi://"+host+":"+port+"/jmxrmi");
            name = new ObjectName("org.glast.pipeline.server:type=Main");
         }
         finally
         {
            stmt.close();
         }
      }
      catch (PipelineException x)
      {
         throw x;
      }
      catch (Exception x)
      {
         throw new PipelineException("Cannot create PipelineConnection",x);
      }
   }
   
   public String getServerHost()
   {
      return host;
   }
   
   public String getServerVersion()
   {
      return version;
   }
   public Timestamp getStartTime()
   {
      return started;
   }
   
   private JMXConnector connect() throws IOException
   {
      return JMXConnectorFactory.connect(serviceURL);
   }
   public void createTaskFromXML(String xml, String userName) throws PipelineException
   {
      try
      {
         JMXConnector c = connect();
         try
         {
            MBeanServerConnection connection = c.getMBeanServerConnection();
            connection.invoke(name,"createTaskFromXML",new String[]{xml,userName},new String[]{"java.lang.String","java.lang.String"});
         }
         finally
         {
            c.close();
         }
      }
      catch (Exception x)
      {
         throw new PipelineException("Error calling createTaskFromXML",x);
      }
   }
   public int createStream(String task, int stream, String env) throws PipelineException
   {
      try
      {
         JMXConnector c = connect();
         try
         {
            MBeanServerConnection connection = c.getMBeanServerConnection();
            Object result = connection.invoke(name,"createStream",new Object[]{task,stream,env},new String[]{"java.lang.String","int","java.lang.String"});
            return ((Number) result).intValue();
         }
         finally
         {
            c.close();
         }
      }
      catch (Exception x)
      {
         throw new PipelineException("Error calling createStream",x);
      }      
   }

   public void restartServer() throws PipelineException
   {
      try
      {
         JMXConnector c = connect();
         try
         {
            MBeanServerConnection connection = c.getMBeanServerConnection();
            connection.invoke(name,"restart",null,null);
         }
         finally
         {
            c.close();
         }
      }
      catch (Exception x)
      {
         throw new PipelineException("Error calling restart",x);
      } 
   }
   
   public class PipelineServerNotRunningException extends PipelineException
   {
      PipelineServerNotRunningException()
      {
         super("Pipeline server not running",null);
      }
   }
   public class PipelineException extends Exception
   {
      PipelineException(String message, Throwable cause)
      {
         super(message,cause);
      }
   }
}

