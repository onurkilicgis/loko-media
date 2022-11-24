Vue.component('medialist', {
  data: function () {
    return this.setDefault();
  },
  beforeMount: function () {

  },
  methods: {
    setDefault: function () {
      return {
        onoff: true,
        hidden:true,
        items:[
          /*{
            id:1,
            image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
            latitude:0,
            longitude:0
          },
          {
            id:2,
            image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },
          {
            id:3,
            image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },
          {
            id:4,
            image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },
          {
            id:5,
            image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },*/
        ],
        selected:-1,
        item:false,
        viewverid:0,
        viewer:false,
      }
    },
    open: function (items) {
      this.items=items;
      this.populateImages();
      this.onoff = true;
    },
    close: function (e) {
      this.clear();
      this.onoff = false;
    },
    clear:function(){

    },
    save: function () {
      this.onoff = false;
    },
    setItems(items){
      this.items = items;
    },
    showOnTheMap(item){
      this.item=item;
      this.selected=item.id;
      GL.flyTo({
        lng:item.longitude,
        lat:item.latitude,
      });
      GL.openImagePopup(item);
    },
    iptal(){
      this.item=false;
      this.selected=-1;
    },
    populateImages(){
      /*var ress = '';
      this.items.map((a,i)=>{
        ress+='<img src="'+a.image_url+'" alt="'+a.name+'" />';
      });
      document.getElementById('gallery').innerHTML=ress;*/
    },
    resimGoster:function(item){
      debugger;
      var that = this;
      var ind = 0;
      var id = 'galeri-'+Date.now();
      document.getElementById('galeri').innerHTML='<div id="'+id+'"></div>';
      var gallery = document.getElementById(id);
      gallery.innerHTML='';
      for(var i=0;i<this.items.length;i++){
        var it = this.items[i];
        if(it.id==item.id){
          ind=i;
        }
        var img = document.createElement('img');
        img.alt = it.name;
        img.src = it.image_url;
        gallery.appendChild(img);
      }
      setTimeout(()=>{
        debugger;
        that.hidden=false;
        gallery.addEventListener('hidden',function(){
          debugger;
          that.viewer.destroy();
          that.hidden=true;
        });
        that.viewer = new Viewer(gallery,{
          inline: false,
          button:true,
          fullscreen:false
        });
        that.viewer.view(ind);
      },100);
      
    }
  },
  template: `<div v-if="onoff && hidden">
    <div :class="selected!==-1?'medialist flex-col h160':'medialist flex-col h120'" v-if="items.length>0">
      <div class="mb5 actions1" v-if="selected!==-1">
        <div>
          <button @click="resimGoster(item)" v-if="item.fileType=='image'" class="button is-small is-dark is-responsive">Göster</button>
          <button v-if="item.fileType=='video'" class="button is-small is-dark is-responsive">İzle</button>
          <button v-if="item.fileType=='audio'" class="button is-small is-dark is-responsive">Dinle</button>
          <button v-if="item.fileType=='txt'"   class="button is-small is-dark is-responsive">Oku</button>
          <button class="button is-small is-dark is-responsive">Navigasyon</button>
          <button class="button is-small is-dark is-responsive">Bilgi</button>
        </div>
        <div>
          <button @click="iptal()" class="button is-small is-danger is-responsive">Kapat</button>
        </div>
      </div>
      <div class="flexBox">
        <div :key="i" v-for="(media,i) in items" @click="showOnTheMap(media)">
          <div :class="media.id==selected?'imageCardSelected':'imageCard'">
            <img class="slideImage" :src="media.image_url">
          </div>
        </div>
      </div>
    </div>
  </div>`
});
var medialist = new Vue({
  el: '#bottomMediaList'
});