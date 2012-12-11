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
package com.adobe.images
{
  // ==========================================================================
  //  Imports
  // --------------------------------------------------------------------------
  import com.adobe.display.Color;
  
  import flash.display.BitmapData;
  import flash.display.Shader;
  import flash.filters.ShaderFilter;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.utils.ByteArray;
  
  // ==========================================================================
  //  Class
  // --------------------------------------------------------------------------
  public class ImageUtils
  {
    // ========================================================================
    // Embedded Resources
    // ------------------------------------------------------------------------
    [ Embed( source="/../res/kernels/out/SphericalToCubic.pbj",
      mimeType="application/octet-stream" ) ]
    private static var SphericalToCubic:Class;
    
    [ Embed( source="/../res/kernels/out/HeightToNormal.pbj",
      mimeType="application/octet-stream" ) ]
    private static var HeightToNormal:Class;
    
    [ Embed( source="/../res/kernels/out/CentralDifference.pbj",
      mimeType="application/octet-stream" ) ]
    private static var CentralDifference:Class;
    
    // ========================================================================
    //  Properties
    // ------------------------------------------------------------------------
    public static var CUBE_FACE_MAX_SIZE:uint = 1024;
    
    // ========================================================================
    //  Methods
    // ------------------------------------------------------------------------
    /**
     * Converts a spherical map to a cube map made up of 6 tiles.
     * 
     * @param data Input image data.
     * @param size Desired output pixel size. Will be clamped to
     * ImageUtils.CUBE_FACE_MAX_SIZE. If set to zero, the smaller edge of the
     * source bitmap will determine the output size.
     * @param flipX Flag to flip cube map in X axis.
     * @param flipY Flag to flip cube map in Y axis.
     * @param flipZ Flag to flip cube map in Z axis.
     * @return A Vector of 6 BitmapDatas, one for each cube face. Results are
     * packed in the following order: +x, -x, +y, -y, +z, -z.
     */
    public static function convertSphericalToCubic(
      data:BitmapData,
      size:int = 0,
      flipX:Boolean = false,
      flipY:Boolean = false,
      flipZ:Boolean = false
    ):Vector.<BitmapData>
    {
      var result:Vector.<BitmapData> = new Vector.<BitmapData>( 6, true );
      
      var shader:Shader = new Shader( new SphericalToCubic() as ByteArray );
      
      var dstSize:uint = size ? size : Math.min( 6, data.width, data.height );
      
      shader.data[ "dstSize" ].value = [ dstSize ];
      shader.data[ "srcWidth" ].value = [ data.width ];
      shader.data[ "srcHeight" ].value = [ data.height ];
      shader.data[ "flipX" ].value = [ flipX ? 1 : 0 ];
      shader.data[ "flipY" ].value = [ flipY ? 1 : 0 ];
      shader.data[ "flipZ" ].value = [ flipZ ? 1 : 0 ];
      
      var rect:Rectangle = new Rectangle( 0, 0, dstSize, dstSize ); 
      var point:Point = new Point();
      var shaderFilter:ShaderFilter = new ShaderFilter( shader );
      
      for ( var i:uint = 0; i < 6; i++ )
      {
        var face:BitmapData = new BitmapData( dstSize, dstSize, false, 0 );
        
        shader.data[ "face" ].value = [ i ];
        face.applyFilter( data, rect, point, shaderFilter );
        
        result[ i ] = face;
      }
      
      return result;
    }
    
    /**
     * Converts a height map to a normal map. The red channel is used used as
     * the source in a non greyscale image.
     * 
     * @param data Input image data.
     * @param scale Output scale factor for the normal.
     * @return A new BitmapData containging the normal map.
     */
    public static function convertHeightToNormal(
      data:BitmapData,
      scale:Number = 1
    ):BitmapData
    {
      var w:uint = data.width;
      var h:uint = data.height;
      
      var result:BitmapData = new BitmapData( w, h, false, 0 );
      
      var shader:Shader = new Shader( new HeightToNormal() as ByteArray );
      
      shader.data[ "width" ].value = [ w ];
      shader.data[ "height" ].value = [ h ];
      shader.data[ "scale" ].value = [ scale ];
      
      var rect:Rectangle = new Rectangle( 0, 0, w, h ); 
      var point:Point = new Point();
      var shaderFilter:ShaderFilter = new ShaderFilter( shader );
      
      result.applyFilter( data, rect, point, shaderFilter );
      
      return result;
    }
    
    /**
     * Calculates a central difference map from a provided BitmapData.
     * 
     * @param data Input image data.
     * @return A new BitmapData containg the central difference map.
     */
    public static function computeCentralDifference(
      data:BitmapData
    ):BitmapData
    {
      var w:uint = data.width;
      var h:uint = data.height;
      
      var result:BitmapData = new BitmapData( w, h, false, 0 );
      
      var shader:Shader = new Shader( new CentralDifference() as ByteArray );
      
      shader.data[ "width" ].value = [ w ];
      shader.data[ "height" ].value = [ h ];
      
      var rect:Rectangle = new Rectangle( 0, 0, w, h ); 
      var point:Point = new Point();
      var shaderFilter:ShaderFilter = new ShaderFilter( shader );
      
      result.applyFilter( data, rect, point, shaderFilter );
      
      return result;
    }
    
    /**
     * Creates a BitmapData with a horizontal color ramp.
     * 
     * @param width The width of the result.
     * @param height The height of the result.
     * @param saturation The saturation [0, 1] of the color ramp.
     * @param value The value [0, 1] of the color ramp.
     * @return A BitmapData filled with a color ramp.
     */
    public static function generateColorRamp(
      width:uint = 360,
      height:uint = 1,
      saturation:Number = .85,
      value:Number = 1
    ):BitmapData
    {
      var result:BitmapData = new BitmapData( width, height, false );
      
      width = Math.max( width, 1 ); 
      height = Math.max( height, 1 ); 
      
      var x:uint;
      
      if ( height == 1 )
      {
        for ( x = 0; x < width; x++ )
          result.setPixel( x, 0, Color.hsv2rgb( x / width * 360, saturation, value ) );
      }
      else
      {
        var rect:Rectangle = new Rectangle( 0, 0, 1, height );
        
        for ( x = 0; x < width; x++ )
        {
          rect.x = x;
          result.fillRect( rect, Color.hsv2rgb( x / width * 360, saturation, value ) );
        }
      }
      
      return result;
    }
    
    /**
     * Creates a BitmapData with a horizontal greyscale ramp.
     * 
     * @param width The width of the result.
     * @param height The height of the result.
     * @return A BitmapData filled with a greyscale ramp.
     */
    public static function generateGreyscaleRamp(
      width:uint = 256,
      height:uint = 1
    ):BitmapData
    {
      var result:BitmapData = new BitmapData( width, height, false );
      
      var x:uint;
      var v:Number;
      
      if ( height == 1 )
      {
        for ( x = 0; x < width; x++ )
        {
          v = x / width * 255;
          result.setPixel( x, 0, 0x000000 | v << 16 | v << 8 | v );
        }
      }
      else
      {
        var rect:Rectangle = new Rectangle( 0, 0, 1, height );
        
        for ( x = 0; x < width; x++ )
        {
          rect.x = x;
          v = x / width * 255;
          var color:uint = 0x000000 | v << 16 | v << 8 | v;
          result.fillRect( rect, color );
        }
      }
      
      return result;
    }
  }
}
