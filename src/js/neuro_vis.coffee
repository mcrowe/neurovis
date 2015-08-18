# NeuroVis
#
# A wrapper around vis.js the works with neural networks.

_ = require('lodash')

Color = require('./color')
NeuralNetwork = require('./neural_network')

BIAS_LABEL = '+'

VIS_OPTIONS = {
  autoResize: false,
  layout: {
    hierarchical: {
      direction: 'LR',
      sortMethod: 'directed'
    }
  },
  edges: {
    font: {
      color: Color.ACTIVATED,
      strokeWidth: 0,
      align: 'bottom'
    }
  },
  nodes: {
    borderWidth: 2,
    fixed: true
    font: { color: Color.ACTIVATED }
  }
  interaction:{
    dragNodes: false,
    dragView: false,
    multiselect: false,
    navigationButtons: false,
    selectable: false,
    zoomView: false
  }
}

MIN_EDGE_ALPHA = 0.1

INPUT_LABELS = ['A', 'B']

fontColor = (alpha) ->
    if alpha < 0.5 then Color.ACTIVATED else Color.BG

nodeColor = (activation) ->
    bgColor = Color.lerpColor(Color.RGB_BG, Color.RGB_ACTIVATED, activation)

    {
      background: bgColor,
      border: Color.ACTIVATED,
      highlight: {
        background: bgColor,
        border: Color.HIGHLIGHT
      }
    }

nodeTitle = (activation) ->
    "activation <strong>#{activation.toFixed(1)}</strong>"

edgeColor = (weight, input) ->
    alpha = if weight == 0
        0
    else
        (input * (1 - MIN_EDGE_ALPHA)) + MIN_EDGE_ALPHA

    rgbArray = if weight < 0 then Color.RGB_NEGATIVE else Color.RGB_POSITIVE
    Color.rgba(rgbArray, alpha)

buildEdge = (fromId, toId, weight, input) ->
    value = Math.abs(weight)
    {
      from: fromId,
      to: toId,
      value: Math.abs(weight),
      color: {
        color: edgeColor(weight, input),
        highlight: Color.HIGHLIGHT
      }
    }

buildGraph = (network, inputs) ->
    nodes = []
    edges = []
    layers = network.layers

    # Nodes
    for layer, l in layers
        for neuron in layer
            a = neuron.activation
            if l == network.layers.length - 1
                # output node
                nodes.push({
                  id: neuron.id,
                  color: nodeColor(a),
                  title: '',
                  label: a.toFixed(1),
                  font: {
                    size: 20,
                    face: 'Open Sans',
                    color: fontColor(a)
                  }
                })
            else
                # hidden node
                nodes.push({
                  id: neuron.id,
                  color: nodeColor(a)
                })

    # Edges
    for layer, i in layers[1..]
        prevLayer = layers[i]
        for neuron in layer
            for axon, k in prevLayer
                edges.push( buildEdge(axon.id, neuron.id, neuron.weights[k], axon.activation) )

    # Input Nodes

    firstHiddenLayer = layers[0]

    for input, i in inputs
        id = -(i+1)
        nodes.push({
          id: id,
          label: input.toFixed(1),
          color: nodeColor(input),
          title: '',
          font: {color: fontColor(input), size: 20, face: 'Open Sans'}
        })

        for neuron in firstHiddenLayer
            edges.push( buildEdge(id, neuron.id, neuron.weights[i], input) )

    # Bias Nodes

    for layer, i in layers
        id = -(i+inputs.length+1)
        nodes.push({
          id: id,
          color: nodeColor(1),
          label: BIAS_LABEL,
          font: {color: fontColor(1)}
        })

        for neuron in layer
            edges.push( buildEdge(id, neuron.id, neuron.bias, 1) )

    {nodes: nodes, edges: edges}

class NeuroVis

    constructor: (id, arch, @inputs) ->
        target = document.getElementById(id)
        @_vis = new vis.Network(target, {}, VIS_OPTIONS)
        @setArch(arch)

    findNode: (id) ->
        @_vis.findNode(id)[0]

    nodeAt: (x, y) ->
        id = @_vis.getNodeAt({x, y})
        id and String(id)

    edgeAt: (x, y) ->
        edge = @_vis.getEdgeAt({x, y})
        edge and @_vis.getConnectedNodes(edge)

    nodeType: (node) ->
        if node.id > 0
            'normal'
        else if node.id >= -@inputs.length
            'input'
        else
            'bias'

    outputNode: ->
        id = _.last(@_network.layers)[0].id
        @findNode(id)

    inputIds: ->
        String(-i) for i in [1..@inputs.length]

    nodeCoords: (testNode) ->
        if @nodeType(testNode) == 'input'
            return [-1, -parseInt(testNode.id) - 1]

        for layer, l in @_network.layers
            for node, i in layer
                if node.id == testNode.id
                    return [l, i]

    getOutput: ->
        @_network.getOutputs()[0]

    setInputs: (inputs) ->
        @inputs = inputs
        @_loadNetworkData()

    setArch: (arch) ->
        @_network = new NeuralNetwork(arch)
        @_loadNetworkData()

    _loadNetworkData: ->
        @_network.computeActivations(@inputs)
        graph = buildGraph(@_network, @inputs)
        @_vis.setData({
          nodes: new vis.DataSet(graph.nodes),
          edges: new vis.DataSet(graph.edges)
        })

module.exports = NeuroVis