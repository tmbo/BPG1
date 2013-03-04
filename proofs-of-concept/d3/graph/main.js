// Generated by CoffeeScript 1.4.0
(function() {
  var Graph, HEIGHT, WIDTH, colors,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WIDTH = 960;

  HEIGHT = 500;

  colors = d3.scale.category10();

  Graph = (function() {

    function Graph(selector) {
      this.keyup = __bind(this.keyup, this);

      this.keydown = __bind(this.keydown, this);

      this.mouseup = __bind(this.mouseup, this);

      this.mousemove = __bind(this.mousemove, this);

      this.mousedown = __bind(this.mousedown, this);
      this.svg = d3.select(selector).append("svg").attr("WIDTH", WIDTH).attr("HEIGHT", HEIGHT);
      this.svg.on("mousedown", this.mousedown).on("mousemove", this.mousemove).on("mouseup", this.mouseup);
      d3.select(window).on("keydown", this.keydown).on("keyup", this.keyup);
      this.nodes = [
        {
          id: 0,
          reflexive: false
        }, {
          id: 1,
          reflexive: true
        }, {
          id: 2,
          reflexive: false
        }
      ];
      this.links = [
        {
          source: this.nodes[0],
          target: this.nodes[1],
          left: false,
          right: true
        }, {
          source: this.nodes[1],
          target: this.nodes[2],
          left: false,
          right: true
        }
      ];
      this.lastNodeId = 2;
      this.init();
      this.restart();
    }

    Graph.prototype.init = function() {
      var _this = this;
      this.force = d3.layout.force().nodes(this.nodes).links(this.links).size([WIDTH, HEIGHT]).linkDistance(150).charge(-500).on("tick", (function() {
        return _this.tick();
      }));
      this.drag_line = this.svg.append("svg:path").attr("class", "link dragline hidden").attr("d", "M0,0L0,0");
      this.path = this.svg.append("svg:g").selectAll("path");
      this.circle = this.svg.append("svg:g").selectAll("g");
      this.selected_node = null;
      this.selected_link = null;
      this.mousedown_link = null;
      this.mousedown_node = null;
      this.mouseup_node = null;
      return this.initArrowMarkers();
    };

    Graph.prototype.initArrowMarkers = function() {
      this.svg.append("svg:defs").append("svg:marker").attr("id", "end-arrow").attr("viewBox", "0 -5 10 10").attr("refX", 6).attr("markerWidth", 3).attr("markerHeight", 3).attr("orient", "auto").append("svg:path").attr("d", "M0,-5L10,0L0,5").attr("fill", "#000");
      return this.svg.append("svg:defs").append("svg:marker").attr("id", "start-arrow").attr("viewBox", "0 -5 10 10").attr("refX", 4).attr("markerWidth", 3).attr("markerHeight", 3).attr("orient", "auto").append("svg:path").attr("d", "M10,-5L0,0L10,5").attr("fill", "#000");
    };

    Graph.prototype.resetMouseVars = function() {
      this.mousedown_node = null;
      this.mouseup_node = null;
      return this.mousedown_link = null;
    };

    Graph.prototype.tick = function() {
      this.path.attr("d", function(d) {
        var deltaX, deltaY, dist, normX, normY, sourcePadding, sourceX, sourceY, targetPadding, targetX, targetY, _ref, _ref1;
        deltaX = d.target.x - d.source.x;
        deltaY = d.target.y - d.source.y;
        dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
        normX = deltaX / dist;
        normY = deltaY / dist;
        sourcePadding = (_ref = d.left) != null ? _ref : {
          17: 12
        };
        targetPadding = (_ref1 = d.right) != null ? _ref1 : {
          17: 12
        };
        sourceX = d.source.x + (sourcePadding * normX);
        sourceY = d.source.y + (sourcePadding * normY);
        targetX = d.target.x - (targetPadding * normX);
        targetY = d.target.y - (targetPadding * normY);
        return "M " + sourceX + "," + sourceY + "L" + targetX + "," + targetY;
      });
      return this.circle.attr("transform", function(d) {
        return "translate(" + d.x + "," + d.y + ")";
      });
    };

    Graph.prototype.restart = function() {
      var g, mousedown_link, mousedown_node, mouseup_node, selected_link, selected_node,
        _this = this;
      mousedown_node = this.mousedown_node, mousedown_link = this.mousedown_link, mouseup_node = this.mouseup_node, selected_node = this.selected_node, selected_link = this.selected_link;
      this.path = this.path.data(this.links);
      this.path.classed("selected", function(d) {
        return d === selected_link;
      }).style("marker-start", function(d) {
        var _ref;
        return (_ref = d.left) != null ? _ref : {
          "url(#start-arrow)": ""
        };
      }).style("marker-end", function(d) {
        var _ref;
        return (_ref = d.right) != null ? _ref : {
          "url(#end-arrow)": ""
        };
      });
      this.path.enter().append("svg:path").attr("class", "link").classed("selected", function(d) {
        return d === selected_link;
      }).style("marker-start", function(d) {
        var _ref;
        return (_ref = d.left) != null ? _ref : {
          "url(#start-arrow)": ""
        };
      }).style("marker-end", function(d) {
        var _ref;
        return (_ref = d.right) != null ? _ref : {
          "url(#end-arrow)": ""
        };
      }).on("mousedown", function(d) {
        if (d3.event.ctrlKey) {
          return;
        }
        mousedown_link = d;
        if (mousedown_link === selected_link) {
          _this.selected_link = null;
        } else {
          _this.selected_link === mousedown_link;
        }
        _this.selected_node = null;
        return restart();
      });
      this.path.exit().remove();
      this.circle = this.circle.data(this.nodes, function(d) {
        return d.id;
      });
      this.circle.selectAll("circle").style("fill", function(d) {
        if (d === selected_node) {
          return d3.rgb(colors(d.id)).brighter().toString();
        } else {
          return colors(d.id);
        }
      }).classed("reflexive", function(d) {
        return d.reflexive;
      });
      g = this.circle.enter().append("svg:g");
      g.append("svg:circle").attr("class", "node").attr("r", 12).style("fill", function(d) {
        if (d === selected_node) {
          return d3.rgb(colors(d.id)).brighter().toString();
        } else {
          return colors(d.id);
        }
      }).style("stroke", function(d) {
        return d3.rgb(colors(d.id)).darker().toString();
      }).classed("reflexive", function(d) {
        return d.reflexive;
      }).on("mouseover", function(d) {
        if (!mousedown_node || d === mousedown_node) {
          return;
        }
        return d3.select(this).attr("transform", "scale(1.1)");
      }).on("mouseout", function(d) {
        if (!mousedown_node || d === mousedown_node) {
          return;
        }
        return d3.select(this).attr("transform", "");
      }).on("mousedown", function(d) {
        if (d3.event.ctrlKey) {
          return;
        }
        mousedown_node = d;
        if (mousedown_node === selected_node) {
          _this.selected_node = null;
        } else {
          _this.selected_node = mousedown_node;
        }
        _this.selected_link = null;
        _this.mousedown_node = mousedown_node;
        _this.drag_line.style("marker-end", "url(#end-arrow)").classed("hidden", false).attr("d", "M" + mousedown_node.x + "," + mousedown_node.y + "L" + mousedown_node.x + "," + mousedown_node.y);
        return _this.restart();
      }).on("mouseup", function(d) {
        var direction, link, source, target, __this;
        if (!mousedown_node) {
          return;
        }
        _this.drag_line.classed("hidden", true).style("marker-end", "");
        mouseup_node = d;
        if (mouseup_node === mousedown_node) {
          _this.resetMouseVars();
          return;
        }
        __this = _this.svg[0][0];
        d3.select(__this).attr("transform", "");
        if (mousedown_node.id < mouseup_node.id) {
          source = mousedown_node;
          target = mouseup_node;
          direction = "right";
        } else {
          source = mouseup_node;
          target = mousedown_node;
          direction = "left";
        }
        link = _this.links.filter(function(l) {
          return l.source === source && l.target === target;
        })[0];
        if (link) {
          link[direction] = true;
        } else {
          link = {
            source: source,
            target: target,
            left: false,
            right: false
          };
          link[direction] = true;
          _this.links.push(link);
        }
        _this.selected_link = link;
        _this.selected_node = null;
        return _this.restart();
      });
      g.append("svg:text").attr("x", 0).attr("y", 4).attr("class", "id").text(function(d) {
        return d.id;
      });
      this.circle.exit().remove();
      return this.force.start();
    };

    Graph.prototype.mousedown = function() {
      var node, point, __this;
      this.svg.classed("active", true);
      if (d3.event.ctrlKey || this.mousedown_node || this.mousedown_link) {
        return;
      }
      __this = this.svg[0][0];
      point = d3.mouse(__this);
      node = {
        id: ++this.lastNodeId,
        reflexive: false
      };
      node.x = point[0];
      node.y = point[1];
      this.nodes.push(node);
      return this.restart();
    };

    Graph.prototype.mousemove = function() {
      var __this;
      if (!this.mousedown_node) {
        return;
      }
      __this = this.svg[0][0];
      this.drag_line.attr("d", "M" + this.mousedown_node.x + "," + this.mousedown_node.y + "L" + (d3.mouse(__this)[0]) + "," + (d3.mouse(__this)[1]));
      return this.restart();
    };

    Graph.prototype.mouseup = function() {
      if (this.mousedown_node) {
        this.drag_line.classed("hidden", true).style("marker-end", "");
      }
      this.svg.classed("active", false);
      return this.resetMouseVars();
    };

    Graph.prototype.spliceLinksForNode = function(node) {
      var toSplice;
      toSplice = links.filter(function(l) {
        return l.source === node || l.target === node;
      });
      return toSplice.map(function(l) {
        return links.splice(links.indexOf(l), 1);
      });
    };

    Graph.prototype.keydown = function() {
      var selected_link, selected_node;
      selected_node = this.selected_node, selected_link = this.selected_link;
      if (d3.event.keyCode === 17) {
        circle.call(force.drag);
        this.svg.classed("ctrl", true);
      }
      if (!(selected_node && selected_link)) {
        return;
      }
      switch (d3.event.keyCode) {
        case 46:
          if (selected_node) {
            nodes.splice(nodes.indexOf(selected_node), 1);
            spliceLinksForNode(selected_node);
          } else if (selected_link) {
            links.splice(links.indexOf(selected_link), 1);
          }
          this.selected_link = null;
          this.selected_node = null;
          return this.restart();
        case 66:
          if (selected_link) {
            selected_link.left = true;
            selected_link.right = true;
          }
          return this.restart();
      }
    };

    Graph.prototype.keyup = function() {
      if (d3.event.keyCode === 17) {
        circle.on("mousedown.drag", null).on("touchstart.drag", null);
        return this.svg.classed("ctrl", false);
      }
    };

    return Graph;

  })();

  new Graph("body");

}).call(this);
