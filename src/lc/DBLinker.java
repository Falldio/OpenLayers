package lc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBLinker {
    private Connection connection = null;

    public void connectToServer(){
        String host = "101.37.14.3";
        String user = "postgres";
        String passwd = "xinhancanlan.0523";
        String port = "5432";
        String db = "/webgis";
        String url = "jdbc:postgresql://"+host+":"+port+db;

        try{
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection(url,user,passwd);

        }catch (Exception e){
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            System.exit(0);
        }
    }

    public ResultSet getData(String query){
        if(connection==null){
            return null;
        }

        Statement statement = null;
        ResultSet resultSet = null;

        try{
            statement = connection.createStatement();
            resultSet = statement.executeQuery(query);
        }catch (Exception e){
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            System.exit(0);
        }
        return resultSet;
    }

    public void closeConnection(){
        if (connection != null){
            try{
                connection.close();
            }catch (Exception e){
                System.err.println(e.getClass().getName()+": "+e.getMessage());
                System.exit(0);
            }
        }
    }

    public static void main(String[] args){
        DBLinker dbLinker = new DBLinker();
        dbLinker.connectToServer();
        ResultSet resultSet = dbLinker.getData(
                "SELECT json_build_object(" +
                            "'type', 'FeatureCollection'," +
                            "'features', json_agg(" +
                                "json_build_object(" +
                                "'type',  'Feature'," +
                                "'name',  name," +
                                "'geometry',  ST_AsGeoJSON(ST_Transform(ST_SetSRID(geom,4326),3857))::json" +
                                ")" +
                            ")"+
                        ") as geom " +
                        "FROM res1_4m " );//+
//                        "WHERE name = '北京'");
//      ResultSet resultSet=dbLinker.getData("SELECT ST_AsGeoJSON(ST_Transform(ST_SetSRID(geom,4326),3857)) as geom FROM res1_4m WHERE name = '北京'");
        dbLinker.closeConnection();

        try{
            while (resultSet.next()) {
                System.out.print(resultSet.getString("geom"));
            }
        }catch (Exception e){
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            System.exit(0);
        }
    }
}
