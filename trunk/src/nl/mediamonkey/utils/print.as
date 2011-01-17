package {
	
	import flash.globalization.DateTimeFormatter;
	
	public function print(...message:Array):void {
		
		var timeStamp		:String = "";
		var functionName	:String = "";
		var callerOffset	:Number= 3;
		
		try {
			timeStamp = new DateTimeFormatter("nl_NL", "none", "long").format(new Date());
		} catch(e) {}
		
		try {
			var stack:String = new Error().getStackTrace();
			var subStack:String = stack.split("\n\r\tat")[callerOffset]; 
			functionName = subStack.substring(0, subStack.indexOf("()") + 2);
	 
		} catch(e) {}
		
		trace(timeStamp + "\t" + functionName + "\t" + message.join(" "));
	}
	
}