package ru.antkarlov.anthill.debug
{
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ru.antkarlov.anthill.*;
	
	/**
	 * Отладочный класс позволяющий мониторить какие-либо значения. Используется для слежения за 
	 * происходящим внутри программы во время разработки.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  23.11.2011
	 */
	public class AntMonitor extends AntPopup
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------	
		protected var _tfKey:TextField;
		protected var _tfValue:TextField;
		
		protected var _registry:AntStorage;
		
		protected var _prevHeight:int;
		protected var _canRedraw:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntMonitor(aParent:Sprite, aX:Number, aY:Number)
		{
			super(aParent, aX, aY, 160, 24);
			
			_registry = new AntStorage();
			
			_prevHeight = -1;
			_canRedraw = true;
			
			create();
			updateDisplay(true);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет значение в монитор.
		 * 
		 * @param	aKey	 Уникальное имя значения.
		 * @param	aValue	 Значение.
		 */
		public function watchValue(aKey:String, aValue:*):void
		{
			_registry.set(aKey, aValue);
			if (_canRedraw)
			{
				updateDisplay();
			}
		}
		
		/**
		 * Удаляет значение из монитора.
		 * 
		 * @param	aKey	 Уникальное имя значения.
		 */
		public function unwatchValue(aKey:String):void
		{
			_registry.remove(aKey);
			if (_canRedraw)
			{
				updateDisplay();
			}
		}
		
		/**
		 * Удаляет все значения из монитора.
		 */
		public function clear():void
		{
			_registry.clear();
			if (_canRedraw)
			{
				updateDisplay(true);
			}
		}
		
		/**
		 * Блокирует обновление монитора до тех пор пока не будет вызван метод endWatch().
		 * 
		 * <p>Примечание: Рекомендуется использовать если в монитор отправляется сразу несколько
		 * разных значений в одном месте программы. Например:</p>
		 * 
		 * <p><code>AntG.beginWatch();
		 * AntG.watchValue("x", hero.x);
		 * AntG.watchValue("y", hero.y);
		 * AntG.watchValue("weapon", hero.weapon);
		 * AntG.endWatch();</code></p>
		 */
		public function beginWatch():void
		{
			_canRedraw = false;
		}
		
		/**
		 * Завершение просмотра данных. Необходимо вызвать после того как был вызван метод 
		 * <code>beginWatch()</code>, чтобы разрешить монитору обновление.
		 */
		public function endWatch():void
		{
			if (!_canRedraw)
			{
				_canRedraw = true;
				updateDisplay();
			}
		}
				
		/**
		 * @inheritDoc
		 */
		override public function show():void
		{
			updateDisplay();
			super.show();
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function create():void
		{
			super.create();
			title = "Monitor";
			
			_tfKey = makeLabel(2, 14, _fGray);
			_tfKey.width = _width * 0.5;
			addChild(_tfKey);
			
			_tfValue = makeLabel(_width * 0.5, 14, _fWhite);
			_tfValue.width = _width * 0.5;
			addChild(_tfValue);
		}
				
		/**
		 * Обновляет коно монитора.
		 * 
		 * @param	aForce	 Принудительное обновление дисплея не зависимо от того видим он или нет.
		 */
		protected function updateDisplay(aForce:Boolean = false):void
		{
			if (!visible && !aForce)
			{
				return;
			}
			
			_prevHeight = (aForce) ? -1 : _prevHeight;
			
			if (_registry.length == 0)
			{
				_tfKey.text = "-";
				_tfValue.text = "-";
				_height = 20 + _tfKey.textHeight;
				_tfKey.height = _tfValue.height = _tfKey.textHeight + 20;
				draw();
				return;
			}
			
			_tfKey.text = "";
			_tfValue.text = "";
			for (var value:* in _registry)
			{
				_tfKey.appendText(value + "\n");
				_tfValue.appendText(_registry[value] + "\n");
			}
			
			_height = 20 + _tfKey.textHeight;
			_tfKey.height = _tfValue.height = _tfKey.textHeight + 20;
			if (_height != _prevHeight)
			{
				draw();
				_prevHeight = _height;
			}
		}

	}

}