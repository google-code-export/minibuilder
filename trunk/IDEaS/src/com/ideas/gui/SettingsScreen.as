package com.ideas.gui {
	import com.ideas.data.DataHolder;
	import com.ideas.data.Resources;
	import com.ideas.gui.buttons.CheckBox;
	import com.ideas.gui.buttons.GeneralButton;
	import com.ideas.gui.buttons.IconToggleButton;
	import com.ideas.gui.buttons.LineSeparator;
	import com.ideas.gui.buttons.MinusButton;
	import com.ideas.gui.buttons.NumericStepper;
	import com.ideas.gui.buttons.PlusButton;
	import com.ideas.gui.buttons.RadioButton;
	import com.ideas.gui.buttons.SwitchButton;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class SettingsScreen extends Sprite {
		private static const WIDTH:int = 430;
		private static const HEIGHT:int = 420;
		public static const SAVE_CLICKED:String = "save_clicked";
		public static const CANCEL_CLICKED:String = "cancel_clicked";
		private var _wid:int = 0;
		private var _hgt:int = 0;
		private var saveButton:GeneralButton = new GeneralButton(200, 50, "Save");
		private var cancelButton:GeneralButton = new GeneralButton(200, 50, "Cancel");
	
		private var darkButton:RadioButton = new RadioButton();
		private var lightButton:RadioButton = new RadioButton();
		//
		private var pixelButton:RadioButton = new RadioButton();
		private var percentButton:RadioButton = new RadioButton();
		//
		private var swfHeightStepper:NumericStepper = new NumericStepper(10, 2880,10);
		private var swfWidthStepper:NumericStepper = new NumericStepper(10, 2880,10);
		private var htmlHeightStepper:NumericStepper = new NumericStepper(10, 2880,10);
		private var htmlWidthStepper:NumericStepper = new NumericStepper(10, 2880,10);
		private var fontStepper:NumericStepper = new NumericStepper(8, 30);
		private var lightLabel:TextField = new TextField();
		private var darkLabel:TextField = new TextField();
		private var labelFont:TextField = new TextField();
		private var labelBg:TextField = new TextField();
		private var labelScreen:TextField = new TextField();
		//
		private var swfSizeLabel:TextField = new TextField();
		private var htmlSizeLabel:TextField = new TextField();
		//
		private var pixelLabel:TextField = new TextField();
		private var percentLabel:TextField = new TextField();
		private var stageSwitch:SwitchButton = new SwitchButton(200, 50, DataHolder.STAGE_OPTIONS)
		//
		private var fullScreen:IconToggleButton = new IconToggleButton(50, 50);
		private var lineCateg:LineSeparator = new LineSeparator();
		private var lineHtml:LineSeparator = new LineSeparator();
		private var shp:Shape = new Shape();
		public function SettingsScreen() {
			this.addChild(shp);
			addChild(labelBg);
			addChild(labelFont);
			addChild(labelScreen);
			addChild(htmlSizeLabel);
			addChild(swfSizeLabel);
			addChild(pixelLabel);
			addChild(percentLabel);
			//
			this.addChild(saveButton);
			this.addChild(cancelButton);
			this.addChild(lightButton);
			this.addChild(darkButton);
			this.addChild(lightLabel);
			this.addChild(darkLabel);
			this.addChild(lineCateg);
			this.addChild(lineHtml);
			this.addChild(fullScreen);
			//
			this.addChild(fontStepper);
			//
			this.addChild(swfHeightStepper)
			this.addChild(swfWidthStepper)
			this.addChild(htmlHeightStepper)
			this.addChild(htmlWidthStepper)
			this.addChild(pixelButton);
			this.addChild(percentButton);
			this.addChild(stageSwitch);
			//
			fullScreen.setEnableImage(new Resources.MinimizeIcon());
			fullScreen.setDisableImage(new Resources.MaximizeIcon());
			labelFont.width = WIDTH;
			labelBg.width = WIDTH;
			labelScreen.width = WIDTH;
			htmlSizeLabel.width = WIDTH / 2;
			swfSizeLabel.width = WIDTH / 2;
			labelFont.selectable = false;
			labelBg.selectable = false;
			labelScreen.selectable = false;
			htmlSizeLabel.selectable = false;
			swfSizeLabel.selectable = false;
			percentLabel.selectable = false;
			pixelLabel.selectable = false;
			htmlSizeLabel.defaultTextFormat = swfSizeLabel.defaultTextFormat = new TextFormat("_sans", 30, 0xffffff, false, null, null, null, null, "center");
			percentLabel.defaultTextFormat = pixelLabel.defaultTextFormat = labelScreen.defaultTextFormat = this.labelBg.defaultTextFormat = this.labelFont.defaultTextFormat = new TextFormat("_sans", 24, 0xffffff, false, null, null, null, null, "left");
			labelFont.text = "Font";
			labelBg.text = "Background:";
			labelScreen.text = "Screen"
			htmlSizeLabel.text = "HTML Size";
			swfSizeLabel.text = "SWF Size";
			pixelLabel.text = "px"
			percentLabel.text = "perc"
			lightButton.enable = true;
			lightLabel.selectable = darkLabel.selectable = false;
			lightLabel.width = darkLabel.width = 60;
			lightLabel.height = darkLabel.height = 34;
			lightLabel.defaultTextFormat = darkLabel.defaultTextFormat = new TextFormat("_sans", 24, 0xffffff);
			lightLabel.text = "Light";
			darkLabel.text = "Dark"
			this.saveButton.addEventListener(MouseEvent.CLICK, onSaveClick);
			this.cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			//
			this.lightButton.addEventListener(MouseEvent.CLICK, onRadioClick);
			this.darkButton.addEventListener(MouseEvent.CLICK, onRadioClick);
			//
			this.percentButton.addEventListener(MouseEvent.CLICK, onUnitsClick);
			this.pixelButton.addEventListener(MouseEvent.CLICK, onUnitsClick);
			//
			this.fullScreen.addEventListener(MouseEvent.CLICK, onFullScreenClick);
			stageSwitch.addEventListener(MouseEvent.CLICK, onStageSwitchClick);
			this.addEventListener(Event.ADDED, onAdded);
		}
		private function onAdded(e:Event):void {
			darkButton.enable = Boolean(DataHolder.backgroundColor == 0);
			lightButton.enable = !darkButton.enable;
			fontStepper.setValue(DataHolder.fontSize);
			swfWidthStepper.setValue(DataHolder.swfWidth);
			swfHeightStepper.setValue(DataHolder.swfHeight);
			htmlWidthStepper.setValue(DataHolder.htmlWidth);
			htmlHeightStepper.setValue(DataHolder.htmlHeight);
			stageSwitch.counter = DataHolder.getStagePos(DataHolder.htmlStage);
			fullScreen.enable = Boolean(DataHolder.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE);
			//
			percentButton.enable = Boolean(DataHolder.htmlSizeType == "%");
			pixelButton.enable = !percentButton.enable;
			//
		}
		private function onStageSwitchClick(e:MouseEvent):void {
			stageSwitch.counter++;
		}
		private function onFullScreenClick(e:MouseEvent):void {
			fullScreen.enable = !fullScreen.enable;
		}
		private function onUnitsClick(e:MouseEvent):void {
			percentButton.enable = !percentButton.enable;
			pixelButton.enable = !pixelButton.enable;
		}
		private function onRadioClick(e:MouseEvent):void {
			darkButton.enable = !darkButton.enable;
			lightButton.enable = !lightButton.enable;
		}
		public function resize(wid:int, hgt:int):void {
			_wid = wid;
			_hgt = hgt;
			redraw();
		}
		
		private function onSaveClick(e:MouseEvent):void {
			DataHolder.backgroundColor = darkButton.enable ? 0 : 0xffffff;
			DataHolder.fontSize = this.fontStepper.getValue();
			DataHolder.displayState = fullScreen.enable ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
			//
			DataHolder.htmlStage = stageSwitch.getValue().value;
			DataHolder.swfWidth = swfWidthStepper.getValue();
			DataHolder.swfHeight = swfHeightStepper.getValue();
			DataHolder.htmlWidth = htmlWidthStepper.getValue();
			DataHolder.htmlHeight = htmlHeightStepper.getValue();
			DataHolder.htmlSizeType = percentButton.enable ? "%" : "px"
			//
			this.dispatchEvent(new Event(SAVE_CLICKED));
		}
		private function onCancelClick(e:MouseEvent):void {
			this.dispatchEvent(new Event(CANCEL_CLICKED));
		}
		private function redraw():void {
			labelBg.x = (_wid - WIDTH) / 2 + 10;
			//
			//
			fullScreen.x = (_wid - WIDTH) / 2 + 10;
			fullScreen.y = (_hgt - HEIGHT) / 2 + 10;
			labelScreen.x = fullScreen.x + fullScreen.width + 5;
			labelScreen.y = fullScreen.y + 8;
			labelFont.y = labelScreen.y
			//
			fontStepper.y = fullScreen.y;
			fontStepper.x = labelScreen.x + labelScreen.textWidth + 10;
			//
			labelFont.x = fontStepper.x + fontStepper.width + 5;
			//
			saveButton.x = (_wid - WIDTH) / 2 + 10;
			cancelButton.x = (_wid + WIDTH) / 2 - cancelButton.width - 10;
			saveButton.y = cancelButton.y = _hgt / 2 + HEIGHT / 2 - saveButton.height - 10;
			darkButton.y = lightButton.y = fullScreen.y + fullScreen.height + 10 + RadioButton.SIZE / 2;
			lineCateg.x = (_wid - WIDTH) / 2 + 10;
			lineCateg.draw(WIDTH - 10 - 10, 0);
			lineCateg.y = darkButton.y + RadioButton.SIZE / 2 + 10;
			lineHtml.draw(0, 150);
			lineHtml.x = (_wid) / 2;
			lineHtml.y = lineCateg.y + 10;
			//
			darkLabel.x = (_wid + WIDTH) / 2 - darkLabel.textWidth - 10;
			darkButton.x = darkLabel.x - RadioButton.SIZE / 2 - 10;
			lightLabel.x = darkButton.x - lightLabel.textWidth - RadioButton.SIZE / 2 - 10;
			lightButton.x = lightLabel.x - RadioButton.SIZE / 2 - 10;
			labelBg.y = lightLabel.y = darkLabel.y = darkButton.y - 17;
			//
			htmlSizeLabel.x = _wid / 2
			swfSizeLabel.x = (_wid - WIDTH) / 2;
			htmlSizeLabel.y = swfSizeLabel.y = lineCateg.y + 8;
			//
			this.swfHeightStepper.x=this.swfWidthStepper.x=(_wid - WIDTH) / 2 + 10;
			htmlWidthStepper.y = swfWidthStepper.y = swfSizeLabel.y + 42;
			htmlHeightStepper.y = swfHeightStepper.y = swfWidthStepper.y + swfWidthStepper.height + 10;
			htmlHeightStepper.x = htmlWidthStepper.x = (_wid) / 2 + 10;
			//
			pixelButton.y = percentButton.y = htmlHeightStepper.y + htmlHeightStepper.height + 10 + RadioButton.SIZE / 2;
			pixelButton.x = htmlHeightStepper.x + RadioButton.SIZE / 2;
			percentButton.x = pixelButton.x + 85;
			//
			pixelLabel.x = pixelButton.x + RadioButton.SIZE / 2 + 2;
			percentLabel.x = percentButton.x + RadioButton.SIZE / 2 + 2;
			pixelLabel.y = percentLabel.y = pixelButton.y - 17;
			//
			stageSwitch.x = (_wid - WIDTH) / 2 + 10;
			stageSwitch.y = swfHeightStepper.y + swfHeightStepper.height + 10
			//
			DataHolder.drawBg(this, _wid, _hgt, WIDTH, HEIGHT);
		}
	}
}
