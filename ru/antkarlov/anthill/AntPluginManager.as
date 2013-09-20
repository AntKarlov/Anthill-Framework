package ru.antkarlov.anthill
{
	import ru.antkarlov.anthill.AntCamera;
	import ru.antkarlov.anthill.plugins.IPlugin;
	
	/**
	 * Данный класс реализует управление активными и не активными плагинами.
	 * 
	 * <p>Экземпляр менеджера плагинов создается автоматически при запуске Anthill и доступен
	 * через <code>AntG.plugins</code>. Чтобы добавить в работу свой плагин, необходимо добавить
	 * его в менеджер:</p>
	 * 
	 * <pre>AntG.plugins.add(new MyPlugin());</pre>
	 * 
	 * <p>Так же в задачи менеджера плагинов входить возможность приостанавливать и возобновлять
	 * работу плагинов соотвествующих указанным критериям. В качестве критериев принимаются: тэги,
	 * классы и указатели на сами плагины.</p>
	 * 
	 * <pre>AntG.plugins.stop("someTag", MyPluginClass, myPlugin);</pre>
	 * 
	 * <p>Чтобы возобновить работу остановленных плагинов, достаточно вызывать <code>resume()</code>:</p>
	 * 
	 * <pre>AntG.plugins.resume("someTag", MyPluginClass, myPlugin);</pre>
	 * 
	 * <p>Более подробно о том как <a href="http://anthill.ant-karlov.ru/wiki/guide:plugins_use" target="_blank">
	 * использовать</a> и <a href="http://anthill.ant-karlov.ru/wiki/guide/plugins_create" target="_blank">
	 * создавать</a> свои плагины, читайте в Anthill Wiki.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 10.0.0
	 * 
	 * @author Anton Karlov
	 * @since  26.05.2013
	 */
	public class AntPluginManager extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		protected static const ASCENDING:int = -1;
		protected static const DESCENDING:int = 1;
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Список активных плагинов.
		 */
		public var listOfActive:Vector.<IPlugin>;
		
		/**
		 * Список остановленных плагинов.
		 */
		public var listOfPaused:Vector.<IPlugin>;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		protected var _numActive:int;
		protected var _numPaused:int;
		protected var _sortOrder:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntPluginManager()
		{
			super();
			
			listOfActive = new <IPlugin>[];
			listOfPaused = new <IPlugin>[];
			
			_numActive = 0;
			_numPaused = 0;
			_sortOrder = DESCENDING;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет плагин.
		 * 
		 * @param	aPlugin	 Плагин который необходимо добавить.
		 * @return		Возвращает указатель на добавленный плагин.
		 */
		public function add(aPlugin:IPlugin):IPlugin
		{
			if (contains(aPlugin))
			{
				return aPlugin;
			}
			
			var i:int = 0;
			while (i < _numActive)
			{
				if (listOfActive[i] == null)
				{
					listOfActive[i] = aPlugin;
					listOfActive.sort(sortHandler);
					return aPlugin;
				}
				i++;
			}
			
			listOfActive.push(aPlugin);
			listOfActive.sort(sortHandler);
			_numActive++;
			return aPlugin;
		}
		
		/**
		 * Добавляет плагин в список остановленных плагинов.
		 * 
		 * @param	aPlugin	Плагин который необходимо остановить.
		 * @return		Возвращает указатель на плагин добавленный в список остановленных.
		 */
		public function addToPaused(aPlugin:IPlugin):IPlugin
		{
			if (contains(aPlugin))
			{
				return aPlugin;
			}
			
			var i:int = 0;
			while (i < _numPaused)
			{
				if (listOfPaused[i] == null)
				{
					listOfPaused[i] = aPlugin;
					return aPlugin;
				}
				i++;
			}
			
			listOfPaused.push(aPlugin);
			_numPaused++;
			return aPlugin;
		}
		
		/**
		 * Удаляет плагин.
		 * 
		 * <p>Примичание: Если удаляемый плагин был ранее помещен в список остановленных (поставлен на паузу),
		 * то он так же будет удален и из списка остановленных.</p>
		 * 
		 * @param	aPlugin	 Плагин который необходимо удалить.
		 * @param	aSplice	 Если true то элемент массива в котором размещался плагин так же будет удален.
		 * @default    Возвращает указатель на удаленный плагин.
		 */
		public function remove(aPlugin:IPlugin, aSplice:Boolean = false):IPlugin
		{
			var i:int = listOfActive.indexOf(aPlugin);
			if (i >= 0 && i < listOfActive.length)
			{
				listOfActive[i] = null;
				if (aSplice)
				{
					listOfActive.splice(i, 1);
					_numActive--;
				}
			}
			
			removeFromPaused(aPlugin, aSplice);
			return aPlugin;
		}
		
		/**
		 * Удаляет плагин из списка остановленных.
		 * 
		 * @param	aPlugin	 Плагин который необходимо удалить из списка остановленных.
		 * @param	aSplice	 Флаг определяющий будет ли удалена ячейка из списка при удалении плагина.
		 * @return		Возвращает указатель на плагин удаленный из списка приостановленных.
		 */
		public function removeFromPaused(aPlugin:IPlugin, aSplice:Boolean = false):IPlugin
		{
			var i:int = listOfPaused.indexOf(aPlugin);
			if (i >= 0 && i < listOfPaused.length)
			{
				listOfPaused[i] = null;
				if (aSplice)
				{
					listOfPaused.splice(i, 1);
					_numPaused--;
				}
			}
			
			return aPlugin;
		}
		
		/**
		 * Удаляет несколько плагинов по указанным критериям.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>
		 * AntG.plugins.removeSeveral([ "tween", AntTween ]); // Удаление по тэгу и классу
		 * AntG.plugins.removeSeveral("tween"); // Удаление только по тэгу
		 * AntG.plugins.removeSeveral(AntTween); // Удаление только по классу
		 * </pre>
		 * 
		 * @param	aPlugins	 Список или массив плагинов, тэгов или классов плагинов которые следует удалить.
		 * @return		Возвращает список удаленных плагинов.
		 */
		
		public function removeSeveral(...aPlugins):Array /* of IPlugin */
		{
			if (aPlugins == null) return null;
			
			var res:Array = [];
			var list:Array = (aPlugins.length == 1 && aPlugins[0] is Array) ? aPlugins[0] : aPlugins;
			const n:int = list.length;
			var i:int = 0;
			while (i < n)
			{
				removePlugin(list[i++], res);
			}
			
			return res;
		}
		
		/**
		 * Проверят был ли ранее добавлен указанный плагин.
		 * 
		 * @param	aPlugin	Плагин наличие которого необходимо проверить.
		 * @return		Вовзращает true если плагин был ранее добавлен.
		 */
		public function contains(aPlugin:IPlugin):Boolean
		{
			return (listOfActive.indexOf(aPlugin) > -1 || listOfPaused.indexOf(aPlugin) > -1);
		}
		
		/**
		 * Проверят находится ли указанный плагин в списке активных плагинов.
		 * 
		 * @param	aPlugin	 Плагин который необходимо проверить.
		 * @return		Возвращает true если плагин находится в списке активных.
		 */
		public function isActive(aPlugin:IPlugin):Boolean
		{
			return (listOfActive.indexOf(aPlugin) > -1);
		}
		
		/**
		 * Проверяет находится ли указанный плагин в списке остановленных плагинов.
		 * 
		 * @param	aPlugin	 Плагин который необходимо проверить.
		 * @return		Возвращает true если плагин находится в списке остановленных.
		 */
		public function isPaused(aPlugin:IPlugin):Boolean
		{
			return (listOfPaused.indexOf(aPlugin) > -1);
		}
		
		/**
		 * Извлекает список плагинов по указанным критериям.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>
		 * AntG.plugins.get([ "tween", AntTween ]); // Извлечение по тэгу и классу
		 * AntG.plugins.get("tween"); // Извлечение только по тэгу
		 * AntG.plugins.get(AntTween); // Извлечение только по классу
		 * </pre>
		 * 
		 * @param	aPlugins	 Массив или список тэгов или классов плагинов которые нужно извлечь.
		 * @return		Возвращает массив плагинов соответствующих указанным критериям.
		 */
		public function get(...aPlugins):Array /* of IPlugin */
		{
			if (aPlugins == null)
			{
				return null;
			}
			
			var res:Array = [];
			var list:Array = (aPlugins.length == 1 && aPlugins[0] is Array) ? aPlugins[0] : aPlugins;
			const n:int = list.length;
			var i:int = 0;
			while (i < n)
			{
				getPlugin(list[i++], res);
			}
			
			return res;
		}
		
		/**
		 * Останавливает работу плагинов которые соотвествуют указанным критериям.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>
		 * AntG.plugins.stop([ "tween", AntTween, myTween ]); // Остановка по тэгу, классу и указателю на экземпляр
		 * AntG.plugins.stop("tween"); // Остановка по тэгу
		 * AntG.plugins.stop(myTween); // Остановка по указателю на экземпляр
		 * </pre>
		 * 
		 * @param	aPlugins	 Массив или список тэгов, классов или указателей на плагины которые необходимо остановить.
		 * @return		Возвращает количество остановленных плагинов.
		 */
		
		public function pause(...aPlugins):int
		{
			if (aPlugins == null)
			{
				return 0;
			}
			
			var count:int = 0;
			var list:Array = (aPlugins.length == 1 && aPlugins[0] is Array) ? aPlugins[0] : aPlugins;
			const n:int = list.length;
			var i:int = 0;
			while (i < n)
			{
				count += stopPlugin(list[i++]);
			}
			
			return count;
		}
		
		/**
		 * Возобновляет работу плагинов которые соотвествуют указанным критериям.
		 * 
		 * <p>Пример использования:</p>
		 * <pre>
		 * AntG.plugins.resume([ "tween", AntTween, myTween ]); // Запуск по тэгу, классу и указателю на экземпляр
		 * AntG.plugins.resume("tween"); // Запуск по тэгу
		 * AntG.plugins.resume(myTween); // Запуск по указателю на экземпляр
		 * </pre>
		 * 
		 * @param	aPlugins	 Массив или список тэгов, классов или указателей на плагины работу которых необходимо возобновить.
		 * @return		Возвращает количество запущенных плагинов.
		 */
		public function resume(...aPlugins):int
		{
			if (aPlugins == null)
			{
				return 0;
			}
			
			var count:int = 0;
			var list:Array = (aPlugins.length == 1 && aPlugins[0] is Array) ? aPlugins[0] : aPlugins;
			const n:int = list.length;
			var i:int = 0;
			while (i < n)
			{
				count += resumePlugin(list[i++]);
			}
			
			return count;
		}
		
		/**
		 * Обработка плагинов.
		 */
		public function update():void
		{
			var i:int = 0;
			var plugin:IPlugin;
			while (i < _numActive)
			{
				plugin = listOfActive[i++];
				if (plugin != null)
				{
					plugin.update();
				}
			}
		}
		
		/**
		 * Отрисовка плагинов.
		 */
		public function draw(aCamera:AntCamera):void
		{
			var i:int = 0;
			var plugin:IPlugin;
			while (i < _numActive)
			{
				plugin = listOfActive[i++];
				if (plugin != null)
				{
					plugin.draw(aCamera);
				}
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Удаляет плагин соответствующий указанному критерию.
		 * 
		 * @param	aPlugin	 Тэг, класс или сам плагин который необходимо удалить.
		 * @param	aResult	 Массив в который будет записан удаленный плагин(ы).
		 * @return		Возвращает массив удаленных плагинов.
		 */
		protected function removePlugin(aPlugin:*, aResult:Array = null):Array /* of IPlugin */
		{
			if (aPlugin == null) return null;
			if (aResult == null) aResult = [];

			var i:int = 0;
			var plugin:IPlugin;
			while (i < _numActive)
			{
				plugin = listOfActive[i++];
				if (compare(aPlugin, plugin))
				{
					aResult.push(plugin);
					remove(plugin);
				}
			}
			
			i = 0;
			while (i < _numPaused)
			{
				plugin = listOfPaused[i++];
				if (compare(aPlugin, plugin))
				{
					aResult.push(plugin);
					remove(plugin);
				}
			}
			
			return aResult;
		}
		
		/**
		 * Извлекает плагин соответствующий указанному критерию.
		 * 
		 * @param	aPlugin	 Тэг, класс или сам плагин который необходимо извлечь.
		 * @param	aResult	 Массив в который будет записан извлеченный плагин(ы).
		 * @return		Возвращает массив извлеченных плагинов.
		 */
		protected function getPlugin(aPlugin:*, aResult:Array = null):Array /* of IPlugin */
		{
			if (aPlugin == null) return null;
			if (aResult == null) aResult = [];
			
			var i:int = 0;
			var plugin:IPlugin;
			while (i < _numActive)
			{
				plugin = listOfActive[i++];
				if (compare(aPlugin, plugin))
				{
					aResult.push(plugin);
				}
			}
			
			i = 0;
			while (i < _numPaused)
			{
				plugin = listOfPaused[i++];
				if (compare(aPlugin, plugin))
				{
					aResult.push(plugin);
				}
			}
			
			return aResult;
		}
		
		/**
		 * Останавливает работу плагина соотвествующего указанному критерию.
		 * 
		 * @param	aPlugin	 Тэг, класс или сам плагин который необходимо остановить.
		 * @return		Возвращает количество остановленных плагинов.
		 */
		protected function stopPlugin(aPlugin:*):int
		{
			var count:int = 0;
			var plugin:IPlugin;
			var i:int = 0;
			while (i < _numActive)
			{
				plugin = listOfActive[i];
				if (compare(aPlugin, plugin))
				{
					listOfActive[i] = null;
					addToPaused(plugin);
					count++;
				}
				i++;
			}
			
			return count;
		}
		
		/**
		 * Возобновляет работу плагина соотвествующего указанному критерию.
		 * 
		 * @param	aPlugin	 Тэг, класс или сам плагин который необходимо возобновить.
		 * @return		Возвращает количество возобновленных плагинов.
		 */
		protected function resumePlugin(aPlugin:*):int
		{
			var count:int = 0;
			var plugin:IPlugin;
			var i:int = 0;
			while (i < _numPaused)
			{
				plugin = listOfPaused[i];
				if (compare(aPlugin, plugin))
				{
					listOfPaused[i] = null;
					add(plugin);
					count++;
				}
				i++;
			}
			
			return count;
		}

		/**
		 * Проверяет соотвествует ли указанный критерий для указанного плагина.
		 * 
		 * @param	aCondition	 Критерий: тэг, класс или экземпляр.
		 * @param	aPlugin	 Конкретный плагин с которым нужно проверить соотвествие.
		 * @return		Возвращает true если указанный критерий соотвествует указанному плагину.
		 */
		protected function compare(aCondition:*, aPlugin:IPlugin):Boolean
		{
			if (aCondition == null || aPlugin == null)
			{
				return false;
			}
			
			if ((aCondition is String && aPlugin.tag == aCondition as String) ||
				(aCondition is Class && aPlugin is aCondition) ||
				(aCondition is IPlugin && aPlugin == aCondition))
			{
				return true;
			}
			
			return false;
		}
		
		/**
		 * Помошник для сортировки плагинов по приоритету.
		 */
		protected function sortHandler(aPlugin1:IPlugin, aPlugin2:IPlugin):int
		{
			if (aPlugin1 == null)
			{
				return _sortOrder;
			}
			else if (aPlugin2 == null)
			{
				return -_sortOrder;
			}
			
			if (aPlugin1.tag < aPlugin2.tag)
			{
				return _sortOrder;
			}
			else if (aPlugin1.tag > aPlugin2.tag)
			{
				return -_sortOrder;
			}
			
			return 0;
		}
		
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает количество активных плагинов,
		 * включая пустые ячейки в списке <code>listOfActive</code>.
		 */
		public function get numActive():int { return _numActive; }
		
		/**
		 * Возвращает количество остановленных плагинов,
		 * включая пустые ячейки в списке <code>listOfPaused</code>. 
		 */
		public function get numPaused():int { return _numPaused; }
		
		/**
		 * Возвращает количество реально работающих плагинов.
		 */
		public function get numWorks():int
		{
			var count:int = 0;
			var i:int = 0;
			while (i < _numActive)
			{
				if (listOfActive[i++] != null)
				{
					count++;
				}
			}
			
			return count;
		}
	
	}
	
}