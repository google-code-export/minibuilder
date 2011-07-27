package com.ideas.local {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	public class UserSettings extends EventDispatcher {
		public static const NAME:String = "userSettings";
		private var shared:SharedObject;
		private var _sharedData:Object;
		public static const WRITE_ERROR:String = "write_error";
		public static const WRITE_DONE:String = "write_done";
		public function UserSettings() {
			
		}
		// getting data stored in a shared object
		public function retrieveData():Object {
			shared = SharedObject.getLocal(NAME);
			_sharedData = {};
			for (var o:String in shared.data) {
				_sharedData[o] = shared.data[o];
			}
			return _sharedData;
		}
		// writing data in to a shared object
		public function init(data:Object):void {
			if (!data) {
				return;
			}
			var flushStatus:String = null;
			shared = SharedObject.getLocal(NAME);
			for (var o:String in data) {
				shared.data[o] = data[o];
			}
			try {
				flushStatus = shared.flush(1000);
			} catch (error:Error) {
				this.dispatchEvent(new Event(WRITE_ERROR));
			}
			if (flushStatus != null) {
				switch (flushStatus) {
					case SharedObjectFlushStatus.PENDING:
						shared.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
						break;
					case SharedObjectFlushStatus.FLUSHED:
						_sharedData = shared.data;
						this.dispatchEvent(new Event(WRITE_DONE));
						shared.close();
						break;
				}
			}
		}
		// writing data responce
		private function onFlushStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "SharedObject.Flush.Success":
					_sharedData = shared.data;
					this.dispatchEvent(new Event(WRITE_DONE));
					break;
				case "SharedObject.Flush.Failed":
					this.dispatchEvent(new Event(WRITE_ERROR));
					break;
			}
			shared.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
			shared.close();
		}
		public function get sharedData():Object {
			return _sharedData;
		}
	}
}