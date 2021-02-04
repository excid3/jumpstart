// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

window.Rails = require("@rails/ujs")
require("@hotwired/turbo-rails")
require("@rails/activestorage").start()
require("channels")
require("trix")
require("@rails/actiontext")
require("local-time").start()

// Start Rails UJS
Rails.start()

// Stimulus
import "controllers"

// Bootstrap
import 'bootstrap'
import 'data-confirm-modal'

$(document).on("turbo:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
})
