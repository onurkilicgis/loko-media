Vue.component('myvideos', {
  data: function () {
    return this.setDefault();
  },
  beforeMount: function () {

  },
  methods: {
    setDefault: function () {
      return {
        item: false,
        type:'video/mp4',
        style:{
          height:'300px',
          bgColor:'#202B3F',
          border:'1px solid #1a1a1a'
        }
      }
    },
    open: function (item) {
      this.item=item;
      var part = item.path('.');
      var ext = part.pop();
      ext = ext.toLocaleLowerCase()
      switch(ext){
        case 'mp4':{
          this.type='video/mp4';
          break;
        }
        case 'webm':{
          this.type='video/webm';
          break;
        }
        case 'ogg':{
          this.type='video/ogg';
          break;
        }
      } 
      this.style.height = (window.screen.availHeight)+'px';
    },
    close: function (e) {
      this.clear();
    },
    clear:function(){
      this.item=false;
    },
    save: function () {
    },
    setItem(item){
      this.item = item;
    },
  },
  template: `<div v-if="item!==false">
  <div id="modal-ter" class="modal is-active" bis_skin_checked="1">
  <div class="modal-background" bis_skin_checked="1"></div>
  <div class="modal-card" bis_skin_checked="1" style="margin:5px;">
    <header class="modal-card-head p10" :style="{backgroundColor:style.bgColor,borderBottom:style.border}">
      <p class="modal-card-title" style="color:#eee; font-size:12px;">{{item.name}}</p>
      <button @click="close" class="delete" aria-label="close"></button>
    </header>
    <section class="modal-card-body p5" style="background-color:#1A2133; padding:5px;">
      <video autoplay loop controls controlsList="nodownload" class="video-js" :style="{width:'100%',height:style.height}">
        <source :src="item.path" :type="type">
      </video>
    </section>
    <footer class="modal-card-foot p5" :style="{backgroundColor:style.bgColor,borderTop:style.border}">
    </footer>
  </div>
</div>
  </div>`
});
var myvideo = new Vue({
  el: '#video'
});