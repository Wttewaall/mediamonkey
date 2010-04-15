package nl.mediamonkey.zinc {
	
	import flash.system.Capabilities;
	
	import mdm.Application;
	import mdm.Dialogs;
	import mdm.FileSystem;
	import mdm.Process;
	import mdm.System;
	
	public class ZincFileManager {
		
		/**	
		 *	Set this to the path of your copy2.exe, relative to the main app.
		 *	Use forward slashes for directories, regardless of which OS you're on.
		 */
		
		public static var pathToCopyUtil:String = 'assets/utils/Copy2.exe';
		
		/**
		*	Arguments are as follows
		*	
		*	1) 	Path to the file, relative to the main app
		*		Use forward slashes for directories, regardless of which OS you're on.
		*		
		*	2)	Default base filename to save as (only works on windows)
		*	
		*	3)	Extension to save as
		*	
		*	4) 	Filter list for saving
		*	
		*  Usage:
		*  saveFile('nestedFolder/Images/SomeImage.png', 'SomeImage', 'png', 'PNG Image Files|*.png');
		*/
		
		public static function saveFile(pathToFile:String, baseName:String, extension:String, filterList:String):void {
			var titleWindow:String = "Please give the file a name, select a destination folder, and click 'save'";;
			var os:String = Capabilities.os.toLowerCase().substr(0, 3);
			var appLine:String; 
			var myFile:String;
			var myFolder:String;
			
			pathToFile = pathToFile.split("\\").join("/");
			pathToFile = buildRealPath(pathToFile);
			
			if(os == "win") {
				appLine = buildRealPath(pathToCopyUtil) + ' /f ' + pathToFile + ' /m ' + ' /c ' + titleWindow;
				mdm.Process.create(titleWindow, 0,0,320,240,"",appLine,mdm.Application.path,3,4);
			}
			else {
				if(os == "mac") {
					myFile = mdm.Dialogs.BrowseFileToSave.show();
					if(myFile && myFile != 'false') {
						mdm.FileSystem.copyFile(pathToFile, myFile);
					}
				} else {
					mdm.Dialogs.BrowseFile.filterList = filterList;
					mdm.Dialogs.BrowseFile.buttonText = "Save";
					mdm.Dialogs.BrowseFile.title = titleWindow;
					mdm.Dialogs.BrowseFile.defaultExtension = extension;
					mdm.Dialogs.BrowseFile.defaultFilename = baseName;
					mdm.Dialogs.BrowseFile.defaultDirectory = (mdm.System.Paths.desktop) ? mdm.System.Paths.desktop : '~/';
					
					myFile = mdm.Dialogs.BrowseFile.show();
					if(myFile && myFile != 'false') {
						mdm.FileSystem.copyFile(pathToFile, myFile);
					}
				}
			}			
		}
		
		private static function buildRealPath(aPath:String):String {
			if (!mdm.Application.path || mdm.Application.path == '') {
				return aPath;
			} else {
				aPath = mdm.Application.path + fixPath(aPath, Capabilities.os.toLowerCase().substr(0, 3));
				return(aPath);
    		}
		}
		
		private static function fixPath(aPath:String, os:String):String {
			if(os == "win") {
				return(aPath.split("/").join("\\"));
			} else if(os == "mac") {
				return(aPath.split("/").join(":"));
			} else {
				return(aPath);
			}
		}
		
	}
}