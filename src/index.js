"use strict";

const { Elm } = require("./Main.elm");

Elm.Main.init({
  node: document.getElementById("app"),
  flags: process.env.SUPABASE_API_KEY
});