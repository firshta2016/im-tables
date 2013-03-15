do ->

  class History extends Backbone.Collection

    initialize: ->
      @currentStep = 0
      @currentQuery = null
      @on 'revert', @revert, @

    unwatch: ->
      #if @currentQuery?
      #  @stopListening @currentQuery

    watch: ->
      if q = @currentQuery
        @listenTo q, "change:constraints", => @onChange q, 'constraints', 'filter'
        @listenTo q, "change:views", => @onChange q, 'views', 'column'
        @listenTo q, "change:joins", => @addStep "Changed joins", q
        @listenTo q, "set:sortorder", => @addStep "Changed sort order", q
        @listenTo q, "count:is", (n) => @last().set count: n
        @listenTo q, "undo", => @popState()

    onChange: (query, prop, label) ->
      xs = @last().get('query')[prop]
      ys = query[prop]
      was = xs.length
      now = ys.length
      n = Math.abs was - now
      quantity = if n is 1 then 'a ' else if n then "#{ n } " else ''
      pl = if n isnt 1 then 's' else ''
      verb = if was < now
        'Added'
      else if was > now
        'Removed'
      else if now is _.union(xs, ys).length
        'Rearranged'
      else
        'Changed'

      title = "#{ verb } #{ quantity }#{ label }#{pl}"
      @addStep title, query

    addStep: (title, query) ->
      @unwatch()
      @currentQuery = query.clone()
      @currentQuery.revision = @currentStep
      @watch()
      @each (state) -> state.set current: false
      @add query: query.clone(), current: true, title: title, stepNo: @currentStep++

    popState: -> @revert @at @length - 2

    revert: (target) ->
      @unwatch()
      while @last().get('stepNo') > target.get('stepNo')
        @pop()
      current = @last()
      current?.set current: true
      @currentQuery = current?.get('query')?.clone()
      @currentQuery.revision = current.get('stepNo')
      @watch()
      @trigger 'reverted', @currentQuery

  scope 'intermine.models.table', {History}
