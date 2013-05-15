package controllers.main

import securesocial.core.SecureSocial
import models.Implicits._
import play.api.libs.json.Json
import play.api.libs.json.Format
import models.DAO
import play.api.libs.json.JsObject
import play.api.libs.json.JsValue
import play.api.libs.json.Reads
import play.api.libs.json.Writes
import play.api.libs.concurrent.Execution.Implicits._
import projectZoom.util.MongoHelpers
import play.api.libs.json.Json.toJsFieldJsValueWrapper

trait JsonCRUDController extends CRUDController[JsObject] {
  implicit def formatter = Format.apply[JsObject](Reads.JsObjectReads, Writes.JsValueWrites)
}

trait ListPortionHelpers {
  def withPortionInfo(js: JsValue, offset: Int, limit: Int) = {
    Json.obj(
      "offset" -> offset,
      "limit" -> limit,
      "content" -> js)
  }
}

trait CRUDController[T] extends SecureSocial with ListPortionHelpers with MongoHelpers {

  def dao: DAO[T]
  implicit def formatter: Format[T]

  def list(offset: Int, limit: Int) = SecuredAction(ajaxCall = true) { implicit request =>
    //TODO: restrict access
    Async {
      dao.findSome(offset, limit).map { l =>
        Ok(withPortionInfo(Json.toJson(l.map(e => Json.toJson(e).transform(beautifyObjectId).get)), offset, limit))
      }
    }
  }

  def read(id: String) = SecuredAction(ajaxCall = true) { implicit request =>
    //TODO: restrict access
    Async {
      dao.findOneById(id).map {
        case Some(obj) =>
          Ok(Json.toJson(obj).transform(beautifyObjectId).get)
        case _ =>
          Ok(Json.obj())
      }
    }
  }
}