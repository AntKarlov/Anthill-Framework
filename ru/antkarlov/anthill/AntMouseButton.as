package ru.antkarlov.anthill
{
	import flash.events.MouseEvent;
	import flash.display.Stage;
	
	import ru.antkarlov.anthill.signals.AntSignal;
	
	/**
	 * Класс помошник для AntMouse реализующий обработку основных кнопок мыши.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  11.05.2014
	 */
	public class AntMouseButton extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const LEFT_BUTTON:String = "leftButton";
		public static const MIDDLE_BUTTON:String = "middleButton";
		public static const RIGHT_BUTTON:String = "rightButton";
		
		private static const _names:Vector.<String> = new <String>[ 
			LEFT_BUTTON, 
			MIDDLE_BUTTON, 
			RIGHT_BUTTON ];
			
		private static const _downEvents:Vector.<String> = new <String>[ 
			MouseEvent.MOUSE_DOWN, 
			MouseEvent.MIDDLE_MOUSE_DOWN, 
			MouseEvent.RIGHT_MOUSE_DOWN ];
			
		private static const _upEvents:Vector.<String> = new <String>[
			MouseEvent.MOUSE_UP,
			MouseEvent.MIDDLE_MOUSE_UP,
			MouseEvent.RIGHT_MOUSE_UP ];
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на объект по которому был произведен клик текущей кнопкой мыши.
		 * @default    null
		 */
		public var target:Object;
		
		/**
		 * Указатель на объект по которому был произведен клик текущей кнопкой мыши.
		 * @default    null
		 */
		public var currentTarget:Object;
		
		/**
		 * Событие срабатывающее в момент нажатия текущей кнопки мыши.
		 */
		public var eventDown:AntSignal;
		
		/**
		 * Событие срабатывающее в момент отжатия текущей кнопки мыши.
		 */
		public var eventUp:AntSignal;
		
		/**
		 * @private
		 */
		public var eventClick:AntSignal;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Имя кнопки.
		 */
		protected var _name:String;
		
		/**
		 * Указатель на Stage.
		 */
		protected var _stage:Stage;
		
		/**
		 * Определяет активна кнопка или нет.
		 */
		protected var _isEnabled:Boolean;
		
		/**
		 * Текущее состояние кнопки.
		 */
		protected var _current:int;
		
		/**
		 * Предыдущее состояние кнопки.
		 */
		protected var _last:int;
		
		/**
		 * @constructor
		 */
		public function AntMouseButton(aName:String)
		{
			super();
			reset();
			
			eventDown = new AntSignal();
			eventUp = new AntSignal();
			eventClick = new AntSignal();
			
			_name = aName;
			_stage = null;
			_isEnabled = false;
		}
		
		/**
		 * Инициализация.
		 */
		public function init(aStage:Stage):void
		{
			_stage = aStage;
		}
		
		/**
		 * Сброс состояния кнопки.
		 */
		public function reset():void
		{
			target = null;
			currentTarget = null;
			_current = 0;
			_last = 0;
		}
		
		/**
		 * Обработка кнопки.
		 */
		public function update():void
		{
			if (_isEnabled)
			{
				if (_last == -1 && _current == -1)
				{
					_current = 0;
				}
				else if (_last == 2 && _current == 2)
				{
					_current = 1;
				}

				_last = _current;
				
				if (isPressed())
				{
					eventClick.dispatch();
				}
			}
		}
		
		/**
		 * Определяет активна кнопка или нет.
		 */
		public function get enabled():Boolean { return _isEnabled; }
		public function set enabled(aValue:Boolean):void
		{
			if (_isEnabled != aValue)
			{
				var index:int = _names.indexOf(_name);
				if (index >= 0 && index < _names.length)
				{
					if (aValue)
					{
						_stage.addEventListener(_downEvents[index], onMouseDown);
						_stage.addEventListener(_upEvents[index], onMouseUp);
					}
					else
					{
						_stage.removeEventListener(_downEvents[index], onMouseDown);
						_stage.removeEventListener(_upEvents[index], onMouseUp);
					}
					
					_isEnabled = aValue;
				}
			}
		}
		
		/**
		 * Определяет была ли нажата текущая кнопка.
		 */
		public function isPressed():Boolean 
		{
			return _current == 2;
		}
		
		/**
		 * Определяет удерживается ли текущая кнопка нажатой.
		 */
		public function isDown():Boolean 
		{
			return _current > 0;
		}
		
		/**
		 * Определяет была ли отпущена текущая кнопка.
		 */
		public function isReleased():Boolean 
		{
			return _current == -1;
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Обработчик события нажатия кнопки мыши.
		 */
		protected function onMouseDown(aEvent:MouseEvent):void
		{
			target = aEvent.target;
			currentTarget = aEvent.currentTarget;
			_current = (_current > 0) ? 1 : 2;
			
			if (eventDown.numListeners > 0)
			{
				eventDown.dispatch();
			}
		}
		
		/**
		 * Обработчик соыбтия отпускания кнопки мыши.
		 */
		protected function onMouseUp(aEvent:MouseEvent):void
		{
			_current = (_current > 0) ? -1 : 0;
			
			if (eventUp.numListeners > 0)
			{
				eventUp.dispatch();
			}
		}
	
	}

}