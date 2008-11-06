package nl.mediamonkey.managers {
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.Singleton;
	import mx.managers.HistoryManagerGlobals;
	import mx.managers.IHistoryManager;
	import mx.managers.IHistoryManagerClient;
	import mx.managers.ISystemManager;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerGlobals;
	import mx.utils.ObjectUtil;
	
	import nl.mediamonkey.log.Logger;
	
	public class HistoryManagerImpl extends EventDispatcher implements IHistoryManager {
		
		private static const _instance:HistoryManagerImpl = new HistoryManagerImpl(SingletonLock);
		
		[Bindable] public var backStates:ArrayCollection;
		[Bindable] public var forwardStates:ArrayCollection;
		
		private static const HANDSHAKE_INTERVAL:int = 500; // milliseconds
		private static const MAX_HANDSHAKE_TRIES:int = 100;
		
		private static const ID_NAME_SEPARATOR:String = "-";
		private static const NAME_VALUE_SEPARATOR:String = "=";
		private static const PROPERTY_SEPARATOR:String = "&";
		
	    private static var systemManager:ISystemManager;
		private static var appID:String;
		
		private static var lconID:String;
		private static var historyURL:String;
		
		// ---- getters & setters ----
		
		public static function get instance():HistoryManagerImpl {
			return _instance;
		}
		
		// ---- constructor ----
		
		public function HistoryManagerImpl(lock:Class) {
			super();
			
			if (lock != SingletonLock) {
				throw new Error("Cannot instantiate directly, use HistoryManagerImpl.instance");
			}
			
			systemManager = SystemManagerGlobals.topLevelSystemManagers[0];
			
			backStates = new ArrayCollection();
			forwardStates = new ArrayCollection();
			
			if (appID) return;
			
			var loaderInfo:LoaderInfo;
			
			// Added to support Cross-versioning issue,
			// so one needs to set the Singleton.loaderInfo object
			// to the loaderInfo of the top-most object
			if (HistoryManagerGlobals.loaderInfo) {
			    loaderInfo = HistoryManagerGlobals.loaderInfo;
			} else {
			    // Get values that were passed in via the FlashVars
				// in the HTML wrapper.
			    loaderInfo = DisplayObject(systemManager).loaderInfo;
			}
			
			lconID = loaderInfo.parameters.lconid;
			historyURL = loaderInfo.parameters.historyUrl;
	
			if (!lconID || !historyURL) {
				trace("*** HistoryManagerImpl - lconID:"+lconID+", historyURL:"+historyURL);
				return;
			}
			
			var appURL:String;
			
			// Use our URL as the unique CRC for this movie.
			appURL = (HistoryManagerGlobals.loaderInfo) ? HistoryManagerGlobals.loaderInfo.url : DisplayObject(systemManager).loaderInfo.url;
			
			appID = calcCRC(appURL);
			// Set up a LocalConnection for communicating with the history.swf.
			lc = new MainLocalConnection();
			lc.allowDomain("~", "localhost");
			lc.addEventListener(StatusEvent.STATUS, statusHandler);
			lc.connect(appID + lconID);
	
			lcinit = new InitLocalConnection();
			lcinit.addEventListener(StatusEvent.STATUS, statusHandler);
			lcinit.allowDomain("~", "localhost");
			try {
				lcinit.connect("init" + lconID);
			} catch (error:Error) {
				// Ignore error.
				// If you try to load multiple applications on the same HTML page,
				// the init connection will fail for the second
				// (and any subsequent) app.
			}
			
			// Start trying to contact the history.swf.
			handshakeTimer = new Timer(HANDSHAKE_INTERVAL, MAX_HANDSHAKE_TRIES);
			handshakeTimer.addEventListener(TimerEvent.TIMER, initHandshake);
			handshakeTimer.start();
		}
		
		public var isRegistered:Boolean = false;
		private var registeredObjects:Array = [];
		private var registrationMap:Dictionary;
		private var pendingStates:Object = {};
		private var handshakeTimer:Timer;
		private var lc:MainLocalConnection;
		private var lcinit:InitLocalConnection;
		private var pendingQueryString:String;
		
		public function register(obj:IHistoryManagerClient):void {
			// Ensure that this object isn't already registered.
			unregister(obj);
			
			// Add the object to the Array of all registered objects.
			registeredObjects.push(obj);
					
			// Get a "path" string such as "Application_1.VBox0.hb:HBox.main:
			// Panel.bodyStack:ViewStack.checkoutView:VBox.accordion:Accordion"
			// that uniquely represents this object in the visual hierarchy
			// of the application.
			var path:String = getPath(obj);
			
			// Calculate a 4-character hex CRC of this path as a short
			// identifier for the object to be encoded into the
			// query parameters of the history URL.
			var crc:String = calcCRC(path);
			
			// Determine the depth of the object in the visual hierarchy.
			// This is important because state must be restored
			var depth:int = calcDepth(path);
			
			// Store the crc and depth of the registered object in a
			// RegistrationInfo instance kept in the HistoryManager's
			// registrationMap. Given a registed object, we can look up
			// its crc and depth using getRegistrationInfo().
			if (!registrationMap)
				registrationMap = new Dictionary();
			registrationMap[obj] = new RegistrationInfo(crc, depth);
			
			// Sort the Array of all registered objects according to their depth.
			registeredObjects.sort(depthCompare);
			
			// See if there is a pending state for this object.
			if (pendingStates[crc]) {
				obj.loadState(pendingStates[crc]);
				delete pendingStates[crc];
			}
			
			isRegistered = true;
		}
		
		private function getPath(obj:IHistoryManagerClient):String {
			return obj.toString();
		}
		
		private function calcCRC(s:String):String {
			var crc:uint = 0xFFFF;
	
			// Process each character in the string.
			var n:int = s.length;
			for (var i:int = 0; i < n; i++) {
				var charCode:uint = s.charCodeAt(i);
				
				// Unicode characters can be greater than 255.
				// If so, we let both bytes contribute to the CRC.
				// If not, we let only the low byte contribute.
				var loByte:uint = charCode & 0x00FF;
				var hiByte:uint = charCode >> 8;
				if (hiByte != 0)
					crc = updateCRC(crc, hiByte);
				crc = updateCRC(crc, loByte);
			}
	
			// Process 2 additional zero bytes, as specified by the CCITT algorithm.
			crc = updateCRC(crc, 0);
			crc = updateCRC(crc, 0);
	
			return crc.toString(16);
		}
		
		private function updateCRC(crc:uint, byte:uint):uint {
			const poly:uint = 0x1021; // CRC-CCITT mask
	
			var bitMask:uint = 0x80;
	
			// Process each bit in the byte.
			for (var i:int = 0; i < 8; i++) {
				var xorFlag:Boolean = (crc & 0x8000) != 0;
				
				crc <<= 1;
				crc &= 0xFFFF;
	
				if ((byte & bitMask) != 0)
					crc++;
	
				if (xorFlag)
					crc ^= poly;
	
				bitMask >>= 1;
			}
	
			return crc;
		}
		
		private function calcDepth(path:String):int {
			return path.split(".").length;
		}
		
		private function depthCompare(a:Object, b:Object):int {
			var regInfoA:RegistrationInfo = getRegistrationInfo(IHistoryManagerClient(a));
			var regInfoB:RegistrationInfo = getRegistrationInfo(IHistoryManagerClient(b));
			
			// Guard against the possibility of an object's 
			// registration info not being found.
			if (!regInfoA || !regInfoB)
				return 0;
			
			if (regInfoA.depth > regInfoB.depth)
				return 1;
			
			if (regInfoA.depth < regInfoB.depth)
				return -1;
				
			return 0;
		}
		
		private function getRegistrationInfo(obj:IHistoryManagerClient):RegistrationInfo {
			return registrationMap ? registrationMap[obj] : null;
		}
		
		public function unregister(obj:IHistoryManagerClient):void {
			// Find the index of the object in the Array of all
			// registered objects; -1 means not found.
			var index:int = -1;
			var n:int = registeredObjects.length;
			for (var i:int = 0; i < n; i++) {
				if (registeredObjects[i] == obj) {
					index = i;
					break;
				}
			}
				
			// If the object was found in the Array, remove it.
			if (index >= 0) registeredObjects.splice(index, 1);
			
			// Remove it from the map as well.
			if (obj && registrationMap) delete registrationMap[obj];
		}
		
		public function save():void {
			if (!isRegistered) return;
			
			var haveState:Boolean = false;
	
			// Query string always starts with the application identifier.
			var queryString:String = "app=" + appID;
			
			var stateObject:Object = new Object();
			
			// Call saveState() on every registered object
			// to get an Object containing its state information.
			var n:int = registeredObjects.length;
			for (var i:int = 0; i < n; i++) {
				var registeredObject:IHistoryManagerClient = registeredObjects[i];
				var stateInfo:Object = registeredObject.saveState();
					
				// stateInfo might be something like { selectedIndex: 1 }
				
				// Encode the stateInfo into the query string, building up
				// a string like "ce41-selectedIndex=1&10f7-selectedIndex=2"
				// that specifies objects (via the crcs of their paths),
				// property names, and property values.
				var crc:String = getRegistrationInfo(registeredObject).crc;
				
				// save the state of each registered object
				stateObject[crc] = stateInfo;
				
				for (var name:String in stateInfo) {
					var value:Object = stateInfo[name];
					
					if (queryString.length > 0)
						queryString += PROPERTY_SEPARATOR;
					queryString += crc;
					queryString += ID_NAME_SEPARATOR;
					queryString += escape(name);
					queryString += NAME_VALUE_SEPARATOR;
					queryString += escape(value.toString());
					//haveState = true;
				}
			}
			
			// when running standalone set haveState to false in order to bypass calling history.swf in a browser
			haveState = HistoryManager.instance.javaScriptEnabled;
			
			// If any registered objects specified any state information to save,
			// reload the history SWF with an URL that encodes all the state info.
			if (haveState) {
				pendingQueryString = queryString;
				Application.application.callLater(this.submitQuery);
			}
			
			// store the stateObject in backStates and reset forwardStates
			backStates.addItem(stateObject);
			forwardStates.removeAll();
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function submitQuery():void {
			if (pendingQueryString) {
				var url:String = historyURL + "&" + pendingQueryString;
				navigateToURL(new URLRequest(url), "_history");
				pendingQueryString = null;
				Application.application.resetHistory = true;
			}
		}
		
		private function initHandshake(event:TimerEvent):void {
			lc.send("history" + lconID, "register", appID + lconID);
		}
		
		private function statusHandler(event:StatusEvent):void {
		    //	    trace(event.level + " " + event.code);
		}
		
		public function registered():void {
			if (!isRegistered) {
				// We've successfully registered with the HistoryManager.
				isRegistered = true;
				
				// Kill the handshake timer since it is no longer needed.
				if (handshakeTimer != null) {
					handshakeTimer.reset();
					handshakeTimer = null;
				}
			}
		}
		
		public function registerHandshake():void {
			// Return the handshake.
			lc.send("history" + lconID, "registered");
			registered();
		}
		
		public function load(stateVars:Object):void {
			// Whenever we save state (by calling the save() method), load is called
			// to load the state we just saved. Most of the time this is harmless
			// (loadState methods are written to not do anything if they are at the
			// current state), but sometimes we get into timing issues where we are
			// loading a state that is older than the last state we saved.
			// To work around this, we ignore any load that immediately follows a 
			// call to save().
			if (Application.application.resetHistory) {
				Application.application.resetHistory = false;
				return;
			}
			var p:String;
			var crc:String;
				
			var params:Object = {};
			var stateObject:Object = new Object();
	
			// Unpack the stateVars into parameter objects for each state interface.
			// stateVars looks like
			//   { ce41-selectedIndex: 1, 10f7-selectedIndex: 2 }
			// params will look like
			//   { ce41: { selectedIndex: 1 }, 10f7: { selectedIndex: 2 } }
			for (p in stateVars) {
				var crclen:int = p.indexOf(ID_NAME_SEPARATOR)
				if (crclen > -1) {
					crc = p.substr(0, crclen);
					var name:String = p.substr(crclen + 1, p.length);
					var value:Object = stateVars[p];
					
					if (!params[crc]) {
						params[crc] = {};
						stateObject[crc] = {};
					}
					params[crc][name] = value;
					stateObject[crc][name] = value;
				}
			}
			
			// --
			
			/* stateObject looks like this:
				1dd2 = (Object)#1
					uid = "8"
				8820 = (Object)#2
					categoryTitle = "Introductie"
					pageTitle = "2.2 Frequentie"
					selectedCategoryIndex = "1"
					selectedPageIndex = "4"
			*/
			
			// get uid from stateObject
			var uid:uint = getUid(stateObject);
			
			var direction:String;
			var savedState:Object = getStateByUid(uid, backStates);
			if (savedState) {
				direction = "back";
			} else {
				savedState = getStateByUid(uid, forwardStates);
				if (savedState) {
					direction = "forward";
				}
			}
			
			var currentState:Object;
			if (direction == "back") {
				
				// remove current state and add to forwardStates
				currentState = backStates.removeItemAt(backStates.length - 1);
				forwardStates.addItem(currentState);
				
			} else if (direction == "forward") {
				
				// remove last added element and add loaded state to backStates
				if (forwardStates.length > 0) forwardStates.removeItemAt(forwardStates.length - 1);
				backStates.addItem(stateObject);
			}
			
			// --
			
			/*
			var currentEntry:Object = (backStates.length > 0) ? backStates.getItemAt(backStates.length-1) : null;
			var lastBackEntry:Object = (backStates.length > 0) ? backStates.getItemAt(backStates.length-2) : null;
			var lastForwardEntry:Object = (forwardStates.length > 0) ? forwardStates.getItemAt(forwardStates.length-1) : null;
			
			if (equals(stateObject, lastBackEntry)) {
				backStates.removeItemAt(backStates.getItemIndex(currentEntry));
				forwardStates.addItem(currentEntry);
				trace("going to: "+ObjectUtil.toString(lastBackEntry));
				
			} else if (equals(stateObject, lastForwardEntry)) {
				trace("state found in forwardStates");
			} else {
				trace("state not found in any history");
			}*/
			
			// remove states from backStates after found index
			// add state to forwardStates
			// dispatch a change event
			
			// --
			
			distributeLoadStates(params);
		}
		
		private function getUid(obj:Object):uint {
			for (var prop:String in obj) {
				var uid:uint = obj[prop]["uid"];
				if (uid > 0) return uid;
			}
			return 0;
		}
		
		private function getStateByUid(uid:uint, arr:ArrayCollection):Object {
			for (var i:uint=0; i<arr.length; i++) {
				var item:Object = arr.getItemAt(i);
				if (uid == getUid(item)) return item;
			}
			return null;
		}
		
		public function distributeLoadStates(stateObject:Object):void {
			var n:int = registeredObjects.length;
			for (var i:int = 0; i < n; i++) {
				var registeredObject:IHistoryManagerClient = registeredObjects[i];
				var crc:String = getRegistrationInfo(registeredObject).crc;
				
				// dodge nullException
				if (stateObject == null) {
					registeredObject.loadState(null);
					
				} else {
					registeredObject.loadState(stateObject[crc]);
					delete stateObject[crc];
				}
			}
			
			// Save off any remaining state variables in the pendingStates object.
			// This way the state can be restored if the interface
			// is instantiated later.
			for (var p:String in stateObject) {
				pendingStates[p] = stateObject[p];
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function loadInitialState():void {
			// Load up the initial application state.
			if (!Application.application.resetHistory) load({});
			Application.application.resetHistory = false;
		}
		
		private function equals(obj1:Object, obj2:Object, depth:int = 1, currentDepth:int = 0):Boolean {
			if (obj1 == null || obj2 == null) return false;
			if (obj1 == obj2) return true;
			
			for (var prop:String in obj1) {
				
				// test if property is simple, of not: recurse the object
				if (isSimple(obj1[prop])) {
					if (obj2[prop] != obj1[prop]) return false;
					
				// recurse unless target depth is reached
				} else if (currentDepth < depth-1) {
					var result:Boolean = equals(obj1[prop], obj2[prop], depth, currentDepth + 1);
					if (!result) return false;
				}
			}
			return true;
		}
		
		private function isSimple(value:Object):Boolean {
			var type:String = typeof(value);
			switch (type) {
				case "number":
				case "string":
				case "boolean": {
					return true;
				}
				case "object": {
					return (value is Date) || (value is Array);
				}
			}
			return false;
	    }
	    
	}
}

class RegistrationInfo {
	
	public var crc:String;
	public var depth:int;
	
	public function RegistrationInfo(crc:String, depth:int) {
		super();

		this.crc = crc;
		this.depth = depth;
	}
}

internal class SingletonLock {
}