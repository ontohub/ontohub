return unless $("div#d3_graph")[0]



width = $('div#d3_graph').width()
height = 350
$('div#d3_context').height(height)
distance = 60
force_charge = -400
colors = d3.scale.category10()
edge_type = null # May be LogicMapping or Link
mode = "normal"
sentence_klasses = ["non_theorem", "proven", "unproven"]

graphs_uri = window.location.href
  .replace(/\/graphs(\?[^/]+|\/)?$/, '/graphs')

d3.selectAll('div#graph_depth_setting ul li a').on 'click', (e) ->
  d3.event.preventDefault()
  depth = parseInt(d3.select(this).html())

  d3.select('div#graph_depth_setting > a').html(depth)
    .append('span').attr('class', 'caret')

  $.get("#{graphs_uri}?depth=#{depth}", displayGraph, "json")

randomNumber = (min, max) ->
  Math.random() * (max - min) + min

resetSelections = ->
  d3.selectAll('g.node').classed('selected', false)
  d3.selectAll('path').classed('selected', false)

templateName = (edge_type, template_type) ->
  if edge_type == 'LogicMapping'
    "graphs/logic_mappings_#{template_type}"
  else if edge_type == 'Link'
    "graphs/links_#{template_type}"

addSVGMarker = (svg_element, payload) ->
  svg_element.append("svg:defs").selectAll("marker")
    .data(payload)
    .enter()
    .append("svg:marker")
      .attr("id", String)
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 14.5)
      .attr("refY", -0.0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
    .append("svg:path")
      .attr("d", "M0,-6L10,0L0,6")

jQuery ->
  d3.select("div#d3_graph").html(HandlebarsTemplates['graphs/loading']({}))
  $.get(graphs_uri, displayGraph, "json")

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

  d3.select('a#all').classed('btn-primary', true)

  edgesForMode = (the_mode) ->
    if the_mode == "normal"
      edges
    else if the_mode == "import"
      import_edges = _.filter edges, (edge) ->
        edge.info.kind == "import"
      import_edges

  drawGraph = (nodes, edges) ->
    zoom = ->
      svg_group.attr("transform",
        "translate(#{d3.event.translate}), scale(#{d3.event.scale})")
    zoom_listener = d3.behavior.zoom().
      scaleExtent([0.1, 3]).on("zoom", zoom)

    d3.select("div#d3_graph").html("")
    svg = d3.select("div#d3_graph")
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .call(zoom_listener)
    svg_group = svg.append('g')
      .attr('class', 'graph')

    force = d3.layout.force()
    force.nodes(nodes)
    force.links(edges)
    force.size([width, height])
      .gravity(0.05)
      .linkDistance(distance)
      .charge(force_charge)
    force.start()

    # Arrows
    addSVGMarker svg_group, [klass] for klass in sentence_klasses

    path = svg_group.append("svg:g").selectAll("path")
      .data(force.links())
      .enter()
      .append("svg:path")
    path.attr "class", (d) ->
        proven = "link proven" if !! d.info.proven
        unproven = "link unproven"
        not_proveable = "link" unless !! d.info.theorem
        not_proveable || proven || unproven
    path.attr "marker-end", (d) ->
        proven = "url(#proven)" if !! d.info.proven
        unproven = "url(#unproven)"
        not_proveable = "url(#non_theorem)" unless !! d.info.proven
        not_proveable || proven || unproven

    node = svg_group.selectAll(".node")
      .data(force.nodes())
      .enter().append("g")
      .attr("class", "node")
      .attr("data-label", (d) -> d.label)

    embedNodeInfo = (node) ->
      payload =
        node_url: node_url
        node: node
        url: "#{node_url}/#{node.info.id}/"
      template = templateName(edge_type, 'node')
      if template
        d3.select("div#d3_context").html('')
          .append('ul').attr('id', 'node_info')
          .html(HandlebarsTemplates[template](payload))

    embedEdgeInfo = (edge) ->
      payload =
        edge_url: edge_url
        edge: edge
      template = templateName(edge_type, 'edge')
      if template
        d3.select("div#d3_context").html('')
          .append('ul').attr('id', 'edge_info')
          .html(HandlebarsTemplates[template](payload))

    d3.selectAll("g.node").on "click", (node_data) ->
      d3.event.preventDefault()
      resetSelections()
      default_classes = "node"
      classes = "#{default_classes} selected"
      # use attr, because jquery-class doesn't work
      if window.selected_node != this
        $(window.selected_node).attr('class', default_classes)
      window.selected_node = this
      d3.select(this).attr('class', classes)
      embedNodeInfo(node_data)

    d3.selectAll("g > path").on "click", (path_data) ->
      d3.event.preventDefault()
      resetSelections()
      d3.select(this).classed('selected', true)
      embedEdgeInfo(path_data)

    d3.select('path').on('mouseenter', (e) ->
      d3.selectAll('g.node').classed('highlight', false)
      path_data = d3.select(this).data()[0]
      source_index = path_data.source.index
      target_index = path_data.target.index
      d3.select(node[0][source_index]).classed('highlight', true)
      d3.select(node[0][target_index]).classed('highlight', true)
    )
    d3.select('path').on('mouseleave', (e) -> d3.selectAll('g.node').classed('highlight', false))

    node.append("circle").
      attr("r", (d) -> if d.is_center then 10 else 7)

    node.append("text").
      attr("x", 12).
      attr("dy", ".35em").
      text(nodeDisplayName)

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
      node.attr "transform", (d) ->
        if d.is_center
          d.x = width/2
          d.y = height/2
        "translate(#{d.x},#{d.y})"
      path.attr "d", (d) ->
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

    force.on('tick', tick)

  drawGraph(nodes, edgesForMode(mode))

  actOnModeButton = (the_mode, button) ->
    d3.select('a.mode').classed('btn-primary', true)
    mode = the_mode
    d3.select(button).classed('btn-primary', true)
    drawGraph(nodes, edgesForMode(mode))


  d3.select('a#import').on('click', (e) ->
    d3.event.preventDefault()
    actOnModeButton("import", this))

  d3.select('a#all').on('click', (e) ->
    d3.event.preventDefault()
    actOnModeButton("normal", this))
