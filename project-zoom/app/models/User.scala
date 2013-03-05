package models

import reactivemongo.bson.BSONDocument
import reactivemongo.bson.BSONString
import reactivemongo.bson.BSONWriter
import securesocial.core._
import reactivemongo.bson.BSONArray
import reactivemongo.bson.BSONInteger
import play.modules.reactivemongo.MongoJSONHelpers
import play.modules.reactivemongo.Implicits
import reactivemongo.bson.BSONHandler
import reactivemongo.bson.BSONHandler
import play.api.libs.json._
import play.api.libs.json.util._
import play.api.libs.json.Reads._
import play.api.libs.functional.syntax._

case class User(
    id: UserId,
    firstName: String,
    lastName: String,
    email: Option[String],
    authMethod: AuthenticationMethod,
    oAuth1Info: Option[OAuth1Info],
    oAuth2Info: Option[OAuth2Info],
    passwordInfo: Option[PasswordInfo],
    roles: List[String]) extends Identity {
  val fullName: String = s"$firstName $lastName"
  val avatarUrl = None
}

object User extends MongoDAO[User] {
  override def collection = db("users")

  def findByEmail(email: String) = findHeadOption("email", email)

  def findByAccessToken(accessToken: String) = findHeadOption("accessToken", accessToken)

  def findByUserId(userId: UserId) = {
    collection.find(BSONDocument(
      "id" -> BSONString(userId.id),
      "provider" -> BSONString(userId.providerId))).one
  }

  def findByEmailAndProvider(email: String, provider: String) = {
    collection.find(BSONDocument(
      "email" -> BSONString(email),
      "provider" -> BSONString(provider))).one
  }

  def fromIdentity(i: Identity): User = {
    User(i.id, i.firstName, i.lastName, i.email, i.authMethod, i.oAuth1Info, i.oAuth2Info, i.passwordInfo, Nil)
  }

  implicit val AuthenticationMethodFormat: Format[AuthenticationMethod] = {
    val r = ((__).read[String]).map(AuthenticationMethod.apply)
    val w = Writes.apply[AuthenticationMethod](a => JsString(a.method))
    Format.apply(r, w)
  }

  implicit val OAuth1InfoFormat: Format[OAuth1Info] = (
    (__ \ 'token).format[String] and
    (__ \ 'secret).format[String])(OAuth1Info.apply, unlift(OAuth1Info.unapply))

  implicit val OAuth2InfoFormat: Format[OAuth2Info] = (
    (__ \ 'accessToken).format[String] and
    (__ \ 'tokenType).formatNullable[String] and
    (__ \ 'expiresIn).formatNullable[Int] and
    (__ \ 'refreshToken).formatNullable[String])(OAuth2Info.apply, unlift(OAuth2Info.unapply))

  implicit val PasswordInfoFormat: Format[PasswordInfo] = (
    (__ \ 'hasher).format[String] and
    (__ \ 'password).format[String] and
    (__ \ 'salt).formatNullable[String])(PasswordInfo.apply, unlift(PasswordInfo.unapply))

  implicit val UserIdFormat: Format[UserId] = (
    (__ \ 'id).format[String] and
    (__ \ 'providerId).format[String])(UserId.apply, unlift(UserId.unapply))

  val userFormat = (
    (__ \ 'userId).format[UserId] and
    (__ \ 'firstName).format[String] and
    (__ \ 'lastName).format[String] and
    (__ \ 'email).formatOpt[String] and
    (__ \ 'authMethod).format[AuthenticationMethod] and
    (__ \ 'oAuth1Info).formatNullable[OAuth1Info] and
    (__ \ 'oAuth2Info).formatNullable[OAuth2Info] and
    (__ \ 'passwordInfo).formatNullable[PasswordInfo] and
    (__ \ 'roles).format(list[String]))(User.apply _, unlift(User.unapply))

  /*val userWrites = (
    (__ \ 'id).writes[String] and
    (__ \ 'firstName).writes[String] and
    (__ \ 'lastName).writes[String] and
    (__ \ 'email).writes(optional[String]) and
    (__ \ 'authMethod).writes[AuthenticationMethod] and
    (__ \ 'oAuth1Info).writes(optional[OAuth1Info]) and
    (__ \ 'oAuth2Info).writes(optional[OAuth2Info]) and
    (__ \ 'passwordInfo).writes(optional[PasswordInfo]) and
    (__ \ 'roles).writes(list[String]))(User.unapply)*/

  implicit object handler extends BSONDocumentHandler[User] {
    def read(doc: BSONDocument): User =
      userFormat.reads(MongoJSONHelpers.toJSON(doc)).get

    def write(u: User): BSONDocument =
      Implicits.JsObjectWriter.write(userFormat.writes(u))
  }
}
