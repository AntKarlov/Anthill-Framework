package ru.antkarlov.anthill.debug
{
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.system.System;
	
	import ru.antkarlov.anthill.utils.AntFormat;
	import ru.antkarlov.anthill.utils.AntRating;
	import ru.antkarlov.anthill.AntAnimation;
	import ru.antkarlov.anthill.AntBasic;
	
	/**
	 * Отладочный класс собирающий и демонстрирующий статистику производительности игры.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  14.01.2015
	 */
	public class AntPerfomance extends AntWindow
	{
		public var ratingPlugins:AntRating = new AntRating(30);
		public var ratingUpdate:AntRating = new AntRating(30);
		public var ratingRender:AntRating = new AntRating(30);
		public var ratingTotal:AntRating = new AntRating(30);
		
		private var _isStarted:Boolean;
		private var _isFirstTick:Boolean;
		
		private var _itvTime:int;
		private var _initTime:int;
		private var _currentTime:int;
		private var _frameCount:int;
		private var _totalCount:int;
		
		private var _fpsChart:AntChart;
		private var _msChart:AntChart;
		private var _memChart:AntChart;
		
		private var _currentFPSView:AntCounterView;
		private var _frameTimeView:AntCounterView;
		private var _playTimeView:AntCounterView;
		private var _currentMemView:AntCounterView;
		
		private var _fpsUpper:AntRatingView;
		private var _fpsLower:AntRatingView;
		private var _memUpper:AntRatingView;
		private var _memLower:AntRatingView;
		
		private var _fpsUpperValue:Number;
		private var _fpsLowerValue:Number;
		private var _memUpperValue:Number;
		private var _memLowerValue:Number;
		
		/**
		 * @constructor
		 */
		public function AntPerfomance(aParent:Sprite, aX:Number, aY:Number)
		{
			super(aParent, aX, aY, 424, 128);
			_isStarted = false;
			_isFirstTick = true;
			
			_fpsUpperValue = -9999;
			_fpsLowerValue = 9999;
			_memUpperValue = -9999;
			_memLowerValue = 9999;
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
					updateDisplay(_isFirstTick);
					
					if (_fpsUpperValue < currentFps)
					{
						_fpsUpperValue = currentFps;
					}
					
					if (_fpsLowerValue > currentFps)
					{
						_fpsLowerValue = currentFps;
					}
					
					if (_memUpperValue < currentMem)
					{
						_memUpperValue = currentMem;
					}
					
					if (_memLowerValue > currentMem)
					{
						_memLowerValue = currentMem;
					}
					
					_isFirstTick = false;
					_itvTime = _currentTime;
					_frameCount = 0;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function updateDisplay(aForce:Boolean = false):void
		{
			_fpsChart.beginUpdate();
			_fpsChart.update("current", currentFps);
			_fpsChart.update("average", averageFps);
			_fpsChart.endUpdate(visible || aForce);
			
			var all:int = ratingTotal.average();
			var upd:int = ratingUpdate.average();
			var rnd:int = ratingRender.average();
			var plg:int = ratingPlugins.average();
			var ant:int = upd + rnd + plg;
			
			_msChart.beginUpdate();
			_msChart.update("update", upd);
			_msChart.update("render", rnd);
			_msChart.update("plugins", plg);
			_msChart.update("flash", all - ant);
			_msChart.endUpdate(visible || aForce);
			
			var animCache:Number = AntAnimation.getCacheSize();
			var buffers:Number = AntBasic.BUFFERS_SIZE;
			var other:Number = System.totalMemory - (animCache + buffers);
			
			_memChart.beginUpdate();
			_memChart.update("anim. cache", (animCache / 1024) / 1024);
			_memChart.update("buffers", (buffers / 1024) / 1024);
			_memChart.update("other", (other / 1024) / 1024);
			_memChart.endUpdate(visible || aForce);
			
			if (visible || aForce)
			{
				_currentFPSView.text = currentFps.toFixed(1);
				_frameTimeView.text = ratingTotal.average().toFixed(0);
				_playTimeView.text = AntFormat.formatTime(_currentTime);
				_currentMemView.text = currentMem.toFixed(1);
				
				_fpsUpper.value = _fpsUpperValue;
				_fpsLower.value = _fpsLowerValue;
				_memUpper.value = _memUpperValue;
				_memLower.value = _memLowerValue;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function show():void
		{
			updateDisplay(true);
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
			
			_fpsChart = new AntChart(this, 6, 38);
			_fpsChart.add("current", AntChart.C_GREEN, true, 1);
			_fpsChart.add("average", AntChart.C_BLUE, true, 1);
			
			_msChart = new AntChart(this, 6 + _fpsChart.bufferWidth + 4, 38);
			_msChart.add("update", AntChart.C_BLUE, true);
			_msChart.add("render", AntChart.C_GREEN, true);
			_msChart.add("plugins", AntChart.C_YELLOW, true);
			_msChart.add("flash", AntChart.C_ORANGE, true);
			
			_memChart = new AntChart(this, 6 + _fpsChart.bufferWidth + _msChart.bufferWidth + 8, 38);
			_memChart.add("anim. cache", AntChart.C_BLUE, true, 1);
			_memChart.add("buffers", AntChart.C_GREEN, true, 1);
			_memChart.add("other", AntChart.C_YELLOW, true, 1);
			
			_currentFPSView = new AntCounterView(this, _fpsChart.x, 18, "Frame Rate", "fps");
			_frameTimeView = new AntCounterView(this, _msChart.x, 18, "Frame Time", "ms");
			_playTimeView = new AntCounterView(this, _msChart.x + 80, 18, "Play Time");
			_currentMemView = new AntCounterView(this, _memChart.x, 18, "Memory", "Mb");
			
			_fpsUpper = new AntRatingView(this, _fpsChart.x + 85, 18, "fps");
			_fpsLower = new AntRatingView(this, _fpsChart.x + 85, 27, "fps");
			_fpsLower.value = _fpsLowerValue;
			
			_memUpper = new AntRatingView(this, _memChart.x + 85, 18, "mb");
			_memUpper.reverseColors = true;
			
			_memLower = new AntRatingView(this, _memChart.x + 85, 27, "mb");
			_memLower.reverseColors = true;
			_memLower.value = _memLowerValue;
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
			return (System.totalMemory / 1024) / 1024;
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