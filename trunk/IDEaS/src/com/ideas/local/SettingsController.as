package com.ideas.local
{
	import com.ideas.data.DataHolder;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;

	public class SettingsController
	{
		private var userSettings:UserSettings = new UserSettings();
		public function SettingsController()
		{
			userSettings.addEventListener(UserSettings.WRITE_DONE, onUserSettingsSaved);
			userSettings.addEventListener(UserSettings.WRITE_ERROR, onUserSettingsError);
			
		}
		public function initUserData():void {
			var data:Object = userSettings.retrieveData();
			if (data) {
				if (data.fontSise != undefined && (data.fontSise >= 8 && data.fontSise <= 30)) {
					DataHolder.fontSize = data.fontSise;
				}
				if (data.backgroundColor != undefined && (data.backgroundColor >= 0 && data.backgroundColor <= 0xffffff)) {
					DataHolder.backgroundColor = data.backgroundColor;
				}
				if (data.displayState != undefined) {
					if (data.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
						DataHolder.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					} else if (data.displayState == StageDisplayState.NORMAL) {
						DataHolder.displayState = StageDisplayState.NORMAL;
					}
				}
				if (data.swfWidth != undefined && (data.swfWidth >= 10 && data.swfWidth <= 2880)) {
					DataHolder.swfWidth = data.swfWidth;
				}
				if (data.swfHeight != undefined && (data.swfHeight >= 10 && data.swfHeight <= 2880)) {
					DataHolder.swfHeight = data.swfHeight;
				}
				if (data.htmlWidth != undefined && (data.htmlWidth >= 10 && data.htmlWidth <= 2880)) {
					DataHolder.htmlWidth = data.htmlWidth;
				}
				if (data.htmlHeight != undefined && (data.htmlHeight >= 10 && data.htmlHeight <= 2880)) {
					DataHolder.htmlHeight = data.htmlHeight;
				}
				if (data.htmlStage != undefined) {
					DataHolder.htmlStage = DataHolder.STAGE_OPTIONS[DataHolder.getStagePos(data.htmlStage)];
					trace(DataHolder.htmlStage)
				}
				if (data.htmlSizeType != undefined) {
					if (data.htmlSizeType == "%") {
						DataHolder.htmlSizeType = "%";
					} else {
						DataHolder.htmlSizeType = "px";
					}
				}
				if(data.recentFiles != undefined && data.recentFiles.length>0){
					
					DataHolder.recentFiles=data.recentFiles;
				}
				
			}
		}
		public function saveUserSettings():void {
			userSettings.init({ htmlSizeType: DataHolder.htmlSizeType, htmlStage: DataHolder.htmlStage, swfHeight: DataHolder.swfHeight, swfWidth: DataHolder.swfWidth, htmlHeight: DataHolder.htmlHeight, htmlWidth: DataHolder.htmlWidth, fontSise: DataHolder.fontSize, backgroundColor: DataHolder.backgroundColor, displayState: DataHolder.displayState ,recentFiles:DataHolder.recentFiles});
			
		}
		private function onUserSettingsError(e:Event):void {
		}
		private function onUserSettingsSaved(e:Event):void {
		}
	}
}