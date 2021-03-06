package projectZoom.connector.box

import play.api.libs.json._
import play.api.libs.ws._
import scala.concurrent._
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._
import play.api.Logger
import scala.util.{ Try, Success, Failure }
import play.api.libs.iteratee.Iteratee

class BoxAPI {

  val pickEntries = (__ \ 'entries).json.pick[JsArray]

  val apiURL = "https://api.box.com/2.0"

  def authHeader(implicit accessTokens: BoxAccessTokens) = ("Authorization" -> s"Bearer ${accessTokens.access_token}")

  private def jsonAPI(url: String)(implicit accessTokens: BoxAccessTokens): JsValue = {
    Logger.debug(s"calling jsonAPI on url $url")
    Await.result(WS.url(url)
      .withHeaders(authHeader)
      .get
      .map(response => Json.parse(response.body)), 30 seconds)
  }

  def fetchFolderInfo(folderId: String)(implicit accessTokens: BoxAccessTokens): JsValue = {
    jsonAPI(s"$apiURL/folders/$folderId")
  }
  
  def fetchFolderCollaborations(folderId: String)(implicit accessTokens: BoxAccessTokens): JsValue = {
    jsonAPI(s"$apiURL/folders/$folderId/collaborations")
  }

  def fetchFolderContent(folderId: String,
    offset: Int = 0,
    fields: List[String] = Nil,
    limit: Int = 1000)(implicit accessTokens: BoxAccessTokens): JsValue = {
    jsonAPI(s"$apiURL/folders/$folderId/items?offset=$offset&fields=${fields.mkString(",")}&limit=$limit")
  }

  def fetchFileInfo(fileId: String)(implicit accessTokens: BoxAccessTokens) = {
    jsonAPI(s"$apiURL/files/$fileId")
  }

  def fetchEvents(stream_position: Long = 0, limit: Int = 1000)(implicit accessTokens: BoxAccessTokens) = {
    jsonAPI(s"$apiURL/events?stream_position=$stream_position&limit=$limit")
  }

  def downloadFile(fileId: String)(implicit accessTokens: BoxAccessTokens) = {
    Logger.debug(s"downloading file with Id $fileId")
    WS.url(s"$apiURL/files/$fileId/content")
      .withHeaders(authHeader)
      .get(status => Iteratee.consume[Array[Byte]]())
      .flatMap(i => i.run)
  }
}