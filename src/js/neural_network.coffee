# NeuralNetwork
#
# Represents the state of a Neural Network, including layers,
# inputs, and activations.

_ = require('lodash')

sigmoid = (x) -> 1 / (1 + Math.pow(Math.E, -x))

sum = (a) -> _.reduce(a, (t, s) -> t + s)

class NeuralNetwork

    constructor: (@layers) ->
        @_assignIds()

    getOutputs: ->
        node.activation for node in _.last(@layers)

    computeActivations: (inputs) ->
        for layer, i in @layers
            prevActivations = if i == 0
                inputs
            else
                n.activation for n in @layers[i-1]

            for node in layer
                a = node.bias + sum(a * node.weights[k] for a, k in prevActivations)
                node.activation = sigmoid(a)

    _assignIds: ->
        id = 1
        for layer in @layers
            for node in layer
                node.id = id
                id += 1

module.exports = NeuralNetwork