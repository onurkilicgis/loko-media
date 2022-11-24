var GL = {
  map:{}
};

GL.config = {
};

GL.sendToAndroid = function(json){
  window.flutter_inappwebview.callHandler('sendRequestFromWeb', JSON.stringify(json));
}


GL.setMap = function(){
  mapboxgl.accessToken = 'pk.eyJ1IjoiYWxpa2lsaWNoYXJpdGEiLCJhIjoiY2prcGpwajY4MnpqMDNxbXpmcnlrbWdneCJ9.0NaE-BID7eX38MDSY40-Qg';
  GL.map = new mapboxgl.Map({
    container: 'map', // container ID
    // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
    style: 'mapbox://styles/mapbox/streets-v12', // style URL
    center: [27.084713, 38.601132], // starting position [lng, lat]
    zoom: 13 // starting zoom
  });
}
GL.setMap();
setTimeout(function(){
    GL.sendToAndroid({type:'pageload',data:true});
},2000);


GL.getToAndroid = function(str){
    var gelen = JSON.parse(str);
    switch(gelen.type){
      case 'album':{
        GL.loadAlbumToMap(gelen.data);
        break;
      }
    }
}


GL.loadAlbumToMap = function(items){
  var features = [];
  items.map((item)=>{
    const div = document.createElement('div');
    const img = document.createElement('img');
    img.style.width='36px';
    img.src = `http://127.0.0.1:1991/album-${item.id}/${item.miniName}`;
    alert(img.src);
    div.appendChild(img);
    var geojsonPart = { "type": "Feature", "properties": item, "geometry": { "coordinates": [ Number(item.longitude), Number(item.latitude) ], "type": "Point" } };
    features.push(geojsonPart);
    new mapboxgl.Popup()
    .setLngLat(geojsonPart.geometry.coordinates)
    .setHTML(div.outerHTML)
    .addTo(GL.map);
  });
  var geojson = {type:'FeatureCollection',features:features};
  GL.zoomToGeoJSON(geojson);
  
}

GL.zoomToGeoJSON = function(geojson){
  var bbox = turf.bbox(geojson);
  //alert(JSON.stringify(bbox));
  GL.zoomToBBox(bbox);
}

GL.zoomToBBox = function(bbox){
  GL.map.fitBounds(bbox,{padding: 25,maxZoom:17});
}
