////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

// Originally mx.utils.ObjectUtil

package nl.mediamonkey.utils
{

import flash.utils.Dictionary;

/**
 *  The ObjectUtil class is an all-static class with methods for
 *  working with Objects within Flex.
 *  You do not create instances of ObjectUtil;
 *  instead you simply call static methods such as the 
 *  <code>ObjectUtil.isSimple()</code> method.
 */
public class CompareUtil
{
	
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
	
    /**
     *  Compares the Objects and returns an integer value 
     *  indicating if the first item is less than greater than or equal to
     *  the second item.
     *  This method will recursively compare properties on nested objects and
     *  will return as soon as a non-zero result is found.
     *  By default this method will recurse to the deepest level of any property.
     *  To change the depth for comparison specify a non-negative value for
     *  the <code>depth</code> parameter.
     *
     *  @param a Object.
     *
     *  @param b Object.
     *
     *  @param depth Indicates how many levels should be 
     *  recursed when performing the comparison.
     *  Set this value to 0 for a shallow comparison of only the primitive 
     *  representation of each property.
     *  For example:<pre>
     *  var a:Object = {name:"Bob", info:[1,2,3]};
     *  var b:Object = {name:"Alice", info:[5,6,7]};
     *  var c:int = ObjectUtil.compare(a, b, 0);</pre>
     *
     *  <p>In the above example the complex properties of <code>a</code> and 
     *  <code>b</code> will be flattened by a call to <code>toString()</code>
     *  when doing the comparison.
     *  In this case the <code>info</code> property will be turned into a string
     *  when performing the comparison.</p>
     *
     *  @return Return 0 if a and b are null, NaN, or equal. 
     *  Return 1 if a is null or greater than b. 
     *  Return -1 if b is null or greater than a. 
     */
    public static function compare(a:Object, b:Object, depth:int = -1):int
    {
        return internalCompare(a, b, 0, depth, new Dictionary(true));
    }
    
    /**
     *  Returns <code>true</code> if the object reference specified
     *  is a simple data type. The simple data types include the following:
     *  <ul>
     *    <li><code>String</code></li>
     *    <li><code>Number</code></li>
     *    <li><code>uint</code></li>
     *    <li><code>int</code></li>
     *    <li><code>Boolean</code></li>
     *    <li><code>Date</code></li>
     *    <li><code>Array</code></li>
     *  </ul>
     *
     *  @param value Object inspected.
     *
     *  @return <code>true</code> if the object specified
     *  is one of the types above; <code>false</code> otherwise.
     */
    public static function isSimple(value:Object):Boolean
    {
        var type:String = typeof(value);
        switch (type)
        {
            case "number":
            case "string":
            case "boolean":
            {
                return true;
            }

            case "object":
            {
                return (value is Date) || (value is Array);
            }
        }

        return false;
    }

    /**
     *  Compares two numeric values.
     * 
     *  @param a First number.
     * 
     *  @param b Second number.
     *
     *  @return 0 is both numbers are NaN. 
     *  1 if only <code>a</code> is a NaN.
     *  -1 if only <code>b</code> is a NaN.
     *  -1 if <code>a</code> is less than <code>b</code>.
     *  1 if <code>a</code> is greater than <code>b</code>.
     */
    public static function numericCompare(a:Number, b:Number):int
    {
        if (isNaN(a) && isNaN(b))
            return 0;

        if (isNaN(a))
            return 1;

        if (isNaN(b))
           return -1;

        if (a < b)
            return -1;

        if (a > b)
            return 1;

        return 0;
    }

    /**
     *  Compares two String values.
     * 
     *  @param a First String value.
     * 
     *  @param b Second String value.
     *
     *  @param caseInsensitive Specifies to perform a case insensitive compare, 
     *  <code>true</code>, or not, <code>false</code>.
     *
     *  @return 0 is both Strings are null. 
     *  1 if only <code>a</code> is null.
     *  -1 if only <code>b</code> is null.
     *  -1 if <code>a</code> precedes <code>b</code>.
     *  1 if <code>b</code> precedes <code>a</code>.
     */
    public static function stringCompare(a:String, b:String,
                                         caseInsensitive:Boolean = false):int
    {
        if (a == null && b == null)
            return 0;

        if (a == null)
          return 1;

        if (b == null)
           return -1;

        // Convert to lowercase if we are case insensitive.
        if (caseInsensitive)
        {
            a = a.toLocaleLowerCase();
            b = b.toLocaleLowerCase();
        }

        var result:int = a.localeCompare(b);
        
        if (result < -1)
            result = -1;
        else if (result > 1)
            result = 1;

        return result;
    }

    /**
     *  Compares the two Date objects and returns an integer value 
     *  indicating if the first Date object is before, equal to, 
     *  or after the second item.
     *
     *  @param a Date object.
     *
     *  @param b Date object.
     *
     *  @return 0 if <code>a</code> and <code>b</code>
     *  are <code>null</code> or equal; 
     *  1 if <code>a</code> is <code>null</code>
     *  or before <code>b</code>; 
     *  -1 if <code>b</code> is <code>null</code>
     *  or before <code>a</code>. 
     */
    public static function dateCompare(a:Date, b:Date):int
    {
        if (a == null && b == null)
            return 0;

        if (a == null)
          return 1;

        if (b == null)
           return -1;

        var na:Number = a.getTime();
        var nb:Number = b.getTime();
        
        if (na < nb)
            return -1;

        if (na > nb)
            return 1;

        return 0;
    }
    
    /**
     *  @private
     *  This method will append a newline and the specified number of spaces
     *  to the given string.
     */
    private static function newline(str:String, n:int = 0):String
    {
        var result:String = str;
        result += "\n";
        
        for (var i:int = 0; i < n; i++)
        {
            result += " ";
        }
        return result;
    }
    
    private static function internalCompare(a:Object, b:Object,
                                            currentDepth:int, desiredDepth:int,
                                            refs:Dictionary):int
    {
        if (a == null && b == null)
            return 0;
    
        if (a == null)
            return 1;
    
        if (b == null)
            return -1;
            
        var typeOfA:String = typeof(a);
        var typeOfB:String = typeof(b);
        
        var result:int = 0;
        
        if (typeOfA == typeOfB)
        {
            switch(typeOfA)
            {
                case "boolean":
                {
                    result = numericCompare(Number(a), Number(b));
                    break;
                }
                
                case "number":
                {
                    result = numericCompare(a as Number, b as Number);
                    break;
                }
                
                case "string":
                {
                    result = stringCompare(a as String, b as String);
                    break;
                }
                
                case "object":
                {
                    var newDepth:int = desiredDepth > 0 ? desiredDepth -1 : desiredDepth;
                    // refs help us avoid circular reference infinite recursion.
                    // Each time an object is encoumtered it is pushed onto the
                    // refs stack so that we can determine if we have visited
                    // this object already.
                    // Here since we are comparing two objects we can short
                    // circuit at the first encounter but have to exhaust all
                    // references found.  A visited reference makes an object 
                    // "greater" than another object, only if both objects
                    // have a visited reference will the result be 0
                    var aRef:Boolean = refs[a];
                    var bRef:Boolean = refs[b];
                    
                    if (aRef && !bRef)
                        return 1;
                    else if (bRef && !aRef)
                        return -1;
                    else if (bRef && aRef)
                        return 0;
                    
                    refs[a] = true;
                    refs[b] = true;
                    
                    if (desiredDepth != -1 && (currentDepth > desiredDepth))
                    {
                        // once we try to go beyond the desired depth we should 
                        // toString() our way out
                        result = stringCompare(a.toString(), b.toString());
                    }
                    else if ((a is Array) && (b is Array))
                    {
                        result = arrayCompare(a as Array, b as Array, currentDepth, desiredDepth, refs);
                    }
                    else if ((a is Date) && (b is Date))
                    {
                        result = dateCompare(a as Date, b as Date);
                    }
                    else
                    {
                        // We must be inequal, so return 1
                        return 1;
                    }
                    break;
                }
            }
        }
        else // be consistent with the order we return here
        {
            return stringCompare(typeOfA, typeOfB);
        }

        return result;
    }
    
    /**
     *  @private
     */
    private static function arrayCompare(a:Array, b:Array,
                                         currentDepth:int, desiredDepth:int,
                                         refs:Dictionary):int
    {
        var result:int = 0;

        if (a.length != b.length)
        {
            if (a.length < b.length)
                result = -1;
            else
                result = 1;
        }
        else
        {
            var key:Object;
            for (key in a)
            {
                if (b.hasOwnProperty(key))
                {
                    result = internalCompare(a[key], b[key], currentDepth,
                                         desiredDepth, refs);

                    if (result != 0)
                        return result;
                }
                else
                {
                    return -1;
                }
            }

            for (key in b)
            {
                if (!a.hasOwnProperty(key))
                {
                    return 1;
                }
            }
        }

        return result;
    }
    
}

}