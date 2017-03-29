//= require jquery
//= require_tree ./templates
//= require active_admin/base
//= require admin/nestedsortable
//= require admin/chosen/chosen.jquery.min
//= require rich
//= require select2

addFlash = (message, type="notice") ->
  flash = JST['templates/active_admin_flash']({
    type : type
    message : message
  })
  $('#title_bar').after flash

class sortablelist
  constructor: ->
    $('.sortable').nestedSortable
      handle: '.itemcontainer'
      items: 'li'
      toleranceElement: '> div'
      isTree : true
      update : @update_pages
    @bind_events()

  bind_events: ->
    # open/close arrow
    $('.itemcontainer').on 'click', (e) ->
      $(this).toggleClass('open')

  update_pages: (event, ui) ->
    post_path = $(@).attr('data-sort-url')
    data = $(@).nestedSortable('serialize', { 'key' : 'page_ids' } )
    $.post(post_path, data).success (data) =>
      make_link = for id, new_link of data
        #console.log "ID: #{id} is now #{new_link}"
        $('#view_for_' + id + ' a').attr('href', new_link)


class AutoSave
  constructor: ->
    @interval = 15000
    @form = $('.formtastic')
    @save_container = $('.autosave_status')
    @save_text = $('.autosave_status .text_status')
    @info_fieldset = $('#resource_data')
    @autosaves_list = $('#autosaves_list')

    @set_to('idle', "Autosave idle.")
    @bind_events()
  bind_events: ->
    setInterval @serialize_and_submit, @interval

  remove_status_classes: ->
    @save_container.removeClass('idle successful active error')

  set_to: (klass, message) ->
    @remove_status_classes()
    @save_container.addClass(klass)
    @set_message(message)

  set_message: (message) ->
    @save_text.text(message)

  idle_in_five: ->
    setTimeout =>
      @set_to('idle', "Autosave idle.")
    , 5000

  reset_status: ->
    @set_to('idle', "No edits since last autosave, Autosave idle.")

  check_and_trim_list: ->
    @autosaves_list.find('li').slice(5).remove()

  new_autosave: (response) ->
    url = [location.protocol, '//', location.host, location.pathname].join('')
    new_list_item = """<li><a href="#{url}?autosave_id=#{response.as_id}">Autosave #{response.time}</a></li>"""

    @autosaves_list.prepend(new_list_item)
    @check_and_trim_list()
    @idle_in_five()

  serialize_and_submit: =>
    @set_to('active', "Autosaving...")
    CKEDITOR.instances[k].updateElement() for k, v of CKEDITOR.instances
    klass = @info_fieldset.attr('data-class')
    id = @info_fieldset.attr('data-id')
    data = "class=#{klass}&id=#{id}&"
    formdata = @form.serialize()
    $.ajax
      "data" : data + formdata
      "url" : "/autosave"
      "type" : "POST"
      "dataType" : "json"
      success : (response) =>
        if response.new_record
          @set_to('successful', response.message)
          @new_autosave(response)
        else
          @reset_status()
      error : (response) =>
        @set_to('error', response.message)
        @idle_in_five()

class WarnBeforeExit
  constructor: ->
    window.onbeforeunload = @stopBackIfEdits
    @bindEvents()

  bindEvents: ->
    $('form').on 'submit', (e) ->
      window.onbeforeunload = null

  stopBackIfEdits: (e) =>
    e = e || window.event
    if e && @testForDirtyFields()
      return 'You may have made edits that haven\'t been saved. Are you sure?'

  testForDirtyFields: (e) ->
    statuses = []
    statuses.push CKEDITOR.instances[k].checkDirty() for k, v of CKEDITOR.instances
    return $.inArray(true, statuses) > -1





    #CKEDITOR.instances[k].updateElement() for k, v of CKEDITOR.instances

disable_time_to_send = ->
  $('#channel_partner_time_to_send_latest_release').attr('disabled', true).prop('selectedIndex', 0)

enable_time_to_send = ->
  $('#channel_partner_time_to_send_latest_release').attr('disabled', false)

create_select2_tag_field = (element) ->
  placeholder = $(element).data("placeholder")
  url = $(element).data("url")
  saved = $(element).data("saved")
  $(element).select2(
    tags: true
    placeholder: placeholder
    minimumInputLength: 1
    initSelection: (element, callback) ->
      saved and callback(saved)
      return

    ajax:
      url: url
      dataType: "json"
      data: (term) ->
        q: term

      results: (data) ->
        results: data

    id: (object) ->
      object.name

    createSearchChoice: (term, data) ->
      if $(data).filter(->
        this.name == term
      ).length is 0
        id: term
        name: term

    formatResult: (item, page) ->
      item.name

    formatSelection: (item, page) ->
      item.name
  )

filter_pages = (value) ->
  
  $('#api_framemaker_export_location option').attr("disabled", false)
  $('#api_framemaker_export_location option').each (index, option) ->
    #console.log $(option).val().indexOf(value)
    $(option).attr("disabled", true) if $(option).val().indexOf(value) != 0
    $('#api_framemaker_export_location').trigger("chosen:updated")

filter_chapters = (value) ->
  
  $('#api_framemaker_chapter option').attr("disabled", false)
  $('#api_framemaker_chapter option').each (index, option) ->
    $(option).attr("disabled", true) if $(option).val().indexOf(value) != 0
    $('#api_framemaker_chapter').trigger("chosen:updated")

$ ->
  $(".chosen-input").chosen({
    search_contains: true,
    display_disabled_options: false
  })

  $('.js-open-all').on "click", (e) ->
    console.log "open-all clicked"
    e.preventDefault()
    $('.itemcontainer').toggleClass('open')

  $('.js-remove').on "ajax:success", (e) ->
    $(this).parents(".annotation-list-item").remove()

  $(".tagselect").each ->
    create_select2_tag_field(this)
  list_view = new sortablelist
  if $('#autosaves_sidebar_section').length
    autosave = new AutoSave

  $('.has_many .button').click (e) ->
    $(".chosen-input").chosen()
    $(".tagselect").each ->
      create_select2_tag_field(this)

  if $('#channel_partner_day_to_send_latest_release').val() == ""
    disable_time_to_send()

  $('#channel_partner_day_to_send_latest_release').on 'change', (e) ->
    if $(this).val() == ""
      disable_time_to_send()
    else
      enable_time_to_send()

  if $('#api_framemaker_export_location').length

    if $("#api_framemaker_chapter option:selected").val().length > 0
      filter_pages($("#api_framemaker_chapter option:selected").val())

    if $("#api_framemaker_book option:selected").val().length > 0
      filter_pages($("#api_framemaker_chapter option:selected").val())
      filter_chapters($("#api_framemaker_book option:selected").val())


    $("#api_framemaker_book").on "change", (e) ->
      value = $(e.target).val()
      $('#api_framemaker_export_location option:selected').removeAttr("selected") if $('#api_framemaker_chapter option:selected').val() != ""
      $('#api_framemaker_chapter option:selected').removeAttr("selected") if $('#api_framemaker_chapter option:selected').val() != ""
      filter_chapters(value)
      filter_pages(value)

    $("#api_framemaker_chapter").on "change", (e) ->
      $('#api_framemaker_export_location option:selected').removeAttr("selected") if $('#api_framemaker_chapter option:selected').val() != ""
      filter_pages($(e.target).val())

    field = $('#api_framemaker_export_location')
    field.on "change", (e) ->
      value = field.val().split("---")[1].replace(".html", "")
      $('#api_framemaker_page_id').val(value)



  if $('body.edit').length
    warn = new WarnBeforeExit
