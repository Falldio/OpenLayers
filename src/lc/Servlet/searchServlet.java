package lc.Servlet;

import lc.DBLinker;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;

@WebServlet(name = "searchServlet", urlPatterns = "/search")
public class searchServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json; charset=utf-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        response.setCharacterEncoding("UTF-8");
        String query = request.getParameter("query");
        String sqlQuery =
                "SELECT json_build_object(" +
                    "'type', 'FeatureCollection'," +
                    "'features', json_agg(" +
                        "json_build_object(" +
                            "'type',  'Feature'," +
                            "'name',  name," +
                            "'geometry',  ST_AsGeoJSON(ST_Transform(ST_SetSRID(geom,4326),3857))::json" +
                        ")" +
                    ")" +
                ") AS geom " +
                "FROM res1_4m " +
                "WHERE name LIKE '%" + query + "%'";
        DBLinker dbLinker = new DBLinker();
        dbLinker.connectToServer();
        ResultSet resultSet = dbLinker.getData(sqlQuery);
        try{
            while (resultSet.next()) {
                out.write(resultSet.getString("geom"));
            }
        }catch(Exception e){
            System.exit(0);
        }
        dbLinker.closeConnection();
        out.flush();
        out.close();
    }
}
