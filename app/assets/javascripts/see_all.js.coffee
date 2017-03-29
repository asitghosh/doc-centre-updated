

# this file only gets loaded when the user.can_see_all?
# impersonation and other stuff that shouldn't be
# exposed to normal users should be put here.
$ ->

# contentType is included in these requests mostly so our tests stop bitching about it.
  if $('.impersonation').is(":visible")
    $('.impersonation .chosen-input').trigger("chosen:updated")

  $('select#partner').change (e) ->
    val = $(e.target).val()
    url = "/impersonate/#{val}"
    $.ajax
      type: "POST"
      url: url
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
      success: (response) ->
        location.reload()
      error: (response) ->
        # we should probably do something

  $('.stop_impersonation').click (e) ->
    e.preventDefault()
    url = "/unimpersonate"
    $.ajax
      type: "POST"
      url: url
      contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
      success: (response) ->
        location.reload()
      error: (response) ->
        # we should probably do something

  $('.close_impersonation').click (e) ->
    e.preventDefault()
    if $('.impersonation').is(":visible")
      $('.impersonation').slideUp(200)
    else
      false

  $('#start_impersonation').click (e) ->
    e.preventDefault()
    $imperson_banner = $('.impersonation')
    if $imperson_banner.is(":visible")
      $imperson_banner.slideUp(200)
    else
      $imperson_banner.slideDown(200)
      $('.impersonation select').trigger("chosen:updated")

  $('#dismiss_updates').click (e) ->
    e.preventDefault()
    $.ajax
      type: "POST"
      url: "/dismiss_update_notice"
      success: (response) ->
        $('#flash_posted').hide()
      error: (response) ->
        #do something
