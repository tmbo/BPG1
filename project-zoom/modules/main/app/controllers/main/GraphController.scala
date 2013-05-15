package controllers.main
import projectZoom.util.ExtendedTypes.ExtendedJsObject
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.JsError
import models.GraphDAO
import models.Graph
import projectZoom.core.event._
import play.api.libs.json.JsValue
import models.GraphTransformers
import models.Implicits._
import controllers.common.ControllerBase

case class GraphUpdated(graph: Graph, patch: JsValue) extends Event

object GraphController extends ControllerBase with JsonCRUDController with EventPublisher with GraphTransformers {
  val dao = GraphDAO
  
  def patch(graphId: String) = SecuredAction(true, None, parse.json) { implicit request =>
    Async {
      val patch = request.body
      GraphDAO.findOneById(graphId).map {
        case Some(graph) =>
          (graph patchWith patch)
            .flatMap(graphFormat.reads)
            .map { updatedGraph =>
              GraphDAO.insert(updatedGraph).map { _ =>
                publish(GraphUpdated(updatedGraph, patch))
              }
              Ok
            }
            .recoverTotal {
              case e: JsError =>
                BadRequest(e.toString)
            }
        case _ =>
          NotFound
      }
    }
  }
}