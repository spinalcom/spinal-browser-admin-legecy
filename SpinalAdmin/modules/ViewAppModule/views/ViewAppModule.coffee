
class ViewAppModule
  constructor: () ->
    for dash_lib in DASHBOARD_MOD
      obj = new window[dash_lib]()
      el = $("#app-module-list")
      div = new_dom_element({
        nodeName: 'div'
        className: 'col-xs-6 app-btn-container'
      })

      btn = new_dom_element({
        nodeName: 'button'
        nodeType: 'button'
        className: 'btn btn-primary app-btn'
        onclick: obj.action
      })
      btn.tree = obj.tree
      icon = new_dom_element({
        nodeName: 'i'
        className: 'fa fa-plus-square'
      })

      name = new_dom_element({
        nodeName: 'div'
        innerHTML: obj.name
      })

      btn.appendChild icon
      btn.appendChild name
      div.appendChild btn
      el.append(div)
      console.log obj


# <div class="col-xs-6 app-btn-container">
#   <button type="button" class="btn btn-primary app-btn">
#     <i class="fa fa-plus-square"></i><br/>
#     Back Up
#   </button>
# </div>
