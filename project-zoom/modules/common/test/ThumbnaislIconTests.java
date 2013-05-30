
import static org.junit.Assert.*;

import java.io.File;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import projectZoom.thumbnails.*;
import projectZoom.thumbnails.all.AllThumbnailPlugin;

import models.ResourceInfo;

public class ThumbnaislIconTests {

	String folder = "/home/user/testfiles/";
	String tempFolder = "/home/user/";
	
	@Before
	public void setUp() throws Exception {
	}
	
		
	@Test
	public void onRessourceFoundDocxTest() {
		String filename = folder + "test.docx";
		AllThumbnailPlugin iconPlugin = new AllThumbnailPlugin();
		ResourceInfo res = new ResourceInfo(filename, "default"); 
		File file = new File(filename);
		List<TempFile> tempFiles = iconPlugin.onResourceFound(file, res);
		assertTrue(tempFiles.size() == 1);	
	}

	@Test
	public void onRessourceFoundUndefinedTest() {
		String filename = folder + "test.undefined";
		AllThumbnailPlugin iconPlugin = new AllThumbnailPlugin();
		ResourceInfo res = new ResourceInfo(filename, "default"); 
		File file = new File(filename);
		List<TempFile> tempFiles = iconPlugin.onResourceFound(file, res);
		assertTrue(tempFiles.size() == 1);		
	}
}
