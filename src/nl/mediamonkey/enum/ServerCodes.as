package nl.mediamonkey.enum {
	
	public final class ServerCodes {
		
		/** OK
		 * <p>The Web page appears as expected.</p> */
		public static const OK:uint = 200;
		
		/** Moved Permanently.
		 * <p>The Web page has been redirected permanently to another Web page URL.
		 * When a search engine spider sees this status code, it moves easily to the appropriate new page.
		 * A 301 Redirect status is NOT a problem for search engine optimization.</p> */
		public static const MOVED:uint = 301;
		
		/** Found (Moved Temporarily)
		 * <p>The Web page has been moved temporarily to a different URL.
		 * This status should raise a red flag if it’s on your Web server.
		 * Even though there are supposed to be legitimate uses for a 302 Redirect code,
		 * they can cause serious problems for your optimization efforts.
		 * Spammers frequently use 302 Redirects maliciously, so if you don’t want a
		 * search engine mistaking your site for a spam site, avoid them.</p> */
		public static const FOUND:uint = 302;
		
		/** Bad Request
		 * <p>The server could not understand the request because of bad syntax.
		 * This could be caused by a typo in the URL.
		 * Whatever the cause, you don’t want a search engine spider blocked from reaching
		 * your content pages, so investigate this if you see this status code on your site.</p> */
		public static const BAD_REQUEST:uint = 400;
		
		/** Unauthorized
		 * <p>The request requires user authentication.
		 * Usually this means that you need to log in before you can view the page content.
		 * Not a good error for spiders to hit.</p> */
		public static const UNAUTHORIZED:uint = 401;
		
		/** Forbidden
		 * <p>The server understood the request, but refuses to fulfill it.
		 * If you find this status code on your Web site, find out why.
		 * If you want to block the spiders from entering, there ought to be a good reason.</p> */
		public static const FORBIDDEN:uint = 403;
		
		/** Not Found
		 * <p>The Web page is not available.</p>
		 * <p>You’ve seen this error code; it’s the “Page Cannot Be Displayed” page that you
		 * see when a Web site is down or nonexistent. You definitely do not want a spider
		 * following a link to your Web site only to be greeted by a 404 error!
		 * That’s like arriving for a party and finding the lights off and the doors locked.
		 * If your server check shows you have a 404 error for one of your landing pages,
		 * you definitely want to fix it ASAP.</p> */
		public static const NOT_FOUND:uint = 404;
		
		/** The 500–505 status codes indicate that something’s wrong with your server. */
		public static const SERVER_ERROR0:uint = 500;
		
		/** The 500–505 status codes indicate that something’s wrong with your server. */
		public static const SERVER_ERROR1:uint = 501;
		
		/** The 500–505 status codes indicate that something’s wrong with your server. */
		public static const SERVER_ERROR2:uint = 502;
		
		/** The 500–505 status codes indicate that something’s wrong with your server. */
		public static const SERVER_ERROR3:uint = 503;
		
		/** The 500–505 status codes indicate that something’s wrong with your server. */
		public static const SERVER_ERROR4:uint = 504;
		
		/** The 500–505 status codes indicate that something’s wrong with your server. */
		public static const SERVER_ERROR5:uint = 505;
		
	}
}