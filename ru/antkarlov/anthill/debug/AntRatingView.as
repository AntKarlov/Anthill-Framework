package ru.antkarlov.anthill.debug
{
	import flash.display.DisplayObjectContainer;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Счетчик наглядно отображающий меняющиеся данные в большую или меньшую сторону.
	 * Используется только в отладочных инструментах Anthill.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  15.01.2015
	 */
	public class AntRatingView extends Sprite
	{
		public static const C_LOWER:uint = 0xffe22117;
		public static const C_UPPER:uint = 0xff96d130;
		public static const C_SIGN:uint = 0x8a816f;
		
		private var _buffer:BitmapData;
		private var _bitmap:Bitmap;
		
		private var _tfValue:TextField;
		private var _tfSign:TextField;
		
		private var _fUpper:TextFormat;
		private var _fLower:TextFormat;
		
		private var _value:Number;
		private var _reverseColors:Boolean;
		private var _decimals:int;
		private var _prevUpd:int;
		
		/**
		 * @constructor
		 */
		public function AntRatingView(aParent:DisplayObjectContainer = null, aX:int = 0, aY:int = 0, aSign:String = "")
		{
			super();
			
			_tfValue = AntTextHelper.makeLabel(this, 6, 0, "0", "left", "systemSmall", C_SIGN);
			_tfSign = AntTextHelper.makeLabel(this, 10, 0, aSign, "left", "systemSmall", C_SIGN);
			
			_fUpper = AntTextHelper.makeTextFormat("left", "systemSmall", C_UPPER);
			_fLower = AntTextHelper.makeTextFormat("left", "systemSmall", C_LOWER);
			
			_buffer = new BitmapData(5, 5, true, 0x00000000);
			_bitmap = new Bitmap(_buffer);
			_bitmap.y = 3;
			addChild(_bitmap);
			
			_reverseColors = false;
			_decimals = 1;
			_value = 0;
			_prevUpd = 0;
			
			x = aX;
			y = aY;
			
			if (aParent != null)
			{
				aParent.addChild(this);
			}
			
			updateView();
		}
		
		/**
		 * @private
		 */
		public function destroy():void
		{
			removeChild(_tfValue);
			_tfValue = null;
			
			removeChild(_tfSign);
			_tfSign = null;
			
			_fUpper = null;
			_fLower = null;
			
			removeChild(_bitmap);
			_bitmap = null;
			
			_buffer = null;
			
			if (parent != null)
			{
				removeChild(this);
			}
		}
		
		/**
		 * @private
		 */
		public function updateView():void
		{
			if (_prevUpd < 0)
			{
				updateAsLower();
			}
			else
			{
				updateAsUpper();
			}
		}
		
		/**
		 * @private
		 */
		private function updateAsLower():void
		{
			AntDrawer.setCanvas(_buffer, true);
			
			_buffer.lock();
			AntDrawer.fillRect(0, 0, 5, 5, 0x00000000);
			AntDrawer.moveTo(2, 4);
			AntDrawer.lineTo(0, 2, (_reverseColors) ? C_UPPER : C_LOWER);
			AntDrawer.lineTo(4, 2, (_reverseColors) ? C_UPPER : C_LOWER);
			AntDrawer.lineTo(2, 4, (_reverseColors) ? C_UPPER : C_LOWER);
			AntDrawer.drawPoint(2, 3, (_reverseColors) ? C_UPPER : C_LOWER);
			_buffer.unlock();
			
			_tfValue.setTextFormat((_reverseColors) ? _fUpper : _fLower, 0, _tfValue.text.length);
			_tfSign.x = _tfValue.x + _tfValue.textWidth + 2;
			
			_prevUpd = -1;
		}
		
		/**
		 * @private
		 */
		private function updateAsUpper():void
		{
			AntDrawer.setCanvas(_buffer, true);
			
			_buffer.lock();
			AntDrawer.fillRect(0, 0, 5, 5, 0x00000000);
			AntDrawer.moveTo(2, 1);
			AntDrawer.lineTo(4, 3, (_reverseColors) ? C_LOWER : C_UPPER);
			AntDrawer.lineTo(0, 3, (_reverseColors) ? C_LOWER : C_UPPER);
			AntDrawer.lineTo(3, 0, (_reverseColors) ? C_LOWER : C_UPPER);
			AntDrawer.drawPoint(2, 2, (_reverseColors) ? C_LOWER : C_UPPER);
			_buffer.unlock();
			
			_tfValue.setTextFormat((_reverseColors) ? _fLower : _fUpper, 0, _tfValue.text.length);
			_tfSign.x = _tfValue.x + _tfValue.textWidth + 2;
			
			_prevUpd = 1;
		}
		
		/**
		 * @private
		 */
		public function get value():Number { return _value; }
		public function set value(aValue:Number):void
		{
			if (_value != aValue)
			{
				_tfValue.text = aValue.toFixed(_decimals);
				
				if (aValue < _value)
				{
					_value = aValue;
					updateAsLower();
				}
				else if (aValue > _value)
				{
					_value = aValue;
					updateAsUpper();
				}
			}
		}
		
		/**
		 * @private
		 */
		public function get decimals():int { return _decimals; }
		public function set decimals(aValue:int):void
		{
			_decimals = aValue;
		}
		
		/**
		 * @private
		 */
		public function get reverseColors():Boolean { return _reverseColors; }
		public function set reverseColors(aValue:Boolean):void
		{
			if (_reverseColors != aValue)
			{
				_reverseColors = aValue;
				updateView();
			}
		}
	
	}

}