package ro.minibuilder.main
{
	import com.victordramba.console.debug;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import org.aswing.JTextField;
	import ro.mbaswing.TablePane;
	
	import flash.display.*;
	import org.aswing.*;
	
	
	public class LibrarySearch extends Frame
	{
		private var ldLbl:JLabel;
		
		public function LibrarySearch()
		{
			setTitle('Search for a Library');
			
			var pane:TablePane = new TablePane(1);
			setContentPane(pane);
			pane.newRow();
			pane.addLabel('Search');
			pane.addCell(new JTextField(), TablePane.EXPAND_H);
			
			//pane.newRow();
			ldLbl = new JLabel('Loading...', Skins.icnLoading());
			pane.addCell(ldLbl);
			
			
			pane.newRow(true);
			pane.addCell(null);
			
			addOKCancel(pane, 'OK', 'Cancel', 3);
			setSizeAndCenter(400, 300);
			
			
			var ld:URLLoader = new URLLoader;
			ld.load(new URLRequest('http://fluxdb.fluxusproject.org/libraries/catalog.xml'));
			ld.addEventListener(Event.COMPLETE, function(e:Event):void {
				debug(ld.data);
				ldLbl.visible = false;
			});
		}
	}
}
