package com.victordramba.console
{
	/**
	 * Save a reference to have it available in the debugger console<br>
	 * @name the object reference will be available in the console with this var name
	 * @ref the reference
	 * @once set this reference only once. succesive calls for the same name will be ignored
	 */
	public function debugReference(name:String, ref:Object, once:Boolean = true):void
	{
		Debugger.setReference(name, ref, once);
	}
}