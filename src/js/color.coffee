# Color utilities

rgba = (values, a) ->
        rnd = Math.round
        [r, g, b] = values
        "rgba(#{rnd(r)}, #{rnd(g)}, #{rnd(b)}, #{a})"

rgb = (values) -> rgba(values, 1)

lerp = (a, b, u) -> (1 - u) * a + u * b

lerpRGB = (a, b, u) ->
    lerp(a[i], b[i], u) for i in [0..2]

lerpColor = (a, b, u) ->
    rgba(lerpRGB(a, b, u), 1)

Color = {
  rgba,
  rgb,
  lerp,
  lerpRGB,
  lerpColor,
}

Color.RGB_POSITIVE = [192, 57, 43]
Color.RGB_NEGATIVE = [52, 152, 219]
Color.RGB_BG = [44, 62, 80]
Color.RGB_ACTIVATED = [236, 240, 241]
Color.RGB_HIGHLIGHT = [22, 160, 133]

Color.POSITIVE  = rgb(Color.RGB_POSITIVE)
Color.NEGATIVE  = rgb(Color.RGB_NEGATIVE)
Color.ACTIVATED = rgb(Color.RGB_ACTIVATED)
Color.BG        = rgb(Color.RGB_BG)
Color.HIGHLIGHT = rgb(Color.RGB_HIGHLIGHT)

module.exports = Color