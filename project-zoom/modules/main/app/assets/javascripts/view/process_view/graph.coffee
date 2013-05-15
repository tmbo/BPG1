### define
jquery : $
d3 : d3
./node : Node
./edge : Edge
./cluster : Cluster
###

class Graph

  constructor : (@container) ->

    @nodes = []
    @edges = []
    @clusters = []

    @clusterPaths = @container.append("svg:g").selectAll("path")
    @paths = @container.append("svg:g").selectAll("path")
    @foreignObjects = @container.append("svg:g").selectAll("foreignObject")

    @colors = d3.scale.category10()

    @nodeId = 0


  addNode : (x, y, nodeId, artifact) =>

    id = nodeId ? @nodeId++

    node = new Node(
      x,
      y,
      id,
      artifact
    )

    @nodes.push node

    #was the node dropped in a cluster?
    for cluster in @clusters
      cluster.checkForNodes([node])

    @drawNodes()


  addEdge : (source, target) =>

    maxNode = @nodes[@nodes.length - 1]
    if source <= maxNode.id and target <= maxNode.id

      for node in @nodes
        sourceNode = node if node.id == source
        targetNode = node if node.id == target


      tmp = new Edge(sourceNode, targetNode)
      @edges.push(tmp)

      @drawEdges()


  addCluster : (cluster) =>

    cluster.checkForNodes(@nodes)
    @clusters.push( cluster )
    @drawClusters()


  removeNode : (node) ->

    index = @nodes.indexOf(node)
    if index > -1

      @nodes.splice(index, 1)

      #remove all edges connected to the node
      # for edge,i in @edges
      #   if edge.source == node or edge.target == node
      #     @edges.splice(i,1)

      @drawNodes()
      @drawEdges()


  removeEdge : (edge) ->

    index = @edges.indexOf(edge)
    if index > -1

      @edges.splice(index, 1)
      @drawEdges()


  drawNodes : ->

    HTML = ""
    @foreignObjects = @foreignObjects.data(@nodes, (d) -> d.id)

    #add new nodes or update existing one
    foreignObject = @foreignObjects.enter()
      .append("svg:g")
        .attr( class : "node" )
      .append("svg:foreignObject")
        .attr(

          width : 68
          height : 68

          x : (d) -> d.x - d.getSize() / 2
          y : (d) -> d.y - d.getSize() / 2

          workaround : (d, i) ->

            if d.artifact?
              html = d.artifact.domElement
            else
              html = """<html xmlns="http://www.w3.org/1999/xhtml"><body><div class="nodeElement" style="background-color: rgb(0,127,255)"><img class="nodeElement" draggable="false" data-id="#{d.id}"></img></body></html>""" #return HTML element

            $(this).append(html)
            return ""
        )

    #remove deleted nodes
    @foreignObjects.exit().remove()


  drawEdges : ->

    @paths = @paths.data(@edges)

    #add new edges or update existing ones
    path = @paths.enter().append("svg:path")
    path
      .attr(
        class : "edge"
        d : (data) -> data.getLineSegment()
      )
      .style("marker-end", (d) -> "url(#end-arrow)")

    #remove deleted edges
    @paths.exit().remove()


  drawClusters : ->

    @clusterPaths = @clusterPaths.data(@clusters)

    #add new edges or update existing ones
    clusterPath = @clusterPaths.enter().append("svg:path")
    clusterPath
      .attr(
        class : "cluster"
        d : (data) -> data.getLineSegment()
      )

    #remove deleted edges
    @clusterPaths.exit().remove()





