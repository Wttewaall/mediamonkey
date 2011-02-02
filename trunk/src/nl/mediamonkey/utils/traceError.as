package nl.mediamonkey.utils {
	
	//import flash.globalization.DateTimeFormatter;
	import mx.formatters.DateFormatter;
	
	public function traceError(...message:Array):void {
		
		var timeStamp		:String = "";
		var functionName	:String = "";
		var callerOffset	:Number = 2;
		
		try {
			//timeStamp = new DateTimeFormatter("nl_NL", "none", "long").format(new Date());
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "HH:NN:SS";
			timeStamp = formatter.format(new Date());
			
		} catch(e:Error) {}
		
		try {
			var stack:String = new Error().getStackTrace();
			var subStack:String = stack.split("at ")[callerOffset];
			functionName = subStack.substring(0, subStack.indexOf("()") + 2);
	 
		} catch(e:Error) {}
		
		trace(timeStamp + "\t" + functionName + "\t" + message.join(" "));
	}
	
}