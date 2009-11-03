/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

package ro.minibuilder.main
{
	import flash.display.DisplayObject;
	
	import org.aswing.AssetIcon;
	import org.aswing.Icon;

	public class Skins
	{
		[Embed(source="/icons/as.png")]
		private static var AS3Icon:Class;
		
		[Embed(source="/icons/folder-open.png")]
		private static var FolderOpenIcon:Class;
		
		[Embed(source="/icons/swc.png")]
		private static var SWCIcon:Class;
		
		[Embed(source="/icons/file.png")]
		private static var FileIcon:Class;
		
		[Embed(source="/icons/bw-f.png")]
		private static var MXIcon:Class;
		
		[Embed(source="/icons/mblogo.png")]
		private static var MBLogo:Class;
		
		public static function icnAS():Icon
		{
			return new AssetIcon(new AS3Icon);
		}
		
		public static function icnSWC():Icon
		{
			return new AssetIcon(new SWCIcon);
		}
		
		public static function icnFolderOpen():Icon
		{
			return new AssetIcon(new FolderOpenIcon);
		}
		
		public static function icnFolder():Icon
		{
			return new AssetIcon(new FolderOpenIcon);
		}
		
		public static function icnFile():Icon
		{
			return new AssetIcon(new FileIcon);
		}
		
		public static function icnMX():Icon
		{
			return new AssetIcon(new MXIcon);
		}
		
		public static function imgLogo():DisplayObject
		{
			return new MBLogo;
		}
		
		public static function topbar():DisplayObject
		{
			return new TopLogo;
		}
		
		public static function icnLoading():Icon
		{
			return new AssetIcon(new LoadingIcn, 16, 16);
		}
	}
}
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;

import ro.minibuilder.main.*;

class TopLogo extends Sprite
{
	function TopLogo()
	{
		addChild(Skins.imgLogo());
		filters = [new DropShadowFilter(3, 45, 0, 1, 3, 3, .4)];
	}
	
	override public function set width(value:Number):void
	{
		graphics.clear();
		graphics.beginFill(0x990000, 1);
		graphics.drawRect(0, 0, value, 62);
	}
	
	override public function set height(value:Number):void
	{
		
	}
}

class LoadingIcn extends Sprite
{
	function LoadingIcn()
	{
		var sh:Shape = new Shape;
		sh.graphics.beginFill(0x980000, 1);
		sh.graphics.drawRoundRect(-7, -3, 14, 6, 7, 7);
		sh.x = 7;
		sh.y = 7;
		addEventListener(Event.ENTER_FRAME, function(e:Event):void {
			sh.rotation += 15;
		});
		addChild(sh);
	}
}