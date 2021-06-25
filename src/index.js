'use strict';

const { Elm } = require('./Main.elm');

Elm.Main.init({
  node: document.getElementById('app'),
  flags: process.env.FOREM_API_KEY
});
