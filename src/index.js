"use strict";

const { Elm } = require("./Main.elm");

Elm.Main.init({
  node: document.getElementById("app"),
  flags: {
      supabase_api_key: process.env.SUPABASE_API_KEY
  },
});