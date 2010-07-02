package nl.mediamonkey.utils {
	
	/**
	 * Taken and modified from: br.com.stimuli.loading.utils.SmartURL
	 */
	
	public class URLUtil {
		
		// ---- variables ----
		
		public var url				:String;
		public var protocol			:String;
		public var port				:uint;
		public var host				:String;
		public var path				:String;
		public var queryString		:String;
		public var queryObject		:Object;
		public var queryLength		:uint;
		public var fileName			:String;
		
		// ---- constructor ----
		
		public function URLUtil(url:String) {
			decode(url);
		}
		
		public function decode(url:String):void {
			this.url = url;
			resetProperties();
			
			var urlExpression:RegExp = /((?P<protocol>[a-zA-Z]+: \/\/)   (?P<host>[^:\/]*) (:(?P<port>\d+))?)?  (?P<path>[^?]*)? ((?P<query>.*))? /x;
			
			var match:* = urlExpression.exec(url);
			if (!match) return;
			
			protocol = Boolean(match.protocol) ? match.protocol : "http://";
			protocol = protocol.substr(0, protocol.indexOf("://"));
			host = match.host || null;
			port = match.port ? int(match.port) : 80;
			path = match.path;
			fileName = path.substring(path.lastIndexOf("/"), path.lastIndexOf("."));
			queryString = match.query;
			
			if (queryString) {
				queryObject = {};
				queryString = queryString.substr(1);
				
				var pair		:String;
				var value		:String;
				var varName		:String;
				
				queryLength = 0;
				
				for each (pair in queryString.split("&")) {
					varName = pair.split("=")[0];
					value = pair.split("=")[1];
					queryObject[varName] = value;
					queryLength++;
				}
			}
			
		}
		
		protected function resetProperties():void {
			protocol = "";
			port = 0;
			host = "";
			path = "";
			queryString = "";
			queryObject = null;
			queryLength = 0;
			fileName = "";
		}
		
		/** If called as <code>toString(true)</code> will output a verbose version of this URL.
		 **/
		public function toString(verbose:Boolean):String {
			return (verbose) ? url : "[URL] url:"+url+", protocol:"+protocol+", port:"+port+", host:"+host+", path:"+path+". queryLength:"+queryLength;
		}
		
	}
}
