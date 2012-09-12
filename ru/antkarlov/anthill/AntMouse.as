package ru.antkarlov.anthill
{
	import flash.events.MouseEvent;
	
	/**
	 * Класс обработчик событий мыши.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  20.05.2011
	 */
	public class AntMouse extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на объект в который был произведен последний клик мышкой.
		 */
		public var target:Object;
		
		/**
		 * Значение глубины колеса при прокрутке.
		 */
		public var wheelDelta:int;
		
		/**
		 * Событие выполняющиеся при нажатии кнопки мыши.
		 */
		public var eventDown:AntEvent;
		
		/**
		 * Событие выполняющиеся при отпускании кнопки мыши.
		 */
		public var eventUp:AntEvent;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Помошник для хранения текущих координат мыши.
		 */
		protected var _globalScreenPos:AntPoint;
		
		/**
		 * @private
		 */
		protected var _current:int = 0;
		
		/**
		 * @private
		 */
		protected var _last:int = 0;
		
		/**
		 * @private
		 */
		protected var _out:Boolean = false;
		
		/**
		 * @private
		 */
		protected var _currentWheel:int = 0;
		
		/**
		 * @private
		 */
		protected var _lastWheel:int = 0;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntMouse()
		{
			super();
			
			_globalScreenPos = new AntPoint();
			
			target = null;
			wheelDelta = 0;
			eventDown = new AntEvent();
			eventUp = new AntEvent();
		}

		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
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
				aCamera = AntG.camera;
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
			aResult.x = aResult.x + aCamera.scroll.x * -1;
			aResult.y = aResult.y + aCamera.scroll.y * -1;
			return aResult;
		}
		
		/**
		 * Обновление состояния мышки.
		 */
		public function update(aX:int, aY:int):void
		{
			_globalScreenPos.x = aX;
			_globalScreenPos.y = aY;
			
			if (_last == -1 && _current == -1)
			{
				_current = 0;
			}
			else if (_last == 2 && _current == 2)
			{
				_current = 1;
			}
			
			_last = _current;
			
			// Обработка колесика мышки.
			if (AntMath.abs(_lastWheel) == 1 && AntMath.abs(_currentWheel) == 1)
			{
				_currentWheel = 0;
			}
			else if (AntMath.abs(_lastWheel) == 2 && AntMath.abs(_currentWheel) == 2)
			{
				_currentWheel = (_currentWheel < 0) ? _currentWheel + 1 : _currentWheel - 1;
			}
			
			_lastWheel = _currentWheel;
		}

		/**
		 * Сбрасывает текущее состояние мышки.
		 */
		public function reset():void
		{
			_current = 0;
			_last = 0;
			_currentWheel = 0;
			_lastWheel = 0;
		}
		
		/**
		 * Проверят нажала-ли кнопка мыши. Срабатывает постоянно пока кнопка мыши удерживается.
		 * 
		 * @return		Возвращает true если кнопка мыши нажата.
		 */
		public function isDown():Boolean
		{
			return _current > 0;
		}
		
		/**
		 * Проверяет нажата-ли кнопка мыши. Срабатывает только однажды в момент нажатия кнопки мыши.
		 * 
		 * @return		Возвращает true если кнопка мыши нажата.
		 */
		public function isPressed():Boolean
		{
			return _current == 2;
		}
		
		/**
		 * Проверяет отпущена-ли кнопка мышки. Срабатывает только однажды в момент отпускания кнопки мышки.
		 * 
		 * @return		Возвращает true если кнопка мыши отпущена.
		 */
		public function isReleased():Boolean
		{
			return _current == -1;
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
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Обработчик события нажатия кнопки мыши.
		 */
		public function mouseDownHandler(event:MouseEvent):void
		{
			target = event.target;
			_current = (_current > 0) ? 1 : 2;
			eventDown.send();
		}
		
		/**
		 * Обработчик соыбтия отпускания кнопки мыши.
		 */
		public function mouseUpHandler(event:MouseEvent):void
		{
			_current = (_current > 0) ? -1 : 0;
			eventUp.send();
		}
		
		/**
		 * Обработчик события выхода мышки за пределы сцены.
		 */
		public function mouseOutHandler(event:MouseEvent):void
		{
			/*
				TODO 
			*/
		}
		
		/**
		 * Обработчик события возвращаения мышки в пределы сцены.
		 */
		public function mouseOverHandler(event:MouseEvent):void
		{
			/*
				TODO 
			*/
		}
		
		/**
		 * Обработчик события вращения колеса мышки.
		 */
		public function mouseWheelHandler(event:MouseEvent):void
		{
			wheelDelta = event.delta;
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