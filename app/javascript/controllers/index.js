// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";

// Manually import controllers that need special handling
import GeoController from "controllers/geo_controller";
application.register("geo", GeoController);

// Load all other controllers automatically
eagerLoadControllersFrom("controllers", application);
