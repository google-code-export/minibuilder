package ro.minibuilder.data
{
	import __AS3__.vec.Vector;
	
	public class ProjectConfig
	{
		//load playerglobal
		public static const TARGET_PLAYER:String = 'player';
		//load airglobal
		public static const TARGET_AIR:String = 'air';
		//load nothing
		public static const TARGET_OTHER:String = 'other';
		
		//target player version
		public var targetPlayerVersion:String = '9.0.124';
		
		//paths
		public var sourcePaths:Vector.<String>;
		public var libs:Vector.<String>;
		public var libsExtern:Vector.<String>;
		public var mainApp:String;
		//choose globals
		public var target:String;
		//load flex libs
		public var useFlex:Boolean = false;
		
		public var extractAbc:Boolean = false;
		public var createProjector:Boolean = false;
		
		
		public function load(asprops:XML):void
		{
			sourcePaths = new Vector.<String>;
			libs = new Vector.<String>;
			libsExtern = new Vector.<String>;
			
			mainApp = asprops.@mainApplicationPath;
			
			if (asprops.compiler.@useApolloConfig == 'true')
				target = TARGET_AIR;
			else
				target = TARGET_OTHER;
			
			if (asprops.compiler.@targetPlayerVersion.length())
				targetPlayerVersion = String(asprops.compiler.@targetPlayerVersion);
			
			
			
			createProjector = asprops.minibuilder.@projector == 'true';
			extractAbc = asprops.minibuilder.@extract == 'true';
			
			
			sourcePaths.push(asprops.compiler.@sourceFolderPath);
			for each (var n:* in asprops.compiler.compilerSourcePath.compilerSourcePathEntry)
				sourcePaths.push(n.@path);
			
			useFlex = true;
				
			for each (n in asprops.compiler.libraryPath.libraryPathEntry)
			{
				if (n.excludedEntries.length())
				{
					for each (var ex:* in n.excludedEntries.libraryPathEntry)
						if (ex.@path.indexOf('framework.swc') != -1)
						{
							useFlex = false;
							break;
						}
				}
				
				//we have sdk libs
				if (n.@kind == 4 && target == TARGET_OTHER)
					target = TARGET_PLAYER;
				
				if (n.@kind == 1 && n.@linkType == 1)
					libs.push(n.@path);
				else if (n.@kind == 1 && n.@linkType == 2)
					libsExtern.push(n.@path);
			}
			
			if (target == TARGET_OTHER)
				useFlex = false;
		}
		
		public function get appName():String
		{
			return 	mainApp.substring(mainApp.lastIndexOf('/')+1, mainApp.lastIndexOf('.'));
		}
		
		public function doTemplate(template:XML):void
		{
			template.@mainApplicationPath = mainApp;
			template.applications.application.@path = mainApp;
			
			if (target == TARGET_AIR)
				template.compiler.@useApolloConfig = 'true';
			else if (target == TARGET_PLAYER)
			{
				var ex:XML = <libraryPathEntry kind="4" path=""><excludedEntries/></libraryPathEntry>;
				if (useFlex)
					ex.excludedEntries.appendChild(<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/flex.swc" useDefaultLinkType="false"/>);
				else
					ex.excludedEntries.appendChild(<libraryPathEntry kind="3" linkType="1" path="${PROJECT_FRAMEWORKS}/libs/framework.swc" useDefaultLinkType="false"/>);
				template.compiler.libraryPath[0].appendChild(ex);
			}
			
			if (createProjector)
				template.minibuilder.@projector = 'true';
			if (extractAbc)
				template.minibuilder.@extract = 'true';
		}
	}
}