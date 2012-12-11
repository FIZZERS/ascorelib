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
  public final class BitUtils
  {
    // ========================================================================
    //  Constants
    // ------------------------------------------------------------------------
    /**
     * An Array of length 32 where each element at a given index is set to
     * 2<sup>index</sup>.
     */
    public static const VALUE_TO_POSITION:Array = initValueToPosition();
    
    // ========================================================================
    //  Methods
    // ------------------------------------------------------------------------
    /** @private */
    private static function initValueToPosition():Array
    {
      var result:Array = [];
      
      for ( var i:uint = 0; i < 32; i++ )
        result[ 0x1 << i ] = i;
      
      return result;
    }
  }
}
