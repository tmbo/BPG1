package models

import play.api.libs.json.Json
import play.api.libs.json.JsObject
import reactivemongo.bson.BSONObjectID
import play.api.libs.json.Format

trait ResourceLike {
  def name: String
  def typ: String
  
  def isSameAs(o: ResourceLike) = 
    name == o.name && typ == o.typ
}

case class ResourceInfo(name: String, typ: String)
  extends ResourceLike

case class Resource(name: String, hash: String, typ: String)
  extends ResourceLike
  
trait DefaultResourceTypes {
  val DEFAULT_TYP = "default"
}
object DefaultResourceTypes extends DefaultResourceTypes

trait ResourceHelpers {
  implicit val resourceFormat: Format[Resource] = Json.format[Resource]

  implicit val resourceInfoFormat: Format[ResourceInfo] = Json.format[ResourceInfo]

  def resourceCreateFrom(ri: ResourceInfo, hash: String) =
    Resource(
      ri.name,
      hash,
      ri.typ)
}