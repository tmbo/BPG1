package projectZoom.thumbnails.video

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

class VideoThumbnailActor extends ThumbnailActor {
  
  lazy val thumbnailPlugin = new VideoThumbnailPlugin()

  def handleResourceUpdate(resource: File, artifactInfo: ArtifactInfo, resourceInfo: ResourceInfo) {
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

object VideoThumbnailActor extends StartableActor[VideoThumbnailActor]{
  
  def name = "videoThumbnailActor"    
}