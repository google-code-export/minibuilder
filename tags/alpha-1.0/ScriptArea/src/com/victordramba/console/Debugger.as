/**
* ...
* @author Victor Dramba
* @version 0.1
*/

package com.victordramba.console
{

//import fl.controls.UIScrollBar;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.external.ExternalInterface;
import flash.filters.DropShadowFilter;
import flash.net.SharedObject;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;

public class Debugger extends Sprite
{
	private static const WIDTH:int = 450;
	private static const BORDER_COLOR:int = 0xE0DFE3;
	private static const BG_COLOR:int = 0xF2F2E9;
	private static const NOT_SUPPORTED_BIN:String =
		'successive binary operators not suported. hint: store local temp values';
	private static const HELP:String =
			'commands: clear (clear console), help (diaplay this message), = (assignment)\n'+
			'functions: evalPath, list, listDisplay, describe\n'+
			'unary operators: new\n'+
			'binary operators: ==, +, -, *, /';

	private static var inst:Debugger;
	private static var text:String = '';
	private static var _parent:DisplayObjectContainer;

	private var txt:TextField;
	//private var sb:UIScrollBar;
	private var inputTxt:TextField;
	static private var so:SharedObject;
	private var index:int;

	private var commands:Array;

	private static var local:Object = {};



	public static function debug(message:*):void
	{
		
		if (nspaces.length > 0)
		{
			if (message is Array && message.length==2 && message[0] is String && nspaces.indexOf(message[0])!=-1)
				message = message[1];
			else
				return;
		}
		
		if(inst)
			inst.debugWrite(message);
		else
			text += message + '\n';
	}
	
	public static function setReference(name:String, ref:Object, once:Boolean = true):void
	{
		if (once && local.hasOwnProperty(name)) return;
		local[name] = ref;
		debug('Debugger Reference: '+name+'='+ref);
	}

	public static function setParent(p:DisplayObjectContainer, openNow:Boolean=false):void
	{
		so = SharedObject.getLocal('debugger');
		nspaces = so.data.nspaces;
		if (!nspaces) nspaces = [];
		
		
		_parent = p;
		if (openNow)
		{
			externalCallback();
			return;
		}
		try {
			flash.external.ExternalInterface.addCallback('debug', externalCallback);
		}catch (e:Error)
		{
			if (!ApplicationDomain.currentDomain.hasDefinition('flash.filesystem.File'))//not AIR
				throw new Error('You need to run this app from a web server in order to have the Debugger Console working');
		}
	}

	private static function externalCallback():void
	{
		if(inst) closeWindow();
		else
			inst = _parent.stage.addChild(new Debugger) as Debugger;
	}

	private static function closeWindow():void
	{
		text = inst.txt.text;
		inst.parent.removeChild(inst);
		inst = null;
	}


	/**
	 * constructor
	 */
	public function Debugger():void
	{
		if(so.data.debug == undefined)
			so.data.debug = {x:0, y:0, commands: []};
		commands = so.data.debug.commands;
		//ExternalInterface.addCallback
		//_level0.addProperty('debugmode', function(){}, function(){Debug.createWindow()});

		// init local functions and vars
		local.local = local;
		local.list = listObject;
		local.toString = function():String{return '[localObj]'};
		local.listDisplay = listDisplay;
		local['true'] = true;
		local['false'] = false;
		local.global = getGlobal();
		for (var n:String in local)
			local.setPropertyIsEnumerable(n, false);

		local.describe = function(o:*):String
		{
			var xml:XML = flash.utils.describeType(o);
			var a:Array = [];
			a.push('Type: '+xml.@name);
			for (var i:int = 0; i < xml.accessor.length(); i++)
				a.push('set/get '+xml.accessor[i].@name+':'+xml.accessor[i].@type);
			for (i = 0; i < xml.method.length(); i++)
				a.push(xml.method[i].@name+'():'+xml.method[i].@returnType+' in '+xml.method[i].@declaredBy);
			var list:XMLList = xml..metadata;//.(@name=='Event');
			//return list;
			for (i = 0; i < list.length(); i++)
				a.push('event:'+list[i].arg.(@key=='name').@value);
			return a.join('\n');
		};
		local.setPropertyIsEnumerable('describe', false);

		local.evalPath = evalPath;
		local.setPropertyIsEnumerable('evalPath', false);


		x = so.data.debug.x;
		y = so.data.debug.y;
		alpha = 0.8;
		addEventListener(MouseEvent.ROLL_OVER, function(e:Event):void{alpha=1;filters = [new DropShadowFilter(3,45,0,.3)]});
		addEventListener(MouseEvent.ROLL_OUT, function(e:Event):void{alpha=0.8;filters=[]});

		var topBar:Sprite = new Sprite;
		addChild(topBar);
		//debugWin.createEmptyMovieClip('topBar',10);

		var gf:Graphics = topBar.graphics;
		gf.beginFill(0x4B4A44, 0.8);
		gf.drawRect(0,0,WIDTH,15);
		gf.endFill();
		topBar.addEventListener(MouseEvent.MOUSE_DOWN, function():void
		{
			startDrag(false);
		});

		topBar.addEventListener(MouseEvent.MOUSE_MOVE, function(evt:MouseEvent):void
		{
			evt.updateAfterEvent();
		});

		topBar.addEventListener(MouseEvent.MOUSE_UP, function():void
		{
			stopDrag();
			so.data.debug.x = x;
			so.data.debug.y = y;
			so.flush();
		});

		//debugWin.createEmptyMovieClip('closeBtn', 11);


		var closeBtn:Sprite = new Sprite;
		addChild(closeBtn);
		gf = closeBtn.graphics;
		gf.beginFill(0xFF0000, 1);
		gf.drawRect(WIDTH-13, 2, 11, 11);
		gf.endFill();
		closeBtn.addEventListener(MouseEvent.MOUSE_DOWN, function():void
		{
			closeWindow();
		});



		var clearBtn:Sprite = new Sprite;
		addChild(clearBtn);
		gf = clearBtn.graphics;
		gf.beginFill(0x0000FF, 1);
		gf.drawRect(WIDTH-28, 2, 11, 11);
		gf.endFill();
		clearBtn.addEventListener(MouseEvent.MOUSE_UP, function():void
		{
			if(txt.text == ''){
				commands.length = 0;
				so.flush();
				index = 0;
			}
			txt.text = '';//\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n';
			//sb.scrollTarget = txt;
		});

		/*var mc = debugWin.createEmptyMovieClip('detail_btn', 13);

		mc.x = 10;
		mc.y = 2;
		mc.alpha = so.data.details ? 0.2 : 1;
		mc.beginFill(0x008855, 100);
		drawRect(mc, 0, 0, 11, 11);
		mc.endFill();
		mc.onRelease = function()
		{
			Debug.so.data.details = !Debug.so.data.details;
			this.alpha = Debug.so.data.details ? 0.2 : 1;
		}*/


		gf = graphics;
		gf.beginFill(BG_COLOR, 1);
		gf.drawRect(0,0, WIDTH, 301);
		gf.endFill();

		var tf:TextFormat = new TextFormat();
		tf.font = 'Arial';
		tf.size = 11;
		tf.color = 0x101010;
		txt = new TextField();
		addChild(txt);
		txt.width = WIDTH-15;
		txt.height = 265;
		txt.y = 15;
		txt.defaultTextFormat = tf;
		txt.border=true;
		txt.borderColor = BORDER_COLOR;
		txt.selectable = true;
		txt.wordWrap = true;

		//scrollbar
		/*if (ApplicationDomain.currentDomain.hasDefinition('ScrollArrowDown_disabledSkin'))
		{
			sb = new UIScrollBar;
			sb.direction = 'vertical';
			sb.height = txt.height;
			sb.scrollTarget = txt;
			sb.x = txt.x + txt.width;
			sb.y = txt.y;
			addChild(sb);
		}*/

		debugWrite(text);
		text = '';

		inputTxt = new TextField();
		addChild(inputTxt);
		inputTxt.width = WIDTH;
		inputTxt.height = 20;
		inputTxt.y = 280;
		tf.size = 12;
		inputTxt.defaultTextFormat = tf;
		inputTxt.border=true;
		inputTxt.borderColor = BORDER_COLOR;
		inputTxt.selectable = true;
		inputTxt.type = 'input';
		inputTxt.multiline = false;

		inputTxt.text = '';
		index = commands.length-1;

		inputTxt.addEventListener(KeyboardEvent.KEY_DOWN, function(evt:KeyboardEvent):void
		{
			if (menu.parent)
			{
				if (evt.keyCode == Keyboard.UP)
					menu.selectedIndex ++;
				else if (evt.keyCode == Keyboard.DOWN)
					menu.selectedIndex --;
				else if (evt.keyCode == Keyboard.BACKSPACE)
				{
					if (menu.tmpText.length == 0)
					{
						hideMenu(false);
						return;
					}
					menu.tmpText = menu.tmpText.substr(0, -1);
					menu.filter(menu.tmpText);
				}
				else if (evt.keyCode == Keyboard.ESCAPE || evt.keyCode == Keyboard.ENTER)
				{
					hideMenu(evt.keyCode == Keyboard.ENTER);
				}
				return;
			}
			
			
			if(evt.keyCode == Keyboard.ENTER)
			{
				//debug('enter pressed');
				debugInput();
			}
			if(evt.keyCode == Keyboard.UP)
			{
				//debugWrite('up pressed');
				if(inputTxt.text == commands[index])
				{
					index--;
					if(index < 0) index = 0;
					if(index > commands.length-1) index = commands.length-1;
				}
				if(commands.length) inputTxt.text = commands[index];
			}
			if(evt.keyCode == Keyboard.DOWN)
			{
				index++;
				if(index > commands.length-1)
				{
					index = commands.length-1;
					inputTxt.text = '';
				}
				else
				{
					if(index < 0) index = 0;
					inputTxt.text = commands[index];
				}
			}
		});
		inputTxt.addEventListener(TextEvent.TEXT_INPUT, function(e:TextEvent):void {
			if (e.text == '.')
			{
				try {
				var ref:* = evalExpr(inputTxt.text);
				} catch (e:Error) {debug(e.message)}
				if (ref)
				{
					var xml:XML = flash.utils.describeType(ref);
					var a:Array = [];
					for (var i:int = 0; i < xml.accessor.length(); i++)
						a.push(xml.accessor[i].@name);
					for (i = 0; i < xml.method.length(); i++)
						a.push(xml.method[i].@name+'()');
					for (i=0; i<xml.variable.length(); i++)
						a.push(xml.variable[i].@name);
					for (i=0; i<xml.constant.length(); i++)
						a.push(xml.constant[i].@name);
						
					if (a.length == 0) return;
					a.sort(Array.DESCENDING);
					menu.setData(a);
					
					inputTxt.selectable = false;
					addChild(menu);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageRemoveMenu);
				}
				menu.tmpText = '';
			}
			else if (menu.parent)
			{
				menu.tmpText += e.text;
				if (!menu.filter(menu.tmpText))
					hideMenu(false);
			}	
		});
		
		
		//completion menu
		menu = new Menu;
		menu.y = inputTxt.y;
		menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent):void {
			hideMenu(true);
		});
	}
	
	private function stageRemoveMenu(e:MouseEvent):void
	{
		if (menu.contains(e.target as DisplayObject)) return;
		hideMenu(false);
	}
	
	private function hideMenu(complete:Boolean):void
	{
		if (complete)
		{
			inputTxt.replaceText(inputTxt.length-menu.tmpText.length, inputTxt.length, menu.value);
			inputTxt.setSelection(inputTxt.length, inputTxt.length);
		}
		inputTxt.selectable = true;
		removeChild(menu);
		menu.tmpText = '';
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageRemoveMenu);
	}
	
	private var menu:Menu;

	private function debugWrite(msg:String):void
	{
		txt.appendText(msg + '\n');
		txt.scrollV = txt.maxScrollV;
	}

	private function debugInput():void
	{
		//couldn't set this in the contructor. i am now sure that the stage exists here
		local.stage = stage;
		local.root = root;

		var ind:int = commands.indexOf(inputTxt.text);
		if(ind != -1)
			commands.splice(ind, 1);
		commands.push(inputTxt.text);
		index = commands.length-1;

		try{
			parseCommand(inputTxt.text);
		}catch(e:Error)
		{
			debugWrite(e.message);
		}
		inputTxt.text = '';

	}
	
	private static var nspaces:Array;
	
	private function parseCommand(str:String):void
	{
		var ref:*;

		str = str.replace(/;$/, '');

		if(str == '')
			debugWrite('');
		else if(str == 'help')
			debugWrite(HELP);
		else if(str == 'clear')
			txt.text = '';
		//namespace
		else if (/^ns\b/.test(str))
		{
			if (str.length == 2)
			{
				debugWrite('NAMESPACE OFF');
				nspaces.length = 0;
			}
			else
			{
				var nspace:String = str.substr(str.indexOf(' ')+1);
				if (nspace == 'list')
				{
					debugWrite(nspaces.toString());
					return;
				}
				debugWrite('NAMESPACE: '+nspace);
				nspaces.push(nspace);
			}
			so.data.nspaces = nspaces;
			so.flush();
		}

		else if(str.match('[^=]=[^=]'))
		{
			var a:Array = str.split(/\s*=\s*/);
			if(a[0].indexOf('.')==-1 && a[0].indexOf('::')==-1)
			{
				parseCommand('local.' + str);
				return;
			}
			//TODO: Cls::name = value
			var indC:int = a[0].lastIndexOf('::');
			var indD:int = a[0].lastIndexOf('.');
			var varName:String;
			var obj:Object;
			if(indC > indD)
			{
				obj = evalExpr(a[0].substr(0, indC))
				varName = a[0].substr(indC + 2);
			}
			else
			{
				obj = evalExpr(a[0].substr(0, indD))
				varName = a[0].substr(indD + 1);
			}

			var value:* = evalExpr(a[1]);
			obj[varName] = value;
			debugWrite('Set '+str);
		}
		else
		{
			debugWrite('Print '+str);
			debugWrite(evalExpr(str));
		}
	}


	private function listDisplay(obj:DisplayObjectContainer, level:int=0):String
	{
		function fill(i:int):String
		{
			var a:Array = [];
			for(;i>=0;i--) a.push('\t');
			return a.join('');
		}

		var a:Array = [];
		for(var i:int=0; i<obj.numChildren; i++)
		{
			var sp:DisplayObject = obj.getChildAt(i);
			a.push(fill(level)+sp+' '+sp.name);
			if(sp is DisplayObjectContainer && (sp as DisplayObjectContainer).numChildren)
				a.push(listDisplay(sp as DisplayObjectContainer, level+1));
		}
		return a.join('\n');
	}

	private function evalPath(s:String):DisplayObject
	{
		var a:Array = s.split('.');
		if(a[0] == 'stage')
		{
			var ref:* = stage;
			for(var i:Number=1; i<a.length && ref; i++)
			{
				//debugWrite('i='+i+'; '+a[i]);
				ref = ref.getChildByName(a[i]);
			}
			return ref;
		}
		return undefined;
	}

	private function evalExpr(str:String):*
	{
		var a:Array;
		var b:Array;

		//1. Extract strings
		//-----------------------
		str = str.replace('\\"', '#escapedquote#');
		var re:RegExp = /"(.*?)"/g;
		var strings:Array = str.match(re);
		for (var i:int = 0; i < strings.length; i++){
			strings[i] = strings[i].replace('#escapedquote#', '"');
			strings[i] = strings[i].substr(1,strings[i].length-2);
		}
		str = str.replace(re, '__string__');
		a = str.split('__string__');
		str = a[0];
		for (i = 1; i < a.length; i++)
			str += '$strings.'+(i-1)+a[i];
		//debug('strings: '+strings);

		str = str.replace(/\bnew\s+/, 'new€');

		//strip all spaces
		str = str.replace(/\s+/g,'');
		//debug('after strip: '+str);

		//2.asign paranthesis
		str = str.replace(/\(/g, '<a>').replace(/\)/g, '</a>');
		try{
			var xml:XML = XML('<a>'+str+'</a>');
		}catch(e:Error)
		{
			throw(new Error('Syntax error. Check parantheses.'));
		}

		return(recExecNode(xml)[0]);

		function recExecNode(node:XML):Array
		{
			if(String(node) == '') return [];

			var params:Array = [];//a list with params lists
			var list:XMLList = node.*;
			var k:int = 0;
			var str:String = '';
			for (var i:int = 0; i < list.length(); i++)
			{
				if(list[i].name() == 'a')
				{
					str += '#'+k;
					params[k++] = recExecNode(list[i]);
				}
				else
					str += list[i];
			}
			//debug('rec: '+str);

			var a:Array = str.split(',');
			var ret:Array = [];
			for(i=0; i<a.length; i++)
				ret[i] = resolve(a[i], params);
			return ret;
		}


		function resolve(expr:String, params:Array):*
		{
			var a:Array;
			//debug('resolve:'+expr);

			//try a definition
			var cls:Object;
			try{
				cls = flash.utils.getDefinitionByName(expr);
			}catch(each:Error){}
			if(cls) return cls;


			//new operator
			if(expr.indexOf('new€') == 0)
			{
				a = expr.substr(4).split('#');
				var ref:* = resolve(a[0],[]);
				if (a.length == 1)
					return new ref;
				var p:Array = params[Number(a[1])];
				//only support max 10 arguments for "new" operator
				switch (p.length)
				{
					case 0: return new ref;
					case 1: return new ref(p[0]);
					case 2: return new ref(p[0], p[1]);
					case 3: return new ref(p[0], p[1], p[2]);
					case 4: return new ref(p[0], p[1], p[2], p[3]);
					case 5: return new ref(p[0], p[1], p[2], p[3], p[4]);
					case 6: return new ref(p[0], p[1], p[2], p[3], p[4], p[5]);
					case 7: return new ref(p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
					case 8: return new ref(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
					case 9: return new ref(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]);
					case 10: return new ref(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]);
				}
				throw new Error('Max 10 arguments are allowed for a constructor');
			}

			//try binary operators
			if(expr.indexOf('==') != -1)
			{
				a = expr.split('==');
				if(a.length>2) throw(new Error(NOT_SUPPORTED_BIN));
				return resolve(a[0], params) == resolve(a[1], params);
			}
			if(expr.indexOf('+') != -1)
			{
				a = expr.split('+');
				if(a.length>2) throw(new Error(NOT_SUPPORTED_BIN));
				return resolve(a[0], params) + resolve(a[1], params);
			}
			if(expr.indexOf('-') != -1)
			{
				a = expr.split('-');
				if(a.length>2) throw(new Error(NOT_SUPPORTED_BIN));
				return resolve(a[0], params) - resolve(a[1], params);
			}
			if(expr.indexOf('*') != -1)
			{
				a = expr.split('*');
				if(a.length>2) throw(new Error(NOT_SUPPORTED_BIN));
				return resolve(a[0], params) * resolve(a[1], params);
			}
			if(expr.indexOf('/') != -1)
			{
				a = expr.split('/');
				if(a.length>2) throw(new Error(NOT_SUPPORTED_BIN));
				return resolve(a[0], params) / resolve(a[1], params);
			}

			//try String and Number
			if(!isNaN(Number(expr)))
				return Number(expr);
			if(expr.indexOf('$strings.') == 0)
				return strings[expr.split('.')[1]];

			//resolve complex ref
			var res:*;
			var clsName:String;

			a = expr.split('.');
			var obj:*;
			var i:int;
			for(i=0; i<a.length; i++)
			{
				try{
					//look for definition in global scope
					clsName = a.slice(0,i+1).join('.').split('#')[0];
					res = flash.utils.getDefinitionByName(clsName);
				}catch(e:Error){}
				if(res)
				{
					//execute the fn call
					if (res is Function && a[i].indexOf('#') != -1)
						res = res.apply(res, params[Number(a[i].split('#')[1])]);
					
					a = a.slice(i+1,a.length);
					break;
				}
			}
			if(!res) res = local;

			var b:Array;
			for(i=0; i<a.length; i++)
			{
				if (!res) throw(new Error(a.slice(0, i).join('.')+' is null'));
				if(a[i].indexOf('#') == -1)
				{
					try{
						res = res[a[i]];
					}catch(e:Error)
					{
						throw(new Error('Property '+a[i]+' not found on '+res+'.'+a.slice(0,i).join('.')));
					}
				}
				else
				{
					b = a[i].split('#');
					if(!(res[b[0]] is Function))
						throw(new Error(clsName+'.'+a.slice(0,i).join('.')+b[0]+' is not a function.'));
					res = res[b[0]].apply(res, params[Number(b[1])]);
				}
			}
			return res;
		}
	}

	private function listObject(o:Object):String
	{
		var a:Array = [];
		for(var n:String in o)
			a.push(n+'='+o[n]);
		return a.join('\n');
	}


}//end class

}
//end pack

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.filters.DropShadowFilter;
import flash.events.MouseEvent;
import flash.display.DisplayObject;

class Menu extends Sprite
{
	private var _selectedIndex:int = -1;
	private var data:Array;
	private var _data:Array;
	public var tmpText:String;
	
	function Menu()
	{
		filters = [new DropShadowFilter(4, 45, 0, .15)];
	}
	
	public function setData(labels:Array):void
	{
		data = labels.concat();
		removeDuplicates();
		_data = data;
		update();
	}
	
	private function update():void
	{
		while (numChildren > 0) removeChildAt(0);
		
		var y:int = 0;
		for each (var str:String in _data)
		{
			var txt:TextField = new TextField;
			txt.width = 200;
			txt.height = 17;
			txt.border = true;
			txt.borderColor = 0xc0c0c0;
			txt.background = true;
			txt.y = (y -= 16);
			txt.defaultTextFormat = new TextFormat('_sans', '11');
			txt.text = str;
			txt.selectable = false;
			txt.doubleClickEnabled = true;
			addChild(txt);
		}
		selectedIndex = 0;
		addEventListener(MouseEvent.MOUSE_DOWN, onItemClick);
	}
	
	private function onItemClick(e:MouseEvent):void
	{
		selectedIndex = getChildIndex(e.target as DisplayObject);
	}
	
	public function set selectedIndex(index:int):void
	{
		if (index < 0) index = 0;
		if (index > numChildren-1) index = numChildren-1;
		_selectedIndex = index;
		if (index == -1) return;
		for (var i:int=0; i<numChildren; i++)
			(getChildAt(i) as TextField).backgroundColor = 0xffffff;
		(getChildAt(index) as TextField).backgroundColor = 0xc0c0c0;
	}
	
	public function get selectedIndex():int
	{
		return _selectedIndex;
	}
	
	public function get value():String
	{
		return (getChildAt(_selectedIndex) as TextField).text;
	}
	
	public function filter(str:String):Boolean
	{
		_data = data.filter(function(item:*, i:int, arr:Array):Boolean {
			return str.length == 0 || (item.toLowerCase().indexOf(str.toLowerCase()) == 0);
		});
		if (_data.length)
		{
			update();
			return true;
		}
		return false;
	}
	
	private function removeDuplicates():void
	{
		var dict:Object = {};
		var output:Array = new Array( );
		for each (var str:String in data) 
		{
			if(!dict['*'+str]) 
			{
				output.push(str);
				dict['*'+str] = true;
			}
		}
		data = output;
	}
}

function getGlobal():Object
{
	return this;
}