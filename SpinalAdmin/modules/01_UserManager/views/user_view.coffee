
usermanager_view = {
  add: () ->
    user = document.getElementById("input_user").value
    password = document.getElementById("input_password").value
    if user == "" or password == ""
      return false
    SpinalUserManager.new_account("http://" + config.host + ":" + config.port + "/", user, password,
      (response) ->
        $.gritter.add({
            title: 'Notification'
            text: 'Success create new account.'
        })
      , (err) ->
        $.gritter.add({
            title: 'Notification'
            text: 'Error create new account.'
        })
        console.log("Error create new account")
      )

}
