import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

import GeoController from "/controllers/geo_controller"

const application = Application.start()
application.register("geo", GeoController)

application.debug = true
window.Stimulus = application

const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

export { application }
