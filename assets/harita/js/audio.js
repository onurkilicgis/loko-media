Vue.component('myaudio', {
  data: function () {
    return this.setDefault();
  },
  beforeMount: function () {

  },
  methods: {
    setDefault: function () {
      return {
        item: false,
        type:'audio/mpeg'
      }
    },
    open: function (item) {
      this.item=item;
      var part = item.path('.');
      var ext = part.pop();
      ext = ext.toLocaleLowerCase()
      switch(ext){
        case 'mp3':{
          this.type='audio/mpeg';
          break;
        }
        case 'wav':{
          this.type='audio/wav';
          break;
        }
        case 'ogg':{
          this.type='audio/ogg';
          break;
        }
        case 'm4a':{
          this.type='audio/x-m4a';
          break;
        }
      } 
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
    <header class="modal-card-head" style="background-color:#202B3F; border-bottom: 1px solid #1a1a1a; padding: 10px;">
      <p class="modal-card-title" style="color:#eee; font-size:12px;">{{item.name}}</p>
      <button @click="close" class="delete" aria-label="close"></button>
    </header>
    <section class="modal-card-body cc" style="background-color:#1A2133; padding:5px;">
      <audio autoplay loop controls controlsList="nodownload">
        <source :src="item.path" :type="type">
      </audio>
    </section>
    <footer class="modal-card-foot" style="background-color:#202B3F; border-top: 1px solid #1a1a1a; padding: 5px;">
    </footer>
  </div>
</div>
  </div>`
});
var myaudio = new Vue({
  el: '#audio'
});