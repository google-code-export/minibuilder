package com.ideas.data {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.Font;
	import flash.utils.ByteArray;
	public class DataHolder extends EventDispatcher {
		private static var _fontSize:int = 14;
		private static var _displayState:String = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		private static var _backgroundColor:uint = 0xffffff;
		//
		private static var _swfWidth:Number = 550;
		private static var _swfHeight:Number = 550;
		private static var _htmlWidth:Number = 100;
		private static var _htmlHeight:Number = 100;
		private static var _htmlSizeType:String = "%";
		private static var _htmlStage:String = "exactfit"; //"exactfit"//"showall"//"noborder"//"noscale"
		private static var _recentFiles:Array = [];
		//
		private static var instance:DataHolder;
		private static var _swfData:ByteArray;
		private static var _memoryCounter:int = -1;
		private static var _memoryArray:Vector.<String> = new Vector.<String>();
		public static const SHADOW:GlowFilter = new GlowFilter(0, 1, 12, 12, 1, 3);
		public static const GRADIENT_FILL:Array = [ 0x555555, 0x0 ];
		public static const OUTLINE_COLOR:uint = 0x333333;
		public static const RECENT_LIMIT:uint = 10;
		private static var _mainFont:Font;
		private static var _debugArray:Array;
		public static var initialServerCheck:Boolean;
		public static const STAGE_OPTIONS:Array = [{ label: "« Exact Fit »", value: "exactfit" }, { label: "« Show All »", value: "showall" }, { label: "« No Border »", value: "noborder" }, { label: "« No Scale »", value: "noscale" }];
		public static const DEFAULT_CODE:String = "package {\n\timport flash.display.Sprite;\n\tpublic class Main extends Sprite{\n\t\tpublic function Main(){\n\t\t\t// begin coding here\n\t\t}\n\t}\n}";
		//public static const DEFAULT_CODE:String = "package {\n\timport flash.display.*;\n\tpublic class Main extends Sprite{\n\t\tpublic function Main(){\n\t\t\tvar b:Bitmap=new Bitmap();\n\t\tb\n\t\t}\n\t}\n}";
		public static function set recentFiles(value:Array):void {
			_recentFiles = value;
			if (_recentFiles.length > RECENT_LIMIT) {
				_recentFiles = _recentFiles.slice(0, RECENT_LIMIT);
			}
		}
		public static function get recentFiles():Array {
			return _recentFiles;
		}
		public static function setRecentFile(value:String):Boolean {
			if (_recentFiles.indexOf(value) < 0) {
				_recentFiles.unshift(value);
				if (_recentFiles.length > RECENT_LIMIT) {
					_recentFiles = _recentFiles.slice(0, RECENT_LIMIT);
				}
				return true;
			} else {
				_recentFiles.unshift(_recentFiles.splice(_recentFiles.indexOf(value), 1)[0]);
				return true;
			}
			return false;
		}
		public static function get mainFont():Font {
			return _mainFont;
		}
		public static function set mainFont(value:Font):void {
			_mainFont = value;
		}
		public static function get htmlStage():String {
			return _htmlStage;
		}
		public static function getStagePos(value:String):int {
			for (var i:int = 0; i < STAGE_OPTIONS.length; i++) {
				if (STAGE_OPTIONS[i].value == value) {
					return i;
				}
			}
			return 0;
		}
		public static function set htmlStage(value:String):void {
			_htmlStage = value;
		}
		public static function get htmlSizeType():String {
			return _htmlSizeType;
		}
		public static function set htmlSizeType(value:String):void {
			_htmlSizeType = value;
		}
		public static function get htmlHeight():Number {
			return _htmlHeight;
		}
		public static function set htmlHeight(value:Number):void {
			_htmlHeight = value;
		}
		public static function get htmlWidth():Number {
			return _htmlWidth;
		}
		public static function set htmlWidth(value:Number):void {
			_htmlWidth = value;
		}
		public static function get swfHeight():Number {
			return _swfHeight;
		}
		public static function set swfHeight(value:Number):void {
			_swfHeight = value;
		}
		public static function get swfWidth():Number {
			return _swfWidth;
		}
		public static function set swfWidth(value:Number):void {
			_swfWidth = value;
		}
		public static function get displayState():String {
			return _displayState;
		}
		public static function set displayState(value:String):void {
			_displayState = value;
		}
		public static function getInstance():DataHolder {
			if (instance == null) {
				instance = new DataHolder(new SingletonBlocker());
			}
			return instance;
		}
		public function DataHolder(p_key:SingletonBlocker):void {
			if (p_key == null) {
				throw new Error("Error: Instantiation failed: Use SingletonDemo.getInstance() instead of new.");
			}
		}
		public static function get fontSize():int {
			return _fontSize;
		}
		public static function set fontSize(value:int):void {
			_fontSize = value;
		}
		public static function get backgroundColor():uint {
			return _backgroundColor;
		}
		public static function set backgroundColor(value:uint):void {
			_backgroundColor = value;
		}
		public static function get swfData():ByteArray {
			return _swfData;
		}
		public static function set swfData(value:ByteArray):void {
			_swfData = value;
		}
		public static function saveState(value:String):void {
			_memoryCounter++;
			_memoryArray[_memoryCounter] = value;
			if (_memoryArray.length - 1 > _memoryCounter) {
				_memoryArray.splice(_memoryCounter + 1, _memoryArray.length - _memoryCounter - 1);
			}
			getInstance().dispatchEvent(new Event(Event.CHANGE));
		}
		public static function clearHistory():void {
			_memoryCounter = -1;
			_memoryArray = new Vector.<String>();
		}
		public static function getHistory(direction:int):String {
			if (direction > 0) {
				_memoryCounter++;
				if (_memoryCounter >= _memoryArray.length) {
					_memoryCounter = _memoryArray.length - 1;
				}
			} else {
				_memoryCounter--;
				if (_memoryCounter < 0) {
					_memoryCounter = 0;
				}
			}
			return _memoryArray[_memoryCounter];
		}
		public static function drawBg(shape:Sprite, _wid:int, _hgt:int, WID:int, HGT:int):void {
			//
			shape.graphics.clear();
			shape.graphics.beginFill(0, 0.5);
			shape.graphics.drawRect(0, 0, _wid, _hgt);
			shape.graphics.endFill();
			//
			shape.graphics.lineStyle(2, DataHolder.OUTLINE_COLOR);
			var mtrx:Matrix = new Matrix();
			mtrx.createGradientBox(HGT, HGT, Math.PI / 2, 0, (_hgt - HGT) / 2);
			shape.graphics.beginGradientFill("linear", DataHolder.GRADIENT_FILL, [ 1, 1 ], [ 0, 0xff ], mtrx);
			shape.graphics.drawRoundRect((_wid - WID) / 2, (_hgt - HGT) / 2, WID, HGT, 10, 10);
			shape.graphics.endFill();
			shape.filters = [ DataHolder.SHADOW ];
			shape.cacheAsBitmap = true;
			//
		}
		public static function get memoryCounter():int {
			return _memoryCounter;
		}
		public static function get memoryArray():Vector.<String> {
			return _memoryArray;
		}
		public static function get debugArray():Array {
			return _debugArray;
		}
		public static function set debugArray(value:Array):void {
			_debugArray = value;
		}
	}
}
internal class SingletonBlocker {
}
