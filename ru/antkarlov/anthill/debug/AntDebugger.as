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
	import flash.ui.Mouse;
	
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
		protected var _isDebugDraw:Boolean = false;
		
		private var _tfTitle:TextField;
		private var _currentPosition:int;
		private var _sysPosition:int;
		private var _addedButtons:Array;
		
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
			_addedButtons = null;
			
			makeButton(AntSysButton.CLOSE, onCloseClick, true);
			addSeparator();			
			makeButton(AntSysButton.MONITOR, onMonitorClick, true);
			makeButton(AntSysButton.PERFOMANCE, onPerfomanceClick, true);
			makeButton(AntSysButton.CONSOLE, onConsoleClick, true);
			addSeparator();
			makeButton(AntSysButton.DEBUGDRAW_OFF, onDebugDrawClick, true);
			makeButton(AntSysButton.SOUND_ON, onMuteClick, true);
			addSeparator();
			
			_sysPosition = _currentPosition;
			
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
				if (!AntG.useSystemCursor)
				{
					flash.ui.Mouse.show();
					
					if (AntG.mouse.cursor != null)
					{
						AntG.mouse.hide();
					}
				}
				
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
				if (!AntG.useSystemCursor)
				{
					flash.ui.Mouse.hide();
					
					if (AntG.mouse.cursor != null)
					{
						AntG.mouse.show();
					}
				}
				
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
		
		/**
		 * Создает и добавляет новую кнопку в окно отлдачика.
		 * 
		 * @param	aButtonKind	 Вид кнопки.
		 * @param	aOnClick	 Указатель на метод обработчик клика по кнопке.
		 * @return		Возвращает указатель на созданную и добавленную кнопку.
		 */
		public function makeButton(aButtonKind:uint, aOnClick:Function, aSystem:Boolean = false):AntSysButton
		{
			return addButton(new AntSysButton(aButtonKind), aOnClick, aSystem);
		}
		
		/**
		 * Добавляет нопку в окно отладчика.
		 * 
		 * @param	aButton	 Указатель на добавляемую кнопку.
		 * @param	aOnClick	 Указатель на метод обработчик клика по кнопке.
		 * @default    Возвращает указатель на добавленную кнопку.
		 */
		public function addButton(aButton:AntSysButton, aOnClick:Function, aSystem:Boolean = false):AntSysButton
		{
			if (_addedButtons == null && !aSystem)
			{
				_addedButtons = [];
			}
			
			_currentPosition -= 14;
			if (aSystem)
			{
				_sysPosition = _currentPosition;
			}
			
			aButton.x = _currentPosition;
			aButton.y = 1;
			aButton.onClick = aOnClick;
			addChild(aButton);
			
			if (!aSystem)
			{
				_addedButtons[_addedButtons.length] = aButton;
			}
			
			return aButton;
		}
		
		/**
		 * Добавляет разделитель между кнопками.
		 */
		public function addSeparator():void
		{
			_currentPosition -= 5;
		}
		
		/**
		 * Удаляет все добавленные кнопки.
		 */
		public function removeAllButtons():void
		{
			if (_addedButtons != null)
			{
				var i:int = 0;
				var n:int = _addedButtons.length;
				var btn:AntSysButton;
				while (i < n)
				{
					btn = _addedButtons[i] as AntSysButton;
					if (btn != null)
					{
						if (contains(btn))
						{
							removeChild(btn);
						}
						
						btn.destroy();
						_addedButtons[i] = null;
					}
					i++;
				}
				
				_addedButtons = null;
				_currentPosition = _sysPosition;
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обработчик клика по кнопке скрыть (закрыть).
		 */
		protected function onCloseClick(aButton:AntSysButton):void
		{
			hide();
		}
		
		/**
		 * Обработчик клика по кнопке вкл/выкл звуки.
		 */
		protected function onMuteClick(aButton:AntSysButton):void
		{
			AntG.sounds.mute = !AntG.sounds.mute;
			aButton.kind = (AntG.sounds.mute) ? AntSysButton.SOUND_OFF : AntSysButton.SOUND_ON;
		}
		
		/**
		 * Обработчик клика по кнопке вкл/выкл отладочную отрисовку.
		 */
		protected function onDebugDrawClick(aButton:AntSysButton):void
		{
			if (AntG.debugDrawer != null)
			{
				AntG.debugDrawer = null;
				aButton.kind = AntSysButton.DEBUGDRAW_OFF;
			}
			else
			{
				AntG.debugDrawer = new AntDrawer();
				aButton.kind = AntSysButton.DEBUGDRAW_ON;
			}
		}
		
		/**
		 * Обработчик клика по кнопке показать/скрыть консоль.
		 */
		protected function onConsoleClick(aButton:AntSysButton):void
		{
			(console.visible) ? console.hide() : console.show();
		}
		
		/**
		 * Обработчик клика по кнопке показать/скрыть окно производительности.
		 */
		protected function onPerfomanceClick(aButton:AntSysButton):void
		{
			(perfomance.visible) ? perfomance.hide() : perfomance.show();
		}
		
		/**
		 * Обработчик клика по кнопке показать/скрыть монитор.
		 */
		protected function onMonitorClick(aButton:AntSysButton):void
		{
			(monitor.visible) ? monitor.hide() : monitor.show();
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