return unless $("div#d3_graph")[0]

width = 500
height = 350
distance = 60
force_charge = -400
colors = d3.scale.category10()

$.get("#{window.location.href}/graphs", (data) ->
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
    edges.push(
      source: links[edge.source_id]
      target: links[edge.target_id])
  [nodes,edges]


drawGraph = (data) ->
  nodes_edges = d3NodesEdges(data)
  nodes = nodes_edges[0]
  edges = nodes_edges[1]

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

  $("g.node").on "click", (e) ->
    e.preventDefault()
    if window.selected_node != this
      $(window.selected_node).find("circle").css("stroke", '')
      $(window.selected_node).find("circle").css("fill", '')
    window.selected_node = this
    $(this).find("circle").css("stroke", "#f00")
    $(this).find("circle").css("fill", "#f00")
    $("div#d3_context").html("Node: <b>#{$(this).data('label')}</b>")

  node.append("circle").
    attr("r", (d) ->
      return 10 if d.is_center
      7)

  node.append("text").
    attr("x", 12).
    attr("dy", ".35em").
    text((d) ->
      return d.info.name )

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
