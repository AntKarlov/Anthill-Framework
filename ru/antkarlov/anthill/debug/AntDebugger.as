package ru.antkarlov.anthill.debug
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	
	import ru.antkarlov.anthill.*;
	
	/**
	 * Объеденяет в себе все классы использующиеся для отладки игры.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  22.11.2011
	 */
	public class AntDebugger extends Sprite
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на консоль.
		 */
		public var console:AntConsole;
		
		/**
		 * Указатель на монитор производительности.
		 */
		public var perfomance:AntPerfomance;
		
		/**
		 * Указатель на монитор пользовательских данных.
		 */
		public var monitor:AntMonitor;
		
		/**
		 * Флаг определяющий активирован ли отладчик.
		 * @default    true
		 */
		public var enable:Boolean;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		protected var _isVisible:Boolean = false;
		protected var _isConsoleVisible:Boolean = true;
		protected var _isPerfomanceVisible:Boolean = true;
		protected var _isMonitorVisible:Boolean = true;
		
		private var _tfTitle:TextField;
		private var _btnClose:AntGlyphButton;
		private var _btnConsole:AntGlyphButton;
		private var _btnPerfomance:AntGlyphButton;
		private var _btnMonitor:AntGlyphButton;
		private var _btnDebugDraw:AntGlyphButton;
		private var _btnMute:AntGlyphButton;
		
		private var _currentPosition:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntDebugger()
		{
			super();
			
			console = new AntConsole(this, 10, 24);
			perfomance = new AntPerfomance(this, 180, 224);
			monitor = new AntMonitor(this, 10, 224);
			
			_currentPosition = AntG.width;
			
			_btnClose = new AntGlyphButton(AntGlyphButton.CLOSE);
			addButton(_btnClose, hide);
			
			addSeparator();
			
			_btnMonitor = new AntGlyphButton(AntGlyphButton.MONITOR);
			addButton(_btnMonitor, onMonitor);
			
			_btnPerfomance = new AntGlyphButton(AntGlyphButton.PERFOMANCE);
			addButton(_btnPerfomance, onPerfomance);
			
			_btnConsole = new AntGlyphButton(AntGlyphButton.CONSOLE);
			addButton(_btnConsole, onConsole);
			
			addSeparator();
			
			_btnDebugDraw = new AntGlyphButton(AntGlyphButton.DEBUGDRAW_OFF);
			addButton(_btnDebugDraw, onDebugDraw);
			
			_btnMute = new AntGlyphButton(AntGlyphButton.SOUND_ON);
			addButton(_btnMute, onMute);
			
			_tfTitle = new TextField();
			_tfTitle.x = 2;
			_tfTitle.y -= 2;
			_tfTitle.width = AntG.width - AntG.width * 0.5;
			_tfTitle.height = 14;
			_tfTitle.multiline = true;
			_tfTitle.wordWrap = true;
			_tfTitle.embedFonts = true;
			_tfTitle.selectable = false;
			_tfTitle.antiAliasType = AntiAliasType.NORMAL;
			_tfTitle.gridFitType = GridFitType.PIXEL;
			_tfTitle.defaultTextFormat = new TextFormat(AntPopup.FONT_NAME, AntPopup.FONT_SIZE, 0xffffff);
			_tfTitle.text = AntG.LIB_NAME + " " + AntG.LIB_MAJOR_VERSION.toString() + "." + AntG.LIB_MINOR_VERSION + "." + AntG.LIB_MAINTENANCE;
			addChild(_tfTitle);
			
			visible = false;
			enable = true;
			draw();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Процессинг классов которым это необходимо.
		 */
		public function update():void
		{
			if (enable)
			{
				perfomance.update();
				if (console.visible)
				{
					console.update();
				}
			}
		}
		
		/**
		 * Отображает отладчик.
		 */
		public function show():void
		{
			if (!enable)
			{
				return;
			}
			
			if (!visible)
			{
				AntG.stage.addChild(this);
				visible = true;
				
				if (_isConsoleVisible)
				{
					console.show();
				}
				
				if (_isPerfomanceVisible)
				{
					perfomance.show();
				}
				
				if (_isMonitorVisible)
				{
					monitor.show();
				}
			}
		}
		
		/**
		 * Скрывает отладчик.
		 */
		public function hide():void
		{
			if (visible)
			{
				AntG.stage.removeChild(this);
				visible = false;
				
				_isConsoleVisible = console.visible;
				_isPerfomanceVisible = perfomance.visible;
				_isMonitorVisible = monitor.visible;
				
				console.hide();
				perfomance.hide();
				monitor.hide();
				
				AntG.stage.focus = null;
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected function onMute():void
		{
			AntG.sounds.mute = !AntG.sounds.mute;
			if (AntG.sounds.mute)
			{
				_btnMute.kind = AntGlyphButton.SOUND_OFF;
			}
			else
			{
				_btnMute.kind = AntGlyphButton.SOUND_ON;
			}
		}
		
		/**
		 * @private
		 */
		protected function onDebugDraw():void
		{
			if (AntG.debugDrawer != null)
			{
				AntG.debugDrawer = null;
				_btnDebugDraw.kind = AntGlyphButton.DEBUGDRAW_OFF;
			}
			else
			{
				AntG.debugDrawer = new AntDrawer();
				_btnDebugDraw.kind = AntGlyphButton.DEBUGDRAW_ON;
			}
		}
		
		/**
		 * Обработка клика по кнопке консоли в тулбаре отладчика.
		 */
		protected function onConsole():void
		{
			(console.visible) ? console.hide() : console.show();
		}
		
		/**
		 * Обработка клика по кнопке монитора производительности в тулбаре отладчика.
		 */
		protected function onPerfomance():void
		{
			(perfomance.visible) ? perfomance.hide() : perfomance.show();
		}
		
		/**
		 * Обработка клика по кнопке монитора пользовательских данных в тулбаре отладчика.
		 */
		protected function onMonitor():void
		{
			(monitor.visible) ? monitor.hide() : monitor.show();
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected function addButton(aButton:AntGlyphButton, aOnClick:Function):void
		{
			_currentPosition -= 14;
			aButton.x = _currentPosition;
			aButton.y = 1;
			aButton.onClick = aOnClick;
			addChild(aButton);
		}
		
		/**
		 * @private
		 */
		protected function addSeparator():void
		{
			_currentPosition -= 4;
		}
		
		/**
		 * Перерисовывает окно отладчика.
		 */
		protected function draw():void
		{
			graphics.clear();
			graphics.beginFill(0x000000, 0.9);
			graphics.drawRect(0, 0, AntG.width, 14);
			graphics.endFill();
		}

	}

}