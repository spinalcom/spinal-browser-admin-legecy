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


class ViewSelectedData extends Process
    constructor: ( SelectedData ) ->
        super(SelectedData)
        @SelectedData = SelectedData
        @tree = null
        @tree_model = null

    onchange: () =>
        if @SelectedData.has_been_modified()
            return if (@SelectedData.length == 0)
            selected_model = @getModel_by_model_id @SelectedData[0].get()
            return if !selected_model
            if @tree != null
                @tree_model.unbind @tree
                @tree = null
            _this = this
            selected_model.load (modelLoaded) ->
                _this.tree_model = modelLoaded
                _this.tree = new TreeFileSelected(modelLoaded)

    getModel_by_model_id: (@selectedID) =>
        for k, m of FileSystem._objects
            if parseInt(m.model_id) == parseInt(@selectedID)
                return m
