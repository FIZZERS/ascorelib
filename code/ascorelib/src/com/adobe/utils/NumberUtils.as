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
  public class NumberUtils
  {
    // ========================================================================
    //  Constants
    // ------------------------------------------------------------------------
    public static const EPSILON:Number = 1.0e-8;
    
    // ========================================================================
    //  Methods
    // ------------------------------------------------------------------------
    /**
     * Performs a "fuzzy" equality comparison of two floating point numbers.
     * @param v1 value 1
     * @param v2 value 2
     * @return -1 if v1 < v2, 1 if v1 > v2, 0 if v1 == v2.
     */
    public static function compare( v1:Number, v2:Number ):Number
    {
      var v:Number = v1 - v2;
      return ( v > EPSILON ) ? 1 : ( ( v < -EPSILON ) ? -1 : 0 );
    }
    /**
     * Returns the sign of a floating point number. Result will be 1 if value
     * is greater than epsilon, -1 if is less than negative epsilon.
     */
    public static function sign( v:Number ):Number
    {
      return ( v > EPSILON ) ? 1 : ( ( v < -EPSILON ) ? -1 : 0 );
    }
  }
}
