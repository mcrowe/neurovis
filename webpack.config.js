module.exports = {
    entry: {
      priority: './src/priority.js',
      app: './src/app.js'
    },
    output: {
        path: './dist',
        filename: '[name].bundle.js'
    },
    module: {
        loaders: [
            { test: /\.coffee$/, loader: 'coffee-loader' },
            { test: /\.css$/, loader: 'style!css' },
            { test: /\.less$/, loader: 'style!css!less' },
            { test: /\.png$/, loader: "url-loader?limit=100000" },
        ]
    }, resolve: {
      extensions: ['', '.less', '.coffee']
  }
};