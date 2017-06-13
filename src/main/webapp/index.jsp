<%@page language="java" pageEncoding="utf-8" contentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<link rel="stylesheet" type="text/css" href="static/jslib/jeasyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="static/jslib/jeasyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="static/jslib/leaflet/leaflet.css">
	<link rel="stylesheet" type="text/css" href="static/jslib/leaflet/mouseposition/L.Control.MousePosition.css">
	<link rel="stylesheet" type="text/css" href="static/css/index.css">
	<!-- libraries -->
	<script type="text/javascript" src="static/jslib/jquery-2.2.3.min.js"></script>
	<script type="text/javascript" src="static/jslib/jeasyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="static/jslib/leaflet/leaflet-src.js"></script>
	<script type="text/javascript" src="static/jslib/leaflet/mouseposition/L.Control.MousePosition.js"></script>
	<script type="text/javascript" src="static/jslib/leaflet/leaflet.ChineseTmsProviders.js"></script>
	<script type="text/javascript" src="static/jslib/leaflet/editable/Path.Drag.js"></script>
	<script type="text/javascript" src="static/jslib/leaflet/editable/Leaflet.Editable.js"></script>
	<!-- business -->
	<script type="text/javascript" src="static/js/index.js"></script>
	<script type="text/javascript" src="static/js/draw.js"></script>
</head>
<body class='easyui-layout'>
	<div data-options="region:'north'" style="height:60px;background:#B3DFDA;overflow:hidden;">
		<ul class='topBar'>
			<li>查询</li>
			<li>标绘</li>
			<li>编辑</li>
			<li>图层管理</li>
		</ul>
	</div>
	<div data-options="region:'west',split:true,border:true,title:'菜单'" style="width:200px;padding:0px;background-color:#B3DFDA">
		<div class='leftMenu' style="margin:0;paddng:0">
			<!-- 查询 -->
			<div class='subMenu'>qw</div>
			<!-- 标绘 -->
			<div class='subMenu'>ew</div>
			<!-- 编辑 -->
			<div class='editPanel'>
				<input type="button" value="开启编辑">
				<input type="button" value="结束编辑">
				<input type="button" value="画点">
				<input type="button" value="画线">
				<input type="button" value="画面">
			</div>
			<div class='subMenu layer'>
				<ul>
					<li><input type="checkbox" id="ck1"><label for="ck1" title="test:highway">高速公路</label></li>
					<li><input type="checkbox" id="ck2"><label for="ck2" title="test:gdxzqh">行政区划</label></li>
				</ul>
				
			</div>
		</div>
	</div>
	<div data-options="region:'east',split:true,collapsed:true,title:'East'" style="width:250px;padding:10px;">east region</div>
	<div data-options="region:'south'" style="height:50px;background:#A9FACD;padding:10px;">copyright@zsx</div>
	<div data-options="region:'center'" class="body-center">
		<div class='toolbar'>
			<a href="javascript:;" onclick="clearFeatures();">清除</a>
			<a href="javascript:;" onclick="pan('left');">左移</a>
			<a href="javascript:;" onclick="pan('right');">右移</a>
			<a href="javascript:;" onclick="pan('up');">上移</a>
			<a href="javascript:;" onclick="pan('down');">下移</a>
			<a href="javascript:;" onclick="zoom('in');">放大</a>
		  	<a href="javascript:;" onclick="zoom('out');">缩小</a>
			<a href="javascript:;" onclick="zoom('default');">广州</a>
			<a href="javascript:;" onclick="toFullScreen();">全屏</a>
			<a href="javascript:;" onclick="prevView();">前一试图</a>
			<a href="javascript:;" onclick="nextView();">后一试图</a>
			<a href="javascript:;" onclick="mDistance();">测距</a>
			<a href="javascript:;" onclick="mArea();">面积</a>
		</div>
		<div id='map'></div>
	</div>
</body>
	<script type="text/javascript">
		/**地图配置项*/
		var mapCfg = {
				baseMap:{
					url:"http://localhost:8080/geowebcache/service/wms",
					name:"fsMap",
					format:"image/png"
				},
				center:L.latLng(23.146901,113.280812),
				mxBounds:L.latLngBounds([22.6,112.2],[23.8,113.7]),//佛山地图边界
				gaode:'http://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
				rootWFS:'http://localhost:8080/geoserver/test/ows'
				
		}
		
		$(function(){
			/**resize地图*/
			$('#map').height($('.body-center').height() - $('.toolbar').height());
			map.invalidateSize(true);
			
			//菜单条设置
			$('.topBar li').click(function(){
				//顶部菜单样式设置
				$('.topBar li').removeAttr('class');
				$(this).addClass('active');
				//切换菜单面板
				var idx = $(this).index();
				toggleMenu(idx)
			});
			toggleMenu(0);
			
			//标绘
			$('.editPanel input').click(function(){
				var i = $(this).index();
				toDraw(i);
			});
			//图层
			$('input[type="checkbox"]').click(function(e){
				console.log(e);
				var el = $(this)[0];
				var name = $(this).siblings().attr('title');
				var check = {};
				for(var lyr in map._layers){
					var layer = map._layers[lyr];
					if(layer.name && layer.name == name){
						check.included = true;
						check.layer = layer;
						break;
					}
				}
				if(el.checked){
					loadWFS(name,'EPSG:4326');
				}else{
					check.included && map.removeLayer(check.layer);
				}
			});
		});

		function toggleMenu(index){
			$('.leftMenu > div').hide();
			$('.leftMenu > div').eq(index).show();
		}
		var map = L.map('map',{
			crs:L.CRS.EPSG3857,
			maxBounds:mapCfg.mxBounds,
			minZoom:6,
			maxZoom:17,
			maxBoundsViscosity:1,//最大边界超过反弹粘度
			center:mapCfg.center,
			zoom:11,
			layers:[getFsMap()],
			editable:true,//编辑控制
			attributionControl:false
		});
// 		loadWFS('test:highway','EPSG:4326');
		
		L.control.mousePosition({
			emptystring:'',
			separator:',',
			lngFirst:true,
			prefix:'坐标:'
		}).addTo(map);
		
		function getFsMap(){
			return L.tileLayer.wms(mapCfg.baseMap.url,{
				layers:mapCfg.baseMap.name,
				format:mapCfg.baseMap.format,
				transparent:true,
				attribution:"佛山地图"
			});
		}
		
		function getGaode(){
			return L.tileLayer.chinaProvider('GaoDe.Normal.Map',{});
		}
		
		function getOsmMap(){
			return L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png');
		}
		
		/**加载WFS矢量图层**/
		function loadWFS(layerName,epsg){
			var param = {
					service:'WFS',
					version:'1.0.0',
					request:'GetFeature',
					typeName:layerName,
					outputFormat:'application/json',
					srsName:epsg
			};
			var u = mapCfg.rootWFS + L.Util.getParamString(param,mapCfg.rootWFS);
			$.ajax({
				url: u, 
				dataType:'json',
				success:loadWfsHandler,
			});
			var layer;
			function loadWfsHandler(data){
				console.log(data);
				layer = L.geoJson(data,{
// 					style:function(feature){
// 						return {
// 							stroke:true,
// 							color:'#F80909',
// 							opacity: 1,
// 			                fillOpacity: 0.9,
// 			                fillColor: '#F80909',
// 							weight:5
// 						}
// 					},
					pointToLayer:function(featyre,latlng){
						console.log(feature + ',' + latlng);
					}
				});
				layer.name = layerName;
				layer.addTo(map);
			}
		}
	</script>
</html>
