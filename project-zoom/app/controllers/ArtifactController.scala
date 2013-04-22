package controllers

import securesocial.core.SecureSocial
import models.ArtifactDAO
import play.api.libs.json.Json
import projectZoom.util.PlayActorSystem
import projectZoom.core.artifact.ArtifactActor
import akka.pattern.ask
import projectZoom.core.artifact.RequestResource
import models.ArtifactInfo
import models.ResourceInfo
import models.ArtifactDAO._
import play.api.libs.concurrent.Execution.Implicits._
import models.ProjectDAO
import projectZoom.util.PlayConfig
import projectZoom.util.ExtendedTypes.ExtendedFuture
import akka.util.Timeout
import scala.concurrent.duration._
import java.io.InputStream
import play.api.libs.iteratee.Enumerator
import akka.pattern.AskTimeoutException
import scala.concurrent.Future

object ArtifactController extends ControllerBase with JsonCRUDController with PlayActorSystem with PlayConfig {

  lazy val artifactActor = userActorFor(ArtifactActor.name)

  implicit val timeout = Timeout(config.getInt("artifact.timeout").getOrElse(5) seconds)

  val dao = ArtifactDAO

  def index = SecuredAction { implicit request =>
    Ok(views.html.index())
  }

  def listForProject(project: String, offset: Int, limit: Int) = SecuredAction { implicit request =>
    //TODO: restrict access
    Async {
      dao.findSomeForProject(project, offset, limit).map { l =>
        Ok(withPortionInfo(Json.toJson(l), offset, limit))
      }
    }
  }

  def download(_project: String, artifactId: String, resourceType: String) = SecuredAction { implicit request =>
    Async {
      (for {
        project <- ProjectDAO.findOneByName(_project)
        artifact <- ArtifactDAO.findOneById(artifactId)
      } yield {
        artifact.flatMap(a => (a \ "resources" \ resourceType).asOpt[ResourceInfo]) match {
          case Some(resource) =>
            val r: Future[play.api.mvc.Result] = (artifactActor ? RequestResource(_project, resource))
              .mapTo[Option[InputStream]]
              .map {
                case Some(stream) =>
                  Ok.feed(Enumerator.fromStream(stream))
                case _ =>
                  NotFound
              }
              .recover {
                case a: AskTimeoutException =>
                  NotFound
              }
            r
          case _ =>
            Future.successful(NotFound)
        }
      }).flatten
    }
  }
}