package projectZoom.connector.box.api

import play.api.libs.json._

case class BoxEvent(event_id: String, event_type: String, created_by: BoxMiniUser, created_at: String, session_id: String, source: Option[BoxSource])

object BoxEvent extends Function6[String, String, BoxMiniUser, String, String, Option[BoxSource], BoxEvent]{
  implicit val BoxEventReads: Reads[BoxEvent] = Json.reads[BoxEvent]
}