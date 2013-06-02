package projectZoom.connector.box.api

import play.api.libs.json._
import play.api.libs.functional.syntax._

trait BoxBaseFolder{
  val id: String
}

case class BoxMiniFolder(id: String, sequence_id: Option[String], name: String) extends BoxMiniSource with BoxBaseFolder

object BoxMiniFolder extends Function3[String, Option[String], String, BoxMiniFolder]{
  implicit val BoxMiniFolderAsSourceReads: Reads[BoxMiniSource] = (
      (__ \ "id").read[String] and
      (__ \ "sequence_id").readNullable[String] and 
      (__ \ "name").read[String])(BoxMiniFolder.apply _)
  
  implicit val BoxMiniFolderReads: Reads[BoxMiniFolder] = Json.reads[BoxMiniFolder]
}   

case class BoxFolder( 
    id: String,
    sequence_id: Option[String],
    etag: Option[String],
    name: String,
    created_at: String,
    modified_at: String,
    description: String,
    size: Int,
    path_collection: BoxPathCollection,
    created_by: BoxMiniUser,
    modified_by: BoxMiniUser,
    owned_by: BoxMiniUser,
    parent: BoxMiniFolder,
    item_status: String,
    item_collection: List[BoxMiniSource],
    synced: Boolean) extends BoxSource with BoxBaseFolder

object BoxFolder extends Function16[String, Option[String], Option[String], String, String, String, String, Int, BoxPathCollection, BoxMiniUser, BoxMiniUser, BoxMiniUser, BoxMiniFolder, String, List[BoxMiniSource], Boolean, BoxFolder]{
  val BoxFolderAsSourceReads: Reads[BoxSource] = 
    ((__ \ "id").read[String] and
    (__ \ "sequence_id").readNullable[String] and
    (__ \ "etag").readNullable[String] and
    (__ \ "name").read[String] and
    (__ \ "created_at").read[String] and
    (__ \ "modified_at").read[String] and
    (__ \ "description").read[String] and
    (__ \ "size").read[Int] and
    (__ \ "path_collection").read[BoxPathCollection] and
    (__ \ "created_by").read[BoxMiniUser] and
    (__ \ "modified_by").read[BoxMiniUser] and
    (__ \ "owned_by").read[BoxMiniUser] and
    (__ \ "parent").read[BoxMiniFolder] and
    (__ \ "item_status").read[String] and
    (__ \ "item_collection").read[List[BoxMiniSource]] and
    (__ \ "synced").read[Boolean])(BoxFolder.apply _)
}