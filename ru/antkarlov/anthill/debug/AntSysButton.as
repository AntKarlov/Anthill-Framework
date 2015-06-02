package ru.antkarlov.anthill.debug
{
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import XML;
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  06.05.2014
	 */
	public class AntSysButton extends Sprite
	{
		[Embed(source="../resources/Buttons.png")] protected static var ImgButtons:Class;
		[Embed(source="../resources/Buttons.xml", mimeType="application/octet-stream")] protected static var XmlButtons:Class;
		
		public static const CLOSE:String = "Close";
		public static const CONSOLE:String = "Console";
		public static const PERFOMANCE:String = "Perfomance";
		public static const MONITOR:String = "Monitor";
		public static const SOUND_ON:String = "SoundOn";
		public static const SOUND_OFF:String = "SoundOff";
		public static const MUSIC_ON:String = "MusicOn";
		public static const MUSIC_OFF:String = "MusicOff";
		public static const DEBUGDRAW_ON:String = "DebugdrawOn";
		public static const DEBUGDRAW_OFF:String = "DebugdrawOff";
		public static const ADD:String = "Add";
		public static const DEL:String = "Del";
		public static const CLEAR:String = "Clear";
		public static const EXIT:String = "Exit";
		public static const CURSOR:String = "Cursor";
		public static const MOVE_UP:String = "MoveUp";
		public static const MOVE_UP_RIGHT:String = "MoveUpRight";
		public static const MOVE_RIGHT:String = "MoveRight";
		public static const MOVE_DOWN_RIGHT:String = "MoveDownRight";
		public static const MOVE_DOWN:String = "MoveDown";
		public static const MOVE_DOWN_LEFT:String = "MoveDownLeft";
		public static const MOVE_LEFT:String = "MoveLeft";
		public static const MOVE_UP_LEFT:String = "MoveUpLeft";
		public static const OPTIONS:String = "Options";
		public static const PAUSE:String = "Pause";
		public static const PLAY:String = "Play";
		public static const PRINT:String = "Print";
		public static const SAVE:String = "Save";
		public static const LOAD:String = "Load";
		public static const WARNING:String = "Warning";
		public static const ANT:String = "Ant";
		public static const BUG:String = "Bug";
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var onClick:Function;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _kind:String;
		protected var _bmpNormal:BitmapData;
		protected var _bmpOver:BitmapData;
		protected var _display:Bitmap;
		protected var _isOver:Boolean;
		
		/**
		 * @constructor
		 */
		public function AntSysButton(aKind:String = CLOSE)
		{
			super();
			
			_bmpNormal = new BitmapData(12, 12);
			_bmpOver = new BitmapData(12, 12);
			
			_display = new Bitmap();
			addChild(_display);
			
			_isOver = false;
			
			kind = aKind;
			updateVisual();
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
			
			_bmpNormal.dispose();
			_bmpOver.dispose();
			_bmpNormal = null;
			_bmpOver = null;
			
			removeChild(_display);
			_display = null;
			
			onClick = null;
			
			removeHandlers();
		}
		
		/**
		 * Пересоздает визуальный образ кнопки.
		 * 
		 * @param	aKind	 Визуальный тип кнопки который необходимо создать.
		 */
		public function rebuildButton(aKind:String):void
		{
			_kind = aKind;
			var rect:Rectangle = getRegion(aKind);
			var p:Point = new Point();
			var img:Bitmap = new ImgButtons();
			var btn:BitmapData = new BitmapData(24, 12);
			btn.copyPixels(img.bitmapData, rect, p);
			
			var frame:Rectangle = new Rectangle(0, 0, 12, 12);
			_bmpNormal.copyPixels(btn, frame, p);
			
			frame.x += 12;
			_bmpOver.copyPixels(btn, frame, p);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обновляет визуальное состояние кнопки.
		 */
		protected function updateVisual():void
		{
			_display.bitmapData = (_isOver) ? _bmpOver : _bmpNormal;
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
		
		/**
		 * Возвращает позицию и размеры указанного типа кнопки на общем атласе.
		 * 
		 * @param	aKind	 Тип кнопки для которой необходимо получить регион.
		 * @param	aResult	 Указатель на прямоугольник в который может быть записан результат.
		 * @return		Возвращает позицию и размеры кнопки в общем атласе кнопок.
		 */
		protected function getRegion(aKind:String, aResult:Rectangle = null):Rectangle
		{
			if (aResult == null)
			{
				aResult = new Rectangle();
			}
			
			var data:ByteArray = new XmlButtons();
			var strXML:String = data.readUTFBytes(data.length);
			var buttonsXml:XML = new XML(strXML);
			
			var btnKind:String;
			for each (var subButton:XML in buttonsXml.SubButton)
			{
				btnKind = subButton.attribute("kind");
				if (btnKind == aKind)
				{
					aResult.x = parseFloat(subButton.attribute("x"));
					aResult.y = parseFloat(subButton.attribute("y"));
					aResult.width = parseFloat(subButton.attribute("w"));
					aResult.height = parseFloat(subButton.attribute("h"));
					break;
				}
			}
			
			return aResult;
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
				updateVisual();
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
				updateVisual();
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
		
		/**
		 * Определяет внешний вид кнопки.
		 */
		public function get kind():String { return _kind; }
		public function set kind(aValue:String):void
		{
			if (_kind != aValue)
			{
				rebuildButton(aValue);
			}
		}
	
	}

}
