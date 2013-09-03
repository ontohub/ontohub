return unless $("div#d3_graph")[0]

width = 500
height = 350
distance = 60
force_charge = -400
colors = d3.scale.category10()

graphs_uri = window.location.href
re = /\?[^/]+$/
if graphs_uri.search(re) != -1
  graphs_uri = graphs_uri.replace(re, "/graphs$&")
else
  graphs_uri += "/graphs"

$.get(graphs_uri, (data) ->
    drawGraph(data)
  , "json")

$('div#graph_depth_setting ul li a').on 'click', (e) ->
  e.preventDefault()
  depth = parseInt($(this).html())

  $('div#graph_depth_setting > a').html(depth)
    .append($('<span />', class: 'caret'))

  $.get("#{graphs_uri}?depth=#{depth}", (data) ->
      drawGraph(data)
    , "json")

d3NodesEdges = (data) ->
  nodes = []
  links = {}
  center = data.center
  for node in data.nodes
    nodes.push
      info: node
      is_center: (node.id == center.id)
    links[node.id] = nodes.length - 1
  edges = []
  for edge in data.edges
    edges.push
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


drawGraph = (data) ->
  nodes_edges = d3NodesEdges(data)
  nodes = nodes_edges[0]
  edges = nodes_edges[1]
  node_url = nodes_edges[2]
  edge_url = nodes_edges[3]

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
  svg.append("svg:defs").selectAll("marker")
    .data(["end"])
    .enter().append("svg:marker")
      .attr("id", String)
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 17)
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
    attr("class", "link").
    attr("marker-end", "url(#end)")

  node = svg.selectAll(".node")
    .data(force.nodes())
    .enter().append("g")
    .attr("class", "node")
    .attr("data-label", (d) ->
      d.label)

  embedNodeInfo = (node) ->
    info_list = $('<ul />',
      id: 'node_info')
    addItem = (name, content) ->
      info_list.append($('<li />')
        .append($('<span />').html(name))
        .append($('<span />').html(content)))
    addItem("Node: ", $('<a />',
      href: node_url + "/" + node.info.id)
        .html(node.info.name))
    addItem("IRI: ", $('<a />',
      href: node.info.iri)
        .html(node.info.iri))
    addItem("Description: ", $('<p />')
      .html(node.info.description))
    addItem("Number of Ontologies: ", $('<span />')
      .html(node.info.ontologies_count))
    $("div#d3_context").html(info_list)

  embedEdgeInfo = (edge) ->
    info_list = $('<ul />',
      id: 'edge_info')
    addItem = (name, content) ->
      info_list.append($('<li />')
        .append($('<span />').html(name))
        .append($('<span />').html(content)))
    addItem("Mapping: ", $('<a />',
      href: edge_url + "/" + edge.info.id)
        .html(edge.source.info.name+
          " --> "+
          edge.target.info.name))
    addItem("exactness: ", $('<span />')
        .html(edge.info.exactness))
    addItem("faithfulness: ", $('<span />')
        .html(edge.info.faithfulness))
    $("div#d3_context").html(info_list)

  $("g.node").on "click", (e) ->
    e.preventDefault()
    node_data = d3.select(this).data()[0]
    if window.selected_node != this
      $(window.selected_node).find("circle").css("stroke", '')
      $(window.selected_node).find("circle").css("fill", '')
    window.selected_node = this
    $(this).find("circle").css("stroke", "#f00")
    $(this).find("circle").css("fill", "#f00")
    embedNodeInfo(node_data)

  $("g > path").on "click", (e) ->
    e.preventDefault()
    path_data = d3.select(this).data()[0]
    embedEdgeInfo(path_data)

  node.append("circle").
    attr("r", (d) ->
      return 10 if d.is_center
      7)

  node.append("text").
    attr("x", 12).
    attr("dy", ".35em").
    text((d) ->
      nodeDisplayName(d))

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
      "M#{d.source.x},#{d.source.y}" +
      "A#{dr},#{dr} 0 0,1 #{d.target.x},#{d.target.y}")
  force.on('tick', tick)
