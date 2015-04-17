angular.module('uiGmapgoogle-maps.directives.api.models.parent')
.factory 'uiGmapLayerParentModel', ['uiGmapBaseObject', 'uiGmapLogger', '$timeout','uiGmapEventsHelper', (BaseObject, Logger, $timeout,EventsHelper) ->
  class LayerParentModel extends BaseObject
    @include EventsHelper
    constructor: (@scope, @element, @attrs, @gMap, @onLayerCreated = undefined, @$log = Logger) ->
      unless @attrs.type?
        @$log.info 'type attribute for the layer directive is mandatory. Layer creation aborted!!'
        return
      @createGoogleLayer()

      #@$log.error('creating layer with '+scope.options+' and show '+scope.show)
      listeners = @setEvents @gObject, scope, scope
      #@listener = google.maps.event.addListener @layer, 'click', (event)=>
      #  @$log.info("Click:"+event.infoWindowHtml)
      #myevents event

      if angular.isDefined(scope.events) and scope.events isnt null and angular.isObject(scope.events)
        getEventHandler = (eventName) ->
          ->
            scope.events[eventName].apply#scope, [@layer, eventName, arguments]
        for eventName of scope.events
          @$log.info('eventname2 is: '+eventName)
          google.maps.event.addListener @gObject, eventName, getEventHandler(eventName)  if scope.events.hasOwnProperty(eventName) and angular.isFunction(scope.events[eventName])
      #end
      @doShow = true

      @doShow = @scope.show if angular.isDefined(@attrs.show)
      @gObject.setMap @gMap if @doShow and @gMap?
      @scope.$watch 'show', (newValue, oldValue) =>
        if newValue isnt oldValue
          @doShow = newValue
          if newValue
            @gObject.setMap @gMap
          else
            @gObject.setMap null
      , true
      @scope.$watch("options", (newValue, oldValue) =>
        if newValue isnt oldValue
          @gObject.setMap null
          @gObject = null
          @$log.info('options changed ')
          @createGoogleLayer()
      , true)
      @scope.$on "$destroy", =>
        @removeEvents listeners
        @gObject.setMap null

    createGoogleLayer: =>
      unless @attrs.options?
        @gObject = if @attrs.namespace == undefined then new google.maps[@attrs.type]()
        else new google.maps[@attrs.namespace][@attrs.type]()
      else
        @gObject = if @attrs.namespace == undefined then new google.maps[@attrs.type](@scope.options)
        else new google.maps[@attrs.namespace][@attrs.type](@scope.options)

      if @gObject? and @onLayerCreated?
        @onLayerCreated(@scope, @gObject)? @gObject

  LayerParentModel
]
