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

package ro.minibuilder.data
{
	public class Constants
	{
		
		public static const MAIN_MENU:XML = 
		<menu>
			<n label="File">
				<n label="Show Startup Window" action="showStartup"/>
				<n separator="yes"/>
				<n label="Save File" action="save"/>
				<n label="Save All" action="saveAll"/>
				<n separator="yes"/>
				<n label="Close Project" action="closeProject"/>
			</n>
			<n label="Compile">
				<n label="Compiler Settings" action="buildSettings"/>
				<n separator="yes"/>
				<n label="Compile" action="compile"/>
				<n label="Compile and QuickRun" action="compileAndRun"/>
				<!-- n label="Compile release" action="compileRelease"/ -->
				<n separator="yes"/>
				<n label="Quick run swf" action="testSWF"/>
			</n>
			<n label="Search">
				<n label="Search next" action="searchNext"/>
				<n label="Search prev." action="searchPrev"/>
				<n label="Search/Replace" action="searchReplace"/>
			</n>
			<n label="Tools">
				<n label="Add License Block" action="addLicense"/>
				<n label="Customize Buttons" action="customize"/>
			</n>
			<n label="Help">
				<n label="Help Contents" action="helpContents"/>
				<n label="About MiniBuilder" action="about"/>
				<n label="Keyboard Shortcuts" action="shortcuts"/>
			</n>
		</menu>;
		
		public static const SHORTCUTS:XML = 
			<keys>
				<key key="R" ctrl="1" action="projectSearch"/>
				<key key="R" ctrl="1" shift="1" action="projectSearch"/>
				<key key="S" ctrl="1" action="save"/>
				<key key="S" ctrl="1" shift="1" action="saveAll"/>
				<key key="L" ctrl="1" action="gotoLine"/>
				<key key="G" ctrl="1" action="gotoLine"/>
				<key key="F5" action="refreshProject"/>
				<key key="F7" action="compile"/>
				<key key="F8" action="compileAndRun"/>
				<key key="F3" action="searchNext"/>
				<key key="F3" shift="1" action="searchPrev"/>
				<key key="K" ctrl="1" action="searchNext"/>
				<key key="K" ctrl="1" shift="1" action="searchPrev"/>
				<key key="K" ctrl="1" shift="1" action="searchPrev"/>
				<key key="F" ctrl="1" action="searchReplace"/>
				<key key="W" ctrl="1" action="closeEditor"/>
				<key key="F4" ctrl="1" action="closeEditor"/>
			</keys>;
		
		
		public static const FLASH_CONFIG:XML = 
		<flex-config>
			<target-player>10.0.0</target-player>
			<compiler>
				<accessible>false</accessible>
				<allow-source-path-overlap>false</allow-source-path-overlap>
				<show-actionscript-warnings>true</show-actionscript-warnings>
				<debug>true</debug>
				<keep-generated-actionscript>false</keep-generated-actionscript>
				<source-path/>
				<external-library-path/>
				<library-path/>
				<!--	<path-element>libs/flex.swc</path-element>
				</library-path -->
				<optimize>true</optimize>
		
				<show-unused-type-selector-warnings>true</show-unused-type-selector-warnings>
				<strict>true</strict>
				<as3>true</as3>
				<es>false</es>
		
				<verbose-stacktraces>false</verbose-stacktraces>
			</compiler>
		</flex-config>;
		
		public static const GPL:String = 
			'<appname> is free software: you can redistribute it and/or modify\n'+
			'it under the terms of the GNU General Public License as published by\n'+
			'the Free Software Foundation, either version 3 of the License, or\n'+
			'(at your option) any later version.\n'+
			'\n'+
			'<appname> is distributed in the hope that it will be useful,\n'+
			'but WITHOUT ANY WARRANTY; without even the implied warranty of\n'+
			'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n'+
			'GNU General Public License for more details.\n'+
			'\n'+
			'You should have received a copy of the GNU General Public License\n'+
			'along with <appname>.  If not, see <http://www.gnu.org/licenses/>.\n\n' +
			'© <author> <year>\n\n';
		
		public static const classTpl:String = 
			'package <package>\n' +
			'{\n' +
			'	public class <name>\n' +
			'	{\n' +
			'		public function <name>()\n' +
			'		{\n' +
			'			\n' +
			'		}\n' +
			'	}\n' +
			'}\n';
		
		public static const functionTpl:String =
			'package <package>\n' +
			'{\n' +
			'	public function <name>()\n' +
			'	{\n' +
			'		\n' +
			'	}\n' +
			'}\n';
	}
}