package projectZoom.thumbnails.all;


import java.io.File;
import java.util.ArrayList;
import java.util.List;

import projectZoom.thumbnails.TempFile;
import projectZoom.thumbnails.ThumbnailPlugin;

import models.DefaultResourceTypes;
import models.ResourceLike;


public class AllThumbnailPlugin extends ThumbnailPlugin {
	
	static String ICON_FOLDER = "public/icons/";
	static String ALT_ICON_FOLDER = "modules/common/public/icons/";
	static String DEFAULT_ICON = "unknown";
	static int RESOLUTION = 32;
	static String SUFFIX = ".png";

	
	public AllThumbnailPlugin() {

	}
	
	public List<TempFile> onResourceFound(File file, ResourceLike resource) {
		
		System.out.println("All onResourceFound called ");
		String fn = resource.name();
		String ext = fn.substring(fn.lastIndexOf(".") + 1);

		String url = ICON_FOLDER + ext + ".png";
		System.out.println(ext);
		
		List<TempFile> output = new ArrayList<TempFile>();
		
		File f = new File(url);
		if(f.exists()) { 
			TempFile tempFile = new TempFile(
					String.valueOf(RESOLUTION) + SUFFIX, 
					DefaultResourceTypes.PRIMARY_THUMBNAIL());
			tempFile.copyToTempByFileName(url);
			output.add(tempFile);
			return output;
		 }

		String altUrl = ALT_ICON_FOLDER + ext + ".png";
		f = new File(altUrl);
		if(f.exists()) {
			TempFile tempFile = new TempFile(
					String.valueOf(RESOLUTION) + SUFFIX, 
					DefaultResourceTypes.PRIMARY_THUMBNAIL());
			tempFile.copyToTempByFileName(altUrl);
			output.add(tempFile);
			return output;
		}

		String urlDefault = ICON_FOLDER + DEFAULT_ICON + ".png";
		f = new File(urlDefault);
		if(f.exists()) {
			TempFile tempFile = new TempFile(
					String.valueOf(RESOLUTION) + SUFFIX, 
					DefaultResourceTypes.PRIMARY_THUMBNAIL());
			tempFile.copyToTempByFileName(urlDefault);
			output.add(tempFile);
			return output;
		}
		
		String altUrlDefault = ALT_ICON_FOLDER + DEFAULT_ICON + ".png";
		f = new File(altUrlDefault);
		if(f.exists()) {
			TempFile tempFile = new TempFile(
					String.valueOf(RESOLUTION) + SUFFIX, 
					DefaultResourceTypes.PRIMARY_THUMBNAIL());
			tempFile.copyToTempByFileName(altUrlDefault);
			output.add(tempFile);
			return output;
		} 
		
		return output;
	}
	
}
