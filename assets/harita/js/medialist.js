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
            mini_image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'audio',
            latitude:0,
            longitude:0,
            name:'Denemememem asdas dqw eq asd'
          },
          {
            id:2,
            mini_image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },
          {
            id:3,
            mini_image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },
          {
            id:4,
            mini_image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
            fileType:'image',
          },
          {
            id:5,
            mini_image_url:'https://baklanyeni.baklanmeyvecilik.com/api/v1/public/files/images/upload-1668070262012.jpg',
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
    resimGoster:function(item,yontem){
      debugger;
      var that = this;
      var ind = 0;
      var id = 'galeri-'+Date.now();
      document.getElementById('galeri').innerHTML='<div id="'+id+'"></div>';
      var gallery = document.getElementById(id);
      gallery.innerHTML='';
      if(yontem!=='single'){
        for(var i=0;i<this.items.length;i++){
          var it = this.items[i];
          if(it.id==item.id){
            ind=i;
          }
          var img = document.createElement('img');
          img.alt = it.name;
          img.src = it.path;
          img.dataset.id=it.id;
          img.dataset.lat=it.latitude;
          img.dataset.lng=it.longitude;
          gallery.appendChild(img);
        }
      }else{
        var img = document.createElement('img');
        img.alt = item.name;
        img.src = item.path;
        img.dataset.id=item.id;
        img.dataset.lat=item.latitude;
        img.dataset.lng=item.longitude;
        gallery.appendChild(img);
      }
      
      setTimeout(()=>{
        debugger;
        that.hidden=false;
        gallery.addEventListener('hidden',function(){
          that.viewer.destroy();
          that.hidden=true;
        });
        gallery.addEventListener('viewed',function(e){
          var data = e.detail.originalImage.dataset;
          that.showPoint(data.lat,data.lng);
        });
        that.viewer = new Viewer(gallery,{
          inline: false,
          button:true,
          fullscreen:false
        });
        that.viewer.view(ind);
      },100);
      
    },
    showAimage(id){
      var it = this.items.find((a)=>a.id==id);
      if(it){
        this.selected=it.id;
        this.item = it;
        this.resimGoster(it,'single');
      }
    },
    showAVideo(id){
      var it = this.items.find((a)=>a.id==id);
      if(it){
        this.selected=it.id;
        this.item = it;
        this.videoIzle(it);
      }
    },
    showAAudio(id){
      var it = this.items.find((a)=>a.id==id);
      if(it){
        this.selected=it.id;
        this.item = it;
        this.sesDinle(it);
      }
    },
    showPoint(lat,lng){
      lat=Number(lat);
      lng=Number(lng);
      GL.flyTo({
        lng:lng,
        lat:lat,
      });
    },
    navigasyon(){
      GL.sendToAndroid({type:'navigasyon',data:this.item});
    },
    videoIzle(item){
      myvideo.$children[0].open(item);
    },
    sesDinle(item){
      myaudio.$children[0].open(item);
    }
  },
  template: `<div v-if="onoff && hidden">
    <div :class="selected!==-1?'medialist flex-col h160':'medialist flex-col h120'" v-if="items.length>0">
      <div class="mb5 actions1" v-if="selected!==-1">
        <div>
          <button @click="resimGoster(item,'multi')" v-if="item.fileType=='image'" class="button is-small is-success is-responsive">Göster</button>
          <button @click="videoIzle(item);" v-if="item.fileType=='video'" class="button is-small is-success is-responsive">İzle</button>
          <button @click="sesDinle(item);" v-if="item.fileType=='audio'" class="button is-small is-success is-responsive">Dinle</button>
          <button v-if="item.fileType=='txt'"   class="button is-small is-success is-responsive">Oku</button>
          <button @click="navigasyon(item);" class="button is-small is-dark is-responsive">Navigasyon</button>
          <button class="button is-small is-dark is-responsive">Bilgi</button>
        </div>
        <div>
          <button @click="iptal()" class="button is-small is-danger is-responsive">Kapat</button>
        </div>
      </div>
      <div class="flexBox">
        <div :key="i" v-for="(media,i) in items" @click="showOnTheMap(media)">

          <div v-if="media.fileType=='txt'" :class="media.id==selected?'imageCardSelected':'imageCard'">
            <img class="slideImage" src="./img/textfile.png">
          </div>

          <div v-if="media.fileType=='audio'" :class="media.id==selected?'imageCardSelected':'imageCard'">
            <div style="position:relative;">
              <img class="slideImage" src="./img/audiofile3.png">
              <div class="ccb1">
                {{media.name}}
              </div>
            </div>
          </div>

          <div v-if="media.fileType=='image'" :class="media.id==selected?'imageCardSelected':'imageCard'">
            <img class="slideImage" :src="media.mini_image_url">
          </div>

          <div v-if="media.fileType=='video'" :class="media.id==selected?'imageCardSelected cc':'imageCard cc'">
            <div style="position:relative;">
              <img class="slideImage" :src="media.mini_image_url">
              <button @click="showOnTheMap(media)" class="button ccb circle">
                <span class="icon is-small">
                <svg style="height:16px;" xmlns="http://www.w3.org/2000/svg" fill="#333" viewBox="0 0 384 512"><path d="M73 39c-14.8-9.1-33.4-9.4-48.5-.9S0 62.6 0 80V432c0 17.4 9.4 33.4 24.5 41.9s33.7 8.1 48.5-.9L361 297c14.3-8.7 23-24.2 23-41s-8.7-32.2-23-41L73 39z"/></svg>
                </span>
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>`
});
var medialist = new Vue({
  el: '#bottomMediaList'
});