package nl.mediamonkey.managers {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.core.Singleton;
	//import mx.managers.HistoryManagerImpl
	import mx.managers.IHistoryManager;
	import mx.managers.IHistoryManagerClient;
	import mx.managers.ISystemManager;
	import mx.utils.ObjectUtil;
	
	import nl.mediamonkey.log.Logger;
	import nl.mediamonkey.managers.HistoryManagerImpl;
	
	/** plan:
	 * 
	 * finish HistoryManagerImpl
	 * copy functionality that saves and loads states to this class
	 * switch _impl back to mx.managers.HistoryManagerImpl
	 */
	
	public class HistoryManager extends EventDispatcher implements IHistoryManagerClient {
		
		private static const _instance:HistoryManager = new HistoryManager(SingletonLock);
		
	    private static var implClassDependency:HistoryManagerImpl;
		private static var _impl:HistoryManagerImpl;
		private static var registeredObjects:ArrayCollection;
		private static var registeredSelf:Boolean = false;
		
		private var _javaScriptEnabled:Boolean;
		private var uid:uint = 1;
		
		// ---- getters & setters ----
		
		private static function get impl():HistoryManagerImpl {
		    if (!_impl) {
		    	_impl = HistoryManagerImpl.instance;
		    	_impl.addEventListener(Event.CHANGE, instance.changeHandler);
		    }
		    return _impl;
		}
		
		private function changeHandler(event:Event):void {
			dispatchEvent(event);
		}
		
		public static function get instance():HistoryManager {
			return _instance;
		}
		
		[Bindable]
		public function get backStates():ArrayCollection {
			return impl.backStates;
		}
		
		public function set backStates(value:ArrayCollection):void {
			//impl.backStates = value;
		}
		
		[Bindable]
		public function get forwardStates():ArrayCollection {
			return impl.forwardStates;
		}
		
		public function set forwardStates(value:ArrayCollection):void {
			//impl.forwardStates = value;
		}
		
		// ---- constructor ----
		
		public function HistoryManager(lock:Class) {
			if (lock != SingletonLock) {
				throw new Error("Cannot instantiate directly, use HistoryManager.instance");
			}
		}
		
		// ---- Class methods ----
		
	    public static function initialize(sm:ISystemManager):void {
			// this code is handled in HistoryManagerImpl.getInstance() now
	    }
		
		public static function register(obj:IHistoryManagerClient):void {
			
			// register own class once (for additional uid in states)
			if (!registeredSelf) {
				impl.register(instance);
				registeredSelf = true;
			}
			
			impl.register(obj);
		}
		
		public static function unregister(obj:IHistoryManagerClient):void {
		    impl.unregister(obj);
		}
		
		public static function save():void {
			impl.save();
		}
		
		// ---- Class LocalConnection handlers called by history.swf ----
		
		public static function registered():void {
			impl.registered();
		}
		
		public static function isRegistered():Boolean {
			return impl.isRegistered;
		}
		
		public static function registerHandshake():void {
			impl.registerHandshake();
		}
		
		public static function load(stateVars:Object):void {
			impl.load(stateVars);
		}
		
		public static function loadInitialState():void {
			impl.loadInitialState(); // Load up the initial application state.
		}
		
		// ---- additional methods ----
		
		[Bindable]
		public function get javaScriptEnabled():Boolean {
			//return false; // fix for zinc, disables the browser- and enables the internal historymanagement
			
			if (_javaScriptEnabled == true) return _javaScriptEnabled;
			
			var script:String = ""+
				"(window.Browser = {"+
					"javaScriptEnabled:function() {"+
						"return true;"+
					"}"+
				"}).javaScriptEnabled();";
			
			try {
				_javaScriptEnabled = ExternalInterface.call("Browser.javaScriptEnabled");
				if (!_javaScriptEnabled) _javaScriptEnabled = ExternalInterface.call("eval", script);
				return _javaScriptEnabled;
				
			} catch (e:Error) {
				_javaScriptEnabled = false;
			}
			
			return _javaScriptEnabled;
		}
		
		public function set javaScriptEnabled(value:Boolean):void {
			//..
		}
		
		public static function back():void {
			go(-1);
		}
		
		public static function forward():void {
			go(1);
		}
		
		// hier uitbouwen met een soort duplicaat vesie van de history.swf
		// bewaar dus de states in een ArrayCollection en vraag ze op
		
		public static function go(index:int):void {
			if (index == 0) return;
			
			if (instance.javaScriptEnabled) {
				callJSHistory(index);
			} else {
				instance.loadStatesAt(index);
			}
		}
		
		public function loadStatesAt(index:int):void {
			if (index == 0) return;
			
			var currentState:Object;
			var stateObject:Object;
			
			// only go back 1 state, skip multiple states later (deadline)
			
			if (index < 0 && impl.backStates.length > 0) {
				
				// remove current state and add to forwardStates
				currentState = impl.backStates.removeItemAt(impl.backStates.length - 1);
				forwardStates.addItem(currentState);
				
				// what remains will become the current state
				stateObject = (impl.backStates.length > 0) ? impl.backStates.getItemAt(impl.backStates.length - 1) : null;
				
			} else if (impl.forwardStates.length > 0) {
				
				// remove last added element and assign as current state
				stateObject = (impl.forwardStates.length > 0) ? impl.forwardStates.removeItemAt(impl.forwardStates.length - 1) : null;
				
				// add loaded state to backStates
				backStates.addItem(stateObject);
			}
			
			// clone the object or its properties and values will be deleted
			// distribute the state to all registered objects
			impl.distributeLoadStates(ObjectUtil.copy(stateObject));
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected static function callJSHistory(index:int):Boolean {
			//return true; // fix for zinc
			trace("callJSHistory("+index+")");
			
			// use wrapper method that returns a boolean result
			var script:String = ""+
				"(window.Browser = {"+
					"go:function(index) {"+
						"history.go(index);"+
						"return true;"+
					"}"+
				"}).go("+index+");";
			
			try {
				var result:Boolean = ExternalInterface.call("Browser.go", index);
				if (!result) result = ExternalInterface.call("eval", script);
				return result;
				
			} catch(e:Error) {
				//..
			}
			
			return false;
		}
		
		// ---- IHistoryManagerClient methods ----
		
		// add a uid for easier management of states
		public function saveState():Object {
			var state:Object = {};
			state.uid = uid++;
			return state;
		}
		
		public function loadState(state:Object):void {
			//..
		}
	
	}
}

internal class SingletonLock {
}