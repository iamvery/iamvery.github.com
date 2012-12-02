jQuery ($) ->
  $('.container').hide().delay(200).slideDown 1000, 'easeInOutQuint'

  toggle_on = ->
    $this = $(this)
    $this.siblings('.toggle-target').slideDown 1000, 'easeInQuint'
    $this.find('.toggle-on').slideDown 500, 'easeInQuint'
    $this.find('.toggle-off').slideUp 500, 'easeOutQuint'

  toggle_off = ->
    $this = $(this)
    $this.siblings('.toggle-target').slideUp 1000, 'easeOutQuint'
    $this.find('.toggle-off').slideDown 500, 'easeInQuint'
    $this.find('.toggle-on').slideUp 500, 'easeOutQuint'

  $('.toggle-target, .toggle-on').hide()
  $('.toggle').toggle toggle_on, toggle_off
