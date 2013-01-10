package ru.antkarlov.anthill.debug
{
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.*;
	import flash.events.*;
	import flash.system.System;
	import flash.ui.*;
	import flash.utils.getTimer;
	
	import ru.antkarlov.anthill.*;
	
	/**
	 * Отладочный класс собирающий и демонстрирующий статистику производительности игры.
	 * <p>За основу взят <a href="http://lostinactionscript.com/2008/10/06/as3-swf-profiler/">SWFProfiler</a></p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  22.11.2011
	 */
	public class AntPerfomance extends AntPopup
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var minFps:Number;
		public var maxFps:Number;
		public var minMem:Number;
		public var maxMem:Number;
		public var history:int = 60;
		public var fpsList:Array = [];
		public var memList:Array = [];
		
		public var ratingPlugins:AntRating = new AntRating(30);
		public var ratingUpdate:AntRating = new AntRating(30);
		public var ratingRender:AntRating = new AntRating(30);
		public var ratingTotal:AntRating = new AntRating(30);
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _itvTime:int;
		private var _initTime:int;
		private var _currentTime:int;
		private var _frameCount:int;
		private var _totalCount:int;
		
		private var _isStarted:Boolean = false;
		
		private var _tfMaxFps:TextField;
		private var _tfMinFps:TextField;
		private var _tfMaxMem:TextField;
		private var _tfMinMem:TextField;
		private var _tfInfo:TextField;
		private var _tfRating:TextField;
		
		private var _fpsBox:Shape;
		private var _memBox:Shape;
		private var _display:Shape;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntPerfomance(aParent:Sprite, aX:Number, aY:Number)
		{
			super(aParent, aX, aY, 448, 170);
			
			create();
			draw();
			
			minFps = Number.MAX_VALUE;
			maxFps = Number.MIN_VALUE;
			minMem = Number.MAX_VALUE;
			maxMem = Number.MIN_VALUE;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Запуск сбора информации.
		 */
		public function start():void
		{
			if (!_isStarted)
			{
				_isStarted = true;
				_initTime = _itvTime = getTimer();
				_totalCount = _frameCount = 0;
			}
		}
		
		/**
		 * Остановка сбора информации.
		 */
		public function stop():void
		{
			_isStarted = false;
		}
		
		/**
		 * Рассчет производительности.
		 */
		public function update():void
		{
			if (_isStarted)
			{
				_currentTime = getTimer();

				_frameCount++;
				_totalCount++;

				if (intervalTime >= 1)
				{
					(visible) ? updateDisplay() : updateMinMax();
					fpsList.unshift(currentFps);
					memList.unshift(currentMem);

					if (fpsList.length > history)
					{
						fpsList.pop();
					}

					if (memList.length > history)
					{
						memList.pop();
					}

					_itvTime = _currentTime;
					_frameCount = 0;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function show():void
		{
			redrawDisplay();
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
			title = "Perfomance";
			
			_tfMaxFps = makeLabel(2, 15, _fGray);
			addChild(_tfMaxFps);
			
			_tfMinFps = makeLabel(2, 52, _fGray);
			addChild(_tfMinFps);
			
			_tfMaxMem = makeLabel(2, 78, _fGray);
			addChild(_tfMaxMem);
			
			_tfMinMem = makeLabel(2, 115, _fGray);
			addChild(_tfMinMem);
			
			_tfInfo = makeLabel(57, 132, _fGray);
			_tfInfo.width = _width;
			addChild(_tfInfo);
			
			_tfRating = makeLabel(57, 146, _fGray);
			_tfRating.width = _width;
			addChild(_tfRating);
			
			_display = new Shape();
			_display.y = 10;
			addChild(_display);
			
			_fpsBox = new Shape();
			_fpsBox.x = 60;
			_fpsBox.y = 65;
			addChild(_fpsBox);
			
			_memBox = new Shape();
			_memBox.x = 60;
			_memBox.y = 128;
			addChild(_memBox);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function draw():void
		{
			super.draw();

			_display.graphics.clear();
			_display.graphics.beginFill(0x000000, 0.5);
			_display.graphics.lineStyle(1, 0x5e5f5f, 1);

			_display.graphics.moveTo(60, 55);
			_display.graphics.lineTo(60, 10);
			_display.graphics.moveTo(60, 55);
			_display.graphics.lineTo(_width - 7, 55);

			_display.graphics.moveTo(60, 118);
			_display.graphics.lineTo(60, 73);
			_display.graphics.moveTo(60, 118);
			_display.graphics.lineTo(_width - 7, 118);
			_display.graphics.endFill();
		}
		
		/**
		 * Обновление значений в окне производительности.
		 */
		protected function updateDisplay():void
		{
			updateMinMax();
			redrawDisplay();
		}
		
		/**
		 * Сбор статистики о производительности.
		 */
		protected function updateMinMax():void
		{
			minFps = Math.min(currentFps, minFps);
			maxFps = Math.max(currentFps, maxFps);
				
			minMem = Math.min(currentMem, minMem);
			maxMem = Math.max(currentMem, maxMem);
		}
		
		/**
		 * Перерисовка графиков и значений в окне производительности.
		 */
		protected function redrawDisplay():void
		{
			if (runningTime >= 1)
			{
				_tfMinFps.text = minFps.toFixed(1) + " fps";
				_tfMaxFps.text = maxFps.toFixed(1) + " fps";
				_tfMinMem.text = minMem.toFixed(1) + " mb";
				_tfMaxMem.text = maxMem.toFixed(1) + " mb";
			}
			
			_tfInfo.text = "";
			appendText(_tfInfo, "Current ", _fGray);
			appendText(_tfInfo, currentFps.toFixed(1), _fWhite);
			appendText(_tfInfo, " fps : Average ", _fGray);
			appendText(_tfInfo, averageFps.toFixed(1), _fWhite);
			appendText(_tfInfo, " fps : Memory Used ", _fGray);
			appendText(_tfInfo, currentMem.toFixed(1), _fWhite);
			appendText(_tfInfo, " mb", _fGray);
			
			var tot:uint = ratingTotal.average();
			var upd:uint = ratingUpdate.average();
			var rnd:uint = ratingRender.average();
			var box:uint = ratingPlugins.average();
			var ant:uint = upd + rnd + box;
			
			_tfRating.text = "";
			appendText(_tfRating, "Upd ", _fGray);
			appendText(_tfRating, upd.toString(), _fWhite);
			appendText(_tfRating, " ms : Rnd ", _fGray);
			appendText(_tfRating, rnd.toString(), _fWhite);
			appendText(_tfRating, " ms : Plg ", _fGray);
			appendText(_tfRating, box.toString(), _fWhite);
			appendText(_tfRating, " ms : Flash ", _fGray);
			appendText(_tfRating, (tot - ant).toString(), _fWhite);
			appendText(_tfRating, " ms : Total ", _fGray);
			appendText(_tfRating, tot.toString(), _fWhite);
			appendText(_tfRating, " ms", _fGray);

			var vec:Graphics = _fpsBox.graphics;
			vec.clear();
			vec.lineStyle(1, 0x96ff00, 1);

			var i:int = 0;
			var len:int = fpsList.length;
			var height:int = 45;
			var width:int = _width - 67;
			var inc:Number = width / (history - 1);
			var rateRange:Number = maxFps - minFps;
			var value:Number;

			for (i = 0; i < len; i++)
			{
				value = (fpsList[i] - minFps) / rateRange;
				(i == 0) ? vec.moveTo(0, -value * height) : vec.lineTo(i * inc, -value * height);
			}

			vec = _memBox.graphics;
			vec.clear();
			vec.lineStyle(1, 0x009cff, 1);

			i = 0;
			len = memList.length;
			rateRange = maxMem - minMem;
			for (i = 0; i < len; i++)
			{
				value = (memList[i] - minMem) / rateRange;
				(i == 0) ? vec.moveTo(0, -value * height) :	vec.lineTo(i * inc, -value * height);
			}
		}
		
		/**
		 * Применение форматированного текста к указанному текстовому полю.
		 * 
		 * @param	textField	 Поле в которое будет добавлен текст.
		 * @param	text	 Добавляемый текст.
		 * @param	textFormat	 Текстовое форматирование для добавляемого текста.
		 */
		private function appendText(aTextField:TextField, aText:String, aTextFormat:TextFormat):void
		{
			var startIndex:int = aTextField.text.length;
			aTextField.appendText(aText);
			var endIndex:int = aTextField.text.length;
			aTextField.setTextFormat(aTextFormat, startIndex, endIndex);
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет текущее количество кадров в секунду.
		 */
		public function get currentFps():Number
		{
			return _frameCount / intervalTime;
		}
		
		/**
		 * Определяет среднее количество кадров в секунду.
		 */
		public function get averageFps():Number
		{
			return _totalCount / runningTime;
		}
		
		/**
		 * Определяет текущий объем занятой оперативной памяти.
		 */
		public function get currentMem():Number
		{
			return (System.totalMemory / 1024) / 1000;
		}

		/**
		 * Определяет время с момента запуска приложения.
		 */
		public function get runningTime():Number
		{
			return (_currentTime - _initTime) / 1000;
		}
		
		/**
		 * Определяет время с момента запуска отслеживания производительности.
		 */
		public function get intervalTime():Number
		{
			return (_currentTime - _itvTime) / 1000;
		}
		
	}

}