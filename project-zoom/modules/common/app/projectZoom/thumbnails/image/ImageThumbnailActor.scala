package projectZoom.thumbnails.image

import play.api.Logger
import projectZoom.core.event._
import projectZoom.util.StartableActor
import projectZoom.core.artifact._
import projectZoom.thumbnails._
import models.ArtifactInfo
import models.ResourceInfo
import models.DefaultResourceTypes
import java.io.File
import scala.collection.JavaConversions._

class ImageThumbnailActor extends ThumbnailActor {
  
  lazy val thumbnailPlugin = new ImageThumbnailPlugin()

  override def handleResourceUpdate(resource: File, artifactInfo: ArtifactInfo, resourceInfo: ResourceInfo) {
    if (resourceInfo.typ == DefaultResourceTypes.DEFAULT_TYP) {
      
      val tempFiles = thumbnailPlugin.onResourceFound(resource, resourceInfo)
      tempFiles.map { tempFile =>
        val iconResource = ResourceInfo(
        name = tempFile.getName(),
        typ = tempFile.getType())
        publish(ResourceFound(tempFile.getStream(), artifactInfo, iconResource))
      }
    }
  }
}

object ImageThumbnailActor extends StartableActor[ImageThumbnailActor]{
  
  def name = "imageThumbnailActor"    
}