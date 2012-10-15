package ru.antkarlov.anthill
{
	import flash.display.Stage;
	import flash.display.BitmapData;
	
	import ru.antkarlov.anthill.debug.*;
	
	/**
	 * Глобальное хранилище с указателями на часто использующиеся экземпляры классов и их методы.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.08.2012
	 */
	public class AntG extends Object
	{
		/**
		 * Имя движка.
		 */
		public static const LIB_NAME:String = "Anthill Alpha";
		
		/**
		 * Версия основного релиза.
		 */
		public static const LIB_MAJOR_VERSION:int = 0;
		
		/**
		 * Версия второстепенного релиза.
		 */
		public static const LIB_MINOR_VERSION:int = 1;
		
		/**
		 * Версия обслуживания.
		 */
		public static const LIB_MAINTENANCE:int = 1;
		
		/**
		 * Размер окна по ширине. 
		 * @default    Определяется автоматически из stage.stageWidth.
		 */
		public static var width:int;
		
		/**
		 * Размер окна по высоте.
		 * @default    Определяется автоматически из stage.stageHeight.
		 */
		public static var height:int;
		
		/**
		 * Половина ширины окна или центр экрана по X.
		 * @default    Вычисляется автоматически из stage.stageWidth.
		 */
		public static var widthHalf:int;
		
		/**
		 * Половина высоты окна или центр экрана по Y.
		 * @default    Вычисляется автоматически из stage.stageHeight.
		 */
		public static var heightHalf:int;
		
		/**
		 * Как быстро протекает время в игровом мире. Изменяя этот параметр можно получить эффект слоу-мо.
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
		 * Список камер.
		 */
		public static var cameras:Array;
		
		/**
		 * Указатель на последнюю добавленную камеру. Для безопасного получения указателя
		 * на текущую камеру используйте метод: <code>AntG.getDefaultCamera();</code>
		 */
		public static var camera:AntCamera;
		
		/**
		 * Указатель на класс для обработки действий мыши.
		 */
		public static var mouse:AntMouse;
		
		/**
		 * Указатель на класс для обработки действий с клавиатуры.
		 */
		public static var keys:AntKeyboard;
		
		/**
		 * @private
		 */
		public static var sounds:AntSoundManager;
		
		/**
		 * Указатель на класс процессор для невидимых объектов и помошников.
		 */
		public static var updater:AntUpdater;
		
		/**
		 * Указатель на класс кэша с растровыми анимациями.
		 */
		public static var cache:AntCache;

		/**
		 * Указатель на отладчик.
		 */
		public static var debugger:AntDebugger;
		
		/**
		 * Указатель на класс отслеживающий удаление объектов.
		 */
		public static var memory:AntMemory;
		
		/**
		 * Указатель на метод <code>track()</code> класса <code>AntMemory</code>, для добавления объектов в список слежения.
		 * Пример использования <code>AntG.track(myObject);</code>.
		 * <p>Чтобы посмотреть содержимое <code>AntMemory</code>, наберите в консоли команду "-gc", после чего будет принудительно
		 * вызван сборщик мусора и выведена информация о всех объектах которые по каким-либо причинам сохранились в <code>AntMemory</code>.</p>
		 */
		public static var track:Function;
		
		/**
		 * Указатель на метод <code>registerCommand()</code> класса <code>AntConsole</code> для быстрого добавления пользовательских
		 * команд в консоль. Пример использования <code>AntG.registerCommand("test", myMethod, "Эта команда запускает тестовый метод.");</code>
		 */
		public static var registerCommand:Function;
		
		/**
		 * Указатель на метод <code>unregisterCommand()</code> класса AntConsole для быстрого удаления зарегистрированных
		 * пользовальских команд из консоли. Пример использования <code>AntG.unregisterCommand("test");</code>
		 * <p>Примичание: в качестве идентификатора команды может быть указатель на метод который выполняет команда.</p>
		 */
		public static var unregisterCommand:Function;
		
		/**
		 * Указатель на метод <code>log()</code> класса <code>AntConsole</code> для быстрого вывода любой информации в консоль.
		 * Пример использования: <code>AntG.log(someData);</code>
		 */
		public static var log:Function;
		
		/**
		 * Указатель на метод <code>watchValue()</code> класса <code>AntMonitor</code> используется для добавления или обновления
		 * значения в "мониторе". Пример использования: <code>AntG.watchValue("valueName", value);</code>
		 */
		public static var watchValue:Function;
		
		/**
		 * Указатель на метод <code>unwatchValue()</code> класса <code>AntMonitor</code> используется для удаления записи о значении
		 * из "монитора". Пример использования: <code>AntG.unwatchValue("valueName");</code>
		 */
		public static var unwatchValue:Function;
		
		/**
		 * Указатель на метод <code>beginWatch()</code> класса <code>AntMonitor</code> используется для блокировки обновления окна
		 * монитора при обновлении сразу двух и более значений в мониторе. Пример использования:
		 * <code>AntG.beginWatch();
		 * AntG.watchValue("someValue1", value1);
		 * AntG.watchValue("someValue2", value2);
		 * AntG.endWatch();</code>
		 */
		public static var beginWatch:Function;
		
		/**
		 * Указатель на метод <code>endWatch()</code> класса <code>AntMonitor</code> используется для снятия блокировки обновления окна
		 * монитора при обновлнии сразу двух и более значений в мониторе.
		 */
		public static var endWatch:Function;
		
		/**
		 * Указатель на экземпляр класса <code>Anthill</code>.
		 */
		internal static var _anthill:Anthill = null;
		
		/**
		 * Указатель на экземпляр класса <code>AntDrawer</code>.
		 */
		public static var debugDrawer:AntDrawer = null;
		
		/**
		 * Инициализация глобального хранилища и его переменных.
		 * <p>Примечание: Вызывается автоматически при инициализации игрового движка.</p>
		 */
		public static function init(aAnthill:Anthill):void
		{
			timeScale = 0.5;
			elapsed = 0.02;
			maxElapsed = 0.0333333;
			
			_anthill = aAnthill;
			width = _anthill.stage.stageWidth;
			height = _anthill.stage.stageHeight;
			widthHalf = _anthill.stage.stageWidth * 0.5;
			heightHalf = _anthill.stage.stageHeight * 0.5;
			
			cameras = [];
			
			mouse = new AntMouse();
			keys = new AntKeyboard();
			sounds = new AntSoundManager();
			updater = new AntUpdater();
			cache = new AntCache();
			
			debugger = new AntDebugger();

			track = AntMemory.track;
			
			registerCommand = debugger.console.registerCommand;
			unregisterCommand = debugger.console.unregisterCommand;
			log = debugger.console.log;
			
			watchValue = debugger.monitor.watchValue;
			unwatchValue = debugger.monitor.unwatchValue;
			beginWatch = debugger.monitor.beginWatch;
			endWatch = debugger.monitor.endWatch;
		}
		
		/**
		 * Позволяет задать размеры окна вручную.
		 * <p>Примичание: по умолчанию размер экрана определятся исходя из размера <code>stage.stageWidth</code> и <code>stage.stageHeight.</code></p>
		 * Внимание: установленный размер экрана никак не влияет на работу с камерами.
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
		 * Возвращает указатель на <code>stage</code>. Если игровой движок не инициализирован, вернет <code>null</code>.
		 */
		public static function get stage():Stage
		{
			return (_anthill != null) ? _anthill.stage : null;
		}
		
		/**
		 * Добавляет новую камеру в игровой движок.
		 * 
		 * @param	aCamera	 Камера которую необходимо добавить.
		 * @return		Возвращает указатель на добавленную камеру.
		 */
		public static function addCamera(aCamera:AntCamera):AntCamera
		{
			if (cameras.indexOf(aCamera) == -1)
			{
				var n:int = cameras.length;
				for (var i:int = 0; i < n; i++)
				{
					if (cameras[i] == null)
					{
						cameras[i] = aCamera;
						camera = aCamera;
						return aCamera;
					}
				}
				
				cameras[cameras.length] = aCamera;
			}
			
			camera = aCamera;
			return aCamera;
		}
		
		/**
		 * Удаляет камеру из игрового движка.
		 * 
		 * @param	aCamera	 Камера которую необходимо удалить.
		 * @return		Возвращает указатель на удаленную камеру.
		 */
		public static function removeCamera(aCamera:AntCamera, aSplice:Boolean = false):AntCamera
		{
			var i:int = cameras.indexOf(aCamera);
			if (i > -1)
			{
				cameras[i] = null;
				if (aSplice)
				{
					cameras.splice(i, 1);
				}
			}
			
			return aCamera;
		}
		
		/**
		 * Безопасный метод получения текущей активной камеры.
		 */
		public static function getDefaultCamera():AntCamera
		{
			if (camera == null)
			{
				throw new Error("AntG::getDefaultCamera() - Hey, we don't have a camera.");
			}
			
			return camera;
		}
		
		/**
		 * Возвращает установленную частоту кадров.
		 */
		public static function getFramerate():uint
		{
			return _anthill.framerate;
		}
		
		/**
		 * Устанавливает новую частоту кадров.
		 */
		public static function setFramerate(value:uint):void
		{
			_anthill.framerate = value;
		}
		
		/**
		 * Обновляет классы работающие с вводом данных.
		 */
		internal static function updateInput():void
		{
			mouse.update(stage.mouseX, stage.mouseY);
			keys.update();
			updater.update();
		}
		
		/**
		 * Обновляет звуковые классы.
		 */
		internal static function updateSounds():void
		{
			sounds.update();
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает указатель на экземпляр игрового движка.
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
			return AntBasic._numOfActive;
		}
		
		/**
		 * Возвращает кол-во объектов для которых был вызван метод отрисовки (visible = true).
		 */
		public static function get numOfVisible():int
		{
			return AntBasic._numOfVisible;
		}

		/**
		 * Возвращает кол-во объектов которые были отрисованы (попали в видимость одной или нескольких камер).
		 * <p>Примичание: если один и тот же объект попадет в видимость двух камер, то такой объект будет посчитан дважды.</p>
		 */
		public static function get numOnScreen():int
		{
			return AntBasic._numOnScreen;
		}

	}

}