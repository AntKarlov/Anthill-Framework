package ru.antkarlov.anthill
{
	import flash.events.KeyboardEvent;
	import flash.utils.*;
	
	/**
	 * Класс обработчик событий клавиатуры.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  19.05.2011
	 */
	public class AntKeyboard extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------

		// Буквы.
		public var A:Boolean;
		public var B:Boolean;
		public var C:Boolean;
		public var D:Boolean;
		public var E:Boolean;
		public var F:Boolean;
		public var G:Boolean;
		public var H:Boolean;
		public var I:Boolean;
		public var J:Boolean;
		public var K:Boolean;
		public var L:Boolean;
		public var M:Boolean;
		public var N:Boolean;
		public var O:Boolean;
		public var P:Boolean;
		public var Q:Boolean;
		public var R:Boolean;
		public var S:Boolean;
		public var T:Boolean;
		public var U:Boolean;
		public var V:Boolean;
		public var W:Boolean;
		public var X:Boolean;
		public var Y:Boolean;
		public var Z:Boolean;
		
		// Цифры.
		public var ZERO:Boolean;
		public var ONE:Boolean;
		public var TWO:Boolean;
		public var THREE:Boolean;
		public var FOUR:Boolean;
		public var FIVE:Boolean;
		public var SIX:Boolean;
		public var SEVEN:Boolean;
		public var EIGHT:Boolean;
		public var NINE:Boolean;
		
		// Цифровая клавиатура.
		public var NUMPAD_0:Boolean;
		public var NUMPAD_1:Boolean;
		public var NUMPAD_2:Boolean;
		public var NUMPAD_3:Boolean;
		public var NUMPAD_4:Boolean;
		public var NUMPAD_5:Boolean;
		public var NUMPAD_6:Boolean;
		public var NUMPAD_7:Boolean;
		public var NUMPAD_8:Boolean;
		public var NUMPAD_9:Boolean;
		public var NUMPAD_MULTIPLY:Boolean;
		public var NUMPAD_ADD:Boolean;
		public var NUMPAD_ENTER:Boolean;
		public var NUMPAD_SUBTRACT:Boolean;
		public var NUMPAD_DECIMAL:Boolean;
		public var NUMPAD_DIVIDE:Boolean;
		
		// Функциональные клафиши.
		public var F1:Boolean;
		public var F2:Boolean;
		public var F3:Boolean;
		public var F4:Boolean;
		public var F5:Boolean;
		public var F6:Boolean;
		public var F7:Boolean;
		public var F8:Boolean;
		public var F9:Boolean;
		public var F10:Boolean;
		public var F11:Boolean;
		public var F12:Boolean;
		public var F13:Boolean;
		public var F14:Boolean;
		public var F15:Boolean;
		
		// Символы.
		public var COLON:Boolean;
		public var EQUALS:Boolean;
		public var UNDERSCORE:Boolean;
		public var QUESTION_MARK:Boolean;
		public var TILDE:Boolean;
		public var OPEN_BRACKET:Boolean;
		public var BACKWARD_SLASH:Boolean;
		public var CLOSED_BRACKET:Boolean;
		public var QUOTES:Boolean;
		public var LESS_THAN:Boolean;
		public var GREATER_THAN:Boolean;
		
		// Другие клавиши.		
		public var BACKSPACE:Boolean;
		public var TAB:Boolean;
		public var CLEAR:Boolean;
		public var ENTER:Boolean;
		public var SHIFT:Boolean;
		public var CONTROL:Boolean;
		public var ALT:Boolean;
		public var CAPS_LOCK:Boolean;
		public var ESC:Boolean;
		public var SPACEBAR:Boolean;
		public var PAGE_UP:Boolean;
		public var PAGE_DOWN:Boolean;
		public var END:Boolean;
		public var HOME:Boolean;
		public var LEFT:Boolean;
		public var UP:Boolean;
		public var RIGHT:Boolean;
		public var DOWN:Boolean;
		public var INSERT:Boolean;
		public var DELETE:Boolean;
		public var HELP:Boolean;
		public var NUM_LOCK:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Список всех клавиш доступных для использования.
		 */
		protected var _keys:Object;
		
		/**
		 * Массив с технической информацией для определения текущего состояния для каждой из клавиш.
		 */
		protected var _map:Array;
		
		/**
		 * Хранилище указателей на методы которые подписаны на вызов при нажатии определенных клавиш.
		 */
		protected var _functions:AntStorage;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntKeyboard()
		{
			super();
			
			_keys = {};
			_map = new Array(256);
			_functions = new AntStorage();
			
			// Буквы.
			for (var i:int = 0; i <= 90; i++)
			{
				addKey(String.fromCharCode(i), i);
			}
			
			// Цифры.
			addKey("ZERO", 48);
			addKey("ONE", 49);
			addKey("TWO", 50);
			addKey("THREE", 51);
			addKey("FOUR", 52);
			addKey("FIVE", 53);
			addKey("SIX", 54);
			addKey("SEVEN", 55);
			addKey("EIGHT", 56);
			addKey("NINE", 57);
			
			// Цифровая клавиатура.
			addKey("NUMPAD_0", 96);
			addKey("NUMPAD_1", 97);
			addKey("NUMPAD_2", 98);
			addKey("NUMPAD_3", 99);
			addKey("NUMPAD_4", 100);
			addKey("NUMPAD_5", 101);
			addKey("NUMPAD_6", 102);
			addKey("NUMPAD_7", 103);
			addKey("NUMPAD_8", 104);
			addKey("NUMPAD_9", 105);
			addKey("NUMPAD_MULTIPLY", 106);
			addKey("NUMPAD_ADD", 107);
			addKey("NUMPAD_ENTER", 108);
			addKey("NUMPAD_SUBTRACT", 109);
			addKey("NUMPAD_DECIMAL", 110);
			addKey("NUMPAD_DIVIDE", 111);
			
			// Функциональные клавиши.
			for (i = 1; i <= 12; i++)
			{
				addKey("F" + i.toString(), 111 + i);
			}
			
			// Символы.
			addKey("COLON", 186);
			addKey("EQUALS", 187);
			addKey("UNDERSCORE", 189);
			addKey("QUESTION_MARK", 191);
			addKey("TILDE", 192);
			addKey("OPEN_BRACKET", 219);
			addKey("BACKWARD_SLASH", 220);
			addKey("CLOSED_BRACKET", 221);
			addKey("QUOTES", 222);
			addKey("LESS_THAN", 188);
			addKey("GREATER_THAN", 190);
			
			// Другие кнопки.
			addKey("BACKSPACE", 8);
			addKey("TAB", 9);
			addKey("CLEAR", 12);
			addKey("ENTER", 13);
			addKey("SHIFT", 16);
			addKey("CONTROL", 17);
			addKey("ALT", 18);
			addKey("CAPS_LOCK", 20);
			addKey("ESC", 27);
			addKey("SPACEBAR", 32);
			addKey("PAGE_UP", 33);
			addKey("PAGE_DOWN", 34);
			addKey("END", 35);
			addKey("HOME", 36);
			addKey("LEFT", 37);
			addKey("UP", 38);
			addKey("RIGHT", 39);
			addKey("DOWN", 40);
			addKey("INSERT", 45);
			addKey("DELETE", 46);
			addKey("HELP", 47);
			addKey("NUM_LOCK", 144);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Проверяет нажата ли указанная клавиша.
		 * 
		 * @param	aKey	 Имя клавиши которую нужно проверить.
		 * @return		Возвращает true всегда пока клавиша зажата.
		 */
		public function isDown(aKey:String):Boolean
		{
			return this[aKey];
		}
		
		/**
		 * Проверяет нажата ли указанная клавиша.
		 * 
		 * @param	aKey	 Имя клавиши которую нужно проверить.
		 * @return		Возвращает true только в момент нажатия клавиши.
		 */
		public function isPressed(aKey:String):Boolean
		{
			return _map[_keys[aKey]].current == 2;
		}
		
		/**
		 * Проверяет нажата ли любая клавиша.
		 * 
		 * @return		Возвращает true только в момент нажатия любой клавиши.
		 */
		public function isPressedAny():Boolean
		{
			var o:Object;
			for (var i:int = 0; i < 256; i++)
			{
				if (_map[i] == null) 
				{
					continue;
				}
				
				o = _map[i];
				if (o != null && o.current == true)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Проверяет отпущена ли указанная клавиша.
		 * 
		 * @param	aKey	 Имя клавиши которую нужно проверить.
		 * @return		Возвращает true только в момент отпускания клавиши.
		 */
		public function isReleased(aKey:String):Boolean
		{
			return _map[_keys[aKey]].current == -1;
		}
		
		/**
		 * Обработка клавиш.
		 */
		public function update():void
		{
			var o:Object;
			for (var i:int = 0; i < 256; i++)
			{
				o = _map[i];
				if (o == null)
				{
					continue;
				}
				
				if (o.last == -1 && o.current == -1)
				{
					o.current = 0;
				}
				else if (o.last == 2 && o.current == 2)
				{
					o.current = 1;
				}
				
				o.last = o.current;
			}
		}
		
		/**
		 * Сбрасывает состояние всех клавиш.
		 */
		public function reset():void
		{
			var o:Object;
			for (var i:int = 0; i < 256; i++)
			{
				if (_map[i] == null) 
				{
					continue;
				}
				
				o = _map[i];
				if (o != null)
				{
					if (this.hasOwnProperty(o.name))
					{
						this[o.name] = false;
					}
					o.current = 0;
					o.last = 0;
				}
			}
		}
		
		/**
		 * Регистрирует методы на нажатие определенной клавиши (hotkey).
		 * <p>Примечание: На одну клавишу может быть зарегистрирован только один метод,
		 * в противном случае уже существующий метод будет перезаписан новым.</p>
		 * 
		 * @param	aKey	 Имя клавиши которая будет вызывать метод.
		 * @param	aFunc	 Указатель на метод который будет выполнен при нажатии клавиши.
		 */
		public function registerFunction(aKey:String, aFunc:Function):void
		{
			_functions.set(aKey, aFunc);
		}
		
		/**
		 * Удаляет метод на нажатие определенной клавиши (hotkey).
		 * 
		 * @param	aKey	 Имя клавиши или указатель на метод который был зарегистрирован.
		 */
		public function unregisterFunction(aKey:*):void
		{
			if (getQualifiedSuperclassName(aKey) == "Function")
			{
				_functions.remove(_functions.getKey(aKey));
			}
			else
			{
				_functions.remove(aKey.toString());
			}
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Обработчик нажатия клавиши.
		 */
		public function keyDownHandler(event:KeyboardEvent):void
		{
			var o:Object = _map[event.keyCode];
			if (o == null)
			{
				return
			}
			
			o.current = (o.current > 0) ? 1 : 2;
			this[o.name] = true;
			
			if (_functions.containsKey(o.name))
			{
				_functions[o.name]();
			}
		}
		
		/**
		 * Обработчик отпускания клавиши.
		 */
		public function keyUpHandler(event:KeyboardEvent):void
		{
			var o:Object = _map[event.keyCode];
			if (o == null)
			{
				return;
			}
			
			o.current = (o.current > 0) ? -1 : 0;
			this[o.name] = false;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Метод помошник для быстрой и понятной инициализации списка клавиш.
		 */
		protected function addKey(aKeyName:String, aKeyCode:uint):void
		{
			_keys[aKeyName] = aKeyCode;
			_map[aKeyCode] = { name:aKeyName, current:0, last:0 };
		}

	}

}