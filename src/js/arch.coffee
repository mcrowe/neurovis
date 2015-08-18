# Arch
#
# Utilities and constants for building network architectures.

Arch = {}

Arch.DEFAULT = [[{"bias":-10,"weights":[15,8]},{"bias":5,"weights":[-10,10]},{"bias":-9,"weights":[0,14]}],[{"bias":0,"weights":[12,0,-9]},{"bias":10,"weights":[-15,10,0]},{"bias":-10,"weights":[0,12,-10]},{"bias":5,"weights":[10,0,-20]}],[{"bias":-8,"weights":[-11,18,-20,8]},{"bias":13,"weights":[-15,20,-20,5]}],[{"bias":-15,"weights":[-10,22]}]]

Arch.OR = [
  [
    { bias: -10, weights: [20, 20] }
  ]
]

Arch.XOR = [
  [
    { bias: -10, weights: [20, 20] },
    { bias: -30, weights: [20, 20] }
  ],
  [
    { bias: -10, weights: [20, -20] }
  ]
]

Arch.A = [
  [
    { bias: -10, weights: [20, 20] },
    { bias: 10, weights: [-10, -10] },
    { bias: 20, weights: [0, 10] }
  ],
  [
    { bias: 10, weights: [-10, 15, -20] }
  ],
]

Arch.B = [
  [
    { bias: -10, weights: [20, 20] },
    { bias: 10, weights: [-10, -10] },
    { bias: 0, weights: [0, 10] }
  ],
  [
    { bias: 0, weights: [10, 0, -10] },
    { bias: 10, weights: [-5, 10, 0] },
    { bias: -10, weights: [0, 5, -10] },
    { bias: 5, weights: [10, 0, -20] }
  ],
  [
    { bias: -12, weights: [-15, 20, -20, 5] }
  ]
]

Arch.C = [
  [
    { bias: -10, weights: [20, 15] },
    { bias: 5, weights: [-10, 10] },
    { bias: 0, weights: [0, 10] }
  ],
  [
    { bias: 0, weights: [10, 0, -10] },
    { bias: 10, weights: [-15, 10, 0] },
    { bias: -10, weights: [0, 5, -10] },
    { bias: 5, weights: [10, 0, -20] }
  ],
  [
    { bias: -10, weights: [-15, 20, -20, 5] },
    { bias: 10, weights: [-15, 20, -20, 5] },
  ],
  [
    { bias: -15, weights: [-10, 20] }
  ]
]

Arch.D = [
  [
    { bias: -10, weights: [20, 15] },
    { bias: 5, weights: [-10, 10] },
    { bias: 0, weights: [5, 5] },
    { bias: -5, weights: [0, 10] }
  ],
  [
    { bias: 0, weights: [10, 0, -10, 5] },
    { bias: 10, weights: [-15, 10, 0, -10] },
    { bias: 5, weights: [0, 5, -10, 10] },
    { bias: 5, weights: [10, 0, -20, 0] }
  ],
  [
    { bias: 0, weights: [10, 0, -10, 5] },
    { bias: 5, weights: [-15, 10, 0, 5] },
    { bias: -10, weights: [0, 5, -10, 5] },
    { bias: 5, weights: [10, 0, -20, 0] }
  ],
  [
    { bias: -10, weights: [-15, 20, -20, 5] },
    { bias: 10, weights: [-15, 20, -20, 5] },
  ],
  [
    { bias: -15, weights: [-10, 20] }
  ]
]

randomWeight = (sparsity) ->
    if sparsity and Math.random() > sparsity
        0
    else
        # Random between -25 to 25 with 5 step intervals.
        # Never have a 0, so we recurse if we do.
        (5*Math.round(Math.random()*10) - 25) or randomWeight()


Arch.random = ->
    nLayers = Math.floor(Math.random()*5 + 1)
    layerSizes = (Math.floor(Math.random()*5 + 1 + Math.floor(nLayers/2)) for _ in [0..nLayers])
    Arch.build(layerSizes)

Arch.build = (layerSizes) ->
    arch = []
    for layerSize, l in layerSizes
        layer = []
        prevLayerSize = if l == 0 then 2 else layerSizes[l-1]
        # Set connection sparsity so that an average of 3 connections per
        # node. Except on the output layer, where it doesn't make sense to have sparsity.
        sparsity = if l == layerSizes.length-1 then 0 else 3/Math.max(prevLayerSize, layerSize)
        for _ in [0...layerSize]
            weights = (randomWeight(sparsity) for _ in [0...prevLayerSize])
            layer.push({bias: randomWeight(0.8), weights: weights})

        arch.push(layer)

    return arch

Arch.compress = (arch) ->
  layerSizes = []
  weights = []
  biases = []

  for layer, l in arch
    if l < arch.length - 1
        layerSizes.push(layer.length)

    for node in layer
        biases.push(node.bias)
        for w in node.weights
            weights.push(w)


  layerSizes + '|' + biases + '|' + weights

parseList = (list) ->
    list.split(',').map((i) -> parseInt(i))

Arch.expand = (string) ->
  [layerSizes, biases, weights] = string.split('|')

  if layerSizes.length == 0
      # Handle 0 hidden layers properly.
      layerSizes = [1]
  else
      layerSizes = parseList(layerSizes)
      layerSizes.push(1)

  if !(biases and weights)
      console.log('No biases or weights provided. Generating randomly')
      return Arch.build(layerSizes)

  biases = parseList(biases)
  weights = parseList(weights)

  layers = []

  w = 0
  b = 0

  for layerSize, i in layerSizes
      layer = []

      prevLayerSize = if i == 0 then 2 else layerSizes[i-1]

      for _ in [0...layerSize]
          layer.push({bias: biases[b], weights: (weights[j + w] for j in [0...prevLayerSize])})
          b += 1
          w += prevLayerSize

      layers.push(layer)

  layers

module.exports = Arch