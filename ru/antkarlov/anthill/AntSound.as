package ru.antkarlov.anthill
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	import flash.events.Event;
	
	import ru.antkarlov.anthill.signals.AntSignal;
	import ru.antkarlov.anthill.utils.AntRating;
	
	/**
	 * Сущность звука.
	 * 
	 * <p>Примечание: Напрямую работать со звуками не рекомендуется. 
	 * Работайте со звуками используя менеджер звуков <code>AntSoundManager</code>. 
	 * Стандартный менеджер звуков инициализируется автоматически и доступен через <code>AntG.sounds</code>.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  04.09.2012
	 */
	public class AntSound extends AntBasic
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Имя звука.
		 */
		public var name:String;
		
		/**
		 * Указатель на менеджер звуков который управляет данным звуком.
		 */
		public var parent:AntSoundManager;
		
		/**
		 * Указатель на массив слушателей в менеджере звуков.
		 */
		public var listeners:Array;
		
		/**
		 * @private
		 */
		public var eventComplete:AntSignal;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Звук.
		 */
		protected var _sound:Sound;
		
		/**
		 * Звуковая трансформация.
		 */
		protected var _soundTransform:SoundTransform;
		
		/**
		 * Звуковой канал.
		 */
		protected var _soundChannel:SoundChannel;
		
		/**
		 * Указатель на источник звука для рассчета стерео эффекта. Если источник 
		 * не указан, то стерео эффект не рассчитывается.
		 * @default    null
		 */
		protected var _source:AntEntity;
		
		/**
		 * Количество повторов воспроизведения звука.
		 */
		protected var _repeats:int;
		
		/**
		 * Флаг определяющий установлено ли воспроизведение звука на паузу.
		 */
		protected var _paused:Boolean;
		
		/**
		 * Позиция на которой звук был поставлен на паузу, используется для возобновления проигрывания 
		 * с места где воспроизведение было остановлено.
		 */
		protected var _pausePosition:Number;
		
		/**
		 * Текущая громкость звука исходя из положения источника звука.
		 */
		protected var _volumeAdjust:Number;
		
		/**
		 * Текущее параномирование звука исходя из положения источника звука.
		 */
		protected var _panAdjust:Number;
		
		/**
		 * Помошник для определения среднего уровня громкости при нескольких слушателях или камер.
		 */
		protected var _ratingVolume:AntRating;
		
		/**
		 * Помошник для определения среднего параномирования при нескольких слушателях или камер.
		 */
		protected var _ratingPan:AntRating;
		
		/**
		 * Флаг определяющий следует ли поставить воспроизведение звука на паузу после того
		 * как будет завершено уменьшение громкости.
		 */
		protected var _pauseOnFadeOut:Boolean;
		
		/**
		 * Помошник для реализации плавного уменьшения громкости звука звука.
		 */
		protected var _fadeOutTimer:Number;
		
		/**
		 * Помошник для реализации плавного уменьшения громкости звука звука.
		 */
		protected var _fadeOutTotal:Number;
		
		/**
		 * Помошник для реализации плавного увеличения громкости звука звука.
		 */
		protected var _fadeInTimer:Number;
		
		/**
		 * Помошник для реализации плавного увеличения громкости звука звука.
		 */
		protected var _fadeInTotal:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntSound(aName:String, aSound:Sound)
		{
			super();
			
			name = aName;
			parent = null;
			listeners = null;
			eventComplete = new AntSignal(AntSound);
			
			_sound = aSound;
			_paused = false;
			_soundTransform = new SoundTransform();
			
			_source = null;
			_repeats = 1;
			_paused = false;
			_pausePosition = 0;
			_volumeAdjust = 1;
			_panAdjust = 0;
			
			_ratingVolume = new AntRating(1);
			_ratingPan = new AntRating(1);
			
			_pauseOnFadeOut = false;
			_fadeOutTimer = 0;
			_fadeOutTotal = 0;
			_fadeInTimer = 0;
			_fadeInTotal = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			kill();
			
			if (eventComplete != null)
			{
				eventComplete.destroy();
				eventComplete = null;
			}
			
			if (parent != null)
			{
				parent.remove(this);
			}
			
			_sound = null;
			_soundTransform = null;
			
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function kill():void
		{
			if (_soundChannel != null)
			{
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_soundChannel.stop();
				_soundChannel = null;
			}
			
			_source = null;
			listeners = null;
			
			super.kill();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			updateSound();
		}
		
		/**
		 * Запускает проигрывание звука.
		 * 
		 * @param	aSource	 Источник звука, необходимо указывать для рассчета стерео эффекта.
		 * @param	aPosition	 Позиция с какого места начинать проигрывание звука.
		 * @param	aRepeats	 Количество повторов проигрывания.
		 * @param	aVolume 	 Громкость воспроизведения звука.
		 */
		public function play(aSource:AntEntity = null, aPosition:Number = 0, aRepeats:int = 1, aVolume:Number = 1):void
		{
			if (parent == null)
			{
				return;
			}
			
			_repeats = aRepeats;
			_source = aSource;
			
			if (_source == null)
			{
				_soundTransform.volume = (aVolume != 1) ? aVolume : parent.volume;
				if (_sound != null)
				{
					_soundChannel = _sound.play(aPosition, _repeats, _soundTransform);
					if (_soundChannel != null)
					{
						_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					}
				}
			}
			else
			{
				updateSound();
				if (_sound != null)
				{
					_soundChannel = _sound.play(0, _repeats, _soundTransform);
					if (_soundChannel != null)
					{
						_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
					}
				}
			}
		}
		
		/**
		 * Останавливает проигрывание звука.
		 */
		public function stop():void
		{
			if (_soundChannel != null)
			{
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_soundChannel.stop();
				_soundChannel = null;
			}
		}
		
		/**
		 * Ставит проигрывание звука на паузу.
		 */
		public function pause():void
		{
			if (!_paused && _soundChannel != null)
			{
				_paused = true;
				_pausePosition = _soundChannel.position;
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_soundChannel.stop();
				_soundChannel = null;
			}
		}
		
		/**
		 * Продолжает проигрывание звука если он на паузе.
		 */
		public function resume():void
		{
			if (_paused)
			{
				_paused = false;
				play(_source, _pausePosition, _repeats);
			}
		}
		
		/**
		 * Запускает плавное уменьшение громкости звука.
		 * 
		 * @param	aSeconds	 Время в секундах в течении которого будет выполнятся уменьшение громкости.
		 * @param	aOnPause	 Флаг определяющий необходимо ли поставить воспроизводимый звук на паузу после завершения процесса затухания.
		 */
		public function fadeOut(aSeconds:Number, aOnPause:Boolean = false):void
		{
			_pauseOnFadeOut = aOnPause;
			_fadeInTimer = 0;
			_fadeOutTimer = _fadeOutTotal = aSeconds;
		}
		
		/**
		 * Запускает плавное увеличение громкости звука.
		 * 
		 * @param	aSeconds	 Время в секундах в течении которого будет выполнятся увеличение громкости.
		 */
		public function fadeIn(aSeconds:Number):void
		{
			_fadeOutTimer = 0;
			_fadeInTimer = _fadeInTotal = aSeconds;
			play(_source, _pausePosition, _repeats);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обработка стерео эффекта для звука.
		 */
		public function updateSound():void
		{
			if (_source == null)
			{
				return;
			}
			
			if (listeners == null)
			{	
				listeners = parent.listeners;
			}
			
			(listeners.length > 0) ? soundForListeners() : soundForCenter();
		}
		
		/**
		 * Рассчет стерео эффекта для звука со слушателями.
		 */
		protected function soundForListeners():void
		{
			var radial:Number;
			var pan:Number;
			var n:int = listeners.length;
			var listener:AntEntity;
			
			if (_ratingVolume.length() != n)
			{
				_ratingVolume = new AntRating(n);
				_ratingPan = new AntRating(n);
			}
			
			// Рассчет громкости и панирования для каждого из слушателей.
			var i:int = 0;
			while (i < n)
			{
				listener = listeners[i] as AntEntity;
				if (listener != null && listener.exists)
				{
					radial = AntMath.distance(_source.globalX, _source.globalY, listener.globalX, listener.globalY) / parent.radius;
					radial = AntMath.trimToRange(radial, 0, 1);
					_ratingVolume.add(1 - radial);
					
					pan = (_source.globalX - listener.globalX) / parent.radius;
					pan = AntMath.trimToRange(pan, -1, 1);
					_ratingPan.add(pan);
				}
				i++;
			}
			
			// Реальная текущая громкость.
			_volumeAdjust = _ratingVolume.average() * updateFade();
			_panAdjust = _ratingPan.average();
			updateTransform();
		}
		
		/**
		 * Рассчет стерео-эффекта для звука без слушателей.
		 */
		protected function soundForCenter():void
		{
			if (cameras == null)
			{
				cameras = AntG.cameras;
			}
			
			var radial:Number;
			var pan:Number;
			var position:AntPoint = new AntPoint();
			var camera:AntCamera;
			var n:int = cameras.length;
			
			if (_ratingVolume.length() != n)
			{
				_ratingVolume = new AntRating(n);
				_ratingPan = new AntRating(n);
			}
			
			var i:int = 0;
			while (i < n)
			{
				camera = cameras[i] as AntCamera;
				if (camera != null)
				{
					_source.getScreenPosition(camera, position);
					radial = AntMath.distance(position.x, position.y, camera.width * 0.5, camera.height * 0.5) / parent.radius;
					radial = AntMath.trimToRange(radial, 0, 1);
					_ratingVolume.add(1 - radial);

					pan = (position.x - camera.width * 0.5) / parent.radius;
					pan = AntMath.trimToRange(pan, -1, 1);
					_ratingPan.add(pan);
				}
				i++;
			}
			
			_volumeAdjust = _ratingVolume.average() * updateFade();
			_panAdjust = _ratingPan.average();
			updateTransform();
		}
		
		/**
		 * Обработка затухания или увеличения громкости звука.
		 */
		protected function updateFade():Number
		{
			var fade:Number = 1;
			
			if (_fadeOutTimer > 0)
			{
				_fadeOutTimer -= AntG.elapsed;
				if (_fadeOutTimer <= 0)
				{
					(_pauseOnFadeOut) ? pause() : stop();
				}
				
				fade = _fadeOutTimer / _fadeOutTotal;
				fade = (fade < 0) ? 0 : fade;
			}
			else if (_fadeInTimer > 0)
			{
				_fadeInTimer -= AntG.elapsed;
				fade = _fadeInTimer / _fadeInTotal;
				fade = (fade < 0) ? 0 : 1 - fade;
			}
			
			return fade;
		}
		
		/**
		 * Обновление трансформации звука.
		 */
		protected function updateTransform():void
		{
			_soundTransform.volume = (parent.mute ? 0 : 1) * parent.volume * _volumeAdjust;
			_soundTransform.pan = _panAdjust;
			if (_soundChannel != null)
			{
				_soundChannel.soundTransform = _soundTransform;
			}
		}
		
		/**
		 * Обработка события завершения воспроизведения звука.
		 */
		protected function soundCompleteHandler(event:Event):void
		{
			kill();
			eventComplete.dispatch(this);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Возвращает указатель на источник звука.
		 */
		public function get source():AntEntity
		{
			return _source;
		}
		
		/**
		 * Определяет громкость звука.
		 */
		public function set volume(value:Number):void
		{
			if (_source == null && _soundChannel != null)
			{
				_soundTransform.volume = value * parent.volume;
				_soundChannel.soundTransform = _soundTransform;
			}
		}
		
		/**
		 * @private
		 */
		public function get volume():Number
		{
			return _soundTransform.volume;
		}

	}

}
