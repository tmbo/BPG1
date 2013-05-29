###
define
###

NODE_SIZE = 64
HALF_SIZE = 32

Node = (node) ->

  cluster = null
  comment = null

  getCenter : ->

    centerPosition =
      x : node.get("x") + HALF_SIZE
      y : node.get("y") + HALF_SIZE


  getSize : ->

    width : NODE_SIZE
    height : NODE_SIZE


  getCommentPosition : ->

    position =
      x: node.get("x")
      y: node.get("y")

