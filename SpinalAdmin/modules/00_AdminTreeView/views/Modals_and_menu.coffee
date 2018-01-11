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
mnm = {}

class Modals_and_Menu
  constructor: (@selected_data, @folder_list) ->
    mnm = this
    @modal_share = new Modal_Share
    @modal_new = new Modal_New

    @customMenu = (node) =>
      selected = @getModel_by_model_id @selected_data
      selected_type = selected?._info?.model_type?.get()

      items = {}
      switch selected_type
        when "Session"
          items.openSession = {
            separator_before: false
            separator_after: true
            icon: 'fa fa-desktop text-success',
            label: "Open Session"
            action: () ->
              mnm.open_session(node)
          }
        when "Path"
          items.openSession = {
            separator_before: false
            separator_after: true
            icon: 'fa fa-download text-success',
            label: "Download"
            action: () ->
              mnm.download_file()
          }
      items.NewItem = {
        separator_before: false
        separator_after: false
        icon: 'fa fa-file text-warning',
        label: "New..."
        action: () ->
          mnm.modal_new._newItem()
      }
      items.shareItem = {
        icon: 'fa fa-share text-success',
        separator_before: false
        separator_after: false
        label: "Share"
        action: () ->
          mnm.modal_share._shareItem(mnm.getModel_by_model_id(mnm.selected_data))
      }
      items.deleteItem = {
        separator_before: true
        separator_after: false
        icon: 'fa fa-trash text-danger',
        label: "Delete"
        action: () ->
          mnm._deleteItem()
      }
      return items

  _deleteItem: () =>
    selected = @getModel_by_model_id @selected_data
    if selected._parents?.length != 0
      selected._parents[0].remove selected

  download_file: () =>
      selected = @getModel_by_model_id @selected_data
      if selected instanceof TiffFile
          selected.load_tiff ( model, err ) ->
              if Path? and ( model instanceof Path )
                  window.open "/sceen/_?u=" + model._server_id, "_blank"
      else
          selected.load ( model, err ) ->
              if Path? and ( model instanceof Path )
                  window.open "/sceen/_?u=" + model._server_id, "_blank"

  get_name_by_id: (id) =>
    for obj in @folder_list
      if obj.id.get() == id
          return obj.text.get()
    return ""

  open_session: (node) =>
    Projects_dir = node.text
    for obj in node.parents
      if obj == "#"
        Projects_dir = '/' + Projects_dir
        break
      else
        Projects_dir =  @get_name_by_id(parseInt(obj)) + "/" + Projects_dir
    myWindow = window.open '', ''
    myWindow.document.location = "/html/lab.html#" + encodeURI( Projects_dir )
    myWindow.focus()

  getModel_by_model_id: ( @selectedID ) =>
    for k, m of FileSystem._objects
      if parseInt(m.model_id) == parseInt(@selectedID)
        return m
