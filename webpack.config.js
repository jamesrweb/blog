const { resolve } = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const env = require('dotenv').config();

const { ENV } = process.env;

const outputDirectory = resolve(__dirname, 'dist');

const isProduction = ENV === 'production';

const elmLoader = {
  loader: 'elm-webpack-loader',
  options: {
    debug: false,
    optimize: isProduction,
    cwd: __dirname
  }
};

const loaders = isProduction
  ? elmLoader
  : [{ loader: 'elm-hot-webpack-loader' }, elmLoader];

module.exports = {
  mode: isProduction ? 'production' : 'development',
  entry: './src/index.js',
  devServer: {
    static: {
      directory: outputDirectory
    },
    port: 8000,
    devMiddleware: {
      publicPath: '/'
    },
    hot: 'only'
  },
  output: {
    publicPath: '/',
    path: outputDirectory,
    filename: '[name].[contenthash].bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: loaders
      }
    ]
  },
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
    new HtmlWebpackPlugin({
      author: 'James Robb',
      title: 'James Robb | Blog'
    }),
    new webpack.DefinePlugin({
      'process.env': JSON.stringify(env.parsed)
    })
  ]
};
