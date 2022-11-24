Vue.component('empty', {
  data: function () {
    return this.setDefault();
  },
  beforeMount: function () {

  },
  methods: {
    setDefault: function () {
      return {
        onoff: false,
      }
    },
    open: function () {
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
  },
  template: `<div v-if="onoff">
    
  </div>`
});

var empty = new Vue({
  el: '#empty'
});