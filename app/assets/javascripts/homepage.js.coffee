//= require 'underscore'
//= require 'dates_helper'
//= require 'simplestore'

class UpdatesView
  constructor: (@element, @template, @counter, @items, @compare_date_on)->
    @render_items = @items
    @columns = @element.siblings('thead').find('tr th').length
    @template = _.template(@template.html())

    # @filterDays(@start_date)

  addItems: ->
    @clearList()
    @addNoRow() if !@render_items.length
    @appendItems()
    @truncateList()
    @updateCount()
    @bindTdLinks()
    # TODO: come up with a better way of preventing readhover duplication from the changes list
    window.readhovers() if @element.is('#rp_tbody')

  appendItems: ->
    @element.append(@template(
      id: item.id
      title: item.title
      action: item.action
      klass: item.klass
      section: item.section
      date: item.last_update
      status: item.status
      link: item.link
      read_on: item.read_on
      section_link: item.section_link
      action_message: ->
        if item.merged == false
          item.action
        else
          item.merged

    )) for item in @render_items.reverse()

  clearList: ->
    @element.empty()

  addNoRow: ->
    @element.append($("<tr class='no_row'><td colspan='#{@columns}'>No items to display</td></tr>"))

  unreadItems: ->
    _.filter(@items, (item) ->
      return item.status == "Unread"
    )

  updateCount: ->
    @counter.text(@unreadItems().length)

  filterUnread: ->
    @render_items = @unreadItems()
    @addItems()

  filterDays: (date_to_compare) ->
    today = new Date()
    @render_items = _.filter(@items, (item) =>
      item_date = new Date(item[@compare_date_on])
      #console.log "date to compare: #{date_to_compare} - item date: #{item_date} - today: #{today}"
      return dates.inRange(item_date, date_to_compare, today)
    )
    @addItems()

  bindTdLinks: ->
    $(".updates_table").find('.linkable').on 'click', (e) ->
      target = $(e.target)
      if target.find('a')?.attr('href')?
        document.location = target.find('a').attr('href')
      if target.siblings('a').first()?.attr('href')?
        document.location = target.siblings('a').first().attr('href')

  truncateList: ->
    tr_length = @element.find('tr').length
    if tr_length > 20
      @hidden_item_count = tr_length - 20
      @element.find('tr').hide().slice(0,20).show()
      @addShowMore()

  addShowMore: ->
      @show_more = $("<tr class='more_row'><td colspan='#{@columns}' class='show_more'>Show All #{@element.parents('.tab-pane').find('.time_select .active').text().replace('Last', 'Within')} (#{@hidden_item_count} more)</td></tr>")
      @element.append(@show_more)
      @show_more.click (e) =>
        @element.find('tr:hidden').show()
        @show_more.remove()
  
class UpdatesTable
  constructor: ->
    @element = $('.updates_table')
    @items_to_show = 8
    @start_time = @element.attr('data-thirty')
    @thirty_days_ago = new Date(@start_time)
    @seven_days_ago = new Date(@element.attr('data-seven'))
    @items = new Array()

    @updates_tab  = "#recently_published"
    @updates_pill_range = "unread"
    @updates_more = false
    @getSavedView()

    @bindEvents()
    @getData()
    

  bindEvents: ->
    $('.time_select a').click (e) =>
      e.preventDefault()
      target = $(e.target)
      @changeActiveBtn(target)
      @start_time = new Date(target.attr('data-scope'))
      if target.attr('data-scope') == "unread"
        this[@activeTab()].filterUnread()
      else
        this[@activeTab()].filterDays(@start_time)

    $('.main_tabs').find('a').on 'click', (e) =>
      store("updates_tab", $(e.target).attr('href'))
      upcoming_tab = $(e.target).attr('href')
      current_pill = $("#{upcoming_tab}").find('.time_select a.active').attr('data-range')
      store("updates_pill_range", current_pill)

  getSavedView: ->
    @updates_tab =  store("updates_tab")                || @updates_tab
    @updates_pill_range = store("updates_pill_range")   || @updates_pill_range
    @updates_more = store("updates_more")               || @updates_more

  showSavedView: ->
    $("a[href=#{@updates_tab}]").tab('show')
    $('.time_select:visible').find('a[data-range=' + "#{@updates_pill_range}" +']').click()
    # debugger
    if @updates_tab == "#changes"
      inactive_pill = "30_days"
      inactive_start = @thirty_days_ago
    else
      inactive_pill = "7_days"
      inactive_start = @seven_days_ago

    $('.time_select:hidden').find('a[data-range=' + "#{inactive_pill}" + ']').addClass('active')
    this[@inactiveTab()].filterDays(inactive_start)

  changeActiveBtn: (target) ->
    @clearActiveBtn()
    target.addClass('active')
    store("updates_pill_range", "#{target.attr("data-range")}")

  clearActiveBtn: ->
    $("##{@activeTab()} .time_select a.active").removeClass('active')

  activeTab: ->
    $('.main_tabs li.active').find('a').attr('href').replace('#', '')

  inactiveTab: ->
    $('.main_tabs li:not(".active")').find('a').attr('href').replace('#','')

  getData: ->
    $.ajax
      url: "/recent_changes"
      type: "POST"
      data: "date=#{@start_time}"
      dataType: "json"
      success: (response) =>
        @initChildren(response)
      error: (response) ->
        # alert "something went wrong #{response}"

  initChildren: (items) ->
    @items = items
    #(@element, @template, @counter, @items, @compare_date_on)
    @recently_published = new UpdatesView($('#rp_tbody'), $('#recently_published_template'), $('#rp_count'), @filterOldPubs(items), "published_on")
    @changes = new UpdatesView($('#changes_tbody'), $('#changes_template'), $('#changes_count'), items, "last_update")
    @showSavedView()

  filterOldPubs: (items) =>
    # because we can get items that were published > 30days ago
    # in our array because they may have been recently updated
    # let's strip them out of the RP items so we don't get them in
    # our unread view
    today = new Date()
    items = _.filter(items, (item) =>
      pub_date = new Date(item.published_on)
      return dates.inRange(pub_date, @thirty_days_ago, today)
    )
    return items


$ ->
  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  #initialize. test for class so we don't render on maintenance page
  if $('.updates_table').length
    updates = new UpdatesTable