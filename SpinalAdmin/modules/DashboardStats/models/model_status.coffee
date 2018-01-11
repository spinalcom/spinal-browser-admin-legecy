
class model_status extends Model
    constructor: ->
        super()
        @add_attr({
            count_users: 0
            count_models: 0
            ram_usage_virt: 0
            ram_usage_res: 0
            count_sessions: 0
            users: []
            data_list: []
        })

