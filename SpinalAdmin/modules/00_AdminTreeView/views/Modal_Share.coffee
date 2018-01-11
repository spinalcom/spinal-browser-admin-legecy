

class Modal_Share
  constructor: () ->
    @flag = 0
    _this = this
    $('#modal-share-read').on('change', () ->
      if $(this).prop('checked')
        mnm.modal_share.flag |= spinalCore.right_flag.RD
      else
        mnm.modal_share.flag &= ~spinalCore.right_flag.RD
    )
    $('#modal-share-write').on('change', () ->
      if $(this).prop('checked')
        mnm.modal_share.flag |= spinalCore.right_flag.WR
      else
        mnm.modal_share.flag &= ~spinalCore.right_flag.WR
    )
    $('#modal-share-share').on('change', () ->
      if $(this).prop('checked')
        mnm.modal_share.flag |= spinalCore.right_flag.AD
      else
        mnm.modal_share.flag &= ~spinalCore.right_flag.AD
    )
    $('#modal-share').on('shown.bs.modal', () -> $('#modal-share-target').focus() )

  create_right_col: (flag, flagType) ->
    if flag & flagType
      return "<td>Yes</td>"
    return "<td>No</td>"


  create_rightsItem_tab: (ptr, data) =>
    tab = document.getElementById('modal-share-rightsItem')
    res = ""
    for ur in data
      res += "<tr>"
      res += "<td>" + ur.user.id.get() + "</td>"
      res += "<td>" + ur.user.name.get() + "</td>"
      res += mnm.modal_share.create_right_col(ur.flag.get(), spinalCore.right_flag.RD)
      res += mnm.modal_share.create_right_col(ur.flag.get(), spinalCore.right_flag.WR)
      res += mnm.modal_share.create_right_col(ur.flag.get(), spinalCore.right_flag.AD)
      res += "</tr>"
      @namelist.push ur.user.name.get()
    tab.innerHTML = res



  _shareItem: (@mod) =>
    @namelist = []
    $('#modal-share-read').prop('checked', false)
    $('#modal-share-write').prop('checked', false)
    $('#modal-share-share').prop('checked', false)
    document.getElementById('modal-share-target').value = ""
    $( "#modal-share-target" ).autocomplete({
      minLength: 0
      position: {
        my: "right top"
        at: "right bottom"
      }
      source: mnm.modal_share.namelist
    })
    # mnm.getModel_by_model_id mnm.selected_data
    file_name = document.getElementById('modal-share-file')
    if @mod.name
      file_name.value = @mod.name
    else
      file_name.value = @mod.constructor.name
    @flag = 0
    if @mod instanceof File
      _data = @mod._ptr.data.value
    else
      _data = @mod._server_id
    spinalCore.load_right(conn, _data, (res) ->
        mnm.modal_share.create_rightsItem_tab(_data, res)
      , (err) ->
        console.log "Error load_right"
      )

    $('#modal-share').modal()

  send_share: () =>
    user = document.getElementById('modal-share-target').value
    file = document.getElementById('modal-share-file').value
    flag = mnm.modal_share.flag
    data = @mod
    error = document.getElementById('modal-share-error')
    error.innerHTML = ""
    _error = "Error "
    found_error = false
    if user == ""
      if found_error == false
        found_error = true
      _error += "invalid target username"
    if file == ""
      if found_error == false
        found_error = true
      else
        _error += ", "
      _error += "invalid filename"
    if flag == 0
      if found_error == false
        found_error = true
      else
        _error += ", "
      _error += "add Right Types to give"

    if found_error == true
      error.innerHTML = _error + '.'
      return

    spinalCore.share_model(conn, data, file, flag, user)
    $('#modal-share').modal('hide')
