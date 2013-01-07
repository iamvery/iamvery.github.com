jQuery(function($){
  function toggle_on(){
    $this = $(this)
    $this.siblings('.toggle-target').slideDown(1000, 'easeInQuint')
    $this.find('.toggle-on').slideDown(500, 'easeInQuint')
    $this.find('.toggle-off').slideUp(500, 'easeOutQuint')
  }

  function toggle_off(){
    $this = $(this)
    $this.siblings('.toggle-target').slideUp(1000, 'easeOutQuint')
    $this.find('.toggle-off').slideDown(500, 'easeInQuint')
    $this.find('.toggle-on').slideUp(500, 'easeOutQuint')
  }

  $('.toggle-target, .toggle-on').hide()
  $('.toggle').toggle(toggle_on, toggle_off)
})
