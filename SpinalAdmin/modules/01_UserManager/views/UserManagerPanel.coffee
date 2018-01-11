
_userMnagerPanel = {}

class UserMnagerPanel extends Process
    constructor: (model) ->
        super(model)
        @model = model
        @el_list = document.getElementById "user_list"
        _userMnagerPanel = this
    onchange: () =>
        if @model.has_been_modified()
            @make_table()

    make_table: () =>
      data = ""
      for user in @model
          data += "<tr> \
          <td style=\"padding:10px 0px;\"> \
          <i class=\"fa fa-trash-o\" onclick=\"_userMnagerPanel.delete_account(\'" +
            user.name.get() + "\')\" ></i> \
          </td> \
          <td scope=\"row\">#{user.id.get()}</td> \
          <td>#{user.name.get()}</td> \
          <td>#{user.home.get()}</td> \
          </tr>"

      @el_list.innerHTML = data

    delete_account: (user_id) ->
        SpinalUserManager.delete_account_by_admin("http://" + config.host + ":" + config.port + "/",
          user_id, config.user_id, config.password,
          (response) ->
            $.gritter.add({
                title: 'Success'
                text: "User #{user_id} deleted."
            })
          , (err) ->
            $.gritter.add({
                title: 'Error'
                text: "An error happend when trying to delete the User #{user_id}."
            })
      )
