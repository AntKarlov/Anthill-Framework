package ru.antkarlov.anthill.debug
{
    import flash.events.Event;
    import flash.net.LocalConnection;
    import flash.system.System;
    import flash.utils.Dictionary;
    import flash.utils.setTimeout;

	import ru.antkarlov.anthill.AntG;

	/**
	 * Отладочный не визуальный класс позволяющий отслеживать удаление объектов из памяти 
	 * сборщиком мусора.
	 * 
	 * <p>Чтобы отслеживать удаление объектов из памяти, следует добавить указатель 
	 * на необходимый объект через <code>AntG.track(aObject:*, aLabel:String = "");</code> Чтобы посмотреть
	 * список существующих объектов выполните команду <code>-gc</code> в консоли. При выполнении
	 * команды <code>-gc</code> будет принудительно запущен сборщик мусора после чего в консоли
	 * отобразится список всех сохранившихся объектов. <a href="http://divillysausages.com/blog/tracking_memory_leaks_in_as3">
	 * Подробнее...</a></p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  27.12.2011
	 */
	public class AntMemory extends Object
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		private static var _highlightLabels:Array;
		private static var _tracking:Dictionary = new Dictionary(true);
		private static var _count:int = 0;
				
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
				
		/**
		 * Добавляет объект слежения для слежения.
		 * 
		 * @param	aObject	 Указатель на объект который следует отслеживать.
		 * @param	aLabel	 Текстовая метка для идентификации объекта в списке.
		 */
		public static function track(aObject:*, aLabel:String = "?"):void
		{
			_tracking[aObject] = aLabel;
		}
		
		/**
		 * Активация сборщика мусора.
		 * 
		 * @param	aLabels	 Список меток которые необходимо подсветить в результатах.
		 */
		public static function callGarbageCollector(aHighlightLabels:Array = null):void
		{			
			_highlightLabels = aHighlightLabels;
			_count = 0;
			AntG.stage.addEventListener(Event.ENTER_FRAME, AntMemory.enterFrameHandler);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		private static function enterFrameHandler(event:Event):void
		{
            var runLast:Boolean = false;

            //CONFIG::release
            {
                /* Хак для принудительного запуска сборщика мусора, используется для
 				релизной версии плеера. */
                try
				{
                    new LocalConnection().connect("foo");
                    new LocalConnection().connect("foo");
                } 
				catch (e:Error) 
				{
					// ...
				}

                runLast = true;
            }

            //CONFIG::debug
            {
                System.gc();
                runLast = _count++ > 1;
            }

			/* Следует ли остановить обработчик события и запустить последний GC?
			В дебаг режиме мы вызываем System.gc() 4 раза: 3 из них в этом методе,
			а на последок в методе doLastGC() */
            if (runLast)
            {
                AntG.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
                setTimeout(callLastGarbageCollector, 40);
            }
		}
		
		/**
		 * Последний вызов сборщика мусора и вывод списка всех сохранившихся объектов
		 * в консоль.
		 */
		private static function callLastGarbageCollector():void
        {
            //CONFIG::debug
            {
                System.gc();
            }

            // Выводим существующие объекты из библиотеки
			AntG.log("  Remaining references in the AntMemory", "data");
            AntG.log("-------------------------------------------------------", "data");		
			
			var n:int = (_highlightLabels != null) ? _highlightLabels.length : 0;
			var highlight:String;
			var numOfHighlight:int = 0;
			var num:int = 0;
            for (var key:Object in _tracking)
			{
				highlight = "data";
				if (n > 0)
				{
					for (var i:int = 0; i < n; i++)
					{
						if (key.toString().indexOf(_highlightLabels[i]) > -1)
						{
							highlight = AntConsole.RESULT;
							numOfHighlight++;
							break;
						}
						else if (_tracking[key].toString().indexOf(_highlightLabels[i]) > -1)
						{
							highlight = "result";
							numOfHighlight++;
							break;
						}
					}
				}
				
				AntG.log("  " + key + " - " + _tracking[key], highlight);
				num++;
			} 
			
			if (numOfHighlight > 0)
			{
				AntG.log("", "data");
				AntG.log("  Num of highlighting lines: " + numOfHighlight.toString(), "result");
			}
			
			if (num == 0)
			{
				AntG.log("  AntMemory is empty.", "data");
			}
			
            AntG.log("", "data");
        }

	}

}