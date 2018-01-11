

_viewStatHub = {}

class ViewStatsHub extends Process
    constructor: (model) ->
        super(model)
        @model = model
        # get elements
        # @el_list = document.getElementById "user_list"
        _viewStatHub = this
        @model_sparkline_value = []
        @options = {
            height: '23px'
            width: '100%'
            fillColor: 'transparent'
            lineWidth: 2
            spotRadius: '4'
            highlightLineColor: "#3d86f6"
            highlightSpotColor: "#3d86f6"
            lineColor: "#3d86f6"
            spotColor: false
            minSpotColor: false
            maxSpotColor: false
            type: 'line'
        }
        @bind_btn()

    bind_btn: () =>
        @btn_clicked = {
          garbageCollector: false
          backup: false
        }
        @el_garbage_collector = document.getElementById "btn_garbage_collector"
        @el_garbage_collector.onclick = () ->
            _viewStatHub.btn_clicked.garbageCollector = true
            _viewStatHub.model.btn.garbageCollector.set(1)
        @el_backup = document.getElementById "btn_backup"
        @el_backup.onclick = () ->
            _viewStatHub.btn_clicked.backup = true
            _viewStatHub.model.btn.backup.set(1)

    make_sparkline: () =>
        @renderSparkline(@model_sparkline_value)
        $(window).on('resize', () ->
            if _el = $("#sparkLine_count_users")
                _el.empty()
            if _el = $("#sparkLine_count_models")
                _el.empty()
            if _el = $("#sparkLine_ram_usage_res")
                _el.empty()
            if _el = $("#sparkLine_ram_usage_virt")
                _el.empty()
            _viewStatHub.renderSparkline(_viewStatHub.model_sparkline_value)
        )

    renderSparkline: (value) ->
        if _el = $("#sparkLine_count_users")
            _el.sparkline(value["count_users"], _viewStatHub.options)
        if _el = $("#sparkLine_count_models")
            _el.sparkline(value["count_models"], _viewStatHub.options)
        if _el = $("#sparkLine_count_sessions")
            _el.sparkline(value["count_sessions"], _viewStatHub.options)
        if _el = $("#sparkLine_ram_usage_res")
            _el.sparkline(value["ram_usage_res"], _viewStatHub.options)
        if _el = $("#sparkLine_ram_usage_virt")
            _el.sparkline(value["ram_usage_virt"], _viewStatHub.options)


    onchange: () =>
        if @model.has_been_modified()
            @make_admin_model_details()
            @getSparkline(@model.data.get())
            @make_sparkline()
            if @btn_clicked.garbageCollector == true and @model.btn.garbageCollector.get() == 0
                @btn_clicked.garbageCollector = false
                $.gritter.add({
                    title: 'Notification'
                    text: 'GarbageCollector Done.'
                })
            if @btn_clicked.backup == true and @model.btn.backup.get() == 0
                @btn_clicked.backup = false
                $.gritter.add({
                    title: 'Notification'
                    text: 'Backup Done.'
                })

    make_table_line: (el, label, data) ->
        tr = document.createElement "tr"
        el.appendChild tr
        th = document.createElement "th"
        th.innerHTML = label
        tr.appendChild th
        td = document.createElement "td"
        td.innerHTML = data
        tr.appendChild td
        td = document.createElement "td"
        tr.appendChild td
        div = document.createElement "div"
        div.id = "sparkLine_#{label}"
        td.appendChild div

    make_admin_model_details: () =>
        el = $('#admin_details')
        el.empty()
        @make_table_line(el[0], "count_users", @model.count_users.get())
        @make_table_line(el[0], "count_models", @model.count_models.get())
        @make_table_line(el[0], "count_sessions", @model.count_sessions.get())
        @make_table_line(el[0], "ram_usage_res", @model.ram_usage_res.get())
        @make_table_line(el[0], "ram_usage_virt", @model.ram_usage_virt.get())

    getSparkline: (m) =>
        @model_sparkline_value["count_users"] = @getSparklineData m["count_users"]
        @model_sparkline_value["count_models"] = @getSparklineData m["count_models"]
        @model_sparkline_value["count_sessions"] = @getSparklineData m["count_sessions"]
        @model_sparkline_value["ram_usage_res"] = @getSparklineData m["ram_usage_res"]
        @model_sparkline_value["ram_usage_virt"] = @getSparklineData m["ram_usage_virt"]

    getSparklineData: (str) ->
        res = []
        tmp = str.split(";")
        for data in tmp
            res.push data if data != ""
        return res
