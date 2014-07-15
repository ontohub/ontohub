return unless $("div#d3_graph")[0]



width = $('div#d3_graph').width()
height = 350
$('div#d3_context').height(height)
distance = 60
force_charge = -400
colors = d3.scale.category10()
edge_type = null # May be LogicMapping or Link
mode = "normal"

graphs_uri = window.location.href
re = /\?[^/]+$/
if graphs_uri.search(re) != -1
  graphs_uri = graphs_uri.replace(re, "/graphs$&")
else
  graphs_uri += "/graphs" if graphs_uri.search(/\/graphs/) == -1

$('div#graph_depth_setting ul li a').on 'click', (e) ->
  e.preventDefault()
  depth = parseInt($(this).html())

  $('div#graph_depth_setting > a').html(depth)
    .append($('<span />', class: 'caret'))

  $.get("#{graphs_uri}?depth=#{depth}", (data) ->
      displayGraph(data)
    , "json")

randomNumber = (min, max) ->
  return Math.random() * (max - min) + min

addClass = (selector, klass) ->
  el = $(selector)
  el.attr('class', el.attr('class') + " #{klass}")

removeClass = (selector, klass) ->
  func = (index, attr) ->
    if attr
      attr.replace("#{klass}", '')
    else
      ''
  el = $(selector)
  el.attr('class', func)

resetSelections = ->
  removeClass('g.node', 'selected')
  removeClass('path', 'selected')

jQuery ->
  $("div#d3_graph").html(HandlebarsTemplates['graphs/loading']({}))
  $.get(graphs_uri, (data) ->
      displayGraph(data)
    , "json")

d3NodesEdges = (data) ->
  nodes = []
  links = {}
  center = data.center
  for node in data.nodes
    nodes.push
      info: node
      is_center: (node.id == center.id)
      aggregates: data.nodes_aggregate["#{node.id}"]
    links[node.id] = nodes.length - 1
  edges = _.map data.edges, (edge) ->
    source: links[edge.source_id]
    target: links[edge.target_id]
    info: edge
  [nodes,edges,data.node_url,data.edge_url]

nodeDisplayName = (node) ->
  name = node.info.name
  matches = name.match(/^[^.]+\.?/)
  if matches.length
    matches[0]
  else
    name


displayGraph = (data) ->
  edge_type = data.edge_type
  nodes_edges = d3NodesEdges(data)
  nodes = nodes_edges[0]
  edges = nodes_edges[1]
  node_url = nodes_edges[2]
  edge_url = nodes_edges[3]

  addClass($('a#all'), 'btn-primary')

  edgesForMode = (the_mode) ->
    if the_mode == "normal"
      edges
    else if the_mode == "import"
      import_edges = _.filter edges, (edge) ->
        edge.info.kind == "import"
      import_edges

  drawGraph = (nodes, edges) ->
    $("div#d3_graph").html("")
    svg = d3.select("div#d3_graph").
      append('svg').
      attr('width', width).
      attr('height', height)

    force = d3.layout.force()
    force.nodes(nodes)
    force.links(edges)
    force.size([width, height])
      .gravity(0.05)
      .linkDistance(distance)
      .charge(force_charge)
    force.start()

    # Arrows
    for klass in ["non_theorem", "proven", "unproven"]
      svg.append("svg:defs").selectAll("marker")
        .data([klass])
        .enter().append("svg:marker")
          .attr("id", String)
          .attr("viewBox", "0 -5 10 10")
          .attr("refX", 14.5)
          .attr("refY", -0.0)
          .attr("markerWidth", 6)
          .attr("markerHeight", 6)
          .attr("orient", "auto")
        .append("svg:path")
          .attr("d", "M0,-6L10,0L0,6")
    path = svg.append("svg:g").selectAll("path").
      data(force.links()).
      enter().
      append("svg:path").
      attr("class", (d) ->
        proveable = !! d.info.theorem
        proven = !! d.info.proven
        if proveable
          return "link proven" if proven
          "link unproven"
        else
          "link").
      attr("marker-end", (d) ->
        proveable = !! d.info.theorem
        proven = !! d.info.proven
        if proveable
          return "url(#proven)" if proven
          "url(#unproven)"
        else
          "url(#non_theorem)")

    node = svg.selectAll(".node")
      .data(force.nodes())
      .enter().append("g")
      .attr("class", "node")
      .attr("data-label", (d) ->
        d.label)

    embedNodeInfo = (node) ->
      info_list = $('<ul />',
        id: 'node_info')
      template = null
      payload =
        node_url: node_url
        node: node
        url: "#{node_url}/#{node.info.id}/"
      if edge_type == 'LogicMapping'
        template = 'graphs/logic_mappings_node'
      else if edge_type == 'Link'
        template = 'graphs/links_node'
      info_list.html(HandlebarsTemplates[template](payload)) if template
      $("div#d3_context").html(info_list)

    embedEdgeInfo = (edge) ->
      info_list = $('<ul />',
        id: 'edge_info')
      template = null
      payload =
        edge_url: edge_url
        edge: edge
      if edge_type == "LogicMapping"
        template = 'graphs/logic_mappings_edge'
      else if edge_type == "Link"
        template = 'graphs/links_edge'
      info_list.html(HandlebarsTemplates[template](payload)) if template
      $("div#d3_context").html(info_list)

    $("g.node").on "click", (e) ->
      e.preventDefault()
      resetSelections()
      default_classes = "node"
      classes = "#{default_classes} selected"
      node_data = d3.select(this).data()[0]
      # use attr, because jquery-class doesn't work
      if window.selected_node != this
        $(window.selected_node).attr('class', default_classes)
      window.selected_node = this
      $(this).attr('class', classes)
      embedNodeInfo(node_data)

    $("g > path").on "click", (e) ->
      e.preventDefault()
      resetSelections()
      path_data = d3.select(this).data()[0]
      addClass($(this), 'selected')
      embedEdgeInfo(path_data)

    $('path').on('mouseenter', (e) ->
      removeClass('g.node', 'highlight')
      path_data = d3.select(this).data()[0]
      source_index = path_data.source.index
      target_index = path_data.target.index
      addClass($(node[0][source_index]), 'highlight')
      addClass($(node[0][target_index]), 'highlight')
    )
    $('path').on('mouseleave', (e) ->
      removeClass('g.node', 'highlight'))

    node.append("circle").
      attr("r", (d) ->
        return 10 if d.is_center
        7)

    node.append("text").
      attr("x", 12).
      attr("dy", ".35em").
      text((d) ->
        nodeDisplayName(d))

    calc_offsets = (d) ->
      d.arc_offset_a = randomNumber(55, 15) if d.arc_offset_a == undefined
      d.arc_offset_b = randomNumber(20, 10) if d.arc_offset_b == undefined
      if d.pos_offset_a == undefined
        rand = Math.floor(randomNumber(1,100))
        d.pos_offset_a = 1
        d.pos_offset_a = 0 if (rand % 2) == 0
      if d.pos_offset_b == undefined
        rand = Math.floor(randomNumber(1,100))
        d.pos_offset_b = 0
        d.pos_offset_b = 1 if (rand % 2) == 0

    tick = ->
      node.attr("transform", (d) ->
        if d.is_center
          d.x = width/2
          d.y = height/2
        "translate(#{d.x},#{d.y})")
      path.attr("d", (d) ->
        dx = d.target.x - d.source.x
        dy = d.target.y - d.source.y
        dr = Math.sqrt(dx*dx + dy*dy)*2
        calc_offsets(d)
        if d.source.info.id != d.target.info.id
          "M#{d.source.x},#{d.source.y}" +
          "A#{dr},#{dr} 0 0,1 #{d.target.x},#{d.target.y}"
        else
          "M#{d.source.x},#{d.source.y-0.6}" +
          "A-#{d.arc_offset_a},-#{d.arc_offset_b} 0 " +
          "#{d.pos_offset_a},#{d.pos_offset_b} #{d.target.x-4},#{d.target.y}"
      )
    force.on('tick', tick)

  drawGraph(nodes, edgesForMode(mode))

  actOnModeButton = (the_mode, button) ->
    removeClass('a.mode', 'btn-primary')
    mode = the_mode
    addClass($(button), 'btn-primary')
    drawGraph(nodes, edgesForMode(mode))


  $('a#import').on('click', (e) ->
    e.preventDefault()
    actOnModeButton("import", $(this)))

  $('a#all').on('click', (e) ->
    e.preventDefault()
    actOnModeButton("normal", $(this)))
