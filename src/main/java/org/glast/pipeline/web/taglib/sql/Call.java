package org.glast.pipeline.web.taglib.sql;

import org.glast.pipeline.web.util.ConnectionManager;
import java.io.IOException;
import java.io.StringWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.jstl.core.Config;
import javax.servlet.jsp.jstl.sql.SQLExecutionTag;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;
// Note we have dependency on oracle to support oracle specific functionality
// This could be removed if Oracle supported Types.OTHER for ResultSets, as
// recommended by JDBC standard.
import oracle.jdbc.OracleTypes;
// Note, for convenience we have some dependencies on apache/tomcat. These
// could be removed by copying source code into this library.
import org.apache.taglibs.standard.tag.common.core.Util;
import org.apache.taglibs.standard.tag.common.sql.ResultImpl;

/**
 * Similar to the JSTL sql tag, but usable with oracle stored procedures
 * @author tonyj
 */
public class Call extends SimpleTagSupport implements SQLExecutionTag
{
   private static Map<String,Integer> sqlMap = new HashMap<String,Integer>();
   private Object rawDataSource;
   static
   {
      sqlMap.put("array",Types.ARRAY);
      sqlMap.put("bigint",Types.BIGINT);
      sqlMap.put("binary",Types.BINARY);
      sqlMap.put("bit",Types.BIT);
      sqlMap.put("blob",Types.BLOB);
      sqlMap.put("boolean",Types.BOOLEAN);
      sqlMap.put("char",Types.CHAR);
      sqlMap.put("clob",Types.CLOB);
      sqlMap.put("datalink",Types.DATALINK);
      sqlMap.put("date", Types.DATE);
      sqlMap.put("decimal",Types.DECIMAL);
      sqlMap.put("distinct",Types.DISTINCT);
      sqlMap.put("double",Types.DOUBLE);
      sqlMap.put("float",Types.FLOAT);
      sqlMap.put("integer",Types.INTEGER);
      sqlMap.put("longvarbinary",Types.LONGVARBINARY);
      sqlMap.put("longvarchar",Types.LONGVARCHAR);
      sqlMap.put("null",Types.NULL);
      sqlMap.put("numeric",Types.NUMERIC);
      sqlMap.put("other",Types.OTHER);
      sqlMap.put("real",Types.REAL);
      sqlMap.put("ref",Types.REF);
      sqlMap.put("smalling",Types.SMALLINT);
      sqlMap.put("struct",Types.STRUCT);
      sqlMap.put("time",Types.TIME);
      sqlMap.put("timestamp",Types.TIMESTAMP);
      sqlMap.put("tinyint",Types.TINYINT);
      sqlMap.put("varbinary",Types.VARBINARY);
      sqlMap.put("varchar",Types.VARCHAR);
      // Oracle specific
      sqlMap.put("cursor",OracleTypes.CURSOR);
   }
   
   private boolean maxRowsSpecified = false;
   private int maxRows = -1;
   private int startRow;
   private String sql;
   private List params = new ArrayList();
   
   public void addSQLParameter(Object o)
   {
      params.add(o);
   }
   void addResult(String varName, String scopeName, String typeName) throws JspException
   {
      params.add(new Result(varName,Util.getScope(scopeName),getSQLType(typeName)));
   }
   
   public void doTag() throws JspException, IOException
   {
      StringWriter writer = new StringWriter();
      JspFragment fragment = getJspBody();
      if (fragment != null) fragment.invoke(writer);
      String sqlIn = sql == null ? writer.toString() : sql;
      try
      {
         Connection connection = ConnectionManager.getConnection((PageContext) getJspContext(), rawDataSource);
         try
         {
            CallableStatement stmt = connection.prepareCall(sqlIn.replace((char)13,' ').replace((char)10,' '));
            
            int i = 1;
            for (Object param : params)
            {
               if (param instanceof Result)
               {
                  Result result = (Result) param;
                  stmt.registerOutParameter(i,result.sqlType);
               }
               else stmt.setObject(i,param);
               i++;
            }
            
            stmt.execute();
            
            i = 1;
            for (Object param : params)
            {
               if (param instanceof Result)
               {
                  Result result = (Result) param;
                  Object obj = stmt.getObject(i);
                  if (obj instanceof ResultSet)
                  {
                     if (!maxRowsSpecified)
                     {
                        maxRows = defaultMaxRows();
                     }
                     
                     ResultSet rs = (ResultSet) obj;
                     obj = new ResultImpl(rs, startRow, maxRows);
                  }
                  getJspContext().setAttribute(result.varName,obj,result.scope);
               }
            }
            i++;
         }
         finally
         {
            connection.close();
         }
      }
      catch (SQLException x)
      {
         throw new JspException("Error exectuing SQL: \n"+sqlIn,x);
      }
   }
   
   private class Result
   {
      Result(String varName, int scope, int sqlType)
      {
         this.varName = varName;
         this.scope = scope;
         this.sqlType = sqlType;
      }
      private int sqlType;
      private int scope;
      private String varName;
   }

   private static int getSQLType(String type) throws JspException
   {
      Integer result = sqlMap.get(type.toLowerCase());
      if (result == null) throw new JspException("Invalid sql type: "+type);
      return result;
   }
   private int defaultMaxRows() throws JspException
   {
      Object obj = Config.find((PageContext) getJspContext(), Config.SQL_MAX_ROWS);
      if (obj != null)
      {
         if (obj instanceof Integer)
         {
            return ((Integer) obj).intValue();
         }
         else if (obj instanceof String)
         {
            try
            {
               return Integer.parseInt((String) obj);
            }
            catch (NumberFormatException nfe)
            {
               throw new JspException("Maxrows parse error: "+obj,nfe);
            }
         }
         else
         {
            throw new JspException("Maxrows invalid");
         }
      }
      return -1;
   }
   
   public void setSql(String sql)
   {
      this.sql = sql;
   }
   
   public void setDataSource(Object rawDataSource)
   {
      this.rawDataSource = rawDataSource;
   }
   
   public void setMaxRows(int maxRows)
   {
      this.maxRows = maxRows;
      maxRowsSpecified = true;
   }
   
   public void setStartRow(int startRow)
   {
      this.startRow = startRow;
   }
   
}
