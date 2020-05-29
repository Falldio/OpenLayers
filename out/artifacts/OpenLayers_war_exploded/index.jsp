<%--
  Created by IntelliJ IDEA.
  User: admin
  Date: 2020/5/26
  Time: 10:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <meta charset="UTF-8">
    <title>惨兮兮的刘大诚儿</title>
    <link rel="stylesheet" type="text/css" href="./js/ol/ol.css">
    <script type="text/javascript" src="./js/ol/ol.js"></script>
    <style>
      html,body{
        height: 100%;
        width: 100%;
        margin: 0;
        padding: 0;
      }
      #map{
        height:100%;
        width: 100%;
      }
      #wrapper{
        position: absolute;
        left: 0;
        bottom: 0;
        width: 100%;
        background: rgb(250, 241, 241);
        z-index: 10;
        text-align: left;
      }
      #featureInfo{
        background: white;
        width: 100%;
      }
    </style>
    <%@ page import="lc.DBLinker" %>
    <%@ page import="java.sql.ResultSet" %>
  </head>
  <body>
    <div id="map">
      <div id="wrapper">
        <div id="featureInfo">
        </div>
      </div>
    </div>
    <%
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
              ") AS geom " +
              "FROM res1_4m ");// +
//              "WHERE name = '北京'");
//      ResultSet resultSet=dbLinker.getData("SELECT ST_AsGeoJSON(ST_Transform(ST_SetSRID(geom,4326),3857)) as geom FROM res1_4m WHERE name = '北京'");
      dbLinker.closeConnection();
    %>
    <script type="text/javascript">
      let map = new ol.Map({
        target: "map",
        layers: [
          new ol.layer.Tile({                 // 瓦片图层
            source: new ol.source.OSM()     // OpenStreetMap数据源
          }),
          new ol.layer.Tile({
            source: new ol.source.TileWMS({
              extent:[80.7240219116211,6.08244466781616,135.314254760742,53.7941207885742],
              url:'http://localhost:8080/geoserver/wms',
              params: {'LAYERS': 'china','FORMAT':'image/png', 'TILED': true},
              serverType: 'geoserver',
              transition: 0,
            })
          }),
          new ol.layer.Vector({
            source: new ol.source.Vector({
              url:'json/GeoJSON_HB.json',
              format:new ol.format.GeoJSON()
            }),
            style: new ol.style.Style({
              stroke: new ol.style.Stroke({
                color: 'blue',
                lineDash: [4],
                width: 2
              }),
              fill: new ol.style.Fill({
                color: 'rgba(0, 0, 255, 0.3)'
              })
            }),
          }),
          new ol.layer.Vector({
            source: new ol.source.Vector({
              features: (new ol.format.GeoJSON()).readFeatures(<%
                try{
                  while (resultSet.next()) {
                    out.print(resultSet.getString("geom"));
                  }
                  }catch(Exception e){
                  System.exit(0);
                }
              %>)
            }),
            style: new ol.style.Style({
              // image: new ol.style.Circle({
              //   radius: 5,
              //   fill: null,
              //   stroke: new ol.style.Stroke({color: 'red', width: 1})
              // })
              image: new ol.style.Icon({
                src: 'img/plane.jpg',
                scale: 0.1
              })
            })
          })
        ],
        view: new ol.View({
          projection:'EPSG:3857',
          center: ol.proj.fromLonLat([108.0191383, 29.9382827]),
          // center: [108.0191383, 29.9382827],
          zoom: 4
        })
      });

      // this.map.on('singleclick', function(evt) {
      //   var view = this.getView()
      //   var layer = this.getLayers().array_[1]
      //   var source = layer.getSource()
      //   var url = source.getFeatureInfoUrl(
      //     evt.coordinate, view.getResolution(), view.getProjection(),
      //     {'INFO_FORMAT': 'text/html'})
      //   if(url){
      //     document.getElementById('featureInfo').innerHTML='<iframe seamless background="white" width="100%" src="'+url+'"></iframe>'
      //     console.log(document.getElementById('featureInfo').innerHTML)
      //   }
      // })
    </script>
<%--    <h3>登录</h3>--%>
<%--    <hr>--%>
<%--    <form action="search" method="post">--%>
<%--      用户名：<input type="text" name="username"/><br>--%>
<%--      密码:<input type="password" name="password"/><br>--%>
<%--      <input type="submit" />--%>
<%--    </form>--%>
  </body>
</html>
