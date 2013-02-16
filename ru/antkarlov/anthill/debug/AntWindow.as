package ru.antkarlov.anthill.debug
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.events.MouseEvent;
	
	import ru.antkarlov.anthill.AntG;
	
	/**
	 * Базовый класс для отладчиков располагающихся в отдельных окнах. Данный класс 
	 * включает в себя все эелементы окон и осуществляет их работу.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  11.09.2012
	 */
	public class AntWindow extends Sprite
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		/**
		 * Имя шрифта использующееся в текстах.
		 */
		public static const FONT_NAME:String = "system";
		
		/**
		 * Размер шрифта использующегося в текстах.
		 */
		public static const FONT_SIZE:int = 8;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на родительское окно (AntDebugger).
		 */
		protected var _parent:Sprite;
		
		/**
		 * Размер окна по ширине.
		 */
		protected var _width:int;
		
		/**
		 * Размер окна по высоте.
		 */
		protected var _height:int;
		
		/**
		 * Смещение по X. Используется для перетаскивания окна.
		 */
		protected var _offsetX:int;
		
		/**
		 * Смещение по Y. Используется для перетаскивания окна.
		 */
		protected var _offsetY:int;
		
		/**
		 * Флаг определяющий производится ли перетаскивание окна.
		 */
		protected var _isMove:Boolean;
		
		/**
		 * Текстовая метка заголовка окна.
		 */
		protected var _tfTitle:TextField;
		
		/**
		 * Кнопка закрытия окна.
		 */
		protected var _btnClose:AntSysButton;
		
		/**
		 * Формат текста.
		 */
		protected var _fGray:TextFormat;
		protected var _fWhite:TextFormat;
		protected var _fButton:TextFormat;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntWindow(aParent:Sprite, aX:Number, aY:Number, aWidth:Number, aHeight:Number)
		{
			super();
			
			x = aX;
			y = aY;
			_width = aWidth;
			_height = aHeight;
			_offsetX = 0;
			_offsetY = 0;
			_isMove = false;
			
			_parent = aParent;
			create();
			draw();
			
			visible = false;
		}
		
		/**
		 * Отображает окно.
		 */
		public function show():void
		{
			if (!_parent.contains(this))
			{
				_parent.addChild(this);
				addHandlers();
				visible = true;
			}
		}
		
		/**
		 * Скрывает окно.
		 */
		public function hide():void
		{
			if (_parent.contains(this))
			{
				_parent.removeChild(this);
				removeHandlers();
				visible = false;
				AntG.stage.focus = null;
			}
		}
		
		/**
		 * Устанавливает заголовок окна.
		 * 
		 * @param	value	 Текстовый заголовок окна.
		 */
		public function set title(value:String):void
		{
			_tfTitle.text = value;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected function onClose(aButton:AntSysButton):void
		{
			hide();
		}
		
		/**
		 * Метод помошник для быстрого создания текстовых меток.
		 * 
		 * @param	aX	 Положение метки по X.
		 * @param	aY	 Положение метки по Y.
		 * @param	aTextFormat	 Текствое форматирование.
		 * @return		Возвращает указатель на созданный экземпляр текстовой метки.
		 */
		protected function makeLabel(aX:Number, aY:Number, aTextFormat:TextFormat = null):TextField
		{
			var tf:TextField = new TextField();
			tf.x = aX;
			tf.y = aY;
			tf.height = 16;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.antiAliasType = AntiAliasType.NORMAL;
			tf.gridFitType = GridFitType.PIXEL;
			tf.defaultTextFormat = aTextFormat;
			tf.text = "";
			return tf;
		}
		
		/**
		 * Устанавливает обработчики для работы окна.
		 */
		protected function addHandlers():void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * Удаляет обработчики для работы окна.
		 */
		protected function removeHandlers():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		/**
		 * Инициализация окна.
		 */
		protected function create():void
		{
			_fGray = new TextFormat(FONT_NAME, FONT_SIZE, 0x5e5f5f);
			_fWhite = new TextFormat(FONT_NAME, FONT_SIZE, 0xffffff);
			_fButton = new TextFormat(FONT_NAME, FONT_SIZE, 0xc7a863);
			
			_tfTitle = new TextField();
			_tfTitle.x = 2;
			_tfTitle.y -= 2;
			_tfTitle.width = 100;
			_tfTitle.height = 14;
			_tfTitle.multiline = false;
			_tfTitle.wordWrap = false;
			_tfTitle.embedFonts = true;
			_tfTitle.selectable = false;
			_tfTitle.antiAliasType = AntiAliasType.NORMAL;
			_tfTitle.gridFitType = GridFitType.PIXEL;
			_tfTitle.defaultTextFormat = _fWhite;
			_tfTitle.text = "Noname";
			addChild(_tfTitle);
			
			if (_btnClose == null)
			{
				_btnClose = new AntSysButton();
				_btnClose.x = _width - 13;
				_btnClose.y = 1;
				addChild(_btnClose);
				_btnClose.onClick = onClose;
			}
		}
		
		/**
		 * Отрисовка окна.
		 */
		protected function draw():void
		{
			graphics.clear();
			graphics.beginFill(0x000000, 0.7);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		    
			graphics.beginFill(0x000000, 0.9);
			graphics.drawRect(0, 0, _width, 14);
			graphics.endFill();
			
			_btnClose.x = _width - 14;
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Обработчик нажатия мыши.
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if (!_isMove)
			{
				if (_parent.contains(this))
				{
					_parent.removeChild(this);
					_parent.addChild(this);
				}
				
				_isMove = true;
				_offsetX = AntG.stage.mouseX - x;
				_offsetY = AntG.stage.mouseY - y;
				AntG.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
		}
		
		/**
		 * Обработчик отпускания мыши.
		 */
		private function mouseUpHandler(event:MouseEvent):void
		{
			if (_isMove)
			{
				_isMove = false;
				AntG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
		}
		
		/**
		 * Обработчик перемещения мыши.
		 */
		private function mouseMoveHandler(event:MouseEvent):void
		{
			x = AntG.stage.mouseX - _offsetX;
			y = AntG.stage.mouseY - _offsetY;
		}
		
	}

}