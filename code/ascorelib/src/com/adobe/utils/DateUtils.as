// ============================================================================
//
//  Copyright 2012 Adobe Systems
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
// ============================================================================
package com.adobe.utils
{
  // ==========================================================================
  //  Class
  // --------------------------------------------------------------------------
  public final class DateUtils
  {
    // ========================================================================
    //  Methods
    // ------------------------------------------------------------------------
    /**
     * Converts a W3C Date and Time Format string to a native Date object.
     * <p><a href="http://wikipedia.org/wiki/ISO_8601">http://wikipedia.org/wiki/ISO_8601</a></p>
     * 
     * @param w3cdtString The W3C Date and Time Format string.
     * @return The new Date object set to the proper date and time.
     * @see DateUtils.toW3CDTF
     */
    public static function parseW3CDTF( w3cdtString:String ):Date
    {
      var result:Date;
      
      try
      {
        var offsetString:String;
        var multiplier:Number = 1;
        
        var dateString:String = w3cdtString.substring( 0, w3cdtString.indexOf( "T" ) );
        var dateComponents:Array = dateString.split( "-" );
        
        var year:Number = Number( dateComponents[ 0 ] );
        var month:Number = Number( dateComponents[ 1 ] );
        var date:Number = Number( dateComponents[ 2 ] );
        
        var timeString:String = w3cdtString.substring( w3cdtString.indexOf( "T" ) + 1 );
        
        if ( timeString.indexOf( "-" ) != -1 )
        {
          // UTC offset is negative
          multiplier = -1;
          offsetString = timeString.substring( timeString.indexOf( "-" ) + 1, timeString.length );
          timeString = timeString.substring( 0, timeString.indexOf( "-" ) );
        }
        else if ( timeString.indexOf( "+" ) != -1 )
        {
          // UTC offset is positive
          offsetString = timeString.substring( timeString.indexOf( "+" ) + 1, timeString.length );
          timeString = timeString.substring( 0, timeString.indexOf( "+" ) );
        }
        else 
        {
          // no UTC offset
          if ( timeString.indexOf( "Z" ) != -1 )
            timeString = timeString.replace( "Z", "" );
          else
            trace( "Malformed W3C date, no time zone designator!" );
          
          offsetString = "0:00";
        }
        
        var offsetHours:Number = Number( offsetString.substring( 0, offsetString.indexOf( ":" ) ) );
        var offsetMinutes:Number = Number( offsetString.substring( offsetString.indexOf( ":" ) + 1, offsetString.length ) );
        
        var timeArray:Array = timeString.split( ":" );
        var hour:Number = Number( timeArray.shift() );
        var minutes:Number = Number( timeArray.shift() );
        var secondsArray:Array = ( timeArray.length > 0 ) ? String( timeArray.shift() ).split( "." ) : null;
        var seconds:Number = ( secondsArray != null && secondsArray.length > 0 ) ? Number( secondsArray.shift() ) : 0;
        var milliseconds:Number = ( secondsArray != null && secondsArray.length > 0 ) ? 1000 * parseFloat( "0." + secondsArray.shift() ) : 0; 
        var utc:Number = Date.UTC( year, month - 1, date, hour, minutes, seconds, milliseconds );
        var offset:Number = ( ( ( offsetHours * 3600000 ) + ( offsetMinutes * 60000 ) ) * multiplier );
        result = new Date( utc - offset );
        
        if ( result.toString() == "Invalid Date" )
          throw new Error( "This date does not conform to W3CDTF." );
      }
      catch ( error:Error )
      {
        trace( "Unable to parse the string [" + w3cdtString + "] into a date.", error );
      }
      return result;
    }
    
    /**
     * Converts a native Date object to a W3C Date and Time Format string.
     * 
     * @param date The Date to be converted.
     * @param includeMilliseconds When set to true will included milliseconds
     * in the encoded date output string.
     * @return The string encoded in the W3C Date and Time Format.
     * @see DateUtils.parseW3CDTF
     */
    public static function toW3CDTF( date:Date, includeMilliseconds:Boolean = false ):String
    {
      var mo:Number = date.getUTCMonth();
      var d:Number = date.getUTCDate();
      var h:Number = date.getUTCHours();
      var m:Number = date.getUTCMinutes();
      var s:Number = date.getUTCSeconds();
      var ms:Number = date.getUTCMilliseconds();
      
      return (
        date.getUTCFullYear()
        + "-" + ( mo < 9 ? "0" + ( mo + 1 ) : ( mo + 1 ) )
        + "-" + ( d < 10 ? "0" + d : d )
        + "T" + ( h < 10 ? "0" + h : h )
        + ":" + ( m < 10 ? "0" + m : m )
        + ":" + ( s < 10 ? "0" + s : s )
        + ( includeMilliseconds && ms > 0 ? "." + ms : "" )
        + "Z" // -00:00
      );
    }
  }
}
