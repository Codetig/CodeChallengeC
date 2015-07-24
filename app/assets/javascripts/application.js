// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
  console.log("Applcation.js up!");

  $('.alert-msg').fadeOut(5000);

  //setting the tabs to go active and inactive
  var navs = [$('.intro'),$('#prev-search'), $('#new-search')];
  navs.forEach(function(el, i){
    var link = $('.link' + (i + 1));

    el.on('mouseover',function(e){link.addClass('active');});
    el.on('mouseout',function(e){link.removeClass('active');});
  });

});