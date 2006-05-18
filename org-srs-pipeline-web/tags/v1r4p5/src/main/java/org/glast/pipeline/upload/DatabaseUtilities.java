package org.glast.pipeline.upload;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import oracle.jdbc.driver.OracleTypes;
/**
 * A class which simplifies calling Dan's stored oracle procedures.
 * @author tonyj
 * @version $Id: DatabaseUtilities.java,v 1.1 2005-11-14 18:23:46 tonyj Exp $
 */
class DatabaseUtilities
{
   private Connection connection;   
   /** Creates a new instance of DatabaseUtilities */
   DatabaseUtilities(Connection connection) throws SQLException
   {
      this.connection = connection;
   }
   int getGlastUser_PKByName(String userName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getGlastUser_PKByName(?)}");
      stmt.registerOutParameter(1,Types.INTEGER);
      stmt.setString(2,userName);
      stmt.execute();
      return stmt.getInt(1);
   }
   int createGlastUser(String userName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.createGlastUser(?,?)}");
      stmt.registerOutParameter(1,Types.INTEGER);
      stmt.setString(2,userName);
      stmt.setString(3,"password"); // Password, unused
      stmt.execute();
      return stmt.getInt(1);
   }
   int createTask(int user_pk, String taskName, int taskType, String comment, String dataSetPath, String logPath) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.createTask(?,?,?,?,?,?)}");
      stmt.registerOutParameter(1,Types.INTEGER);
      stmt.setInt(2,taskType);
      stmt.setString(3,taskName);
      stmt.setInt(4,user_pk);
      stmt.setString(5,comment == null || comment.length()==0 ? "-" : comment);
      stmt.setString(6,dataSetPath);
      stmt.setString(7,logPath);
      stmt.execute();
      return stmt.getInt(1);
   }
   int getTaskTypeByName(String taskType) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getTaskTypeByName(?)}");
      stmt.registerOutParameter(1,OracleTypes.CURSOR);
      stmt.setString(2,taskType);
      stmt.execute();
      ResultSet result = (ResultSet) stmt.getObject(1);
      result.next();
      int pk = result.getInt(1);
      return pk;
   }
   int getBatchQueueByName(String queueName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getBatchQueueByName(?)}");
      stmt.registerOutParameter(1,OracleTypes.CURSOR);
      stmt.setString(2,queueName);
      stmt.execute();
      ResultSet result = (ResultSet) stmt.getObject(1);
      result.next();
      int pk = result.getInt(1);
      return pk;
   }
   int getBatchGroupByName(String groupName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getBatchGroupByName(?)}");
      stmt.registerOutParameter(1,OracleTypes.CURSOR);
      stmt.setString(2,groupName);
      stmt.execute();
      ResultSet result = (ResultSet) stmt.getObject(1);
      result.next();
      int pk = result.getInt(1);
      return pk;
   }
   int getDSTypeByName(String typeName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getDSTypeByName(?)}");
      stmt.registerOutParameter(1,OracleTypes.CURSOR);
      stmt.setString(2,typeName);
      stmt.execute();
      ResultSet result = (ResultSet) stmt.getObject(1);
      result.next();
      int pk = result.getInt(1);
      return pk;
   }
   int getDSFileTypeByName(String fileTypeName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getDSFileTypeByName(?)}");
      stmt.registerOutParameter(1,OracleTypes.CURSOR);
      stmt.setString(2,fileTypeName);
      stmt.execute();
      ResultSet result = (ResultSet) stmt.getObject(1);
      result.next();
      int pk = result.getInt(1);
      return pk;
   }
   int createTaskProcess(int task_fk, String taskProcessName, int sequence, String appName, String appVersion, String command, int queue_fk, int group_fk, String batchLogPath, int user_fk, String comment, String workingDirectory) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.createTaskProcess(?,?,?,?,?,?,?,?,?,?,?,?)}");
      stmt.registerOutParameter(1,Types.INTEGER);
      stmt.setInt(2,task_fk);
      stmt.setString(3,taskProcessName);
      stmt.setInt(4,sequence);
      stmt.setString(5,appName);
      stmt.setString(6,appVersion);
      stmt.setString(7,command);
      stmt.setInt(8,queue_fk);
      stmt.setInt(9,group_fk);
      stmt.setString(10,batchLogPath);
      stmt.setInt(11,user_fk);
      stmt.setString(12,comment == null || comment.length()==0 ? "-" : comment);
      stmt.setString(13,workingDirectory);
      stmt.execute();
      return stmt.getInt(1);
   }
   int createDataset(int task_fk, int dstype_fk, int dsFileType_fk, String datasetName, String filePath, int user_fk, String comment) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.createDataset(?,?,?,?,?,?,?)}");
      stmt.registerOutParameter(1,Types.INTEGER);
      stmt.setInt(2,task_fk);
      stmt.setInt(3,dstype_fk);
      stmt.setInt(4,dsFileType_fk);
      stmt.setString(5,datasetName);
      stmt.setString(6,filePath);
      stmt.setInt(7,user_fk);
      stmt.setString(8,comment == null || comment.length()==0 ? "-" : comment);
      stmt.execute();
      return stmt.getInt(1);
   }
   void insertTP_DS(int taskProcess_fk, int dataset_fk, boolean read) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call DPF.insertTP_DS(?,?,?)}");
      stmt.setInt(1,taskProcess_fk);
      stmt.setInt(2,dataset_fk);
      stmt.setString(3,read ? "R" : "W");
      stmt.execute();
   }   
   void deleteTaskByPK(int task_pk) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call DPF.deleteTaskByPK(?)}");
      stmt.setInt(1,task_pk);
      stmt.execute();
   }  
   int getTaskPKByName(String taskName) throws SQLException
   {
      CallableStatement stmt = connection.prepareCall("{call ?:=DPF.getTaskPKByName(?)}");
      stmt.registerOutParameter(1,Types.INTEGER);
      stmt.setString(2,taskName);
      stmt.execute();
      return stmt.getInt(1);
   }   
   int getForeignDataset(String pipeline, String datasetName) throws SQLException
   {
      PreparedStatement stmt = connection.prepareStatement("select DATASET_PK from TASK join DATASET on (TASK_FK=TASK_PK) where TASKNAME=? and DATASETNAME=?");
      stmt.setString(1,pipeline);
      stmt.setString(2,datasetName);
      ResultSet rs = stmt.executeQuery();
      rs.next();
      return rs.getInt(1);
   }
}
