package ru.antkarlov.anthill.debug
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	/**
	 * Простая кнопка использующаяся только в отладочных визуальных классах.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  19.08.2012
	 */
	public class AntGlyphButton extends Sprite
	{
		[Embed(source="../resources/btn_close.png")] protected var ImgClose:Class;
		[Embed(source="../resources/btn_console.png")] protected var ImgConsole:Class;
		[Embed(source="../resources/btn_perfomance.png")] protected var ImgPerfomance:Class;
		[Embed(source="../resources/btn_monitor.png")] protected var ImgMonitor:Class;
		[Embed(source="../resources/btn_sound_on.png")] protected var ImgSoundOn:Class;
		[Embed(source="../resources/btn_sound_off.png")] protected var ImgSoundOff:Class;
		[Embed(source="../resources/btn_debugdraw_on.png")] protected var ImgDebugDrawOn:Class;
		[Embed(source="../resources/btn_debugdraw_off.png")] protected var ImgDebugDrawOff:Class;
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const CLOSE:String = "close";
		public static const CONSOLE:String = "console";
		public static const PERFOMANCE:String = "perfomance";
		public static const MONITOR:String = "monitor";
		public static const SOUND_ON:String = "sound on";
		public static const SOUND_OFF:String = "sound off";
		public static const DEBUGDRAW_ON:String = "debugdraw on";
		public static const DEBUGDRAW_OFF:String = "debugdraw off";
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var onClick:Function;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _normal:BitmapData;
		protected var _over:BitmapData;
		protected var _bitmap:Bitmap;
		protected var _kind:String;
		
		protected var _isOver:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntGlyphButton(aKind:String = "close")
		{
			super();
			_isOver = false;
			
			_normal = new BitmapData(12, 12);
			_over = new BitmapData(12, 12);
			
			kind = aKind;
			
			_bitmap = new Bitmap();
			addChild(_bitmap);
			
			updateVisualState();
			addHandlers();
			
			mouseEnabled = true;
			buttonMode = true;
		}
		
		/**
		 * Удаление кнопки и освобождение памяти.
		 */
		public function dispose():void
		{
			if (parent != null && parent.contains(this))
			{
				parent.removeChild(this);
			}
			
			_normal.dispose();
			_over.dispose();
			_normal = null;
			_over = null;
			
			removeChild(_bitmap);
			_bitmap = null;
			
			onClick = null;
			
			removeHandlers();
		}
		
		/**
		 * Определяет внешний вид кнопки.
		 */
		public function set kind(value:String):void
		{
			_kind = value;
			
			var img:Bitmap;
			switch (_kind)
			{
				case CLOSE :
					img = new ImgClose();
				break;
				
				case CONSOLE :
					img = new ImgConsole();
				break;
				
				case PERFOMANCE :
					img = new ImgPerfomance();
				break;
				
				case MONITOR :
					img = new ImgMonitor();
				break;
				
				case SOUND_ON :
					img = new ImgSoundOn();
				break;
				
				case SOUND_OFF :
					img = new ImgSoundOff();
				break;
				
				case DEBUGDRAW_ON :
					img = new ImgDebugDrawOn();
				break;
				
				case DEBUGDRAW_OFF :
					img = new ImgDebugDrawOff();
				break;
			}
			
			var fr:Rectangle = new Rectangle(0, 0, 12, 12);
			_normal.copyPixels(img.bitmapData, fr, new Point());
			
			fr.x += 12;
			_over.copyPixels(img.bitmapData, fr, new Point());
		}
		
		/**
		 * @private
		 */
		public function get kind():String
		{
			return _kind;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обновляет визуальное состояние кнопки.
		 */
		protected function updateVisualState():void
		{
			if (_isOver)
			{
				_bitmap.bitmapData = _over;
			}
			else
			{
				_bitmap.bitmapData = _normal;
			}
		}
		
		/**
		 * Устанавливает обработчики событий для работы кнопки.
		 */
		protected function addHandlers():void
		{
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		/**
		 * Удаляет обработчики событий для работы кнопки.
		 */
		protected function removeHandlers():void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			removeEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Обработчик события наведения курсора мыши на кнопку.
		 */
		private function mouseOverHandler(event:MouseEvent):void
		{
			if (!_isOver)
			{
				_isOver = true;
				updateVisualState();
			}
		}
		
		/**
		 * Обработчик события выхода курсора мыши за переделы кнопки.
		 */
		private function mouseOutHandler(event:MouseEvent):void
		{
			if (_isOver)
			{
				_isOver = false;
				updateVisualState();
			}
		}
		
		/**
		 * Обработчик события клика по кнопке.
		 */
		private function mouseClickHandler(event:MouseEvent):void
		{
			if (onClick != null)
			{
				(onClick as Function).apply(this);
			}
		}
		
	}

}