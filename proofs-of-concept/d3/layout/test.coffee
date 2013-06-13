$ = jQuery


NODE_SIZE = 64
MARGIN = 5

list_of_nodes = [
  {x: 50, y: 30},
  {x: 100, y: 500},
  {x: 120, y: 300},
  {x: 600, y: 200},
  {x: 200, y: 90},
  {x: 100, y: 90},
  {x: 500, y: 50},
  {x: 400, y: 200},
  {x: 200, y: 600},
  {x: 130, y: 400}
]

color = d3.scale.category10()

positions =
  0: "upper_left_corner"
  1: "upper_right_corner"
  2: "bottom_left_corner"
  3: "bottom_right_corner"

$(document).ready( ->
  try_this()
)

###

Functions:

###

try_this = ->

  svg = d3.select("body").append("svg")
    .attr("width", 1000)
    .attr("height", 1000)
    .attr("id", "svg")
    .append("g")

  draw_nodes(svg)

  # node =
  #   x: 10
  #   y: 20

  # node_image = svg.append("rect")
  # .attr(
  #   x: node.x
  #   y: node.y
  #   width: NODE_SIZE
  #   height: NODE_SIZE
  #   rx: 20
  #   ry: 20
  #   opacity: .5
  #   )
  # .style(
  #   fill: "forestgreen"
  #   stroke: "red"
  #   "stroke-width": 5
  #   )

  # colls = get_collisions(node, list_of_nodes)
  # console.log colls


collides_with = (node, other_node) ->

  not ((Math.abs(node.x - other_node.x) > NODE_SIZE) or
    (Math.abs(node.y - other_node.y) > NODE_SIZE))


distance_vector = (node, other_node) ->
# requires both nodes to have x and y attributes

  x = other_node.x - node.x
  y = other_node.y - node.y

  {x: x, y: y}


reverse_vector = (vector) ->

  new_x = - vector.x
  new_y = - vector.y
  {x: new_x, y: new_y}


add_vectors = (vector, other_vector) ->

  x = vector.x + other_vector.x
  y = vector.y + other_vector.y

  {x: x, y: y}


overlap_position = (node, other_node) ->

  result = null

  if (node.y > other_node.y)          # upper corner
    if (node.x > other_node.x)        # upper left
      result = 0
    else                              # upper right
      result = 1
  else                                # bottom corner
    if (node.x > other_node.x)        # bottom left
      result = 2
    else result = 3                   # bottom right

  result


overlap_vector = (node, other_node, overlap_position) ->

  x = y = null

  switch overlap_position
    when 0 then x = - (other_node.x + NODE_SIZE - node.x);  y = - (other_node.y + NODE_SIZE - node.y)
    when 1 then x = node.x + NODE_SIZE - other_node.x;      y = - (other_node.y + NODE_SIZE - node.y)
    when 2 then x = - (other_node.x + NODE_SIZE - node.x);  y = node.y + NODE_SIZE - other_node.y
    when 3 then x = node.x + NODE_SIZE - other_node.x;      y = node.y + NODE_SIZE - other_node.y

  {x: x, y: y}


move_if_collision = (curr_node_position, origin) ->

  no_collisions = false
  destination_vector = {x: 0, y: 0}
  dragged_node = curr_node_position

  while no_collisions is false

    collisions = get_collisions(curr_node_position, list_of_nodes, dragged_node)

    if collisions.length is 0
      no_collisions = true

    else if collisions.length is 1
      overlap_pos = overlap_position(curr_node_position, collisions[0])

      destination_vector = reverse_vector overlap_vector(curr_node_position, collisions[0], overlap_pos)
      destination_vector.x = if (destination_vector.x < 0) then destination_vector.x - MARGIN else destination_vector.x + MARGIN
      destination_vector.y = if (destination_vector.y < 0) then destination_vector.y - MARGIN else destination_vector.y + MARGIN

      curr_node_position = add_vectors(curr_node_position, destination_vector)

    else if collisions.length is 2
      overlap_pos_1 = overlap_position(curr_node_position, collisions[0])
      overlap_pos_2 = overlap_position(curr_node_position, collisions[1])

      overlap_vector_1 = overlap_vector(curr_node_position, collisions[0], overlap_pos_1)
      overlap_vector_2 = overlap_vector(curr_node_position, collisions[1], overlap_pos_2)

      destination_vector = reverse_vector add_vectors(overlap_vector_1, overlap_vector_2)
      destination_vector.x = if (destination_vector.x < 0) then destination_vector.x - MARGIN else destination_vector.x + MARGIN
      destination_vector.y = if (destination_vector.y < 0) then destination_vector.y - MARGIN else destination_vector.y + MARGIN

      curr_node_position = add_vectors(curr_node_position, destination_vector)

    else if collisions.length is 3
      overlap_pos_1 = overlap_position(curr_node_position, collisions[0])
      overlap_pos_2 = overlap_position(curr_node_position, collisions[1])
      overlap_pos_3 = overlap_position(curr_node_position, collisions[2])

      overlap_vector_1 = overlap_vector(curr_node_position, collisions[0], overlap_pos_1)
      overlap_vector_2 = overlap_vector(curr_node_position, collisions[1], overlap_pos_2)
      overlap_vector_3 = overlap_vector(curr_node_position, collisions[2], overlap_pos_3)

      temp_1 = add_vectors(overlap_vector_1, overlap_vector_2)
      temp_2 = add_vectors(overlap_vector_2, overlap_vector_3)

      destination_vector = reverse_vector add_vectors(temp_1, temp_2)
      destination_vector.x = if (destination_vector.x < 0) then destination_vector.x - MARGIN else destination_vector.x + MARGIN
      destination_vector.y = if (destination_vector.y < 0) then destination_vector.y - MARGIN else destination_vector.y + MARGIN

      curr_node_position = add_vectors(curr_node_position, destination_vector)

    else
      # curr_node_position = origin
      no_collisions = true

  curr_node_position


get_collisions = (curr_node, other_nodes, curr_node_copy=null) ->

  collisions = []

  for node, i in _.without(other_nodes, curr_node, curr_node_copy)
    if collides_with(curr_node, node)
      collisions.push node

  collisions


move_node = (node, node_selector, destination) ->

  node.x = destination.x
  node.y = destination.y
  d3.select(node_selector).attr(
    "transform" : "translate(" + [destination.x, destination.y] + ")"
  )


drag = d3.behavior.drag()
# .origin( ->
#   temp = d3.select(this)
#   origin = {x: temp.attr("x"), y: temp.attr("y")}
# )
.on("drag", (d, i) ->
  d.x += d3.event.dx
  d.y += d3.event.dy
  d3.select(this).attr "transform", (d, i) ->
    "translate(" + [d.x, d.y] + ")"

  # move_away = false
  # if (get_collisions(d, list_of_nodes).length is 0) or (move_away is true)
  #   d.x += d3.event.dx
  #   d.y += d3.event.dy
  #   d3.select(this).attr "transform", (d, i) ->
  #     "translate(" + [d.x, d.y] + ")"
  #   move_away = false
  # else
  #   move_away = true
  #   console.log "buuuuuh!!!!!!!"
  #   d3.select(this).attr "transform", (d, i) ->
  #     "translate(" + [d.x, d.y] + ")"
  # console.log "m", move_away
)
.on("dragend", (d, i) ->
  node_selector = "#node_#{i}"

  destination = move_if_collision(d, drag.origin())
  move_node(d, node_selector, destination)

  # console.log d, i
  # collisions = get_collisions(d, list_of_nodes)
  # console.log "--------------------"
  # console.log collisions
  # console.log "--------------------"
  # reversed_distance_vectors = []
  # for collision_node in collisions
  #   reversed_distance_vectors.push reversed_distance_vector(d, collision_node)
  # console.log reversed_distance_vectors
  # console.log "--------------------"
  # reversed_relocation_vector = reversed_distance_vectors[0]
  # for vec, i in reversed_distance_vectors when i isnt 0
  #   reversed_relocation_vector = add_vectors(reversed_relocation_vector, vec)

  # console.log reversed_relocation_vector
  # console.log "--------------------"

)


draw_nodes = (svg) ->

  node = svg.selectAll(".node")
  .data(list_of_nodes)
  .enter().append("g")
  .attr(
    class: "node"
    id: (d, i) -> "node_#{i}"
  )
  .call(drag)
  .attr("transform", (d) ->
    "translate(" + d.x + "," + d.y + ")"
  )
  node.append("rect")
  .attr(
    width: NODE_SIZE
    height: NODE_SIZE
    rx: 20
    ry: 20
  )
  .style "fill", (d, i) ->
    color i % 10
  node.append("text")
  .attr(
    "font-size": 80
    )
  .attr("transform", (d) ->
    "translate(" + d.x-NODE_SIZE + "," + d.y-NODE_SIZE + ")"
  )
  .text((d, i) -> i)






