package ru.antkarlov.anthill
{
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	/**
	 * Менеджер для создания и управления растровыми анимациями.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  20.08.2012
	 */
	public class AntCache extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Событие выполняющееся при запуске процесса кэширования.
		 */
		public var eventStart:AntEvent;
		
		/**
		 * Событие выполняющееся при каждом шаге кэширования.
		 * <p>Внимание: В качестве атрибута в функцию передается 
		 * процент выполненной работы: <code>function yourFunc(percent:int):void { trace(percent); }</code></p>
		 */
		public var eventProcess:AntEvent;
		
		/**
		 * Событие выполняющееся при завершении процесса кэширования.
		 */
		public var eventComplete:AntEvent;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Хранилище добавленных классов клипов для кэширования.
		 */
		protected var _classes:AntStorage;
		
		/**
		 * Хранилище растровых анимаций.
		 */
		protected var _cachedAnimations:AntStorage;
		
		/**
		 * Индекс текущего клипа для кэширования. Используется в процессе кэширования.
		 */
		protected var _index:int;
		
		/**
		 * Список всех клипов для кэширования. Используется в процессе кэширования.
		 */
		protected var _queue:Array;
		
		/**
		 * Список клипов с флагом <code>weak = true</code>.
		 */
		protected var _weakList:Array;
		
		/**
		 * Флаг определяющий запущен ли процесс кэширования клипов.
		 */
		protected var _started:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntCache()
		{
			super();
			
			eventStart = new AntEvent();
			eventProcess = new AntEvent();
			eventComplete = new AntEvent();
			
			_classes = new AntStorage();
			_cachedAnimations = new AntStorage();
			_queue = [];
			_weakList = [];
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет класс клипа в список для кэширования.
		 * 
		 * @param	aClipClass	 Имя класса клипа который необходимо растеризировать.
		 * @param	aKey	 Имя растеризированной анимации. Если не указана то используется имя класса клипа.
		 * @param	aWeak	 Если true то анимация может быть удалена из кэша при вызове метода removeWeakAnimations().
		 */
		public function addClip(aClipClass:Class, aKey:String = null, aWeak:Boolean = false):void
		{
			if (aKey == null)
			{
				aKey = getQualifiedClassName(aClipClass);
			}
			
			_classes.set(aKey, aClipClass);
			(aWeak) ? _weakList[_weakList.length] = aKey : _queue[_queue.length] = aKey;
		}
		
		/**
		 * Добавляет список классов клипов которые необходи растеризировать.
		 * 
		 * @param	aClipClasses	 Массив классов клипов которые необходимо растеризировать.
		 * @param	aWeak	 Если true то анимации могут быть удалены из кэша при вызове метода removeWeakAnimations().
		 */
		public function addClips(aClipClasses:Array, aWeak:Boolean = false):void
		{
			var i:int = 0;
			var n:int = aClipClasses.length;
			while (i < n)
			{
				addClip(aClipClasses[i], null, aWeak);
				i++;
			}
		}
		
		/**
		 * Кэширует клип с указанным именем.
		 * 
		 * @param	aKey	 Имя класса клипа который необходимо кэшировать.
		 * @return		Возвращает указатель на анимацию.
		 */
		public function cacheClip(aKey:String):AntAnimation
		{
			var anim:AntAnimation;
			var clip:*;
			
			if (!_classes.containsKey(aKey))
			{
				throw new Error("AntCache::cacheClip() - Clip \"" + aKey + "\" not found.");
				return null;
			}
			
			if (!_cachedAnimations.containsKey(aKey))
			{
				anim = new AntAnimation(aKey);
				clip = new (_classes.get(aKey) as Class);
				anim.makeAnimation(clip);
				_cachedAnimations.set(aKey, anim);
			}
			else
			{
				anim = _cachedAnimations.get(aKey);
			}
			
			return anim;
		}
		
		/**
		 * Помещает анимацию в кэш.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо добавить.
		 * @param	aAnim	 Анимация которую необходимо поместить в кэш.
		 * @return		Возвращает указатель на добавленную анимацию.
		 */
		public function setAnimation(aKey:String, aAnim:AntAnimation):AntAnimation
		{
			_cachedAnimations.set(aKey, aAnim);
			return aAnim;
		}
		
		/**
		 * Извлекает анимацию из кэша.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо получить.
		 * @return		Возвращает указатель на анимацию.
		 */
		public function getAnimation(aKey:String):AntAnimation
		{
			if (!_cachedAnimations.containsKey(aKey))
			{
				throw new Error("AntCache::getAnimation() - Missing animation \"" + aKey + "\".");
				return null;
			}

			return _cachedAnimations.get(aKey) as AntAnimation;
		}
		
		/**
		 * Удаляет анимацию из кэша.
		 * 
		 * Примечание: Если после удалении анимации из кэша её более не планируется
		 * использовать, то следует вызвать метод destroy() для удаленной анимации 
		 * чтобы освободить память.
		 * 
		 * Внимание: Если удаленная анимация была ранее добавлена в Акетов, то прежде чем
		 * вызывать метод destroy() для удаляемой анимации следует убедится в том, что 
		 * вы удалили эту анимацию из актеров.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо удалить.
		 * @return		Возвращает указатель на удаленную анимацию.
		 */
		public function removeAnimation(aKey:String):AntAnimation
		{
			return _cachedAnimations.remove(aKey) as AntAnimation;
		}
		
		/**
		 * Удаляет анимации из кэша с флагом weak.
		 * Примечание: чтобы восстановить удаленные анимации, необходимо вызвать метод cacheWeakClips().
		 */
		public function removeWeakAnimations():void
		{
			var anim:AntAnimation;
			var key:String;
			var i:int = 0;
			var n:int = _weakList.length;
			while (i < n)
			{
				key = _weakList[i];
				if (_queue.indexOf(key) == -1)
				{
					if (_cachedAnimations.containsKey(key))
					{
						anim = _cachedAnimations.remove(key) as AntAnimation;
						if (anim != null)
						{
							anim.destroy();
						}
					}
				}
				i++;
			}
		}
		
		/**
		 * Кэширует анимации из клипов с флагом weak.
		 * 
		 * @param	aKeys	 Массив с именами анимаци/именами классов клипов которые необходимо перекэшировать.
		 */
		public function cacheWeakClips(aKeys:Array):void
		{
			_queue.length = 0;
			var i:int = 0;
			var n:int = aKeys.length;
			while (i < n)
			{
				_queue[_queue.length] = aKeys[i];
				i++;
			}
			cacheClips();
		}
		
		/**
		 * Запускает процесс кэширования клипов.
		 */
		public function cacheClips():void
		{
			if (!_started && _queue.length > 0)
			{
				_started = true;
				_index = 0;
				eventStart.send();
				step();
			}
			else
			{
				eventComplete.send();
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Шаг процесса кэширования клипов.
		 */
		protected function step():void
		{
			var key:String = _queue[_index++];
			if (key != null)
			{
				cacheClip(key);
				setTimeout(step, 1);
				eventProcess.send([ AntMath.toPercent(_index, _queue.length) ]);
			}
			else
			{
				_queue.length = 0;
				_started = false;
				eventComplete.send();
			}
		}

	}

}