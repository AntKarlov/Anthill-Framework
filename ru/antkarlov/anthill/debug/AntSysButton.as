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
	public class AntSysButton extends Sprite
	{
		[Embed(source="../resources/btn_close.png")] protected var ImgClose:Class;
		[Embed(source="../resources/btn_console.png")] protected var ImgConsole:Class;
		[Embed(source="../resources/btn_perfomance.png")] protected var ImgPerfomance:Class;
		[Embed(source="../resources/btn_monitor.png")] protected var ImgMonitor:Class;
		[Embed(source="../resources/btn_sound_on.png")] protected var ImgSoundOn:Class;
		[Embed(source="../resources/btn_sound_off.png")] protected var ImgSoundOff:Class;
		[Embed(source="../resources/btn_music_on.png")] protected var ImgMusicOn:Class;
		[Embed(source="../resources/btn_music_off.png")] protected var ImgMusicOff:Class;
		[Embed(source="../resources/btn_debugdraw_on.png")] protected var ImgDebugDrawOn:Class;
		[Embed(source="../resources/btn_debugdraw_off.png")] protected var ImgDebugDrawOff:Class;
		
		[Embed(source="../resources/btn_add.png")] protected var ImgAdd:Class;
		[Embed(source="../resources/btn_del.png")] protected var ImgDel:Class;
		[Embed(source="../resources/btn_clear.png")] protected var ImgClear:Class;
		[Embed(source="../resources/btn_exit.png")] protected var ImgExit:Class;
		[Embed(source="../resources/btn_cursor.png")] protected var ImgCursor:Class;
		[Embed(source="../resources/btn_move_up.png")] protected var ImgMoveUp:Class;
		[Embed(source="../resources/btn_move_right_up.png")] protected var ImgMoveRightUp:Class;
		[Embed(source="../resources/btn_move_right.png")] protected var ImgMoveRight:Class;
		[Embed(source="../resources/btn_move_right_down.png")] protected var ImgMoveRightDown:Class;
		[Embed(source="../resources/btn_move_down.png")] protected var ImgMoveDown:Class;
		[Embed(source="../resources/btn_move_left_down.png")] protected var ImgMoveLeftDown:Class;
		[Embed(source="../resources/btn_move_left.png")] protected var ImgMoveLeft:Class;
		[Embed(source="../resources/btn_move_left_up.png")] protected var ImgMoveLeftUp:Class;
		[Embed(source="../resources/btn_options.png")] protected var ImgOptions:Class;
		[Embed(source="../resources/btn_pause.png")] protected var ImgPause:Class;
		[Embed(source="../resources/btn_play.png")] protected var ImgPlay:Class;
		[Embed(source="../resources/btn_print.png")] protected var ImgPrint:Class;
		[Embed(source="../resources/btn_save.png")] protected var ImgSave:Class;
		[Embed(source="../resources/btn_load.png")] protected var ImgLoad:Class;
		[Embed(source="../resources/btn_warning.png")] protected var ImgWarning:Class;
		[Embed(source="../resources/btn_ant.png")] protected var ImgAnt:Class;
		[Embed(source="../resources/btn_bug.png")] protected var ImgBug:Class;
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const CLOSE:uint = 0;
		public static const CONSOLE:uint = 1;
		public static const PERFOMANCE:uint = 2;
		public static const MONITOR:uint = 3;
		public static const SOUND_ON:uint = 4;
		public static const SOUND_OFF:uint = 5;
		public static const MUSIC_ON:uint = 6;
		public static const MUSIC_OFF:uint = 7;
		public static const DEBUGDRAW_ON:uint = 8;
		public static const DEBUGDRAW_OFF:uint = 9;
		public static const ADD:uint = 10;
		public static const DEL:uint = 11;
		public static const CLEAR:uint = 12;
		public static const EXIT:uint = 13;
		public static const CURSOR:uint = 14;
		public static const MOVE_UP:uint = 15;
		public static const MOVE_UP_RIGHT:uint = 16;
		public static const MOVE_RIGHT:uint = 17;
		public static const MOVE_RIGHT_DOWN:uint = 18;
		public static const MOVE_DOWN:uint = 19;
		public static const MOVE_MOVE_LEFT_DOWN:uint = 20;
		public static const MOVE_MOVE_LEFT:uint = 21;
		public static const MOVE_MOVE_LEFT_UP:uint = 22;
		public static const OPTIONS:uint = 23;
		public static const PAUSE:uint = 24;
		public static const PLAY:uint = 25;
		public static const PRINT:uint = 26;
		public static const SAVE:uint = 27;
		public static const LOAD:uint = 28;
		public static const WARNING:uint = 29;
		public static const ANT:uint = 30;
		public static const BUG:uint = 31;

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
		protected var _kind:uint;
		
		protected var _isOver:Boolean;
		protected var _classes:Array;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntSysButton(aKind:uint = 0)
		{
			super();
			
			_classes = [ ImgClose, ImgConsole, ImgPerfomance, 
				ImgMonitor, ImgSoundOn, ImgSoundOff, ImgMusicOn, ImgMusicOff, ImgDebugDrawOn,
				ImgDebugDrawOff, ImgAdd, ImgDel, ImgClear, ImgExit, ImgCursor, ImgMoveUp, ImgMoveRightUp,
				ImgMoveRight, ImgMoveRightDown, ImgMoveDown, ImgMoveLeftDown, ImgMoveLeft, ImgMoveLeftUp,
				ImgOptions, ImgPause, ImgPlay, ImgPrint, ImgSave, ImgLoad, ImgWarning, ImgAnt, ImgBug ];
			
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
		public function destroy():void
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
		public function set kind(value:uint):void
		{
			if (value >= 0 || value < _classes.length)
			{
				_kind = value;
				var img:Bitmap = new (_classes[_kind] as Class);
				var fr:Rectangle = new Rectangle(0, 0, 12, 12);
				_normal.copyPixels(img.bitmapData, fr, new Point());

				fr.x += 12;
				_over.copyPixels(img.bitmapData, fr, new Point());
			}
		}
		
		public function get kind():uint
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
			_bitmap.bitmapData = (_isOver) ? _over : _normal;
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
		protected function mouseOverHandler(event:MouseEvent):void
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
		protected function mouseOutHandler(event:MouseEvent):void
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
		protected function mouseClickHandler(event:MouseEvent):void
		{
			if (onClick != null)
			{
				(onClick as Function).apply(this, [ this ]);
			}
		}
		
	}

}