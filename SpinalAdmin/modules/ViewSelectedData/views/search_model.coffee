

class SeachModelTree

    constructor: (@tree, @el_input, @el_count, @el_prev, @el_next, callback ) ->
        @dataSearch = []
        _this = this
        @old_search = ""
        @el_input.onkeypress = (e) ->
            e = window.event if !e
            keyCode = e.keyCode || e.which
            if keyCode == 13
              if _this.old_search == _this.el_input.value
                _this.el_next.onclick()
              else
                _this.old_search = _this.el_input.value
                callback(_this, _this.el_input.value)
              return false
        @search_ressult = []
        @el_count.innerHTML = "0/0"
        @index = 0
        
        @el_prev.onclick = () ->
            return if (_this.search_ressult.length == 0)
            --_this.index
            _this.index = _this.search_ressult.length - 1 if _this.index < 0
            _this.el_count.innerHTML = "#{_this.index + 1}/#{_this.search_ressult.length}"
            _this.tree.centerNode _this.search_ressult[_this.index]

        @el_next.onclick = () ->
            return if (_this.search_ressult.length == 0)
            _this.index = (_this.index + 1) % (_this.search_ressult.length)
            _this.el_count.innerHTML = "#{_this.index + 1}/#{_this.search_ressult.length}"
            _this.tree.centerNode _this.search_ressult[_this.index]

    set_result: (array) =>
        @search_ressult = array
        @index = 0
        if @search_ressult.length == 0 then res = 0 else res = 1
        @el_count.innerHTML = "#{res}/#{@search_ressult.length}"
        if @search_ressult.length != 0
            @tree.centerNode @search_ressult[@index]
