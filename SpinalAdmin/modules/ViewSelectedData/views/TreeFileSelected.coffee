
_Tree = {}
class TreeFileSelected extends Process
    constructor: ( model ) ->
        super(model)
        @model = model
        @el = document.getElementById("file-content")
        _Tree = this
        @depthLength = []
        @_id = 0
        @data = {}
        new SeachModelTree( this, document.getElementById("search_tree_input"),
            document.getElementById("search_tree_res"),
            document.getElementById("search_tree_prev"),
            document.getElementById("search_tree_next"),
            @search_by_name)

        @makeTree()

    onchange: () =>
        if @model.has_been_modified()
            root_id = @root.server_id
            @visit @root, ((d) ->
                d.used = false
                return
            ), (d) ->
                if d.children and d.children.length > 0
                    return d.children
                else if d._children and d._children.length > 0
                    return d._children
                else
                    return null
            @root.used = true
            @toJson this, @root, @model
            @delete_not_used @root
            @visit @root, ((d) ->
              _Tree.maxLabelLength = Math.max(d.name.length, _Tree.maxLabelLength)
              return
            ), (d) ->
              if d.children and d.children.length > 0 then d.children else null
            @update(@root)
            if root_id != @root.server_id
                @newCenterNode(@root)

    search_by_name: (search_handler, data) ->
        search_res = []
        re = new RegExp ".*#{data}", 'i'
        _Tree.visit _Tree.root, ((d) ->
            if d.name.search(re) != -1
                search_res.push d
            return
        ), (d) ->
            if d.children and d.children.length > 0
                return d.children
            else
                return null
        search_handler.set_result search_res

    update_ptr: (ptr, mod) ->
        _Tree.visit ptr, ((d) ->
            d.used = false
            return
        ), (d) ->
            if d.children and d.children.length > 0
                return d.children
            else if d._children and d._children.length > 0
                return d._children
            else
                return null
        ptr.used = true
        children = ptr.children if ptr.children
        children = ptr._children if ptr._children
        if children not instanceof Array
            ptr.children = []
            children = ptr.children
        child = _Tree.search_child children, mod._server_id
        if child
            _Tree.toJson _Tree, child, mod
        else
            children.push({ name: "" })
            _Tree.toJson _Tree, children[children.length - 1], mod
        _Tree.delete_not_used ptr
        _Tree.update ptr
        _Tree.newCenterNode ptr


    delete_not_used: (source) ->
        _Tree.visit source, ((d) ->
            if d.used == false
                _Tree.remove_node d.parent, d
            return
        ), (d) ->
            if d.children and d.children.length > 0
                return d.children
            if d._children and d._children.length > 0
                return d._children
            else return null

    makeTree: () =>
        @viewerWidth = @el.offsetWidth
        @viewerHeight = 600
        @duration = 750
        @i = 0
        @tree = d3.layout.tree().size([@viewerHeight, @viewerWidth])
        @diagonal = d3.svg.diagonal().projection((d) ->
            return [d.y, d.x]
            )
        @zoomListener = d3.behavior.zoom().scaleExtent([0.1, 3]).on("zoom", @zoom)
        d3.select('svg').remove()
        d3.select("#tree_zoom_root").on "click", (d, i) ->
            _Tree.newCenterNode(_Tree.root)
        d3.select("#tree_center_root").on "click", (d, i) ->
            _Tree.centerNode(_Tree.root)
        baseSvg = d3.select(@el).append("svg")
            .attr("preserveAspectRatio", "xMinYMin meet")
            .attr("viewBox", "0 0 #{@viewerWidth} #{@viewerHeight}")
            .classed("svg-content", true)
            .call(@zoomListener)
        @svgGroup = baseSvg.append("g")
        @root = {
            name: ""
            server_id: -1
            _id: -1
            x0: 0
            y0: 0
        }

        @maxLabelLength = 1
        @update(@root)

    remove_node: (p, c) ->
        if !p
          return
        if p.children
          i = p.children.length - 1
          while i >= 0
            if p.children[i] == c
              p.children.splice i, 1
            i--
        if p._children
          i = p._children.length - 1
          while i >= 0
            if p._children[i] == c
              p._children.splice i, 1
            i--


    newCenterNode: (source) =>
        depth = 0
        @visit source, ((d) ->
          depth = Math.max(d.depth, depth)
          return
        ), (d) ->
          if d.children and d.children.length > 0 then d.children else null
        scale = 1
        x = 0
        depth -= source.depth
        y = -source.x0
        while x < 60
            x = -@root.y0
            x = x * scale + @viewerWidth / 2
            x = x - @calc_dist_depth(depth, 6) / 2 * scale
            scale -= 0.01 if x < 60
        x -= @calc_dist_depth(source.depth, 6) * scale
        y = y * scale + @viewerHeight / 2
        d3.select('g').transition()
            .duration(@duration)
            .attr("transform", "translate(" + x + "," + y + ")scale(" + scale + ")")
        @zoomListener.scale(scale)
        @zoomListener.translate([x, y])

    centerNode: (source) =>
        scale = @zoomListener.scale()
        x = -source.y0
        y = -source.x0
        x = x * scale + @viewerWidth / 2
        y = y * scale + @viewerHeight / 2
        d3.select('g').transition()
            .duration(@duration)
            .attr("transform", "translate(" + x + "," + y + ")scale(" + scale + ")")
        @zoomListener.scale(scale)
        @zoomListener.translate([x, y])

    calc_dist_depth: (depth, mult) =>
        i = 0
        res = 0
        while (i < depth)
            res += @depthLength[i] * 2
            ++i
        res += @depthLength[depth]
        res *= mult
        return res

    update: (source) =>
      levelWidth = [ 1 ]
      childCount = (levelWidth, level, n) ->
        if n and n.children and n.children.length > 0
          if levelWidth.length <= level + 1
            levelWidth.push 0
          levelWidth[level + 1] += n.children.length
          n.children.forEach (d) ->
            childCount levelWidth, level + 1, d
            return
        return

      childCount levelWidth, 0, @root
      newHeight = d3.max(levelWidth) * 25
      tree = @tree.size([newHeight, @viewerWidth])
      @nodes = tree.nodes(@root).reverse()
      links = tree.links(@nodes)
      @nodes.forEach (d) ->
        if !_Tree.depthLength[d.depth]
            _Tree.depthLength[d.depth] = d.name.length
        else
            _Tree.depthLength[d.depth] = Math.max(d.name.length, _Tree.depthLength[d.depth])
      @nodes.forEach (d) ->
        d.y = _Tree.calc_dist_depth d.depth, 6
        return

      node = @svgGroup.selectAll('g.node').data(@nodes, (d) ->
        d.id || (d.id = ++_Tree.i)
      )
      menu = [{
        title: 'share'
        action: (elm, d, i) ->
          console.log FileSystem._objects[d.server_id]
          mnm.modal_share._shareItem FileSystem._objects[d.server_id]
      }]

      nodeEnter = node.enter().append('g').attr('class', 'node').attr('transform', (d) ->
        'translate(' + source.y0 + ',' + source.x0 + ')'
      )
      nodeEnter.append('circle').attr('class', 'nodeCircle').attr('r', 0).style('fill', (d) ->
        if d._ptr
            return '#f00'
        else if d._children and d._children.length > 0
            return 'lightsteelblue'
        else
            return '#fff'
      ).on('click', @click).on('contextmenu', d3.contextMenu(menu))

      nodeEnter.append('text').attr('x', (d) ->
        if d.children or d._children then -10 else 10
      ).attr('dy', '.35em').attr('class', 'nodeText').attr('text-anchor', (d) ->
        if d.children or d._children then 'end' else 'start'
      ).text((d) ->
        d.name
      ).style('fill-opacity', 0).on('click', @click_focus).on('contextmenu', d3.contextMenu(menu))

      node.select('text').attr('x', (d) ->
        if d.children or d._children then -10 else 10
      ).attr('text-anchor', (d) ->
        if d.children or d._children then 'end' else 'start'
      ).text (d) ->
        d.name
      node.select('circle.nodeCircle').attr('r', 4.5).style 'fill', (d) ->
        if d._ptr
            return '#f00'
        else if d._children and d._children.length > 0
            'lightsteelblue'
        else
            '#fff'
      nodeUpdate = node.transition().duration(@duration).attr('transform', (d) ->
        'translate(' + d.y + ',' + d.x + ')'
      )
      nodeUpdate.select('text').style 'fill-opacity', 1
      nodeExit = node.exit().transition().duration(@duration).attr('transform', (d) ->
        'translate(' + source.y + ',' + source.x + ')'
      ).remove()
      nodeExit.select('circle').attr 'r', 0
      nodeExit.select('text').style 'fill-opacity', 0
      link = @svgGroup.selectAll('path.link').data(links, (d) ->
        d.target.id
      )
      link.enter().insert('path', 'g').attr('class', 'link').attr 'd', (d) ->
        o = {
          x: source.x0
          y: source.y0
        }
        _Tree.diagonal({
          source: o
          target: o
        })
      link.transition().duration(@duration).attr 'd', @diagonal
      link.exit().transition().duration(@duration).attr('d', (d) ->
        o = {
          x: source.x0
          y: source.y0
        }
        _Tree.diagonal({
          source: o
          target: o
        })
      ).remove()
      @nodes.forEach (d) ->
        d.x0 = d.x
        d.y0 = d.y
        return
      return

    toggleChildren: (d) ->
        if d.children
            d._children = d.children
            d.children = null
        else if d._children
            d.children = d._children
            d._children = null
        return d

    click: (d) ->
        return if d3.event.defaultPrevented
        if d._ptr && !d.children && !d._children
            model = FileSystem._objects[d.server_id]
            model.load (modelLoaded) ->
                ptr = new Tree_ptr(modelLoaded, _Tree, d)
        d = _Tree.toggleChildren(d)
        _Tree.update(d)
    click_focus: (d) ->
        return if d3.event.defaultPrevented
        if d._ptr then _Tree.newCenterNode d else _Tree.centerNode(d)

    zoom: () ->
        _Tree.svgGroup.attr("transform", "translate(" + d3.event.translate +
          ")scale(" + d3.event.scale + ")")

    visit: (parent, visitFn, childrenFn) =>
      if !parent
        return
      visitFn parent
      children = childrenFn(parent)
      if children
        count = children.length
        i = 0
        while i < count
          @visit children[i], visitFn, childrenFn
          i++
      return

    search_child: (arr, id) ->
        for n in arr
            if id == n.server_id
                return n
        return 0

    toJson: (_this, d, m, depth = 0, name = m.constructor.name) ->
        d.name = name
        d.server_id = m._server_id
        d.used = true
        depth += 1
        if m instanceof Lst
            children = d.children if d.children
            children = d._children if d._children
            if children not instanceof Array
                if depth <= 3
                  d.children = []
                  children = d.children
                else
                  d._children = []
                  children = d._children
            for val in m
                child = _this.search_child children, val._server_id
                if child
                    _this.toJson _this, child, val, depth
                else
                    children.push {}
                    _this.toJson _this, children[children.length - 1], val, depth
        else if m instanceof Val or m instanceof Bool
            d.name += " = #{m.get()}"
        else if m instanceof Str
            str = m.get()
            if str.length > 25
                str = str.substring(0, 25) + '...'
            d.data =  "#{name} = \"#{m.get()}\""
            d.name += " = \"#{str}\""
        else if m instanceof Ptr
            d.name += " = \"#{m.data.value}\""
            d._ptr = m.data.value
        else if m instanceof TypedArray
            d.name += " = #{m._size}"
        else if m instanceof Model
            children = d.children if d.children
            children = d._children if d._children
            if children not instanceof Array
                if depth <= 3
                  d.children = []
                  children = d.children
                else
                  d._children = []
                  children = d._children
            for val in m._attribute_names
                child = _this.search_child children, m[val]._server_id
                if child
                    _this.toJson _this, child, m[val], depth, val
                else
                    children.push {}
                    _this.toJson _this, children[children.length - 1], m[val], depth, val
