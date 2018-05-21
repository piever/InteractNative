"""
`filepicker(label=""; placeholder="", multiple=false, accept="*")`
Create a widget to select files.
If `multiple=true` the observable will hold an array containing the paths of all
selected files. Use `accept` to only accept some formats, e.g. `accept=".csv"`
"""
function filepicker(::WidgetTheme; postprocess=identity, class="interact-widget", multiple=false, kwargs...)
    if multiple
        onFileUpload = """function (event){
            var fileArray = Array.from(this.\$refs.data.files)
            this.filename = fileArray.map(function (el) {return el.name;});
            return this.path = fileArray.map(function (el) {return el.path;});
        }
        """
        path = Observable(String[])
        filename = Observable(String[])
    else
        onFileUpload = """function (event){
            this.filename = this.\$refs.data.files[0].name;
            return this.path = this.\$refs.data.files[0].path;
        }
        """
        path = Observable("")
        filename = Observable("")
    end
    jfunc = WebIO.JSString(onFileUpload)
    attributes = Dict{Symbol, Any}(kwargs)
    multiple && (attributes[:multiple] = true)
    ui = vue(postprocess(dom"input[ref=data, type=file, v-on:change=onFileChange, class=$class]"(attributes = attributes)),
        ["path" => path, "filename" => filename], methods = Dict(:onFileChange => jfunc))
    primary_obs!(ui, "path")
    slap_design!(ui)
end

"""
`autocomplete(options, o=""; multiple=false, accept="*")`

Create a textbox input with autocomplete options specified by `options` and with `o`
as initial value.
"""
function autocomplete(::WidgetTheme, options, o=""; class="interact-widget", outer = dom"div")
    (o isa Observable) || (o = Observable(o))
    args = [dom"option[value=$opt]"() for opt in options]
    s = gensym()
    template = outer(
        dom"input[list=$s, v-model=text, ref=listref, class=$class]"(),
        dom"datalist[id=$s]"(args...)
    )
    ui = vue(template, ["text"=>o]);
    primary_obs!(ui, "text")
    slap_design!(ui)
end

function input(::WidgetTheme, o; postprocess=identity, typ="text", class="interact-widget", kwargs...)
    (o isa Observable) || (o = Observable(o))
    vmodel = isa(o[], Number) ? "v-model.number" : "v-model"
    attrDict = merge(
        Dict(:type=>typ, Symbol(vmodel) => "value"),
        Dict(kwargs)
    )
    template = Node(:input, className=class, attributes = attrDict)() |> postprocess
    ui = vue(template, ["value"=>o])
    primary_obs!(ui, "value")
    slap_design!(ui)
end

function input(T::WidgetTheme; typ="text", kwargs...)
    if typ in ["checkbox", "radio"]
        o = false
    elseif typ in ["number", "range"]
        o = 0.0
    else
        o = ""
    end
    input(T, o; typ=typ, kwargs...)
end

function button(::WidgetTheme, label = "Press me!"; clicks = Observable(0), class = "interact-widget")
    attrdict = Dict("v-on:click"=>"clicks += 1","class"=>class)
    template = dom"button"(label, attributes=attrdict)
    button = vue(template, ["clicks" => clicks]; obskey=:clicks)
    primary_obs!(button, "clicks")
    slap_design!(button)
end

function checkbox(T::WidgetTheme, o=false; label="", class="interact-widget", outer = dom"div.field", kwargs...)
    s = gensym() |> string
    postprocess = t ->outer(t, dom"label[for=$s]"(label))
    input(T, o; typ="checkbox", id=s, class=class, postprocess=postprocess, kwargs...)
end

toggle(T::WidgetTheme, args...; kwargs...) = checkbox(T, args...; kwargs...)

function textbox(T::WidgetTheme, label=nothing; value="", class="interact-widget", kwargs...)
    input(T, value; typ="text", class=class, kwargs...)
end

function slider(T::WidgetTheme, vals; value=medianelement(vals), kwargs...)
    input(T, value; typ="range", min=minimum(vals), max=maximum(vals), step=step(vals), kwargs...)
end
