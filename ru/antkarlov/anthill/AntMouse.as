package ru.antkarlov.anthill
{
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * Класс для перехвата и обработки пользовательских действий с мышки. Экземпляр данного класса
	 * создается автоматически при инициализации Anthill и доступен через AntG.mouse.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  20.05.2011
	 */
	public class AntMouse extends AntPoint
	{		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Значение глубины колеса при прокрутке.
		 * @default    0
		 */
		public var wheelDelta:int;
		
		/**
		 * Позиция курсора мыши на экране по X.
		 * @default    0
		 */
		public var screenX:int;
		
		/**
		 * Позиция курсора мыши на экране по Y.
		 * @default    0
		 */
		public var screenY:int;
		
		/**
		 * Графическое представление курсора мышки.
		 * @default    null
		 */
		public var cursor:AntActor;
		
		/**
		 * Имя анимации курсора мышки по умолчанию.
		 * @default    null
		 */
		public var defCursorAnim:String;
		
		/**
		 * Левая кнопка мыши.
		 */
		public var leftButton:AntMouseButton;
		
		/**
		 * Средняя кнопка мыши. По умолчанию кнопка выключена, 
		 * чтобы активировать обработку кнопки, установите флаг enabled = true.
		 */
		public var middleButton:AntMouseButton;
		
		/**
		 * Правая кнопка мыши. По умолчанию кнопка выключена, 
		 * чтобы активировать обработку кнопки, установите флаг enabled = true.
		 * 
		 * <p><strong>Внимание:</strong> При активации правой кнопки мыши, 
		 * контекстное меню будет недоступно.</p>
		 */
		public var rightButton:AntMouseButton;
		
		/**
		 * Контекстное меню.
		 */
		public var contextMenu:ContextMenu;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на stage.
		 */
		protected var _stage:Stage;
		
		/**
		 * Заголовки пользоательских пунктов меню.
		 */
		protected var _menuCaptions:Vector.<String>;
		
		/**
		 * Указатели на методы перехватчики пользовательских пунктов меню.
		 */
		protected var _menuHandlers:Vector.<Function>;
		
		/**
		 * Смещение позиции пользовательского курсора относительно системного.
		 */
		protected var _cursorOffset:AntPoint;
		
		/**
		 * Помошник для хранения текущих координат мыши.
		 */
		protected var _globalScreenPos:AntPoint;
		
		/**
		 * Помошник для обработки прокрутки колесика мышки.
		 */
		protected var _currentWheel:int;
		
		/**
		 * Помошник для обработки прокрутки колесика мышки.
		 */
		protected var _lastWheel:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntMouse()
		{
			super();
			
			leftButton = new AntMouseButton(AntMouseButton.LEFT_BUTTON);
			middleButton = new AntMouseButton(AntMouseButton.MIDDLE_BUTTON);
			rightButton = new AntMouseButton(AntMouseButton.RIGHT_BUTTON);
			
			_cursorOffset = new AntPoint();
			_globalScreenPos = new AntPoint();
			
			wheelDelta = 0;
			screenX = 0;
			screenY = 0;
			cursor = null;
			defCursorAnim = null;
			
			contextMenu = new ContextMenu();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Инициализация.
		 */
		public function init(aStage:Stage):void
		{
			_stage = aStage;
			AntG.anthill.contextMenu = contextMenu;
			
			leftButton.init(aStage);
			middleButton.init(aStage);
			rightButton.init(aStage);
			
			leftButton.enabled = true;
			
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		/**
		 * Скрывает из контекстного меню стандартные пункты меню.
		 */
		public function hideDefaultContextMenu():void
		{
			contextMenu.hideBuiltInItems();
		}
		
		/**
		 * Добавляет пользовательский пункт меню в контекстное меню.
		 * 
		 * @param	aCaption	 Текст пункта меню.
		 * @param	aFunction	 Указатель на метод обработчик при выборе меню.
		 * @param	aEnabled	 Определяет доступен ли пункт меню для выбора.
		 */
		public function addMenuItem(aCaption:String, aFunction:Function, aEnabled:Boolean = true):void
		{
			if (_menuCaptions == null)
			{
				_menuCaptions = new Vector.<String>();
				_menuHandlers = new Vector.<Function>();
			}
			
			var item:ContextMenuItem = new ContextMenuItem(aCaption);
			item.enabled = aEnabled;
			if (item.enabled)
			{
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemSelect);
			}
			
			contextMenu.customItems.push(item);
			_menuCaptions.push(aCaption);
			_menuHandlers.push(aFunction);
		}
		
		/**
		 * Удаляет пользовательский пункт меню из контекстного меню.
		 * 
		 * @param	aCaption	 Текст пункта меню который необходимо удалить.
		 */
		public function removeMenuItem(aCaption:String):void
		{
			if (_menuCaptions == null)
			{
				return;
			}
			
			var i:int = 0;
			const n:int = contextMenu.customItems.length;
			var item:ContextMenuItem;
			while (i < n)
			{
				item = contextMenu.customItems[i] as ContextMenuItem;
				if (item != null && item.caption == aCaption)
				{
					contextMenu.customItems[i] = null;
					contextMenu.customItems.splice(i, 1);
					break;
				}
				i++;
			}
			
			i = _menuCaptions.indexOf(aCaption);
			if (i >= 0 && i < _menuCaptions.length)
			{
				_menuCaptions[i] = null;
				_menuHandlers[i] = null;
				_menuCaptions.splice(i, 1);
				_menuHandlers.splice(i, 1);
			}
		}
		
		/**
		 * Устанавливает доступность указанного пользовательского пункта меню.
		 * 
		 * @param	aCaption	 Текст пользовательского пункта меню для которого необходимо установить активность.
		 * @param	aEnabled	 Определяет доступность пользовательского меню.
		 */
		public function enableMenuItem(aCaption:String, aEnabled:Boolean):void
		{
			var i:int = 0;
			const n:int = contextMenu.customItems.length;
			var item:ContextMenuItem;
			while (i < n)
			{
				item = contextMenu.customItems[i++] as ContextMenuItem;
				if (item != null)
				{
					if (item.caption == aCaption && item.enabled != aEnabled)
					{
						if (aEnabled)
						{
							item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemSelect);
						}
						else
						{
							item.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemSelect);
						}
						
						item.enabled = aEnabled;
					}
				}
			}
		}
		
		/**
		 * Удаляет все пользовательские пункты меню из контекстного меню.
		 */
		public function clearContextMenu():void
		{
			var i:int = 0;
			var n:int = contextMenu.customItems.length;
			while (i < n)
			{
				contextMenu.customItems[i++] = null;
			}
			
			i = 0;
			n = _menuCaptions.length;
			while (i < n)
			{
				_menuCaptions[i] = null;
				_menuHandlers[i] = null;
				i++;
			}
			
			_menuCaptions.length = 0;
			_menuHandlers.length = 0;
			contextMenu.customItems.length = 0;
		}
		
		/**
		 * Событие обработчик клика по пользовательскому пункту меню.
		 * 
		 * @param	aEvent	 Указатель на событие.
		 */
		private function onContextMenuItemSelect(aEvent:ContextMenuEvent):void
		{
			if (aEvent.target is ContextMenuItem)
			{
				var index:int = _menuCaptions.indexOf((aEvent.target as ContextMenuItem).caption);
				if (index >= 0 && index < _menuCaptions.length)
				{
					_menuHandlers[index].apply(this);
				}
			}
		}
		
		/**
		 * Создает пользовательский курсор.
		 * 
		 * @param	aAnimName	 Имя анимации в кэше анимаций.
		 * @param	aOffsetX	 Смещение пользовательского курсора относительно системного по X.
		 * @param	aOffsetY	 Смещение пользовательского курсора относительно системного по Y.
		 */
		public function makeCursor(aAnimName:String, aOffsetX:int = 0, aOffsetY:int = 0):void
		{
			var switchAnim:Boolean = false;
			if (cursor == null)
			{
				cursor = new AntActor();
				cursor.isScrolled = false;
				switchAnim = true;
				defCursorAnim = aAnimName;
				
				if (AntG.useSystemCursor)
				{
					hide();
				}
			}
			
			cursor.addAnimationFromCache(aAnimName, null, switchAnim);
			_cursorOffset.set(aOffsetX, aOffsetY);
		}
		
		/**
		 * Показывает пользовательский курсор.
		 */
		public function show():void
		{
			if (cursor != null)
			{
				cursor.revive();
			}
		}
		
		/**
		 * Скрывает пользовательский курсор.
		 */
		public function hide():void
		{
			if (cursor != null)
			{
				cursor.kill();
			}
		}
		
		/**
		 * Переключает анимацию курсора.
		 * 
		 * @param	aAnimName	 Имя анимации из кэша анимаций.
		 */
		public function changeCursor(aAnimName:String = null):void
		{
			if (aAnimName == null)
			{
				if (cursor != null && defCursorAnim != null)
				{
					cursor.switchAnimation(defCursorAnim);
				}
			}
			else if (cursor != null)
			{
				cursor.switchAnimation(aAnimName);
			}
		}
		
		/**
		 * Возвращает координаты мыши на экране.
		 * 
		 * @param	aCamera	 Указатель на камеру для которой необходимо получить координаты мыши.
		 * @param	aResult	 Указатель на точку куда может быть записан результат.
		 * @return		Возвращает координаты мыши на экране для указанной камеры.
		 */
		public function getScreenPosition(aCamera:AntCamera = null, aResult:AntPoint = null):AntPoint
		{
			if (aCamera == null)
			{
				aCamera = AntG.getCamera();
			}
			
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
						
			aResult.x = (_globalScreenPos.x - aCamera.x) / aCamera.zoom;
			aResult.y = (_globalScreenPos.y - aCamera.y) / aCamera.zoom;
			return aResult;
		}
		
		/**
		 * Возвращает координаты мыши в игровом мире.
		 * 
		 * @param	aCamera	 Указатель на камеру для которой необходимо получить координаты мыши.
		 * @param	aResult	 Указатель на куда может быть записан результат.
		 * @return		Возвращает координаты мыши в игровом мире исходя из указанной камеры.
		 */
		public function getWorldPosition(aCamera:AntCamera = null, aResult:AntPoint = null):AntPoint
		{
			if (aCamera == null)
			{
				aCamera = AntG.camera;
			}
			
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			getScreenPosition(aCamera, aResult);
			
			var posX:Number = 0;
			var posY:Number = 0;
			
			if (aCamera.zoomStyle == AntCamera.ZOOM_STYLE_CENTER)
			{
				posX = aCamera.scroll.x * -1 + (aCamera.width * 0.5);
				posY = aCamera.scroll.y * -1 + (aCamera.height * 0.5);
				posX = posX - ((aCamera.width / aCamera.zoom) * 0.5);
				posY = posY - ((aCamera.height / aCamera.zoom) * 0.5);
			}
			else
			{
				posX = aCamera.scroll.x * -1;
				posY = aCamera.scroll.y * -1;
			}
			
			aResult.x += posX;
			aResult.y += posY;
			return aResult;
		}
		
		/**
		 * Обновление состояния мышки.
		 */
		public function update(aX:int, aY:int):void
		{
			_globalScreenPos.x = aX;
			_globalScreenPos.y = aY;
			
			updateCursor();
			updateButtons();
			updateWheel();
		}
		
		/**
		 * Отрисовка курсора мышки.
		 */
		public function draw():void
		{
			if (cursor != null && cursor.exists && cursor.visible)
			{
				var cam:AntCamera;
				var i:int = 0;
				var n:int = AntG.cameras.length;
				while (i < n)
				{
					cam = AntG.cameras[i++] as AntCamera;
					if (cam != null)
					{
						cursor.drawActor(cam);
					}
				}
			}
		}

		/**
		 * Сбрасывает текущее состояние мышки.
		 */
		public function reset():void
		{
			leftButton.reset();
			middleButton.reset();
			rightButton.reset();
			
			_currentWheel = 0;
			_lastWheel = 0;
		}
		
		/**
		 * Проверят удерживается ли левая кнопка мыши. Срабатывает постоянно пока кнопка мыши удерживается.
		 * 
		 * @return		Возвращает true если кнопка мыши нажата.
		 */
		public function isDown():Boolean 
		{
			return leftButton.isDown();
		}
		
		/**
		 * Проверяет нажата-ли левая кнопка мыши. Срабатывает только однажды в момент нажатия кнопки мыши.
		 * 
		 * @return		Возвращает true если кнопка мыши нажата.
		 */
		public function isPressed():Boolean
		{
			return leftButton.isPressed();
		}
		
		/**
		 * Проверяет отпущена-ли левая кнопка мышки. Срабатывает только однажды в момент отпускания кнопки мышки.
		 * 
		 * @return		Возвращает true если кнопка мыши отпущена.
		 */
		public function isReleased():Boolean
		{
			return leftButton.isReleased();
		}
		
		/**
		 * Проверяет вращение колеса мыши вниз.
		 * 
		 * @return		Возвращает true если колесо мыши крутится вниз.
		 */
		public function isWheelDown():Boolean
		{
			return _currentWheel < 0;
		}
		
		/**
		 * Проверяет вращение колеса мыши вверх.
		 * 
		 * @return		Возвращает true если колесе мыши крутится вверх.
		 */
		public function isWheelUp():Boolean
		{
			return _currentWheel > 0;
		}
		
		/**
		 * Определяет объект по которому был произведен клик левой кнопкой мыши.
		 */
		public function get target():Object
		{
			return leftButton.target;
		}
		
		/**
		 * Определяет объект по которому был произведен клик левой кнопкой мыши.
		 */
		public function get currentTarget():Object
		{
			return leftButton.currentTarget;
		}
		
		/**
		 * @private
		 */
		public function get cursorAnim():String
		{
			return (cursor != null) ? cursor.currentAnimation : null;
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Обработчик курсора.
		 */
		protected function updateCursor():void
		{
			if (cursor != null && cursor.exists && cursor.active)
			{
				cursor.update();
				cursor.globalX = _globalScreenPos.x + _cursorOffset.x;
				cursor.globalY = _globalScreenPos.y + _cursorOffset.y;
			}
			
			var camera:AntCamera = AntG.camera;
			screenX = (_globalScreenPos.x - camera.x) / camera.zoom;
			screenY = (_globalScreenPos.y - camera.y) / camera.zoom;
			x = screenX + camera.scroll.x;
			y = screenY + camera.scroll.y;
		}
		
		/**
		 * Обработчик кнопок мыши.
		 */
		protected function updateButtons():void
		{
			leftButton.update();
			middleButton.update();
			rightButton.update();
		}
		
		/**
		 * Обработчик вращения колеса мышки.
		 */
		protected function updateWheel():void
		{
			if (Math.abs(_lastWheel) == 1 && Math.abs(_currentWheel) == 1)
			{
				_currentWheel = 0;
			}
			else if (Math.abs(_lastWheel) == 2 && Math.abs(_currentWheel) == 2)
			{
				_currentWheel = (_currentWheel < 0) ? _currentWheel + 1 : _currentWheel - 1;
			}
			
			_lastWheel = _currentWheel;
		}
		
		/**
		 * Обработчик события вращения колеса мышки.
		 */
		protected function onMouseWheel(aEvent:MouseEvent):void
		{
			wheelDelta = aEvent.delta;
			if (wheelDelta > 0)
			{
				_currentWheel = (_currentWheel > 0) ? 1 : 2;
			}
			else
			{
				_currentWheel = (_currentWheel > 0) ? -1 : -2;
			}
		}

	}

}