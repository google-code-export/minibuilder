package ${PACKAGE}
{
	import ro.mbaswing.FButton;
	import org.aswing.border.EmptyBorder;
	import ro.mbaswing.AsWingApplication;
	import ro.mbaswing.TablePane;
	import org.aswing.*;
	import com.victordramba.console.*;
	
	
	/**
	 * Application entry-point
	 */
	public class Application extends AsWingApplication
	{
		public function Application()
		{
			//uncomment to enable debugger console
			//Debugger.setParent(this, true);
			//debug('started in ' + this);
			
			
			//following is an example form you can use as a starting point
			
			
			//second column (1) will get the extra size
			var pane:TablePane = new TablePane(1);
			setContentPane(pane);
			
			pane.setBorder(new EmptyBorder(null, new Insets(30, 100, 30, 100)));
			
			pane.newRow();
			pane.addLabel('Example Form', 0, 3);
			
			pane.newRow();
			pane.addLabel('Field one:');
			pane.addCell(new JTextField);
			pane.addLabel('(required)');
			
			pane.newRow();
			pane.addLabel('Field two:');
			pane.addCell(new JTextField);
			pane.addLabel('(optional)');
			
			pane.newRow();
			pane.addLabel('Long label spanning across 3 columns', 136, 3);
			
			pane.newRow();
			pane.addLabel('Field three:');
			pane.addCell(new JTextField);
			pane.addCell(new JButton('Search'));
			
			//this row will get the extra height
			pane.newRow(true);
			pane.addLabel('Text:', TablePane.ALIGN_TOP);
			pane.addCell(new JTextArea, 136, 2);
			
			pane.newRow();
			pane.addLabel(null);
			pane.addCell(new JCheckBox('Option 1'), TablePane.ALIGN_LEFT);
			
			pane.newRow();
			pane.addLabel(null);
			pane.addCell(new JCheckBox('Option 2'), TablePane.ALIGN_LEFT);
			
			pane.addSeparatorRow();
			
			pane.newRow();
			pane.addCell(TablePane.hBox(10, new FButton('OK'), new FButton('Cancel')), TablePane.ALIGN_RIGHT, 3);
		}
	}
}