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
	 * Отладочная консоль с возможностью ввода команд и вывода любой информации.
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
		 * Определяет стандартный цвет текста.
		 */
		public static const DEFAULT:String = "def";
		
		/**
		 * Определяет цвет текста для ошибок.
		 */
		public static const ERROR:String = "error";
		
		/**
		 * Определяет цвет текста для какой-либо информации.
		 */
		public static const DATA:String = "data";
		
		/**
		 * Определяет цвет текста для вывода результата.
		 */
		public static const RESULT:String = "result";
		
		/**
		 * @private
		 */
		private const LINE_SPACING:int = -3;
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет текущий цвет текста для вывода информации.
		 * @default    DEFAULT
		 */
		public var color:String;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		
		/**
		 * Номер последней строки.
		 */
		protected var _lineNum:int;
		
		/**
		 * Хранилище зарегистрированных команд и методов.
		 */
		protected var _registry:AntStorage;
		
		/**
		 * Хранилище текстовых подсказок для зарегистрированных команд.
		 */
		protected var _hints:AntStorage;
		
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
			
			color = DEFAULT;
			
			_lineNum = 0;
			
			_registry = new AntStorage();
			_hints = new AntStorage();
			
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
		 * @param	aCommand	 Текстовая команда.
		 * @param	aFunction	 Метод который будет вызываться при активации команды.
		 * @param	aHint	 Краткое текстовое описание которое будет отображаться в помощи.
		 */
		public function registerCommand(aCommand:String, aFunction:Function, aHint:String = ""):void
		{
			_registry.set(aCommand, aFunction);
			_hints.set(aCommand, aHint);
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
				cKey = _registry.getKey(aKey);
				if (cKey != null)
				{
					_registry.remove(cKey);
				}
			}
			else
			{
				cKey = aKey.toString();
				_registry.remove(cKey);
			}
			
			_hints.remove(cKey);
		}
		
		/**
		 * Выводит какую-либо информацию в консоль.
		 * <p>Примечание: в качестве данных может быть совершенно любой объект. Если тип объекта не простой, 
		 * то вызывается его стандартный метод <code>toString()</code>.</p>
		 * 
		 * @param	aData	 Данные которые необходимо вывести. Это могут быть любые данные.
		 * @param	aColor	 Цвет текста.
		 */
		public function log(aData:*, aColor:String = null):void
		{
			_lineNum++;
			_tfNumbering.appendText(_lineNum + "\n");
			var str:String = ": " + ((aData == null) ? "null" : aData.toString()) + "\n";
			var startIndex:int = _tfConsole.length;
			var endIndex:int = startIndex + str.length;
			_tfConsole.appendText(str);
			
			if (aColor == null)
			{
				aColor = color;
			}
						
			switch (aColor)
			{
				case ERROR : 
					_fDefault.color = 0xD65558;
					//_tfConsole.setTextFormat(_fError, startIndex, endIndex); 
				break;
				
				case DATA :
					_fDefault.color = 0x7EA460;
					//_tfConsole.setTextFormat(_fData, startIndex, endIndex);
				break;
				
				case RESULT :
					_fDefault.color = 0xF1E590;
					//_tfConsole.setTextFormat(_fResult, startIndex, endIndex);
				break;
				
				default :
					_fDefault.color = 0xFFFFFF;
					//_tfConsole.setTextFormat(_fDefault, startIndex, endIndex);
				break;
			}
			
			_tfConsole.setTextFormat(_fDefault, startIndex, endIndex);
			
			refresh();
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
			var paramA:String = query[1];
			var paramB:String = query[2];
			var paramC:String = query[3];
			
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
					_tfConsole.text = "";
					_tfNumbering.text = "";
					_lineNum = 0;
					log("Type \"-help\" to view list of defaults commands.");
				break;
				
				// Вывод стандартных команд консоли.
				case "-help" :
					write();
					color = DATA;
					log("  Default commands");
					log("-------------------------------------------------------");
					log("  -clear - clears console window;");
					log("  -help - shows this information;");
					log("  -regs - show registered commands in the console;");
					log("  -sys - shows system information;");
					log("  -gc - activates garbage collector and shows results from AntMemory;");
					log("");
					log("  Use \"PageUp\" & \"PageDown\" to scroll console");
					log("");
					color = DEFAULT;
				break;
				
				// Вывод зарегистрированных команд с подсказками.
				case "-regs" :
					write();
					color = DATA;
					log("  Registered commands");
					log("-------------------------------------------------------");
					if (_registry.isEmpty)
					{
						log("  no registered commands");
					}
					else
					{
						for (var value:* in _registry)
						{
							log("  " + value + " " + _hints.get(value));
						}
					}
					log("");
					color = DEFAULT;
				break;
				
				// Принудительный вызов сборщика мусора.
				case "-gc" :
					write();
					AntMemory.callGarbageCollector((!paramA) ? null : paramA.split(","));
				break;
				
				// Вывод системной информации.
				case "-sys" :
					write();
					color = DATA;
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
					color = DEFAULT;
				break;
				
				// Вызов зарегистрированной команды.
				default:
					write();
					if (key != "")
					{
						if (_registry.containsKey(key))
						{
							if (!paramA)
							{
								_registry[key]();
							}
							else
							{
								_registry[key](paramA.split(","));
							}
						}
						else
						{
							log(key + " - Unknown command", ERROR);
						}
					}
				break;
			}
			
			refresh();
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

				// Нажат Enter.
				case "13" :
					if (visible)
					{
						execute();
					}
				break;

				// Нажат Backspace.
				case "8" :
					if (visible && _commandStr.length > 0)
					{
						_commandStr = _commandStr.substr(0, _commandStr.length - 1);
						_cursorVisible = true;
						_blinkInterval = 0.5;
					}
				break;
				
				// Нажат Esc.
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