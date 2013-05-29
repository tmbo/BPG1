
import static org.junit.Assert.*;

import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import projectZoom.thumbnails.TempFile;
import projectZoom.thumbnails.text.TextThumbnailPlugin;

import projectZoom.thumbnails.text.TextReader;

import models.Resource;
import models.ResourceInfo;

public class ThumbnailsOfficeTests {

	String folder = "/home/user/testfiles/";
	
	@Before
	public void setUp() throws Exception {
		
	}

	@Test
	public void onRessourceFoundPptTest() {
		
		String filename = folder + "test.ppt";
		File file = new File(filename);
		TextThumbnailPlugin textThumbnailPlugin = new TextThumbnailPlugin();
		ResourceInfo res = new ResourceInfo(filename, "default"); 
		List<TempFile> arts = textThumbnailPlugin.onResourceFound(file, res);
		
		assertTrue(arts.size() == 8);	
	}	
	@Test
	public void onRessourceFoundPptxTest() {
		
		String filename = folder + "test.pptx";
		File file = new File(filename);
		TextThumbnailPlugin textThumbnailPlugin = new TextThumbnailPlugin();
		ResourceInfo res = new ResourceInfo(filename, "default"); 
		List<TempFile> arts = textThumbnailPlugin.onResourceFound(file, res);
		
		assertTrue(arts.size() == 8);	
	}	
	@Test
	public void onRessourceFoundOdpTest() {
		
		String filename = folder + "test.odp";
		File file = new File(filename);
		TextThumbnailPlugin textThumbnailPlugin = new TextThumbnailPlugin();
		ResourceInfo res = new ResourceInfo(filename, "default"); 
		List<TempFile> arts = textThumbnailPlugin.onResourceFound(file, res);
		
		assertTrue(arts.size() == 8);	
	}		
}
