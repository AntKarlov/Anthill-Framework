package ru.antkarlov.anthill.debug
{
	import flash.display.DisplayObjectContainer;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;	
	import flash.geom.Rectangle;
	
	import ru.antkarlov.anthill.AntMath;
	
	/**
	 * Класс строящий и отрисовывающий графики.
	 * Используется только в отладочных иснтрументах для Anthill.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  14.01.2015
	 */
	public class AntChart extends Sprite
	{
		public static var C_TRANSPARENT:uint = 0x00000000;
		public static var C_WHITE:uint = 0xFFe5dbc6;
		public static var C_GRAY:uint = 0xFF414141;
		public static var C_GREEN:uint = 0xFF96d130;
		public static var C_BLUE:uint = 0xFF34b7f4;
		public static var C_YELLOW:uint = 0xFFfcb41b;
		public static var C_ORANGE:uint = 0xFFef7000;
		public static var C_RED:uint = 0xFFef7000;
		
		private var _maxCols:int;
		private var _colWidth:int;
		private var _colHeight:int;
		
		private var _isUpdating:Boolean;
		private var _isLegendVisible:Boolean;
		
		private var _names:Vector.<String>;
		private var _objects:Vector.<Object>;
		
		private var _upperValue:Number;
		private var _lowerValue:Number;
		
		private var _display:Bitmap;
		private var _buffer:BitmapData;
		private var _bufferWidth:int;
		private var _bufferHeight:int;
		private var _graphWidth:int;
		private var _graphHeight:int;
		private var _flashRect:Rectangle;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntChart(aParent:DisplayObjectContainer = null, aX:int = 0, aY:int = 0, aLegend:Boolean = true)
		{
			super();
			
			_colWidth = 3;
			_colHeight = 35;
			_maxCols = 32;
			
			_isUpdating = false;
			_isLegendVisible = aLegend;
			
			_names = new Vector.<String>();
			_objects = new Vector.<Object>();
			
			_upperValue = Number.MIN_VALUE;
			_lowerValue = Number.MAX_VALUE;
			
			x = aX;
			y = aY;
			
			if (aParent != null)
			{
				aParent.addChild(this);	
			}
			
			_flashRect = new Rectangle();
			_display = new Bitmap();
			addChild(_display);
			
			updateBuffer();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function add(aName:String, aColor:uint, aPointer:Boolean = false, aDecimals:int = 0):void
		{
			if (!has(aName))
			{
				_names.push(aName);
				_objects.push({ color:aColor, 
					values:[], 
					pointer:aPointer, 
					labelName:AntTextHelper.makeLabel(this, 0, 0, aName, "left", "systemSmall", aColor),
					labelValue:AntTextHelper.makeLabel(this, 0, 0, "?", "right", "systemSmall", C_WHITE),
					decimals:aDecimals });
				updateBuffer();
			}
		}
		
		/**
		 * @private
		 */
		public function remove(aName:String):void
		{
			var i:int = _names.indexOf(aName);
			if (i >= 0 && i < _names.length)
			{
				_names[i] = null;
				_names.splice(i, 1);
				
				var obj:Object = _objects[i];
				removeChild(obj.labelName);
				removeChild(obj.labelValue);
				_objects[i] = null;
				_objects[i].splice(i, 1);
				
				updateBuffer();
			}
		}
		
		/**
		 * @private
		 */
		public function has(aName:String):Boolean
		{
			return (get(aName) != null);
		}
		
		/**
		 * @private
		 */
		public function get(aName:String):Object
		{
			var i:int = _names.indexOf(aName);
			if (i >= 0 && i < _names.length)
			{
				return _objects[i];
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		public function update(aName:String, aValue:Number):void
		{
			var o:Object = get(aName);
			if (o != null)
			{
				if (o.values.length >= _maxCols)
				{
					o.values.pop();
				}
				
				o.values.unshift(aValue);
				draw();
			}
		}
		
		/**
		 * @private
		 */
		public function beginUpdate():void
		{
			_isUpdating = true;
		}
		
		/**
		 * @private
		 */
		public function endUpdate(aRedraw:Boolean = true):void
		{
			_isUpdating = false;
			
			if (aRedraw)
			{
				draw();
			}
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		private function updateRange():void
		{
			/*
				Минимальное значение не обнуляется, ичане самый низкий 
				показатель почти всегда будет ниже плинтуса.
			*/
			_upperValue = Number.MIN_VALUE;
			//_lowerValue = Number.MAX_VALUE;
			
			var i:int = 0;
			var j:int = 0;
			var n:int = _objects.length;
			var k:int = 0;
			var value:Number;
			var obj:Object;
			while (i < n)
			{
				obj = _objects[i++];
				j = 0;
				k = obj.values.length;
				while (j < k)
				{
					value = obj.values[j++];
					_upperValue = (value > _upperValue) ? value : _upperValue;
					_lowerValue = (value < _lowerValue) ? value : _lowerValue;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function updateBuffer():void
		{
			_bufferWidth = _graphWidth = (_maxCols * _colWidth + _maxCols + 2) + 5;
			_bufferHeight = _graphHeight = (_colHeight + 3) + 5;
			
			if (legendVisible)
			{
				_bufferHeight += _objects.length * 9 + _objects.length + 1;
			}
				
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = _bufferWidth;
			_flashRect.height = _bufferHeight;
			
			if (_buffer != null)
			{
				_buffer.dispose();
				_buffer = null;
			}
			
			_buffer = new BitmapData(_bufferWidth, _bufferHeight, true, C_TRANSPARENT);
			_display.bitmapData = _buffer;
		}
		
		/**
		 * @private
		 */
		private function draw():void
		{
			if (!_isUpdating)
			{
				updateRange();
				
				AntDrawer.setCanvas(_buffer, true);
				_buffer.lock();
				
				AntDrawer.fillRect(0, 0, _bufferWidth, _bufferHeight, C_TRANSPARENT);
				AntDrawer.drawRect(2, 2, _graphWidth - 5, _graphHeight - 5, C_GRAY);
				
				var i:int = 0;
				while (i < _maxCols)
				{
					drawObject(i++);
				}
				
				_buffer.unlock();
			}
		}
		
		/**
		 * @private
		 */
		private function drawObject(aValueIndex:int):void
		{
			var i:int = 0;
			var n:int = _objects.length;
			var values:Array = [];
			var obj:Object;
			while (i < n)
			{
				obj = _objects[i];
				if (obj.values.length > aValueIndex)
				{
					values.push({ value:obj.values[aValueIndex], color:obj.color, pointer:obj.pointer });
				}
				
				drawRow(i);
				i++;
			}
			
			values.sortOn("value", Array.NUMERIC | Array.DESCENDING);
			i = 0;
			n = values.length;
			while (i < n)
			{
				obj = values[i++];
				drawCol(aValueIndex, obj.value, obj.color, obj.pointer);
			}
		}
		
		/**
		 * @private
		 */
		private function drawRow(aIndex:int):void
		{
			if (_isLegendVisible)
			{
				var obj:Object = _objects[aIndex];
				var dx:int = 2;
				var dy:int = _colHeight + 7 + aIndex * 9 + aIndex + 1;
				var w:int = _maxCols * _colWidth + _maxCols + 3;
				var h:int = 9;
				var offsetX:int = w * 0.2;
				
				AntDrawer.fillRect(dx, dy, w, h, C_GRAY);				
				AntDrawer.fillRect(dx, dy, _colWidth, h, obj.color);
			
				obj.labelName.x = 6;
				obj.labelName.y = dy - 2;
			
				obj.labelValue.x = w - offsetX - obj.labelValue.width;
				obj.labelValue.y = dy - 2;
				obj.labelValue.text = (obj.values.length > 0) ? obj.values[0].toFixed(obj.decimals) : "?";
			
				var rateRange:Number = _upperValue - _lowerValue;
				var value:Number = (obj.values.length > 0) ? obj.values[0] : 0;
				value = (value - _lowerValue) / rateRange;
				if (!isNaN(value))
				{
					AntDrawer.fillRect(w - offsetX + 2, dy, Math.round(offsetX * value), h, obj.color);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function drawCol(aIndex:int, aValue:Number, aColor:uint, aPointer:Boolean):void
		{
			var rateRange:Number = _upperValue - _lowerValue;
			var value:Number = (aValue - _lowerValue) / rateRange;
					
			if (!isNaN(value))
			{
				var dx:int = 4 + aIndex * _colWidth + aIndex;
				var dy:int = 4 + _colHeight;
				var dy2:int = Math.round(-value * _colHeight);
								
				AntDrawer.fillRect(dx, dy, _colWidth, dy2 - 1, C_GRAY);				
				AntDrawer.fillRect(dx, dy, _colWidth, dy2, aColor);
				
				if (aPointer && aIndex == 0)
				{
					drawPointer(value, aColor);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function drawPointer(aPosition:Number, aColor:uint):void
		{
			var dx:int = 0;
			var dy:int = 4 + _colHeight + Math.round(-aPosition * _colHeight) - 3;
			
			AntDrawer.moveTo(dx, dy);
			AntDrawer.lineTo(dx + 2, dy + 2, aColor);
			AntDrawer.lineTo(dx, dy + 4, aColor);
			AntDrawer.lineTo(dx, dy, aColor);
			AntDrawer.drawPoint(dx + 1, dy + 2, aColor);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function get legendVisible():Boolean { return _isLegendVisible; }
		public function set legendVisible(aValue:Boolean):void
		{
			if (_isLegendVisible != aValue)
			{
				_isLegendVisible = aValue;
				updateBuffer();
				var i:int = _objects.length - 1;
				var obj:Object;
				while (i >= 0)
				{
					obj = _objects[i--];
					obj.labelName.visible = _isLegendVisible;
					obj.labelValue.visible = _isLegendVisible;
				}
				
				draw();
			}
		}
		
		/**
		 * @private
		 */
		public function get bufferWidth():int
		{
			return _bufferWidth;
		}
		
		/**
		 * @private
		 */
		public function get bufferHeight():int
		{
			return _bufferHeight;
		}
	
	}

}