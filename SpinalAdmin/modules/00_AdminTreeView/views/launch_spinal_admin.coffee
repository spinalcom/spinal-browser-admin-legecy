# Copyright 2016 SpinalCom  www.spinalcom.com
#
# This file is part of SpinalCore.
#
# SpinalCore is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpinalCore is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with SpinalCore. If not, see <http://www.gnu.org/licenses/>.


launch_spinal_admin = (  ) ->

    #Root File_System_Model
    root_dir = new AdminTreeItem
    root_dir.id.set 0
    root_dir.text.set "root"
    root_dir.type.set "directory"
    root_dir.state.opened.set true

    folder_list = new Lst
    folder_list.push root_dir
    process_list = []
    selected_data = new Lst
    MnM = new Modals_and_Menu(selected_data, folder_list)

    conn.load_or_make_dir "/", (dir, err) ->
        # récupération séquentielle et synchrone du systeme de fichier virtuel du hub,
        # construction de root_dir et association de process à chaque directory observés
        process_list.push new BuildAdminFileSystem dir, root_dir, folder_list, process_list, true

        #construction de l'arbre treejs à partir du root_dir construit à l'étape précédente
        VFS = new ViewAdminFileSystem root_dir, selected_data, MnM

        #affichage du contenu du noeud de l'arbre selectionné
        VSD = new ViewSelectedData selected_data

        spinalCore.load(conn, "/etc/Status", (MS) ->
            VSH = new ViewStatsHub MS
        )
        spinalCore.load(conn, "/etc/users", (user) ->
            UMP = new UserMnagerPanel user
        )
        new ViewAppModule()
