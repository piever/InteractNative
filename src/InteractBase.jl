__precompile__()

module InteractBase

using WebIO, DataStructures, Observables, CSSUtil, Colors, Requires
using JSON
using Knockout
using Widgets
import Widgets:
    observe,
    AbstractWidget,
    div,
    Widget,
    widget,
    widgettype,
    ObservablePair,
    @layout!,
    @output!,
    @display!,
    @widget

import Observables: throttle, _val

export filepicker, datepicker, timepicker, colorpicker, spinbox

export autocomplete, input, dropdown, checkbox, textbox, textarea, button, slider, toggle, togglecontent

export radiobuttons, togglebuttons, tabs, checkboxes, toggles, tabulator

export latex, alert, highlight

export settheme!, resettheme!, gettheme, NativeHTML

export slap_design!

abstract type WidgetTheme; end
struct NativeHTML<:WidgetTheme; end

const font_awesome = joinpath(@__DIR__, "..", "assets", "all.js")
const prism_js = joinpath(@__DIR__, "..", "assets", "prism.js")
const prism_css = joinpath(@__DIR__, "..", "assets", "prism.css")
const style_css = joinpath(@__DIR__, "..", "assets", "style.css")

include("classes.jl")
include("backends.jl")
include("widget.jl")
include("widget_utils.jl")
include("input.jl")
include("optioninput.jl")
include("defaults.jl")
include("manipulate.jl")
include("output.jl")

include("providers/atom.jl")
include("providers/blink.jl")
include("providers/mux.jl")

end # module
