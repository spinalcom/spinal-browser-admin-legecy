

class Tree_ptr extends Process
    constructor: ( model, @parent, @ptr ) ->
        super(model)
        @model = model

    onchange: () =>
        if @model.has_been_modified()
            @parent.update_ptr @ptr, @model
