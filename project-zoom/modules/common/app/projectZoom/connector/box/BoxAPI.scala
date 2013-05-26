package projectZoom.connector.box

import play.api.libs.json._
import play.api.libs.ws._
import scala.concurrent._
import scala.concurrent.ExecutionContext.Implicits.global
import play.api.Logger
import scala.util.{Try, Success, Failure}
import play.api.libs.iteratee.Iteratee

case class BoxAppKeyPair(client_id: String, client_secret: String)

class BoxAPI(appKeys: BoxAppKeyPair) {
  
  val pickEntries = (__ \ 'entries).json.pick[JsArray]
  
  val apiURL = "https//api.box/com/2.0"
  
  def authHeader(accessToken: String) = ("Authorization" -> s"Bearer $accessToken")
  
  private def accessAPI(accessToken: String, url: String): Future[JsValue] = {
    WS.url(url)
      .withHeaders(authHeader(accessToken))
      .get
      .map(response => Json.parse(response.body))
  }
  
  def folderInfo(accessToken: String, folderId: String): Future[JsValue] = {
    accessAPI(accessToken, s"$apiURL/folders/$folderId")
  }
  
  def folderContent(accessToken: String, folderId: String, offset: Int = 0, fields: List[String] = Nil, limit: Int = 1000): Future[JsValue] = {
    accessAPI(accessToken,s"$apiURL/folders/$folderId/items?offset=$offset&fields=${fields.mkString(",")}&limit=$limit")
  }
  
  def completeFolderContent(accessToken: String, folderId: String, fields: List[String]): Future[JsValue] = ???
  
  def fileInfo(accessToken: String, fileId: String) = {
    accessAPI(accessToken, (s"$apiURL/files/$fileId"))
  }
  
  def events(accessToken: String, stream_position: Long = 0) = {
    accessAPI(accessToken, (s"$apiURL/events?stream_position=$stream_position"))
  }
  
  def downloadFile(accessToken: String, fileId: String) = {
    WS.url(s"$apiURL/files/$fileId/content")
      .withHeaders(authHeader(accessToken))
      .get(status => Iteratee.consume[Array[Byte]]())
      .flatMap(i => i.run)
  }

  def enumerateEvents(accessToken: String) = {
    def loop(stream_position: Long, accumulatedEvents: JsArray): Future[JsArray] = {
      events(accessToken, stream_position).flatMap{json => 
        if((json \ "chunk_size").as[Int] == 0)
          Future(accumulatedEvents)
        else
          loop((json \ "next_stream_position").as[Long], accumulatedEvents :+ (json \ "entries"))
      }
    }
    loop(0,JsArray())
  }
  
  def getEventMap(accessToken: String) = {
    enumerateEvents(accessToken).map{jsArr =>
      jsArr.value.groupBy(event => (event \ "event_type").as[String])}
  }
  
}