package org.glast.pipeline.web.taglib.pagination;

import java.io.IOException;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.jstl.sql.SQLExecutionTag;
import javax.servlet.jsp.tagext.JspFragment;
import javax.servlet.jsp.tagext.SimpleTagSupport;
import org.glast.pipeline.web.util.ConnectionManager;

/**
 *
 * @author tonyj
 */
public class Query extends SimpleTagSupport implements SQLExecutionTag
{
    private Object rawDataSource;
    private String sql;
    private int pageSize = 25;
    private int pageNumber = 0;
    private boolean ascending = true;
    private String sortCriterion;
    private String defaultSortCriterion;
    private String var;
    private final List params = new ArrayList();
    
    public void addSQLParameter(Object o)
    {
        params.add(o);
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
                String sql = sqlIn.replace((char)13,' ').replace((char)10,' ');
                PreparedStatement stmt = connection.prepareCall("select count(*) from ("+sql+")");
                int i = 1;
                for (Object param : params)
                {
                    stmt.setObject(i++,param);
                }
                
                ResultSet rs = stmt.executeQuery();
                rs.next();
                int rows = rs.getInt(1);
                stmt.close();
                
                String sortColumn = sortCriterion;
                if (sortColumn == null || sortColumn.length()==0) sortColumn = defaultSortCriterion;
                if (sortColumn != null && sortColumn.length()>0) sql = "select * from ("+sql+") order by "+sortColumn+" "+(ascending?"asc":"desc");
                stmt = connection.prepareCall("select * from (select d.*,rownum rn from ("+sql+") d ) where rn between ? and ?");
                i = 1;
                for (Object param : params)
                {
                    stmt.setObject(i++,param);
                }
                stmt.setInt(i++,pageSize*pageNumber);
                stmt.setInt(i++,pageSize*(pageNumber+1)-1);
                rs = stmt.executeQuery();
                getJspContext().setAttribute(var,new PaginatedResultSet(rs,rows,pageSize,pageNumber,ascending,sortColumn),PageContext.PAGE_SCOPE);
                stmt.close();
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
    
    public void setSql(String sql)
    {
        this.sql = sql;
    }
    
    public void setDataSource(Object rawDataSource)
    {
        this.rawDataSource = rawDataSource;
    }
    
    public void setPageSize(int pageSize)
    {
        this.pageSize = pageSize;
    }
    
    public void setPageNumber(int pageNumber)
    {
        this.pageNumber = Math.max(0,pageNumber-1);
    }
    
    public void setAscending(boolean ascending)
    {
        this.ascending = ascending;
    }
    
    public void setSortColumn(String sortCriterion)
    {
        this.sortCriterion = sortCriterion;
    }
    
    public void setDefaultSortColumn(String sortCriterion)
    {
        this.defaultSortCriterion = sortCriterion;
    }
    
    public void setVar(String var)
    {
        this.var = var;
    }
}
