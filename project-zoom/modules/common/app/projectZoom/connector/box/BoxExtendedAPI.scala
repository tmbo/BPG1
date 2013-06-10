package projectZoom.connector.box

import api._
import scala.concurrent._
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global
import play.api.libs.json._
import play.api.Logger

import akka.agent._
import projectZoom.util.PlayActorSystem
import akka.util.Timeout
import scala.concurrent._
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global


class BoxExtendedAPI(appKeys: BoxAppKeyPair) extends BoxAPI(appKeys) with PlayActorSystem {
  type FolderId=String
  
  implicit val timeout = Timeout(5 seconds)
  val collaborations = Agent[Map[FolderId, List[BoxMiniUser]]](Map())
  
  def enumerateEvents(streamPos: Long = 0)(implicit accessTokens: BoxAccessTokens) = {
    def loop(stream_position: Long, accumulatedEvents: JsArray): Future[(Long, Future[JsArray])] = {
      Logger.debug(s"fetching events at stream pos $stream_position")
      fetchEvents(stream_position).flatMap { json =>
        val chunkSize = (json \ "chunk_size").as[Int]
        val nextStreamPos = (json \ "next_stream_position").as[Long]
        Logger.debug(s"fetched $chunkSize events")
        if (chunkSize == 0)
          Future((nextStreamPos, Future(accumulatedEvents)))
        else
          loop(nextStreamPos, accumulatedEvents ++ (json \ "entries").as[JsArray])
      }
    }
    loop(streamPos, JsArray())
  }
  
  def fetchCollaborators(file: BoxFile)(implicit accessTokens: BoxAccessTokens): Option[List[BoxMiniUser]] = 
    collaborations().get(file.parent.id)
  
  def fetchCollaborators(folder: BoxBaseFolder)(implicit accessTokens: BoxAccessTokens): Option[List[BoxMiniUser]] = 
    collaborations().get(folder.id)
    
  def buildCollaboratorCache(events: List[BoxEvent])(implicit accessTokens: BoxAccessTokens) = {
    val folderIds = events.map{event => 
      event.source match {
        case Some(file: BoxFile) => file.parent.id
        case Some(folder: BoxFolder) => folder.id
      }
    }.distinct
    
    Future.traverse(folderIds)(fId => fetchCollaboratorsList(fId)).map{ collaboratorsListOpts =>
      folderIds.zip(collaboratorsListOpts).foreach{p => 
        p._2.foreach{collaborators =>
          collaborations.send(_ + (p._1 -> collaborators))
        }
      }
    }
  }
    
  private def fetchCollaboratorsList(folderId: FolderId)(implicit accessTokens: BoxAccessTokens): Future[Option[List[BoxMiniUser]]] = {
    fetchFolderCollaborations(folderId).map{ json =>
      (json \ "entries").validate[List[BoxCollaboration]] match {
        case JsSuccess(collaborationList, _) => 
          val collaborators = collaborationList.flatMap(c => c.accessible_by) 
          Some(collaborators)
        case JsError(err) => Logger.error(s"Error fetching collaborations:\n ${err.mkString}\njson:\n${Json.stringify(json)}")
        None
      }
    }
  }
}