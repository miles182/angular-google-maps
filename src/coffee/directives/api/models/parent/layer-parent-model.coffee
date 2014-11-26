angular.module("google-maps.directives.api.models.parent".ns())
.factory "LayerParentModel".ns(), ["BaseObject".ns(), "Logger".ns(), "EventsHelper".ns(), '$timeout',(BaseObject, Logger, EventsHelper, $timeout) ->
  class LayerParentModel extends BaseObject
    @include EventsHelper
    constructor: (@scope, @element, @attrs, @gMap, @onLayerCreated = undefined, @$log = Logger) ->
      unless @attrs.type?
        @$log.info("type attribute for the layer directive is mandatory. Layer creation aborted!!")
        return
      @createGoogleLayer()
      ##added by ML

      listeners = @setEvents @layer, scope, scope
      #@listener = google.maps.event.addListener @layer, 'click', (event)=>
      #  @$log.info("Click:"+event.infoWindowHtml)
      #myevents event

      if angular.isDefined(scope.events) and scope.events isnt null and angular.isObject(scope.events)
        getEventHandler = (eventName) ->
          ->
            scope.events[eventName].apply#scope, [@layer, eventName, arguments]
        for eventName of scope.events
          @$log.info('eventname2 is: '+eventName)
          google.maps.event.addListener @layer, eventName, getEventHandler(eventName)  if scope.events.hasOwnProperty(eventName) and angular.isFunction(scope.events[eventName])


      #end
      @doShow = true

      @doShow = @scope.show  if angular.isDefined(@attrs.show)
      @layer.setMap @gMap  if @doShow and @gMap?
      @scope.$watch("show", (newValue, oldValue) =>
        if newValue isnt oldValue
          @doShow = newValue
          if newValue
            @layer.setMap @gMap
          else
            @layer.setMap null
      , true)
      #commented the scope watch cause this unloads the layer if we change the clickable option
      #@scope.$watch("options", (newValue, oldValue) =>
      #  if newValue isnt oldValue
      #    @layer.setMap null
      #    @layer = null
      #    @createGoogleLayer()
      #, true)
      @scope.$on "$destroy", =>
        @removeEvents listeners
        @layer.setMap null

    createGoogleLayer: ()=>
      unless @attrs.options?
        @layer = if @attrs.namespace == undefined then new google.maps[@attrs.type]()
        else new google.maps[@attrs.namespace][@attrs.type]()
      else
        @layer = if@attrs.namespace == undefined then new google.maps[@attrs.type](@scope.options)
        else new google.maps[@attrs.namespace][@attrs.type](@scope.options)

      if @layer? and @onLayerCreated?
        fn = @onLayerCreated(@scope, @layer)
        if fn
          fn(@layer)
  LayerParentModel
]
