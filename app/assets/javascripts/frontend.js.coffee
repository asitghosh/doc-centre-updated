//= require_tree ./templates

spinner_defaults =
    lines: 9 # The number of lines to draw
    length: 0 # The length of each line
    width: 2 # The line thickness
    radius: 3 # The radius of the inner circle
    corners: 0.8 # Corner roundness (0..1)
    rotate: 30 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: "#FFF" # #rgb or #rrggbb or array of colors
    speed: 1.5 # Rounds per second
    trail: 50 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: true # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: "auto" # Top position relative to parent in px
    left: "auto" # Left position relative to parent in px

#####
#
# -- STICKY HEADINGS
#
#####

class StickyHeaders
  constructor: ->
    @window = $(window)
    @container = $('.left-col')
    @headers = $('h3.h5')
    @fakeheader = @headers.filter(':first').clone()
    @zindex = 2
    @attachFake()
    @bindEvents()
    @adjustment = -1

  attachFake: ->
    @fakeheader.css
      'position' : 'fixed'
      'width' : (parseInt(@container.outerWidth()) - 16)+"px"
      'top' : '0px'
      'z-index' : @zindex
      'margin-top' : '0px'
      'padding' : '15px 0 11px 15px'
      'background' : 'rgba(235,235,235, 0.9)'
      'display' : 'none'
    .addClass('fakeheader')
    @container.prepend(@fakeheader)

  bindEvents: ->
    @window.scroll (e) =>
      @headers.each (index, item) =>
        header = $(item)
        top = header.offset().top + @adjustment

        if top < @scrollPosition()
          @fakeheader.text(header.text()).show()

      if @scrollPosition() < @headers.filter(":first").offset().top + @adjustment
        $('.fakeheader').hide()

  scrollPosition: ->
    @window.scrollTop()

#####
#
# -- SIDE NAVIGATION
#
#####

if $('.public_pages').length
  spyElement = $('.sectionbody, .content-passage').find('h2')
  if spyElement.length == 0 && $('.jumpnav').children().length == 0
    $('.jumpnav').remove()
  spyElement.addClass('spy_this')
  $('h2.spy_this').each (obj, value) ->
    $('.jumpnav').append '<li><a href="#' + $(this).attr("id") + '">' + $(this).text() + '</a></li>'

class JumpNav
  constructor: ->
    @el = $('.jumpnav')
    @offset = @calc_fix_offset()
    @bottom_offset = @calc_bottom_offset()
    @bindPlugins()
  bindPlugins: ->
    @el.localScroll
      'hash' : true
      'offset' : -110 



      # ->
      #   if $('.fix_wrap').length == 0
      #     return -110
      #   else
      #     return 0

    _t = @
    #cache the array of items to spy on
    @spies = $('.spy_this')
    @spies.each (i) ->
      $(this).scrollspy(
        min: =>
          _t.calc_min(this) - 165
        max: =>
          _t.calc_max(i)
        onEnter: (element, position) ->
          #console.log "entering #{element.id}"
          _t.make_sidenav_active(element.id)
        onLeave: (element, position) ->
          #console.log "leaving #{element.id}"
          #_t.remove_sidenav_active(element.id)
        )

    if $('.fix_wrap').length
      $('.fix_wrap').affix({
        'offset' :
          'top' : @offset
          'bottom' : 263
      })
  calc_min: (element) ->
    $(element).offset().top

  calc_max: (index) ->
      if index < @spies.length-1
        return $(@spies[index+1]).offset().top
      else
        return $('body').height()

  #active_load_hash: ->
    # this is going to be problematic when combined with scrollTo since the first movement
    # of the container is going to reset the active state to whatever that element is
    # hash = window.location.hash
    # $("ul.jumpnav a[href='#{hash}']").parent('li').addClass('active')

  make_sidenav_active: (id) ->
    @remove_sidenav_active(id)
    $("ul.jumpnav a[href='##{id}']").addClass('active')

  remove_sidenav_active: (id) ->
    $("ul.jumpnav a.active").removeClass('active')

  calc_fix_offset: ->
    if $('.fix_wrap').length
      $('.fix_wrap').offset().top
    else
      return 0

  calc_bottom_offset: ->
    $('body > footer').outerHeight(true)

class RboxHover
  constructor: ->
    @bindEvents()
  bindEvents: ->

    $('.rbox').find('footer').find('li').hoverIntent({
      over: (e) =>
        @createHelper(e)
      out: (e) =>
        @removeHelper(e)
      timeout: 200
      sensitivity: 1
      interval: 20
    })


  createHelper: (e) ->
    target = $(e.target)
    text = target.attr('title')
    tooltip = @find_tooltip(target)
    target.addClass('active')
    tooltip.text(text).show()

  removeHelper: (e) ->
    target = $(e.target)
    tooltip = @find_tooltip(target)
    target.removeClass('active')
    tooltip.text('').hide()

  find_tooltip: (hovered_a) ->
    hovered_a.parents('.wrapper').find('#hover_title')

#####
#
# -- PDF INTERFACE
#
#####

class PdfStatus
  constructor: ->
    @mediator = window.dc.mediator or= new Mediator

  updateSidebarStatus: (status, channel) ->
    @statuses   = ["default", "generating", "complete", "error"]
    @classes    = $.map(@statuses, (val, i) -> "pdf-status-" + val)
    @allClasses = @classes.join(' ')
    @el = $(this)
    switch status
      when @statuses[0]
        # default
        @el.removeClass(@allClasses).addClass(@classes[0])
      when @statuses[1]
        # generating
        @el.removeClass(@allClasses).addClass(@classes[1])
      when @statuses[2]
        # complete
        @el.removeClass(@allClasses).addClass(@classes[2])
      else
        # error
        @el.removeClass(@allClasses).addClass(@classes[3])

  updateFlashStatus: (status, channel) ->
    console.log "Flash Status #{status}"
    @statuses   = ["default", "generating", "complete", "error"]
    @classes    = $.map(@statuses, (val, i) -> "pdf-status-" + val)
    @allClasses = @classes.join(' ')
    @el = $(this)
    $msg = @el.find('.msg')
    switch status
      when @statuses[0]
        # default
          return false
      when @statuses[1]
        # generating
        pdf_opts = jQuery.extend({}, spinner_defaults);
        pdf_opts.color = "##{$('body').data('color')}"
        if !@el.data('spinner')
          $msg.before('<span class="waiting-spinner"></span>')
          spin_el = @el.find('.waiting-spinner').get(0)
          @el.data('spinner', new Spinner(pdf_opts).spin(spin_el))
        new_message = I18n_pdf.generating # comes from _head partial
        $msg.text(new_message)
      when @statuses[2]
        # complete
        new_message = I18n_pdf.complete # comes from _head partial

        $msg.text(new_message)
      else
        # error
        new_message = I18n_pdf.error # comes from _head partial
        $msg.html("<a href='#'>#{new_message}</a>")
        @el.on 'click.flash_pdf', (e) ->
          e.preventDefault()
          window.dc.PdfDownloader.tryAgain() if window.dc.PdfDownloader
          window.dc.PdfDownloader or= new PdfDownloader(this)
        @el.data('spinner', null).find('.waiting-spinner').remove()


class PdfDownloader
  constructor: (item) ->
    @element = $(item)
    @url = @element.attr('href')
    @tries = 0
    @maxTries = 24
    @try()
    @color = $('body').data('color')

    @replaceSpinner()

  try: ->
    console.log('trying')
    @tries++
    $.ajax
      url: @url
      dataType: "json"
      statusCode:
        202: (response) =>
          @generating()
      success: (response, status, xhr) =>
        @success(response) if response.success? && response.success == true
      error: (response, status, error) =>
        @error()

  tryAgain: ->
    @try() if @tries == 0

  publishStatus: (status) ->
    console.log('publishing status ' + status)
    window.dc.mediator.publish('pdf-status', status)

  success: (response) ->
    @publishStatus('complete')
    window.location = response.url
    setTimeout ( =>
      @publishStatus('default')
      @resetTries()
    ), 4000

  replaceSpinner: ->
    console.log "replacing spinner"
    pdf_opts = jQuery.extend({}, spinner_defaults);
    pdf_opts.color = "##{@color}"

    $('.download_messages').find('.spinner-small').each (i, v) ->
      el = $(v)
      el.empty()
      spinner = new Spinner(pdf_opts).spin(el.get(0))
      #el.append(spinner.el)

  generating: ->
    console.log('tries: ' + @tries)
    console.log('generating')
    @publishStatus('generating')

    if @tries <= @maxTries
      @timeout = setTimeout ( =>
         @try()
      ), 5000
    else
      @error()

  error: ->
    @publishStatus('error')
    @resetTries()

  resetTries: ->
    @tries = 0

#####
#
# -- read UNREAD
#
#####

class ReadUnreadNotifier
    constructor: (item) ->
      @element = $(item)
      @current_state = @element.data('state')
      @queryCount = 0
      @show_classes = ".show, .show_roadmap"
      @offset = @element.position().left + parseInt(@element.css('margin-left'))
      [@klass, @id] = @element.attr('data-resource-id').split('-')
      # console.log "id = #{@id}"
      if $('body').is(@show_classes) and @current_state == "unread"
        setTimeout ( =>
          @markAsRead()
        ), 1000

    changeToLoading: ->
      @element.removeClass('unread').addClass('loading')
      @element.unbind()

    changeToRead: ->
      @element
        .removeClass('unread loading')
        .addClass('read')
        .data('read-on', @timestamp)

    changeToUnread: ->
      @element.removeClass('loading read').addClass('unread')
      @element.parents('.read').removeClass('read').addClass('unread')
      @element.unbind()

    markAsRead: ->
      @queryCount++
      @changeToLoading()
      $.ajax
        url: "/mark_as_read"
        data: "klass=#{@klass}&id=#{@id}"
        success: (response) =>
          switch response.status
            when 200
              #console.log 200, response
              @timestamp = response.timestamp
              setTimeout ( =>
                 @changeToRead()
              ), 750
            when 202
              #console.log 202, response
              if @queryCount < 5
                setTimeout ( =>
                  @markAsRead()
                ), 2000
              else
                @queryCount = 0
                @changeToUnread()
            else
              #console.log 'weird success', response
              @changeToUnread()
        error: (response) =>
          #console.log 'error', response
          @changeToUnread()

$('.chosen-input').chosen({disable_search_threshold: 10})

$ ->
  #Setup global Doc Center namespace
  window.dc or= {}
  $.localScroll.hash({
    offset: -110
  })

  if $('.public_pages, .releases').length > 0 
    $.localScroll({
      offset: -110
      hash: true
    })

  $('.header-search input').keydown (e) ->
    if e.keyCode == 13
      e.preventDefault()
      $('.header-search').submit()

  $('.filter-list input').on 'click', (e) ->
    input = $(e.target)
    name = input.attr('name')
    value = input.val()
    #console.log $('.header-search [name = "' + name + '"]')
    $('.header-search [name = "' + name + '"]').val(value)
    if name == "index"
      $('.header-search .chosen-input').trigger('chosen:updated')
    $('.header-search').submit()

  $('.filter-select select').on 'change', (e) ->
    value = $(this).val()
    name = $(this).attr('name')
    $('.header-search [name = "' + name + '"]').val(value)
    $('.header-search').submit()

  $('a[href*="/fm/"]').on 'click', (e) ->
    target = $(this).attr('href').split("/").pop()
    if $("a[name=#{target}]").length
      #console.log "on this page"
      e.preventDefault()
      #window.location.hash = target
      $(window).scrollTo("a[name=#{target}]", {
        offset: -110,
        duration: 500
      })

  # hover intent for user menu
  # then using hoverintent to remove it after the timeout period
  $('.subnav').hoverIntent({
    over: (e) ->
      $(this).addClass('active')
    out: (e) ->
      $(this).removeClass('active')
    timeout: 0
    interval: 1
  })

  $('.js-download-pdf')
    .each ->
      window.dc.PdfStatus or= new PdfStatus
      subscription =  window.dc.mediator.subscribe("pdf-status",
                                                    window.dc.PdfStatus.updateSidebarStatus).context = this
    .on 'click', (e) ->
      e.preventDefault()
      window.dc.PdfDownloader.tryAgain() if window.dc.PdfDownloader
      window.dc.PdfDownloader or= new PdfDownloader(this)

  if $('#flash_pdf_generation').length
    $flash = $('#flash_pdf_generation')
    window.dc.PdfStatus or= new PdfStatus
    subscription =  window.dc.mediator.subscribe("pdf-status",
                                                    window.dc.PdfStatus.updateFlashStatus).context = $flash
    $msg = $flash.find('.msg')
    new_message = I18n_pdf.generating # comes from _head partial
    $msg.text(new_message)
    $('.js-download-pdf').click()

  if $('.roadmaps.show').length
    # $('.roadmap_nav .active').parents('.depth-2, .depth-1, .depth-0').addClass('open').siblings('h2').addClass('open').find('a').addClass('open')
    #$('.roadmap_nav .active').addClass('open').parents('h2').siblings('.depth-2').addClass('open')
    $('.js-year-toggle').on 'click', (e) ->
      $(this).toggleClass('open').siblings('.depth-1').toggleClass('open')

  # if $('.public_pages.show , .apis.show').length
  #   $('.js-sidenav-toggle').on 'click', (e) ->
  #     $this = $(this)
  #     nestedSiblings = $this.siblings('ul.nested')
  #     sideNavToggle = $('.js-sidenav-toggle')
  #     allList = $('.js-sidenav-toggle').siblings()
  #     sideNavToggle.removeClass('open')
  #     allList.removeClass('open')
  #     $this.addClass('open')
  #     nestedSiblings.addClass('open')
  #     nestedSiblings.find('ul.nested').addClass('open')
  
  # if $('.operation-description').length
  #   $('.operation-description').children().css 'padding-left' , '50px'

  # if $('.js-sidenav-toggle').length
  #   resizeTimer = undefined
  #   calculate_sidenav = ->
  #     sidenav_rootnode_height = 0
  #     $('.depth-0 > li > a > h2').each ->
  #       sidenav_rootnode_height += $(this).outerHeight()
  #     nav_height = 110
  #     flash_height = $('.flash_container').outerHeight() || 0
  #     w_height = $(window).height()
      
  #     available_space = w_height - nav_height - sidenav_rootnode_height

  #     $('.depth-0 .depth-3').height(available_space - 44)

  #   calculate_sidenav()

  #   resizeFunction = ->
  #     calculate_sidenav()

  #   $(window).resize ->
  #     clearTimeout(resizeTimer)
  #     resizeTimer = setTimeout(resizeFunction, 250)

  if $('.api_nav a.active').length
    calculateLink = ->
      linkPosition = $('.api_nav a.active').offset().top - $('.depth-3.open').offset().top
      $('.depth-3.open').animate { scrollTop: linkPosition}

    calculateLink()




  $('.expand').on "click", (e) ->
    e.preventDefault()
    e.stopPropagation()
    $(this).closest('li').toggleClass('open').find('> ul').toggleClass('open')

  $('#modal--user_settings').on 'show', ->
    iframe = $(this).find('iframe')
    url = "/users/iframesettings"
    iframe.attr('src', url) unless iframe.attr('src') == url

  $('#update_settings').on 'ajax:success', (evt, data, status, xhr) ->
      $(this).find('h2').text('Settings - Updated!')

      # if we're on the homepage
      w = $(window.top.document)
      if w.find('.welcome_intro').length > 0
        panel = w.find('.welcome_intro')
        if data.welcome == true && panel.is(':hidden')
          panel.height('0px').removeClass('hidden').animate({
            height: '226px'
          }, 350,  $.easie(0.23, 1.0, 0.32, 1.0)
          )
        else if data.welcome == false && panel.is(':visible')
          panel.animate({
            paddingBottom: '0'
            height: '0'
          }, 250, $.easie(0.23, 1.0, 0.32, 1.0), ->
            $(this).addClass('hidden')
          )

      setTimeout ->
        modal = w.find('.modal.in')
        modal.attr('aria-hidden', true).css({ "display" : "none" }).removeClass('in')
        backdrop = w.find('.modal-backdrop')
        backdrop.remove()
      , 600




  if $('body.show').length and $('h3.h5').length
    sticky = new StickyHeaders

  if $('.jumpnav').length
    jumpnav = new JumpNav

  if $('.rbox footer a').length
    hovers = new RboxHover

  window.readhovers = ->
    window.readindicators = window.readindicators || new Array()
    $('.unread.indicator, .read.indicator').not('.noprefix').each (index, item) ->
      window.readindicators[index] = window.readindicators[index] || new ReadUnreadNotifier(item)

  if $('.unread.indicator, .read.indicator').length > 0
    window.readhovers()

  # if $('.indicator').length
  #   $('.indicator').each (index, item) ->
  #     new MarkAsRead(item)

  # making this accessible on the window so we can call it from
  # hompage.js.coffee as the data changes

  $('.welcome_intro li a').hover(
    (e) ->
      tar = $(e.target)
      tar.parents('li').find('.tooltip').addClass('active')
    ,
    (e) ->
      tar = $(e.target)
      tar.parents('li').find('.tooltip').removeClass('active')
  )

  # external links
  # url = [location.protocol, '//', location.host].join('')
  # $('a:not([href^="#{url}"]):not([href^="/"]):not([href^="#"]):not([href^="mailto"]):not(".no_icon")').attr('rel', 'external').addClass('after-icon-external')

  # anything disabled shouldn't click
  $('.disabled > a, .disabled').click (e) ->
    e.preventDefault()

  $('.spinner-small').each (i, v) ->
    el = $(v)
    el.data('spinner', new Spinner(spinner_defaults).spin(el.get(0)))

  $('#channel_specific ul').each ->
    $this = $(this)
    if $this.find(' > li').length > 8
      $this.find('li:gt(7)').hide()
      $this.append(
        $('<span class="indicator more-ellipsis channel_color_30_background_hover channel_color_border_hover channel_color_hover">&hellip;</span>').on 'click', (e) ->
          $(this).siblings(':hidden').show().end().remove()
      )


  # Grabs immediate directory of URL for active navigation for breadcrumbs

  # $ ->
  #   url = document.location.pathname.split('/').slice(-2, -1).toString()
  #   $('.dynamic-nav a[href*="' + url + '"]').addClass 'active'

