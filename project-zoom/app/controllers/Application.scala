package controllers

import play.api._
import play.api.mvc._


object Application extends Controller {
  /**
   * There currently is a bug in play 2.1, the routes file in conf/routes
   * must at least contain one route. Fixed in 2.2
   */
  def index = Action {
    Ok("Your new application is ready.")
  }
  
}