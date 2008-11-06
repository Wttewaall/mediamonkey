/*
* Copyright 2004 Dirk Eismann
*/
import mx.utils.Delegate;

class nl.mediamonkey.utils.DelayedCall {
	/**
	* Creates a new DelayedCall instance 
   	*
   	* @description
	* DelayedCall postpones the invokation of a function or object method for a given 
	* amount of time. The parameters delay and func are mandatory, additional parameters 
	* can be added. All extra parameters will be used as input parameters to the 
	* receiving object's function. Example:
	*
	* <p>
	* <code>
	*  // After 3.5 seconds addressManager's addContacts() method will be called.
	*  // The parameters passed to the method are contactA and contactB
	*  new DelayedCall(3500, addressManager.addContacts, contactA, contactB);
	* </code>
	* </p>
	* @param	delay 	Amount of milliseconds to wait until the function call is being made
	* @param	func 	The function or object method to invoke after the delay
	*/
	public function DelayedCall(delay:Number, func:Function) {
		if (isNaN(delay)) return;
		if (!func instanceof Function) return;
		createCall(arguments);
	}
	
	
	/**
	* @description
	* Internal implementation, sets up the interval
	*/
	private function createCall(args:Array):Void {
		args.unshift(Delegate.create(this, timeout));
		interval = Number(setInterval.apply(null, args));
	}
	
	/**
	* @description
	* Internal implementation, calls the target function on the target object
	*/
	private function timeout():Void {
		clearInterval(interval);
		delete interval;
		arguments.shift().apply(null, arguments);
	}
	
	private var interval:Number;
	
}