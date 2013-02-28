package ru.antkarlov.anthill
{
	import flash.display.Stage;
	import flash.ui.Mouse;
	
	import ru.antkarlov.anthill.plugins.IPlugin;
	import ru.antkarlov.anthill.debug.*;
	
	/**
	 * Глобальное хранилище с указателями на часто используемые утилитные классы и их методы.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.08.2012
	 */
	public class AntG extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		/**
		 * Название фреймворка.
		 */
		public static const LIB_NAME:String = "Anthill Alpha";
		
		/**
		 * Версия основного релиза.
		 */
		public static const LIB_MAJOR_VERSION:uint = 0;
		
		/**
		 * Версия второстепенного релиза.
		 */
		public static const LIB_MINOR_VERSION:uint = 3;
		
		/**
		 * Версия обслуживания.
		 */
		public static const LIB_MAINTENANCE:uint = 1;
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на <code>stage</code>.
		 * Устанавливается автоматически при инициализации.
		 * @default    null
		 */
		public static var stage:Stage;
		
		/**
		 * Размер окна по ширине. 
		 * Определяется автоматически при инициализации.
		 * @default    stage.stageWidth
		 */
		public static var width:int;
		
		/**
		 * Размер окна по высоте.
		 * Определяется автоматически при инициализации.
		 * @default    stage.stageHeight
		 */
		public static var height:int;
		
		/**
		 * Половина ширины окна или центр экрана по X.
		 * Определяется автоматически при инициализации.
		 * @default    (stage.stageWidth / 2)
		 */
		public static var widthHalf:int;
		
		/**
		 * Половина высоты окна или центр экрана по Y.
		 * Определяется автоматически при инициализации.
		 * @default    (stage.stageHeight / 2)
		 */
		public static var heightHalf:int;
		
		/**
		 * Как быстро протекает время в игровом мире. 
		 * Изменяя этот параметр можно получить эффект слоу-мо.
		 * @default    0.5
		 */
		public static var timeScale:Number;
		
		/**
		 * Временной промежуток прошедший между предыдущим и текущим кадром (deltaTime).
		 * @default    0.02
		 */
		public static var elapsed:Number;
		
		/**
		 * Максимально допустимый временной промежуток прошедший между предыдущим и текущим кадром.
		 * @default    0.0333333
		 */
		public static var maxElapsed:Number;
		
		/**
		 * Массив добавленных камер.
		 */
		public static var cameras:Array;
		
		/**
		 * Указатель на последнюю добавленную камеру. Для безопасного получения указателя
		 * на текущую камеру используйте метод: <code>AntG.getCamera();</code>
		 * @default    null
		 */
		public static var camera:AntCamera;
		
		/**
		 * Список добавленных плагинов.
		 */
		public static var plugins:Vector.<IPlugin>;
				
		/**
		 * Указатель на класс для работы с мышкой.
		 */
		public static var mouse:AntMouse;
		
		/**
		 * Указатель на класс для работы с клавиатурой.
		 */
		public static var keys:AntKeyboard;
		
		/**
		 * Указатель на класс для работы со звуками.
		 */
		public static var sounds:AntSoundManager;
		
		/**
		 * Указатель на отладчик.
		 */
		public static var debugger:AntDebugger;
		
		/**
		 * Указатель на дебаг отрисовщик.
		 * @default    null
		 */
		public static var debugDrawer:AntDrawer;
		
		/**
		 * Указатель на класс следящий за удалением объектов из памяти.
		 */
		public static var memory:AntMemory;
		
		/**
		 * Указатель на метод <code>track()</code> класса <code>AntMemory</code>, для добавления объектов в список слежения.
		 * 
		 * <p>Чтобы посмотреть содержимое <code>AntMemory</code>, наберите в консоли команду "-gc", после чего будет 
		 * принудительно вызван сборщик мусора и выведена информация о всех объектах которые по каким-либо причинам 
		 * сохранились в <code>AntMemory</code>.</p>
		 * 
		 * <p>Пример использования:</p>
		 * <pre>AntG.track(myObject);</pre>
		 */
		public static var track:Function;
		
		/**
		 * Указатель на метод <code>registerCommand()</code> класса <code>AntConsole</code> 
		 * для добавления простых пользовательских команд в консоль.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>AntG.registerCommand("test", myMethod, "Тестовый метод.");</pre>
		 */
		public static var registerCommand:Function;
		
		/**
		 * Указатель на метод <code>registerCommandWithArgs()</code> класса <code>AntConsole</code>
		 * для добавления пользовательских команд с поддержкой аргументов в консоль.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>AntG.registerCommandWithArgs("test", myMethod, [ String, int ], "Тестовый метод с аргументами.");</pre>
		 */
		public static var registerCommandWithArgs:Function;
		
		/**
		 * Указатель на метод <code>unregisterCommand()</code> класса <code>AntConsole</code> для быстрого удаления 
		 * зарегистрированных пользовальских команд из консоли.
		 * 
		 * <p>Примичание: в качестве идентификатора команды может быть указатель на метод который выполняет команда.</p>
		 * 
		 * <p>Пример использования:</p>
		 * <pre>AntG.unregisterCommand("test");</pre>
		 */
		public static var unregisterCommand:Function;
		
		/**
		 * Указатель на метод <code>log()</code> класса <code>AntConsole</code> для быстрого 
		 * вывода любой информации в консоль.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>AntG.log(someData);</pre>
		 */
		public static var log:Function;
		
		/**
		 * Указатель на метод <code>watchValue()</code> класса <code>AntMonitor</code> используется 
		 * для добавления или обновления значения в "мониторе". 
		 * 
		 * <p>Пример использования:</p>
		 * <pre>AntG.watchValue("valueName", value);</pre>
		 */
		public static var watchValue:Function;
		
		/**
		 * Указатель на метод <code>unwatchValue()</code> класса <code>AntMonitor</code> используется
		 * для удаления записи о значении из "монитора". 
		 * 
		 * <p>Пример использования:</p> 
		 * <pre>AntG.unwatchValue("valueName");</pre>
		 */
		public static var unwatchValue:Function;
		
		/**
		 * Указатель на метод <code>beginWatch()</code> класса <code>AntMonitor</code> используется
		 * для блокировки обновления окна монитора при обновлении сразу двух и более значений 
		 * в мониторе.
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <listing>
		 * AntG.beginWatch();
		 * AntG.watchValue("someValue1", value1);
		 * AntG.watchValue("someValue2", value2);
		 * AntG.endWatch();
		 * </listing>
		 */
		public static var beginWatch:Function;
		
		/**
		 * Указатель на метод <code>endWatch()</code> класса <code>AntMonitor</code> используется 
		 * для снятия блокировки обновления окна монитора при обновлнии сразу двух и более значений 
		 * в мониторе.
		 */
		public static var endWatch:Function;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на экземпляр класса <code>Anthill</code>.
		 */
		internal static var _anthill:Anthill;
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Инициализация глобального хранилища и его переменных. Вызывается автоматически при инициализации игрового движка.
		 * @param	aAnthill	 Указатель на ядро фреймворка.
		 */
		public static function init(aAnthill:Anthill):void
		{
			timeScale = 0.5;
			elapsed = 0.02;
			maxElapsed = 0.0333333;
			
			_anthill = aAnthill;
			stage = _anthill.stage;
			width = stage.stageWidth;
			height = stage.stageHeight;
			widthHalf = stage.stageWidth * 0.5;
			heightHalf = stage.stageHeight * 0.5;
			
			cameras = [];
			plugins = new <IPlugin>[];
			
			mouse = new AntMouse();
			keys = new AntKeyboard();
			sounds = new AntSoundManager();
			
			debugger = new AntDebugger();
			debugDrawer = null;

			track = AntMemory.track;
			
			registerCommand = debugger.console.registerCommand;
			registerCommandWithArgs = debugger.console.registerCommandWithArgs;
			unregisterCommand = debugger.console.unregisterCommand;
			log = debugger.console.log;
			
			watchValue = debugger.monitor.watchValue;
			unwatchValue = debugger.monitor.unwatchValue;
			beginWatch = debugger.monitor.beginWatch;
			endWatch = debugger.monitor.endWatch;
		}
		
		/**
		 * Позволяет задать размеры окна вручную.
		 * 
		 * <p>Примичание: по умолчанию размер экрана определятся исходя из размера <code>stage.stageWidth</code>
		 * и <code>stage.stageHeight.</code></p>
		 * 
		 * <p>Внимание: изменение размеров экрана никак не влияет на работу с камерами.</p>
		 * 
		 * @param	aWidth	 Новая ширина экрана.
		 * @param	aHeight	 Новая высота экрана.
		 */
		public static function setScreenSize(aWidth:int, aHeight:int):void
		{
			width = aWidth;
			height = aHeight;
			widthHalf = aWidth * 0.5;
			heightHalf = aHeight * 0.5;
		}
		
		/**
		 * Сбрасывает текущее состояние средств пользовательского ввода.
		 */
		public static function resetInput():void
		{
			mouse.reset();
			keys.reset();
		}
		
		/**
		 * Обработка классов пользовательского ввода.
		 */
		public static function updateInput():void
		{
			mouse.update(stage.mouseX, stage.mouseY);
			keys.update();
		}
		
		/**
		 * Обработка классов звука.
		 */
		public static function updateSounds():void
		{
			sounds.update();
		}
		
		/**
		 * Обработка плагинов.
		 */
		public static function updatePlugins():void
		{
			var i:int = 0;
			const n:int = plugins.length;
			var plugin:IPlugin;
			while (i < n)
			{
				plugin = plugins[i++] as IPlugin;
				if (plugin != null)
				{
					plugin.update();
				}
			}
		}
		
		/**
		 * Добавляет плагин в список для обработки.
		 * 
		 * @param	aPlugin	 Плагин который необходимо добавить.
		 * @param	aSingle	 Если true то один и тот же экземпляр плагина не может быть добавлен дважды.
		 * @return		Возвращает указатель на добавленный плагин.
		 */
		public static function addPlugin(aPlugin:IPlugin, aSingle:Boolean = true):IPlugin
		{
			if (aSingle && plugins.indexOf(aPlugin) > -1)
			{
				return aPlugin;
			}
			
			var i:int = 0;
			const n:int = plugins.length;
			while (i < n)
			{
				if (plugins[i] == null)
				{
					plugins[i] = aPlugin;
					return aPlugin;
				}
				i++;
			}
			
			plugins.push(aPlugin);
			return aPlugin;
		}
		
		/**
		 * Удаляет плагин из списка для обработки.
		 * 
		 * @param	aPlugin	 Плагин который необходимо удалить.
		 * @param	aSplice	 Если true то элемент массива в котором размещался плагин так же будет удален.
		 * @default    Возвращает указатель на удаленный плагин.
		 */
		public static function removePlugin(aPlugin:IPlugin, aSplice:Boolean = false):IPlugin
		{
			var i:int = plugins.indexOf(aPlugin);
			if (i >= 0 && i < plugins.length)
			{
				plugins[i] = null;
				if (aSplice)
				{
					plugins.splice(i, 1);
				}
			}
			
			return aPlugin;
		}
		
		/**
		 * Добавляет камеру в список для обработки.
		 * 
		 * @param	aCamera	 Камера которую необходимо добавить.
		 * @return		Возвращает указатель на добавленную камеру.
		 */
		public static function addCamera(aCamera:AntCamera):AntCamera
		{
			if (cameras.indexOf(aCamera) > -1)
			{
				return aCamera;
			}
			
			if (_anthill.state == null)
			{
				throw new Error("Before adding the Camera need to initialize game state.");
			}
			
			if (!_anthill.state.contains(aCamera._flashSprite))
			{
				_anthill.state.addChild(aCamera._flashSprite);
			}
			
			var i:int = 0;
			const n:int = cameras.length;
			while (i < n)
			{
				if (cameras[i] == null)
				{
					cameras[i] = aCamera;
					camera = aCamera;
					return aCamera;
				}
				i++;
			}
			
			cameras.push(aCamera);
			camera = aCamera;
			return aCamera;
		}
		
		/**
		 * Удаляет камеру из игрового движка.
		 * 
		 * @param	aCamera	 Камера которую необходимо удалить.
		 * @param	aSplice	 Если true то элемент массива в котором размещалась камера так же будет удален.
		 * @return		Возвращает указатель на удаленную камеру.
		 */
		public static function removeCamera(aCamera:AntCamera, aSplice:Boolean = false):AntCamera
		{
			var i:int = cameras.indexOf(aCamera);
			if (i < 0 || i >= cameras.length)
			{
				return aCamera;
			}
			
			if (_anthill.state != null && _anthill.state.contains(aCamera._flashSprite))
			{
				_anthill.state.removeChild(aCamera._flashSprite);
			}
			
			cameras[i] = null;
			if (aSplice)
			{
				cameras.splice(i, 1);
			}
			
			if (camera == aCamera)
			{
				camera = null;
			}
			
			return aCamera;
		}
		
		/**
		 * Безопасный метод извлечения камеры.
		 * 
		 * @param	aIndex	 Индекс камеры которую необходимо получить.
		 * @return		Указатель на камеру.
		 */
		public static function getCamera(aIndex:int = -1):AntCamera
		{
			if (aIndex == -1)
			{
				return camera;
			}
			
			if (aIndex >= 0 && aIndex < cameras.length)
			{
				return cameras[aIndex];
			}
			
			return null;
		}
		
		/**
		 * Переключает игровые состояния.
		 * 
		 * @param	aState	 Новое состояние на которое необходимо произвести переключение.
		 */
		public static function switchState(aState:AntState):AntState
		{
			if (_anthill != null)
			{
				_anthill.switchState(aState);
			}
			
			return aState;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет используется в игре системный курсор или нет.
		 */
		public static function get useSystemCursor():Boolean { return (_anthill != null) ? _anthill._useSystemCursor : true; }
		public static function set useSystemCursor(value:Boolean):void
		{
			if (_anthill != null)
			{
				if (_anthill._useSystemCursor != value)
				{
					_anthill._useSystemCursor = value;
					if (!debugger.visible)
					{
						(value) ? flash.ui.Mouse.show() : flash.ui.Mouse.hide();
					}
				}
			}
		}
		
		/**
		 * Определяет частоту кадров.
		 */
		public static function get frameRate():uint { return (stage != null) ? stage.frameRate : 0; }
		public static function set frameRate(value:uint):void
		{
			if (stage != null)
			{
				stage.frameRate = value;
			}
		}
		
		/**
		 * Возвращает указатель на текущее игровое состояние.
		 */
		public static function get state():AntState
		{
			return (_anthill != null) ? _anthill.state : null;
		}
		
		/**
		 * Возвращает указатель на экземпляр Anthill.
		 */
		public static function get anthill():Anthill
		{
			return _anthill;
		}
		
		/**
		 * Возвращает кол-во объектов для которых были вызваны методы процессинга (exist = true).
		 */
		public static function get numOfActive():int
		{
			return AntBasic.NUM_OF_ACTIVE;
		}
		
		/**
		 * Возвращает кол-во объектов для которых был вызван метод отрисовки (visible = true).
		 */
		public static function get numOfVisible():int
		{
			return AntBasic.NUM_OF_VISIBLE;
		}

		/**
		 * Возвращает кол-во объектов которые были отрисованы (попали в видимость одной или нескольких камер).
		 * 
		 * <p>Примичание: если один и тот же объект попадет в видимость двух камер, то такой объект будет 
		 * посчитан дважды.</p>
		 */
		public static function get numOnScreen():int
		{
			return AntBasic.NUM_ON_SCREEN;
		}
		
	}

}