$ = require('jquery')

Simulation = require('./simulation')
hashy = require('./hashy')
Arch = require('./arch')
NeuroVis = require('./neuro_vis')
Tour = require('./tour')

KEY_SHIFT = 16
MAX_WEIGHT = 20
INIT_INPUTS = [0, 0]
NETWORK_ID = 'network'
ARCH_KEY = 'arch'

shiftPressed = false

clamp = (val, min, max) -> Math.min(max, Math.max(min, val))

incrementInput = (index, amount, min, max) ->
    inputs = nv.inputs
    inputs[index] = clamp(inputs[index] + amount, min, max)
    nv.setInputs(inputs)

handleNodeClick = (id, leftClick) ->
    dirn = if leftClick then 1 else -1
    step = if shiftPressed then 0.5 else 0.1
    d = step * dirn

    index = nv.inputIds().indexOf(id)

    if index >= 0
        incrementInput(index, d, 0, 1)

updateArch = (arch) ->
    hash.set(Arch.compress(arch))

handleEdgeClick = (edge, leftClick) ->
    [from, to] = edge
    toNode = nv.findNode(to)

    fromNode = nv.findNode(from)
    fromType = nv.nodeType(fromNode)

    [toLayer, toIndex] = nv.nodeCoords(toNode)

    direction = if leftClick then 1 else -1
    step = if shiftPressed then 5 else 1

    d = step * direction

    archNode = arch[toLayer][toIndex]

    if fromType == 'normal' or fromType == 'input'
        [fromLayer, fromIndex] = nv.nodeCoords(fromNode)
        w = archNode.weights[fromIndex]
        archNode.weights[fromIndex] = clamp(w + d, -MAX_WEIGHT, MAX_WEIGHT)

    else
      # Bias
      b = archNode.bias
      archNode.bias = clamp(b + d, -MAX_WEIGHT, MAX_WEIGHT)

    updateArch(arch)

loadArch = ->
    # Load the arch from url hash, or default.
    if str = hash.get()
        Arch.expand(str)
    else
        Arch.DEFAULT

onKeydown = (e) ->
    if e.which == KEY_SHIFT
        shiftPressed = true

onKeyup = (e) ->
    if e.which == KEY_SHIFT
        shiftPressed = false

isTourEvent = (e) ->
    e.target.className.indexOf('hopscotch') >= 0

onMouseDown = (e) ->
    if isTourEvent(e) then return

    [x, y] = [e.clientX, e.clientY]

    node = nv.nodeAt(x, y)
    edge = nv.edgeAt(x, y)

    isLeft = e.which == 1

    if node
        handleNodeClick(node, isLeft)
    else if edge
        handleEdgeClick(edge, isLeft)

onRightClick = (e) ->
    if isTourEvent(e) then return

    [x, y] = [e.clientX, e.clientY]

    # Don't show context menu when right-clicking a node/edge.
    if nv.nodeAt(x, y) or nv.edgeAt(x, y)
        e.preventDefault()

hash = hashy.wrap(ARCH_KEY)

arch = loadArch()

$(document).keydown(onKeydown).
            keyup(onKeyup).
            mousedown(onMouseDown).
            on('contextmenu', onRightClick)

$(window).on 'hashchange', ->
    if str = hash.get()
        arch = Arch.expand(str)
    nv.setArch(arch)

nv = new NeuroVis(NETWORK_ID, arch, INIT_INPUTS)

setTimeout(Tour.start.bind(null, nv), 300)

$('#start-tutorial').click (e) ->
    setTimeout(Tour.forceStart.bind(null, nv), 300)

$('#toggle-architecture').click (e) ->
    e.preventDefault()
    $(this).hide()
    $('#architecture').show()

$('#random-arch').click (e) ->
    e.preventDefault()
    updateArch(Arch.random())

$('#simulation').click (e) ->
    $(this).addClass('filled')
    canvas = $(this).children('canvas').get(0)

    Simulation.run(nv, canvas, shiftPressed)