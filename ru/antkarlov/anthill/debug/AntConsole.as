package ru.antkarlov.anthill.debug
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.*;
	
	import ru.antkarlov.anthill.*;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Отладочная консоль позволяет выводить сообщений и предупреждения о работе игры
	 * не зависимо от того в какой версии Flash Player запущена игра (Debugger или Release).
	 * 
	 * <p>По мимо вывода сообщений в консоли можно зарегистрировать пользовательские команды
	 * и вызывать отладочные методы вводом команд. Реализована поддержка команд с аргументами.</p>
	 * 
	 * <p>Пример использования простых команд без аргументов:</p>
	 * 
	 * <listing>
	 * // Метод простой команды
	 * function testCommand():void {
	 *   trace("test command executed!");
	 * }
	 * 
	 * // Регистрация простой команды
	 * AntG.console.registerCommand("test", testCommand, "Its a simple command.");
	 * </listing>
	 * 
	 * <p>Пример использования сложных команд с аргументами:</p>
	 * 
	 * <listing>
	 * // Метод команды с аргументами, количество аргументов не ограничено.
	 * function testCommandWithArgs(aArg1:int, aArg2:String):void {
	 *   trace("test command with arguments: " + aArg1 + " " + aArg2);
	 * }
	 * 
	 * // Регистрация команды с аргументами в консоли.
	 * AntG.console.registerCommandWithArgs("test_args", testCommandWithArgs, [ int, String ], "Its a command with arguments.");
	 * </listing>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  22.11.2011
	 */
	public class AntConsole extends AntWindow
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		/**
		 * Константы стандартных цветов.
		 */
		public static const DEFAULT:String = "def";
		public static const ERROR:String = "error";
		public static const DATA:String = "data";
		public static const RESULT:String = "result";
		
		private const LINE_SPACING:int = -3;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		
		/**
		 * Текущий цвет строки.
		 * @default    0xFFFFFF
		 */
		protected var _color:uint;
		
		/**
		 * Флаг определяющий залочен ли текущий цвет от смены.
		 * @default    false
		 */
		protected var _lockColor:Boolean;
		
		/**
		 * Номер последней строки.
		 */
		protected var _lineNum:int;
		
		/**
		 * Хранилище зарегистрированных методов.
		 */
		protected var _functions:AntStorage;
		
		/**
		 * Хранилище зарегистрированных описаний для команд.
		 */
		protected var _descriptions:AntStorage;
		
		/**
		 * Хранилище зарегистрированных аргументов для команд.
		 */
		protected var _arguments:AntStorage;
		
		/**
		 * Текстовое поле для ввода команд.
		 */
		protected var _tfInput:TextField;
		
		/**
		 * Текстовое поле для вывода информации.
		 */
		protected var _tfConsole:TextField;
		
		/**
		 * Текстовое поле для нумерации строк.
		 */
		protected var _tfNumbering:TextField;
		
		/**
		 * Форматирование текста для строки ввода.
		 */
		protected var _fInput:TextFormat;
		
		/**
		 * Форматирование текста для нумерации строк.
		 */
		protected var _fNumbering:TextFormat;
			
		/**
		 * Стандартное форматирование текста.
		 */
		protected var _fDefault:TextFormat;
		
		/**
		 * Помошник для визуализации окна консоли.
		 */
		protected var _background:Sprite = new Sprite();
		
		/**
		 * Помошник для визуализации окна консоли.
		 */
		protected var _mask:Sprite = new Sprite();
		
		/**
		 * Помошник для визуализации окна консоли.
		 */
		protected var _masked:Sprite = new Sprite();
		
		/**
		 * Текущая команда введенная в консоль.
		 */
		protected var _commandStr:String = "";
		
		/**
		 * Помошник для реализации мигания курсора.
		 */
		protected var _cursorVisible:Boolean = true;
		
		/**
		 * Помошник для реализации мигания курсора.
		 */
		protected var _blinkInterval:Number = 0;
		
		/**
		 * Список последних введенных команд в консоль.
		 */
		protected var _lastCommands:Array = [];
		
		/**
		 * Индекс текущей команды из списка последних введенных.
		 */
		protected var _lastIndex:int = 0;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntConsole(aParent:Sprite, aX:Number, aY:Number)
		{
			super(aParent, aX, aY, 618, 180);
			
			_color = 0xFFFFFF;
			_lockColor = false;
			_lineNum = 0;
			
			_functions = new AntStorage();
			_descriptions = new AntStorage();
			_arguments = new AntStorage();
			
			_background = new Sprite();
			_mask = new Sprite();
			_masked = new Sprite();
			
			create();
			draw();
			
			log("Type \"-help\" to view list of defaults commands.");
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Регистрирует новую команду в консоли.
		 * 
		 * @param	aCommandName	 Текстовая команда.
		 * @param	aFunction	 Метод который будет выполняться при активации команды.
		 * @param	aDesc	 Краткое текстовое описание команды которое будет отображаться в списке зарегистрированных команд.
		 */
		public function registerCommand(aCommandName:String, aFunction:Function, aDesc:String = null):void
		{
			if (_functions.containsKey(aCommandName))
			{
				log("Command '" + aCommandName + "' already rigistered.", "error");
				return;
			}
			
			_functions.set(aCommandName, aFunction);
			if (aDesc != null)
			{
				_descriptions.set(aCommandName, aDesc);
			}
		}
		
		/**
		 * Регистрирует новую команду с аргументами в консоли.
		 * 
		 * @param	aCommandName	 Текстовая команда.
		 * @param	aFunction	 Метод который будет выполняться при активации команды.
		 * @param	aArgs	 Массив классов определяющий порядок и типы аргументов передаваемые в метод команду.
		 * @param	aDesc	 Краткое текстовое описание команды которое будет отображаться в списке зарегистрированных команд.
		 */
		public function registerCommandWithArgs(aCommandName:String, aFunction:Function, aArgs:Array, aDesc:String = null):void
		{
			if (_functions.containsKey(aCommandName))
			{
				log("Command '" + aCommandName + "' already rigistered.", "error");
				return;
			}
			
			const numListenerArgs:int = aFunction.length;
			const argumentString:String = (numListenerArgs == 1) ? "argument" : "arguments";
			
			if (numListenerArgs < aArgs.length)
			{
				log("Command '" + aCommandName + "' not registered. Reason: command method has " + 
					numListenerArgs + " " + argumentString + " but it needs to be " + aArgs.length + 
					" to match.", "error");
				return;
			}
			
			_functions.set(aCommandName, aFunction);
			_arguments.set(aCommandName, aArgs);
			if (aDesc != null)
			{
				_descriptions.set(aCommandName, aDesc);
			}
		}
		
		/**
		 * Удаляет команду или метод из зарегистрированных команд.
		 * 
		 * @param	aKey	 Текстовая команда или метод которые ранее могли быть зарегистрированы в консоле.
		 */
		public function unregisterCommand(aKey:*):void
		{
			var cKey:String = "";
			if (getQualifiedSuperclassName(aKey) == "Function")
			{
				cKey = _functions.getKey(aKey);
				if (cKey != null && _functions.containsKey(cKey))
				{
					_functions.remove(cKey);
				}
				else
				{
					log("Command '" + cKey + "' not found.", ERROR);
					return;
				}
			}
			else
			{
				cKey = aKey.toString();
				if (_functions.containsKey(cKey))
				{
					_functions.remove(cKey);
				}
				else
				{
					log("Command '" + cKey + "' not found.", ERROR);
					return;
				}
			}
			
			if (_descriptions.containsKey(cKey))
			{
				_descriptions.remove(cKey);
			}
			
			if (_arguments.containsKey(cKey))
			{
				_arguments.remove(cKey);
			}
		}
		
		/**
		 * Выводит какую-либо информацию в консоль.
		 * 
		 * <p>Примечание: в качестве данных может быть передан любой объект. Если тип объекта не простой, 
		 * то вызывается его стандартный метод <code>toString()</code>.</p>
		 * 
		 * @param	aData	 Данные которые необходимо вывести. Это могут быть любые данные.
		 * @param	aColor	 Цвет текста для вывода в консоль. Цвет может быть определен константами типа String:
		 * "error", "data", "result", "default" или цветом в формате hex(uint): 0xFFFFFF.
		 */
		public function log(aData:*, aColor:Object = null):void
		{
			_lineNum++;
			_tfNumbering.appendText(_lineNum + "\n");
			var str:String = ": " + ((aData == null) ? "null" : aData.toString()) + "\n";
			var startIndex:int = _tfConsole.length;
			var endIndex:int = startIndex + str.length;
			_tfConsole.appendText(str);
			
			var prevColor:uint = _color;
			var lc:Boolean = _lockColor;
			if (aColor != null)
			{
				beginLog(aColor);
			}
			else if (!_lockColor)
			{
				_color = 0xFFFFFF;
			}
			
			_fDefault.color = _color;
			_tfConsole.setTextFormat(_fDefault, startIndex, endIndex);
			refresh();
			
			(lc) ? _color = prevColor : _lockColor = false;
		}
		
		/**
		 * Определяет начало вывода строк в консоль с заданным цветом.
		 * 
		 * @param	aColor	 Цвет текста для вывода в консоль. Цвет может быть определен константами типа String:
		 * "error", "data", "result", "default" или цветом в формате hex(uint): 0xFFFFFF.
		 */
		public function beginLog(aColor:Object = null):void
		{
			_lockColor = true;
			_color = 0xFFFFFF;
			if (aColor == null)
			{
				return;
			}
			
			if (aColor is String)
			{
				switch (aColor)
				{
					case ERROR : _color = 0xD65558; break;
					case DATA : _color = 0x7EA460; break;
					case RESULT : _color = 0xF1E590; break;
				}
			}
			else if (aColor is uint)
			{
				_color = uint(aColor);
			}
		}
		
		/**
		 * Определяет завершение вывода однотипных строк в консоль (сбрасывает цвет).
		 */
		public function endLog():void
		{
			_fDefault.color = 0xFFFFFF;
			_lockColor = false;
		}
		
		/**
		 * Обновление консоли.
		 */
		public function update():void
		{
			if (visible)
			{
				(_cursorVisible) ? _tfInput.text = "> " + _commandStr + "_" : _tfInput.text = "> " + _commandStr;
				_blinkInterval -= 2 * AntG.elapsed;
				if (_blinkInterval <= 0)
				{
					_cursorVisible = !_cursorVisible;
					_blinkInterval = 0.5;
				}
			}
		}
		
		/**
		 * Очищает окно консоли.
		 */
		public function clear():void
		{
			_tfConsole.text = "";
			_tfNumbering.text = "";
			_lineNum = 0;
			log("Type \"-help\" to view list of defaults commands.");
		}
		
		/**
		 * Выводит системные команды с их описаниями.
		 */
		public function help():void
		{
			beginLog(DATA);
			log("  Default commands");
			log("-------------------------------------------------------");
			log("  -clear - clear console window;");
			log("  -help - shows this information;");
			log("  -regs - show registered commands;");
			log("  -sys - shows system information;");
			log("  -gc - activate garbage collector and show results about tracked objects;");
			log("");
			log("  Use \"PageUp\" & \"PageDown\" to scroll console.");
			log("");
			endLog();
		}
		
		/**
		 * Выводит список зарегистрированных команд с их описаниями.
		 */
		public function registeredCommands():void
		{
			beginLog(DATA);
			log("  Registered commands");
			log("-------------------------------------------------------");
			if (_functions.isEmpty)
			{
				log("  no registered commands");
			}
			else
			{
				var str:String;
				var desc:String;
				var valueClasses:Array;
				var valueClassesStr:String;
				for (var value:* in _functions)
				{
					if (_functions[value] == null)
					{
						continue;
					}
					
					desc = _descriptions.get(value);
					if (desc == null)
					{
						desc = "...";
					}
					
					str = "";
					valueClasses = _arguments.get(value);
					if (valueClasses != null)
					{
						str = "[" + formatClasses(valueClasses).join("] [") + "] - ";
					}
					else
					{
						str = " - ";
					}
					
					log("  " + value + " " + str + desc);
				}
			}
			log("");
			endLog();
		}
		
		/**
		 * Вызывает сборщик мусора из класса <code>AntMemory</code> и выводит результат работы в консоль.
		 */
		public function garbageCollector(aHighlightWords:Array = null):void
		{
			AntMemory.callGarbageCollector(aHighlightWords);
		}
		
		/**
		 * Выводит некоторую системную информацию.
		 */
		public function systemInfo():void
		{
			beginLog(DATA);
			log("  System Information");
			log("-------------------------------------------------------");
			log("  Language: " + Capabilities.language);
			log("  OS: " + Capabilities.os);
			log("  Pixel aspect ratio: " + Capabilities.pixelAspectRatio);
			log("  Player type: " + Capabilities.playerType);
			log("  Screen DPI: " + Capabilities.screenDPI);
			log("  Screen resolution: " + Capabilities.screenResolutionX + " x "+ Capabilities.screenResolutionY);
			log("  Version: " + Capabilities.version);
			log("  Debugger: " + Capabilities.isDebugger);
			log("");
			log("  Memory usage: " + System.totalMemory / 1024 + " Kb");
			log("");
			endLog();
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Выводит текущую команду в окно консоли.
		 */
		protected function write():void
		{
			_lineNum++;
			_tfNumbering.appendText(_lineNum + "\n");
			var str:String = "> " + _commandStr + "\n";
			var startIndex:int = _tfConsole.length;
			var endIndex:int = startIndex + str.length;
			
			_fDefault.color = 0x80C4FC;
			_tfConsole.appendText(str);
			_tfConsole.setTextFormat(_fDefault, startIndex, endIndex);
			_fDefault.color = 0xFFFFFF;
			_commandStr = "";
			refresh();
		}
		
		/**
		 * Выполнение введенной команды.
		 */
		protected function execute():void
		{
			var query:Array = _commandStr.substr(0, _commandStr.length).split(" ");
			var key:String = query[0];
			
			if (key == "")
			{
				return;
			}
			
			if (_lastCommands.indexOf(_commandStr) == -1)
			{
				_lastCommands[_lastCommands.length] = _commandStr;
				_lastIndex = _lastCommands.length;
			}
			
			switch (key)
			{
				// Очистка консоли.
				case "-clear":
					write();
					clear();
				break;
				
				// Вывод стандартных команд консоли.
				case "-help" :
					write();
					help();
				break;
				
				// Вывод зарегистрированных команд с подсказками.
				case "-regs" :
					write();
					registeredCommands();
				break;
				
				// Принудительный вызов сборщика мусора.
				case "-gc" :
					write();
					if (query.length > 1)
					{
						query.splice(0, 1);
						garbageCollector(query);
					}
					else
					{
						garbageCollector(null);
					}
				break;
				
				// Вывод системной информации.
				case "-sys" :
					write();
					systemInfo();
				break;
				
				// Вызов зарегистрированной команды.
				default:
					write();
					command.apply(null, query);
				break;
			}
			
			refresh();
		}
		
		/**
		 * @private
		 */
		protected function command(...aValueObjects):void
		{
			// Извлекаем команду.
			var command:String = String(aValueObjects[0]);
			
			// Если команда не зарегистрирована.
			if (!_functions.containsKey(command))
			{
				log("Unknown command: " + command, ERROR);
				return;
			}
			
			// Если аргументы не указаны и не зарегистрированы...
			if (aValueObjects.length == 1 && !_arguments.containsKey(command))
			{
				// Вызываем метод без аргументов.
				(_functions.get(command) as Function)();
				return;
			}
			// Иначе если аргументы указаны, но не зарегистрированы...
			else if (aValueObjects.length > 1 && !_arguments.containsKey(command))
			{
				log("Command '" + command + "' not supported arguments.", ERROR);
				return;
			}
			
			// Верефикация переданных аргументов с указанной командой.
			var valueClasses:Array = _arguments.get(command);
			var valueObject:Object;
			var valueClass:Class;
			
			const numValueClasses:int = valueClasses.length;
			const numValueObjects:int = aValueObjects.length - 1;
			
			// Количество указанных аргументов не соотвествует зарегистрированному количеству.
			if (numValueObjects < numValueClasses)
			{
				log("Incorrect number of arguments. " +
					"Expected at least " + numValueClasses + " but received " +
					numValueObjects + ".", ERROR);
				return;
			}
			
			// Сверяем вероятные типы аргументов.
			var value:Object;
			for (var i:int = 1; i < numValueClasses; i++)
			{
				valueObject = aValueObjects[i] as valueClasses[i];
				valueClass = valueClasses[i];
				
				if (valueObject === null || valueObject is valueClass)
				{
					continue;
				}
				
				log("Value '" + valueObject + "' is not '" + valueClass + "'.");
				return;
			}
			
			var func:Function = _functions.get(command) as Function;
			if (func != null)
			{
				aValueObjects.splice(0, 1);
				func.apply(null, aValueObjects);
			}
			else
			{
				log("Internal error.", ERROR);
			}
		}
		
		/**
		 * Прокрутка содержимого консоли вверх.
		 */
		protected function scrollUp():void
		{
			if (_tfConsole.y + _background.height <= _background.height)
			{
				_tfConsole.y += 44;
				_tfNumbering.y += 44;
			}
		}
		
		/**
		 * Прокрутка содержимого консоли вниз.
		 */
		protected function scrollDown():void
		{
			if (_tfConsole.y + _tfConsole.height > _background.height)
			{
				_tfConsole.y -= 44;
				_tfNumbering.y -= 44;
			}
		}
		
		/**
		 * Перелистывание истории комманд от новых к старым.
		 */
		protected function prevCommand():void
		{
			if (_lastCommands.length > 0)
			{
				if (_lastIndex == _lastCommands.length)
				{
					_lastIndex--;
					_commandStr = _lastCommands[_lastIndex];
				}
				else
				{
					_lastIndex--;
					if (_lastIndex < 0)
					{
						_lastIndex = _lastCommands.length;
						_commandStr = "";
					}
					else
					{
						_commandStr = _lastCommands[_lastIndex];
					}
				}
			}
		}
		
		/**
		 * Перелистывание истории команд от старых к новым.
		 */
		protected function nextCommand():void
		{
			if (_lastCommands.length > 0)
			{
				if (_lastIndex == _lastCommands.length)
				{
					_lastIndex = 0;
					_commandStr = _lastCommands[_lastIndex];
				}
				else
				{
					_lastIndex++;
					if (_lastIndex >= _lastCommands.length)
					{
						_lastIndex = _lastCommands.length;
						_commandStr = "";
					}
					else
					{
						_commandStr = _lastCommands[_lastIndex];
					}
				}
			}
		}
		
		/**
		 * Инициализация окна консоли.
		 */
		override protected function create():void
		{
			super.create();
			title = "Console";
			
			_fInput = new TextFormat(FONT_NAME, FONT_SIZE, 0xffd200);

			_fNumbering = new TextFormat(FONT_NAME, FONT_SIZE, 0x5e5f5f);
			_fNumbering.align = "right";
			_fNumbering.leading = LINE_SPACING;
			
			_fDefault = new TextFormat(FONT_NAME, FONT_SIZE, 0xffffff);
			_fDefault.leading = LINE_SPACING;
			
			_tfInput = new TextField();
			_tfInput.height = 16;
			_tfInput.multiline = false;
			_tfInput.wordWrap = false;
			_tfInput.embedFonts = true;
			_tfInput.selectable = true;
			_tfInput.type = "dynamic";
			_tfInput.antiAliasType = AntiAliasType.NORMAL;
			_tfInput.gridFitType = GridFitType.PIXEL;
			_tfInput.defaultTextFormat = _fInput;
			_tfInput.text = "";
			
			_tfConsole = new TextField();
			_tfConsole.multiline = true;
			_tfConsole.wordWrap = true;
			_tfConsole.embedFonts = true;
			_tfConsole.selectable = true;
			_tfConsole.type = "dynamic";
			_tfConsole.antiAliasType = AntiAliasType.NORMAL;
			_tfConsole.gridFitType = GridFitType.PIXEL;
			_tfConsole.autoSize = TextFieldAutoSize.LEFT;
			_tfConsole.defaultTextFormat = _fDefault;
			
			_tfNumbering = new TextField();
			_tfNumbering.x = 36;
			_tfNumbering.multiline = true;
			_tfNumbering.wordWrap = false;
			_tfNumbering.embedFonts = true;
			_tfNumbering.selectable = false;
			_tfNumbering.type = "dynamic";
			_tfNumbering.antiAliasType = AntiAliasType.NORMAL;
			_tfNumbering.gridFitType = GridFitType.PIXEL;
			_tfNumbering.autoSize = TextFieldAutoSize.RIGHT;
			_tfNumbering.defaultTextFormat = _fNumbering;
			
			addChild(_background);
			addChild(_tfInput);
			addChild(_masked);
			
			if (contains(_btnClose))
			{
				removeChild(_btnClose);
				addChild(_btnClose);
			}
			
			_masked.addChild(_tfConsole);
			_masked.addChild(_tfNumbering);
		}
		
		/**
		 * Перерисовка окна консоли.
		 */
		override protected function draw():void
		{
			super.draw();
			with (_background.graphics)
			{
				clear();
				beginFill(0x000000, 0);
				drawRect(0, 0, _width, _height);
				endFill();
			}
			
			with (_mask.graphics)
			{
				clear();
				beginFill(0x180c0c, 1);
				drawRect(0, 14, _width, _height - 30);
				endFill();
			}
			
			_tfInput.width = _width - 60;
			_tfInput.height = 16;
			_tfInput.x = 46;
			_tfInput.y = _height - 20;
			
			_tfConsole.width = _width - 60;
			_tfConsole.x = 46;
			_tfConsole.y = 0;
			_tfConsole.cacheAsBitmap = false;
			
			_tfNumbering.x = 36;
			_tfNumbering.y = 0;
			_tfNumbering.cacheAsBitmap = false;
			
			if (!contains(_mask))
			{
				addChild(_mask);
			}
			
			_mask.cacheAsBitmap = false;
			_masked.mask = _mask;
		}
		
		/**
		 * Обновление позиций текстовых полей консоли при выводе новой информации.
		 */
		protected function refresh():void
		{
			if (_tfConsole.numLines >= 1000)
			{
				var regxA:RegExp = /(^]\s.*\s*)/g;
				_tfConsole.text = _tfConsole.text.replace(regxA,"");
				var regxB:RegExp = /(^.*\s*)/g;
				_tfNumbering.text = _tfNumbering.text.replace(regxB,"");
			}
			
			_tfConsole.y = _background.height - _tfConsole.textHeight - 20; // 22
			_tfNumbering.y = _background.height - _tfNumbering.textHeight - 20;
		}
		
		/**
		 * Преобразует имена переданных классов в String и вырезает спец оформление.
		 * 
		 * <p>Используется для автоматического определения типа аргументов для зарегистрированных 
		 * методов при формировании краткой справки зарегистрированных команд.</p>
		 * 
		 * @param	aValueClasses	 Массив классов которые необходимо преобразовать в текст.
		 * @return		Возвращает массив имен классов преобразованных в текст без спец оформления.
		 */
		protected function formatClasses(aValueClasses:Array /* of Class */):Array /* of String */
		{
			var result:Array = [];
			var startIndex:int;
			var endIndex:int;
			var str:String;
			const n:int = aValueClasses.length;
			var i:int = 0;
			while (i < n)
			{
				str = aValueClasses[i++].toString();
				startIndex = str.indexOf("[class ");
				endIndex = str.indexOf("]");
				str = str.slice(startIndex + 7, endIndex);
				result.push(str);
			}
			
			return result;
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
				
		/**
		 * Обработчик нажатия клавиш.
		 */
		public function keyDownHandler(event:KeyboardEvent):void
		{
			var command:String = "";
			if (event.charCode != 0)
			{
				if (event.ctrlKey) 
				{
					command += "CTRL+";
				}

				if (event.altKey)
				{
					command += "ALT+";
				}

				if (event.shiftKey)
				{
					command += "SHIFT+";
				}

				command += event.charCode.toString();
			}
			
			switch (command)
			{
				// Открыть/закрыть консоль.
				case "CTRL+SHIFT+126" :
				case "96" :
					(AntG.debugger.visible) ? AntG.debugger.hide() : AntG.debugger.show();
				break;

				// Нажата клавиша 'Enter'.
				case "13" :
					if (visible)
					{
						execute();
					}
				break;

				// Нажата клавиша 'Backspace'.
				case "8" :
					if (visible && _commandStr.length > 0)
					{
						_commandStr = _commandStr.substr(0, _commandStr.length - 1);
						_cursorVisible = true;
						_blinkInterval = 0.5;
					}
				break;
				
				// Нажата клавиша 'Esc'.
				case "27" :
					if (visible)
					{
						hide();
					}
				break;

				default:
					if (visible)
					{
						// Пролистывание истории команд.
						if (event.keyCode == 38) 
						{
							prevCommand();
						}
						else if (event.keyCode == 40)
						{
							nextCommand();
						}
						// Пролистывание истории консоли вверх (PageUp)
						else if (event.keyCode == 33) 
						{
							scrollUp();
						}
						// Пролистывание истории консоли вниз (PageDown)
						else if (event.keyCode == 34) 
						{
							scrollDown();
						}
						// Ввод
						else if (event.charCode != 0)
						{
							_commandStr = _commandStr + String.fromCharCode(event.charCode);
							_cursorVisible = true;
							_blinkInterval = 0.5;
						}
					}
				break;
			}
		}

	}
	
}