package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CustomerStyleMap;
import model.StyleTag;
import ultil.DBContext;

public class CustomerStyleDAO extends DBContext{
    
    public List<StyleTag> getAllStyleTags() throws SQLException{
        
        List<StyleTag> styletags = new ArrayList<>();
        String sql = """
                     SELECT [tag_id]
                           ,[tag_name]
                           ,[category]
                       FROM [Style_Tags]""";
        
        try(PreparedStatement stm = connection.prepareStatement(sql);
                ResultSet rs = stm.executeQuery())
        {
            while(rs.next()){
                StyleTag styleTag = new StyleTag();
                styleTag.setTagId(rs.getInt("tag_id"));
                styleTag.setTagName(rs.getString("tag_name"));
                styleTag.setCategory(rs.getString("category"));
                
                styletags.add(styleTag);
            }
        }
        return styletags;
    }

    public void insertCustomerStyles(Connection connection, List<CustomerStyleMap> customerStyles){
        
    }
}
