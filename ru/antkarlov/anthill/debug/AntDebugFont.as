package ru.antkarlov.anthill.debug
{
	import XML;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.geom.Point;

	public class AntDebugFont extends Object
	{
		private static const DEST_POINT:Point = new Point();
		
		private var _bitmapData:BitmapData;
		private var _regions:Object;
		private var _points:Object;
		private var _chars:Vector.<String>;
		private var _frames:Vector.<BitmapData>;
		
		/**
		 * @constructor
		 */
		public function AntDebugFont(aGraphicClass:Class, aXMLClass:Class)
		{
			super();
			
			_regions = {};
			_points = {};
			_chars = new <String>[];
			_frames = new <BitmapData>[];
			
			_bitmapData = (new aGraphicClass).bitmapData;
			
			var data:ByteArray = new aXMLClass();
			var strXML:String = data.readUTFBytes(data.length);
			parseAtlasXML(new XML(strXML));
			
			getBitmaps(_frames);
		}
		
		/**
		 * @private
		 */
		public function parseAtlasXML(aFontXML:XML):void
		{
			for each (var char:XML in aFontXML.Char)
			{
				var name:String = char.attribute("name");
				var x:Number = parseFloat(char.attribute("x"));
				var y:Number = parseFloat(char.attribute("y"));
				var width:Number = parseFloat(char.attribute("w"));
				var height:Number = parseFloat(char.attribute("h"));
				var offsetX:Number = parseFloat(char.attribute("offsetX"));
				var offsetY:Number = parseFloat(char.attribute("offsetY"));
				var region:Rectangle = new Rectangle(x, y, width, height);
				var point:Point = new Point((isNaN(offsetX)) ? 0 : offsetX, (isNaN(offsetY)) ? 0 : offsetY);
				_regions[name] = region;
				_points[name] = point;
				_chars.push(name);
			}
		}
		
		/**
		 * @private
		 */
		public function getPoint(aName:String, aResult:Point = null):Point
		{
			if (aResult == null)
			{
				aResult = new Point();
			}
			
			if (_points.hasOwnProperty(aName))
			{
				aResult.x = _points[aName].x;
				aResult.y = _points[aName].y;
			}
			else
			{
				aResult.x = 0;
				aResult.y = 0;
			}
			
			return aResult;
		}
		
		/**
		 * @private
		 */
		public function getFrame(aName:String):BitmapData
		{
			var i:int = _chars.indexOf(aName);
			if (i >= 0 && i < _chars.length)
			{
				return _frames[i];
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		public function getBitmap(aName:String):BitmapData
		{
			var region:Rectangle = _regions[aName];
			if (region == null)
			{
				return null;
			}
			
			var bmpData:BitmapData = new BitmapData(region.width, region.height, true, 0);
			bmpData.copyPixels(_bitmapData, region, DEST_POINT);
			return bmpData;
		}
		
		/**
		 * @private
		 */
		public function getBitmaps(aResult:Vector.<BitmapData> = null):Vector.<BitmapData>
		{
			if (aResult == null)
			{
				aResult = new <BitmapData>[];
			}
			
			const n:int = _chars.length;
			var i:int = 0;
			while (i < n)
			{
				aResult.push(getBitmap(_chars[i++]));
			}
			
			return aResult;
		}
		
	}

}