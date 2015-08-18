# Tour
#
# Utilities for running the tour.
# Uses the hopscotch library.

$ = require('jquery')
hopscotch = require('hopscotch')

setCookie = (key, value) ->
        expires = new Date()
        expires.setTime(expires.getTime() + (1 * 24 * 60 * 60 * 1000))
        cookie = key + '=' + value + ';path=/' + ';expires=' + expires.toUTCString()
        document.cookie = cookie

getCookie = (key) ->
    keyValue = document.cookie.match('(^|;) ?' + key + '=([^;]*)(;|$)')
    if keyValue then keyValue[2] else null

buildTour = (nv) ->
    TARGET = 'tour-anchor'

    inputNode = nv.findNode('-1')
    inputPos = nv._vis.canvasToDOM(inputNode)

    outputNode = nv.outputNode()
    outputPos = nv._vis.canvasToDOM(outputNode)

    centerPos = {x: $(document).outerWidth()/2 - 250, y: 0}

    neuronNode = nv.findNode('1')
    neuronPos = nv._vis.canvasToDOM(neuronNode)

    synapsePos = {x: inputPos.x + (neuronPos.x - inputPos.x)/2, y: inputPos.y + (neuronPos.y - inputPos.y)/2}

    biasNode = nv.findNode('-3')
    biasPos = nv._vis.canvasToDOM(biasNode)

    bottomLeftPos = {x: 0, y: $(document).outerHeight()}

    markTourViewed = ->
        setCookie('toured', 'toured')

    tour = {
      id: "hello-hopscotch",
      steps: [
        {
          title: "This is a <em>neural network</em>.",
          content: "<p>Before you start playing with it, there are a few things you should know&hellip;</p>",
          width: 350,
          target: TARGET,
          placement: "bottom",
          xOffset: centerPos.x,
          yOffset: centerPos.y,
          arrowOffset: 'center'
        }, {
          title: "This is an <em>input node</em>.",
          content: "<p>Inputs nodes reflect the data being fed in to a neural network. This data could represent images, sounds, text, etc. This neural network has two inputs, but it could have many more.</p><p><em><strong>Do:</strong> Increase the value of this input by clicking on it a few times. Right click to reduce its value again. Hold shift to go faster.</em></p>",
          width: 350,
          target: TARGET,
          placement: "right",
          xOffset: inputPos.x + 50,
          yOffset: inputPos.y - 30,
          showPrevButton: true
        }, {
          title: "This is an <em>output node</em>.",
          content: "<p>A neural network's purpose is to compute a function of its inputs. The result of its computation is reflected in its output nodes. This network has only one output.</p><p><em><strong>Do:</strong> Change the input values and watch this output change automatically.</em></p>",
          target: TARGET,
          placement: "left",
          width: 350,
          xOffset: outputPos.x - 50,
          yOffset: outputPos.y - 30,
          showPrevButton: true
        }, {
          title: "This is a <em>neuron</em>.",
          content: "<p>Neurons are arranged into <em>layers</em>, from left to right. The arrangement of neurons in a neural network is called its <em>architecture</em>. In this network, there are 3 inner layers, 1 input layer, and 1 output layer.</p><p>Each neuron computes its own <em>activation</em> based on a weighted sum of its inputs&mdash;the activations of the neurons in the layer to its left.</p><p><em><strong>Do:</strong> Change the inputs until this neuron is painted solid white. That means it is fully activated.</em></p>",
          target: TARGET,
          width: 350,
          placement: "right",
          xOffset: neuronPos.x + 30,
          yOffset: neuronPos.y - 30,
          showPrevButton: true
        }, {
          title: "This is a <em>synapse</em>.",
          content: "<p>A synapse connects two neurons from adjacent layers. Each has a <em>weight</em>, which dictates how strongly the neuron on the left can stimulate the one on the right. The weight can be negative, which means that the synapse is inhibitory.</p><p>In this visualization, thicker synapses have a larger weight. Red represents a positive weight, and blue, negative.</p><p><em><strong>Do:</strong> Change the weight of this synapse by left/right clicking. Hold shift to go faster.</em></p>",
          target: TARGET,
          placement: "bottom",
          xOffset: synapsePos.x - 175,
          yOffset: synapsePos.y + 10,
          arrowOffset: 'center',
          width: 350,
          showPrevButton: true
        }, {
          title: "This is a <em>bias node</em>.",
          content: "<p>Each neuron can have a positive or negative <em>bias</em>. This is a constant term in the weighted sum it computes. We represent the biases visually as a synapse connected to a bias node, a special neuron that is always fully activated. The weight of this synapse is the neuron's bias. Bias nodes are labeled with a <i class='fa fa-plus'></i> sign.</p><p><em><strong>Do:</strong> Change a neuron's bias by changing the weight of the synapse that connects it to this bias node</em>.</p>",
          target: TARGET,
          placement: "right",
          xOffset: biasPos.x + 20,
          yOffset: biasPos.y - 40,
          width: 400,
          showPrevButton: true
        }, {
          title: "This is a map of the <em>computed function</em>.",
          content: "<p>A neural network computes a function of its inputs. That function depends on the architecture, and synapse weights. What type of function does this neural network compute?</p><p><em><strong>Do:</strong> Click <i class='fa fa-play-circle-o'></i> to map the outputs for a range of input values to visualize the function this network computes. Change some weights and see how that changes the map. (This works best in Chrome and Safari.)</em></p>",
          target: 'simulation',
          placement: "left",
          yOffset: -110,
          width: 390,
          arrowOffset: 'center',
          showPrevButton: true
        }, {
          title: "This is a list of <em>architectures</em>.",
          content: "<p>A neural network's <em>architecture</em> describes the number of layers, the number of neurons in each layer, and the connections between neurons. So far we've only seen one architecture.</p><p><em><strong>Do:</strong> Hover the <i class='fa fa-share-alt'></i> and select a different architecture.</em></p>",
          width: 380,
          target: TARGET,
          xOffset: bottomLeftPos.x + 105,
          yOffset: bottomLeftPos.y - 560,
          arrowOffset: '195',
          placement: "right",
          showPrevButton: true
        }, {
          title: "This is the end of the tutorial.",
          content: "<p>Now it's time to play around. Develop some intuition about neural networks. How does the <em>activation</em> change for a neuron as you change the weights of its synapses? How does the <em>computed function</em> change as you modify synapse weights? What types of functions can neural networks compute?</p><p><em><strong>Do:</strong> Create your own awesome neural network. Choose an architecture, modify the weights, and then share it with your friends by copying the URL in the address bar.</em></p><p>P.S. The <a href='https://github.com/mcrowe/neurovis' target='_blank'>source code</a> for this simulation is on github.",
          width: 400,
          target: TARGET,
          placement: "bottom",
          xOffset: centerPos.x,
          yOffset: centerPos.y,
          arrowOffset: 'center',
          showPrevButton: true
        }
      ],
      onEnd: markTourViewed,
      onClose: markTourViewed
    }

start = (nv) ->
    tour = buildTour(nv)
    if !getCookie('toured')
        hopscotch.startTour(tour)

forceStart = (nv) ->
    tour = buildTour(nv)
    hopscotch.startTour(tour, 0)

module.exports = {start, forceStart}