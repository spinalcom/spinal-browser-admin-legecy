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
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Soda. If not, see <http://www.gnu.org/licenses/>.


class BuildAdminFileSystem extends Process
    constructor: ( directory, @data, @list, @process_list, run_init = false ) ->
        super(directory)
        @directory = directory
        @nb_iter = 0
        @uper_list = []
        @change = false

        if run_init
            @builData  @directory, @list[0], 0


    onchange: () =>
        if @directory.has_been_modified() and @change
            # console.log "change directory n= " + @directory.model_id
#             location.reload()
#             console.log @data.id.get()
#             @init()
            @builData  @directory, @data, 0

        @change = true

    add_item_to_list: (data) =>
        for d in @list
            if d.id.get() == data.id.get()
                return
        @list.push data

    add_binded_process: (model, data) =>
        #est ce que le process suivant ce model existe deja
        for p in @process_list
            if p.directory.model_id == model.model_id
                return
        #pour eviter de créer un second process associé au premier directory
        if model.model_id == this.directory.model_id
            return
#         console.log "add process"
        @process_list.push (new BuildAdminFileSystem model, data, @list, @process_list, false)

    init: () =>
        @data.children.clear()

    find_data: (child, data_) ->
#         console.log "model_id = " + child.model_id
        for i in [0 ... data_.children.length]
            d = data_.children[i]
#             console.log Number(d.id.get())
            if Number(d.id.get()) == child.model_id
               return i
        return -1

    getName: (model) ->
      res = model.name.get()
      if model?._info?.model_type?.get() == "Path"
        _info = model._info
        if (_info.remaining.get() != 0)
          percent = (_info.to_upload.get() - _info.remaining.get()) / _info.to_upload.get()
          res += " (#{percent.toFixed(2)}%)"
      return res

    #chargement séquentiel synchrone de l'arbre
    builData: (m, data_, index) =>
        _ref = this
#         data_.id.set m.model_id
        data_.directory_id.set m.model_id
        @add_item_to_list data_
        @add_binded_process m, data_


        #test pour savoir si un children a été supprimé
        # if m.length < data_.children.length
        # for i in [0 ... data_.children.length]
        i = 0
        while (i < data_.children.length)
            d = data_.children[i]
            exist = false
            for j in [0 ... m.length]
                child = m[j]
                if Number(d.id.get()) == child.model_id
                  exist = true
                  break
            if not exist
                # console.log "supression du children " + d.text.get()
                data_.children.remove d
                i = 0
            else
                i++

        if m.length != 0
            #test des modifications sur l'arbre
            for i in [index ... m.length]
                if m[i]?
                    child = m[i]
                    if (child instanceof Val || child.name instanceof Val)
                      continue

                    num = @find_data(child, data_)
                    if num != -1  # l'element existe déja, on change simplement le nom
#                         console.log "modif du nom de l'item"
                        item = data_.children[num]
                        item.text.set @getName(child)

                    else  # l'element n'existe pas, on le créer et on charge ses enfant
#                         console.log "création d'un item"
                        item = new AdminTreeItem
                        data_.children.push item

                        item.id.set child.model_id
                        item.text.set @getName(child)
                        item.link_model = child

                        if child._info.model_type.get() == "Directory"
                            item.type.set "directory"
                            item.state.opened.set true
                            item.state.disabled.set false

                            child._ptr.load (dir) ->
                                _ref.builData( dir, item, 0)
                            @uper_list.push { "model": m, "data": data_, "index": i + 1 }
                            return
                        else if child._info.model_type.get() == "Path"
                            item.type.set "path"
                            item.state.opened.set false
                            item.state.disabled.set true
                        else if child._info.model_type.get() == "Session"
                            item.type.set "session"
                            item.state.opened.set false
                            item.state.disabled.set true
                        else
                            item.type.set "file"
                            item.state.opened.set false
                            item.state.disabled.set true


                @nb_iter += 1

#       console.log @uper_list.length
        length = @uper_list.length
        if @uper_list.length > 0
            test = @uper_list.pop()
            @builData( test["model"], test["data"],  test["index"] )
