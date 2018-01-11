# Copyright 2016 SpinalCom  www.spinalcom.com
#
# This file is part of SpinalCore.
#
# SpinalCore is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Soda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Soda. If not, see <http://www.gnu.org/licenses/>.


class ViewAdminFileSystem extends Process
    constructor: ( data, @SelectedData, MnM ) ->
        super(data)
        @data = data
        $('#jstree2-ajax').jstree({
            "contextmenu": { "items": MnM.customMenu }
            "core": {
                "themes": { "responsive": false },
                "check_callback": true,
                'data': @tojson(@data)
            }
            "types": {
                "default": { "icon": "fa fa-folder text-warning fa-lg" },
                "directory": { "icon": "fa fa-folder text-warning fa-lg" },
                "file": { "icon": "fa fa-file text-warning fa-lg" },
                "session": { "icon": "fa fa-desktop text-success fa-lg" },
                "path": { "icon": "fa fa-download text-success fa-lg" }
            }
            "plugins": [ "contextmenu", "state", "types" ]
        })
          # "core" :
          #   'force_text' : true,
          #   "check_callback" : true
          # "plugins" : [ "contextmenu", "types" ]

    onchange: () =>
        if @data.has_been_modified()
            new_data = @tojson(@data, 0)
            $('#jstree2-ajax').jstree(true).settings.core.data = new_data
            $('#jstree2-ajax').jstree(true).refresh()
            $('#jstree2-ajax').jstree('open_all')

            _selected_data = @SelectedData
            _data = @data
            $("#jstree2-ajax").bind(
                'changed.jstree', (evt, data) ->
                    _selected_data.clear()
                    test = -1
                    r = []
                    for i in [0 ... data.selected.length]
                        r.push(data.instance.get_node(data.selected[i]).id)
                    _selected_data.push r[0]
            )


    tojson: (_data, level) =>
        tree_data = []
        for child in _data.children
            tree_data.push({
                "id": child.id.get()
                "text": child.text.get()
                "state": @get_state(child)
                "type": @get_type(child, level)
                "children": if child.children.length != 0 then @tojson(child, 1) else []
            })

        return tree_data

     get_type: (_data, level) ->
        type = _data.type.get()
        return type

     get_state: (_data) ->
        state = {}
        if _data.type.get() == "file"
            state = { "opened": false }
        else
            state = { "opened": true }
        return state
