class MaterialRaingular.d3.Directives.MrD3HorizontalBarChartModel extends AngularDirectiveModel
  @inject('$timeout','$element','$attrs')
  initialize: ->
    @options = @$scope.$eval(@$attrs.d3Options || '{}')
    @options.margins = Object.merge({top: 20,right: 20, left: 70, bottom: 50},@options.margins || {})
    @svg = d3.select(@$element[0])
    @holder = @svg.select('g')
    @holder.attr('transform',"translate(#{@options.margins.left},#{@options.margins.right})")
    @yAxis = d3.scaleBand().rangeRound([0,@height()]).padding(0.1)
    @xAxis = d3.scaleLinear().range([0,@width()])
  indexOf: (bar) ->
    @bars().nodes().indexOf(bar)
  bars: ->
    nodes = @holder.selectAll('svg > g > rect').nodes()
    d3.selectAll(nodes.concat(@holder.selectAll('g.stacked').nodes()))
  adjustBars: ->
    @yDomain = []
    for bar in @bars().nodes()
      rect = d3.select(bar)
      @yDomain[@indexOf(bar)] = rect.attr('label')
      width = (rect.attr('raw-size') / @maxValue()) * @width()
      rect.attr('width',width)
    @yAxis.domain(angular.copy(@yDomain).reverse())
    for rect in @bars().nodes()
      d3.select(rect).attr('height',@yAxis.bandwidth())
      d3.select(rect).attr('y',@yAxis(@yDomain[@indexOf(rect)]))
    @_yAxis?.call(d3.axisLeft(@yAxis))
  height:   -> @$element[0].clientHeight - @options.margins.top  - @options.margins.bottom
  width:    -> @$element[0].clientWidth  - @options.margins.left - @options.margins.right
  maxValue: ->
    val   = @xAxis?.domain().max()
    val ||= (@bars().nodes().map (rect) -> d3.select(rect).attr('raw-size')).max()
    val
