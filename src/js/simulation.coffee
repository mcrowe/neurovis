# Simulation
#
# Simulation.run() will sequetially simulate all input values
# and plot the output on the given canvas.
#
# By default, there is a delay so that the simulation doesn't
# run too fast.

Color = require('./color')

N = 30 # Number of steps
SLOW_DELAY = 20
FAST_DELAY = 0

fillColor = (value) ->
    Color.lerpColor(Color.RGB_BG, Color.RGB_ACTIVATED, value)

run = (nv, canvas, isFast) ->

    delay = if isFast then FAST_DELAY else SLOW_DELAY

    ctx = canvas.getContext('2d')
    w = canvas.width
    h = canvas.height

    dx = w/N
    dy = h/N

    ctx.clearRect(0, 0, w, h)

    i = 0

    step = ->
        a = i % N
        b = Math.floor(i/N)

        # Get the output for these inputs.
        nv.setInputs([a/N, b/N])
        output = nv.getOutput()

        ctx.fillStyle = fillColor(output)
        ctx.fillRect(a * dx, b * dy, dx, dy)

        # Continue until grid is filled.
        i += 1
        if i < N * N
            setTimeout(step, delay)

    step()

module.exports = {run}