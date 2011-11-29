package nl.mediamonkey.utils {
	
	public function error(...message:Array):void {
		
		var functionName	:String = "";
		var callerOffset	:Number = 2;
		
		try {
			var stack:String = new Error().getStackTrace();
			var subStack:String = stack.split("at ")[callerOffset];
			functionName = subStack.substring(0, subStack.indexOf("()") + 2);
	 
		} catch(e:Error) {}
		
		trace("[ERROR] "+functionName+"\t"+message.join(" "));
	}
	
}