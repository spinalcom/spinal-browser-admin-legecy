

class Modal_New
  constructor: () ->
    _this = this
    @folder = $("#modal-new-head-folder")
    @project = $("#modal-new-head-project")
    @upload = $("#modal-new-head-upload")
    @folder.click () ->
      _this.clickOnFolder()
    @project.click () ->
      _this.clickOnProject()
    @upload.click () ->
      _this.clickOnUpload()
    @content = $('#modal-new-content')
    @flag = 0
    $('#modal-new-content').on('hidden.bs.modal', @modal_closed)

  modal_closed: () ->
    mnm.modal_new.clear_refresh_upload mnm.modal_new
  _newItem: () =>
    @data = mnm.getModel_by_model_id(mnm.selected_data)
    @interval = 0
    _this = this

    if @data._info?.model_type?.get() == "Directory"
      $("#page-container").spin('large')
      @data.load((m) ->
        $("#page-container").spin(false)
        _this.data = m
        $('#modal-new').modal()
        _this.clickOnFolder()
      )
    else
      @data = @data._parents?[0]
      $('#modal-new').modal()
      @clickOnFolder()

  clickOnFolder: () =>
    @flag = 1
    @folder.addClass("active")
    @project.removeClass("active")
    @upload.removeClass("active")
    res = "<h5>New Folder Name:</h5>"
    res += "<input type=\"text\" onfocus=\"this.select()\" " +
     " class=\"form-control\" id=\"modal-new-name\" value=\"New Folder\">"
    @content.html res
    $("#modal-new-name").focus()

  clickOnProject: () =>
    @flag = 2
    @folder.removeClass("active")
    @project.addClass("active")
    @upload.removeClass("active")
    date = new Date
    res = "<h5>New Project Session Name:</h5>"
    res += "<input type=\"text\" onfocus=\"this.select()\" class=\"form-control\" " +
      " id=\"modal-new-name\" value=\"Project name - #{date.toString()}\">"
    @content.html res
    $("#modal-new-name").focus()

  clickOnUpload: () =>
    @flag = 3
    @folder.removeClass("active")
    @project.removeClass("active")
    @upload.addClass("active")
    @content.html ""
    @uploaded_file = []
    _this = this
    input = new_dom_element({
      parentNode: @content.get(0)
      nodeName: "input"
      type: "file"
      id: "modal-new-dropzone-input"
      multiple: "true"
      className: "modal-new-dropzone-input"
      onchange: ( evt ) ->
        _this.handle_files input.files
    })
    file_container = new_dom_element({
      parentNode: @content.get(0)
      nodeName: "label"
      innerHTML: "<span class=\"modal-new-span-upload\" >click to Choose files to upload " +
        "or Drop them here</span><ul id=\"modal-new-list-upload\"></ul>"
      className: "text-center"
      ondrop: ( evt ) ->
        evt.stopPropagation()
        evt.preventDefault()
        _this.handle_files evt.dataTransfer.files
      ondragover: (evt) ->
        evt.preventDefault()
    })
    file_container.htmlFor = "modal-new-dropzone-input"

  validate_Folder: () =>
    name = $("#modal-new-name").val()
    @data.add_file name, new Directory

  validate_Project: () =>
    date = new Date()
    name = $("#modal-new-name").val()
    @data.add_file(name, 0, {
      model_type: 'Session',
      icon: 'Session',
    })

    # td = new TreeAppData
    # td.new_session()
    # td.modules.push new TreeAppModule_UndoManager
    # td.modules.push new TreeAppModule_PanelManager
    # td.modules.push new TreeAppModule_File
    # td.modules.push new TreeAppModule_Apps
    # #td.modules.push new TreeAppModule_Projects
    # td.modules.push new TreeAppModule_Animation
    # td.modules.push new TreeAppModule_TreeView
    # @data.add_file name, td, { model_type: "Session", icon: "session" }

  validate: () =>
    switch @flag
      when 1 then @validate_Folder()
      when 2 then @validate_Project()
      when 3 then @clear_refresh_upload()
    $('#modal-new').modal('hide')

  clear_refresh_upload: (inst = this) =>
    if inst.interval
      clearInterval(inst.interval)
      inst.interval = 0

  update_upload_list: () ->
    if !mnm.modal_new.interval
      mnm.modal_new.interval = setInterval(mnm.modal_new.update_upload_list, 1000)
    if mnm.modal_new.uploaded_file.length != 0
      list = $("#modal-new-list-upload")
      in_process = false
      res = ""
      for file in mnm.modal_new.uploaded_file
        _info = {}
        file.mod.get_file_info _info
        if (_info.remaining.get() == 0)
          percent = 100
        else
          percent = (_info.to_upload.get() - _info.remaining.get()) / _info.to_upload.get()
          in_process = true
        res += "<li>#{file.file.name} (#{percent.toFixed(2)}%)</li>"
      list.html res
      if in_process == false
        mnm.modal_new.clear_refresh_upload(mnm.modal_new)

  handle_files: (files) =>
    if files.length > 0
      for file in files
        filePath = new Path file
        mod_file = @data.force_add_file file.name, filePath
        @uploaded_file.push({ file: mod_file, mod: filePath })
        @update_upload_list()
