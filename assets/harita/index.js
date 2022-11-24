var GL = {
  map:{}
};

var apiKey = 'pk.eyJ1IjoiYWxpa2lsaWNoYXJpdGEiLCJhIjoiY2prcGpwajY4MnpqMDNxbXpmcnlrbWdneCJ9.0NaE-BID7eX38MDSY40-Qg';

GL.config = {
  geocoder:false,
  popups:[],
  popups_id:[],
};

GL.sendToAndroid = function(json){
  window.flutter_inappwebview.callHandler('sendRequestFromWeb', JSON.stringify(json));
}


GL.setMap = function(){
  mapboxgl.accessToken = apiKey;
  GL.map = new mapboxgl.Map({
    container: 'map', // container ID
    // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
    style: 'mapbox://styles/mapbox/streets-v12', // style URL
    center: [27.084713, 38.601132], // starting position [lng, lat]
    zoom: 13 // starting zoom
  });

  GL.map.on('load',()=>{
    GL.addGeoceoder();
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
    var geojsonPart = { "type": "Feature", "properties": item, "geometry": { "coordinates": [ Number(item.longitude), Number(item.latitude) ], "type": "Point" } };
    features.push(geojsonPart);
    var popup = GL.openImagePopup(item);
  });
  medialist.$children[0].open(items);
  var geojson = {type:'FeatureCollection',features:features};
  GL.zoomToGeoJSON(geojson);
}

GL.zoomToGeoJSON = function(geojson){
  var bbox = turf.bbox(geojson);
  GL.zoomToBBox(bbox);
}

GL.zoomToBBox = function(bbox){
  GL.map.fitBounds(bbox,{padding: 25,maxZoom:17});
}

GL.addGeoceoder = ()=>{
  GL.map.addControl(
    GL.config.geocoder = new MapboxGeocoder({
      accessToken: apiKey,
      mapboxgl: mapboxgl
      })
    );
}

GL.flyTo = (obj)=>{
  var target = {
    center: [obj.lng, obj.lat],
    zoom: obj.zoom==undefined?17:obj.zoom,
    bearing: obj.bearing==undefined?0:obj.bearing,
    pitch: obj.pitch==undefined?0:obj.pitch,
  };
  GL.map.flyTo(target);
}

GL.popupRemove=(id) => {
  var ind =GL.config.popups_id.indexOf(id);
  if(ind!==-1){
    GL.config.popups[ind].remove();
    GL.config.popups_id.splice(ind,1);
    GL.config.popups.splice(ind,1);
  }
}

GL.openImagePopup = (item)=>{
  var ind =GL.config.popups_id.indexOf(item.id);
  const div = document.createElement('div');
  const img = document.createElement('img');
  img.style.width='36px';
  img.className='bradius5 p0';
  //div.style.padding='3px';
  div.style.paddingBottom='0';
  img.src = item.mini_image_url;
  div.appendChild(img);
  if(ind!==-1){
    GL.popupRemove(item.id);
    ind=-1;
  }
  if(ind==-1){
    var popup = new mapboxgl.Popup({ closeOnClick: false, closeButton:false })
      .setLngLat([item.longitude,item.latitude])
      .setHTML(div.outerHTML);
    popup.popup_id = item.id;
    popup.addTo(GL.map);
    GL.config.popups.push(popup);
    GL.config.popups_id.push(item.id);
    popup.on('close', () => {
      //GL.popupRemove(item.id);
    });
  }
  return popup;
}
