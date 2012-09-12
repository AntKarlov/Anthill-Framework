package ru.antkarlov.anthill
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	
	/**
	 * Ядро игрового движка.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  29.08.2012
	 */
	public class Anthill extends Sprite
	{
		//Flex v4.x SDK
		// Обычное подключение шрифта.
		//[Embed(source="resources/iFlash706.ttf",fontFamily="system",embedAsCFF="false")] protected var junk:String;
		
		//Flex v3.x SDK
		// Подключение шрифта с кирилицой.
		//[Embed(source="resources/iFlash706.ttf",fontFamily="system")] protected var junk:String;
		[Embed(source= "resources/iFlash706.ttf",fontFamily="system",mimeType="application/x-font",
			unicodeRange="U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+0400-U+04CE,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183")] protected var junk:String;
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Текущее игровое состояние.
		 */
		public var state:AntState;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Класс игрового состояния которое будет создано при инициализации движка.
		 */
		protected var _initialState:Class;
		
		/**
		 * Определяет ограничение количества кадров в секунду.
		 * @default    35
		 */
		protected var _framerate:uint;
		
		/**
		 * Флаг определяющий проинициализирован ли игровой движок.
		 * @default    false
		 */
		protected var _isCreated:Boolean;
		
		/**
		 * Флаг определяющий запущен ли игровой движок.
		 * @default    false
		 */
		protected var _isStarted:Boolean;
		
		/**
		 * Помошник для рассчета игрового времени.
		 */
		internal var _elapsed:Number;
		
		/**
		 * Помошник для рассчета игрового времени.
		 */
		internal var _total:uint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function Anthill(aInitialState:Class = null)
		{
			super();
			
			_initialState = aInitialState;
			_framerate = 35;
			_isCreated = false;
			_isStarted = false;
			
			if (stage != null)
			{
				create();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, create);
			}
		}
		
		/**
		 * Инициализация игрового движка.
		 */
		public function create(event:Event = null):void
		{
			AntG.init(this);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = _framerate;
						
			removeEventListener(Event.ADDED_TO_STAGE, create);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, AntG.debugger.console.keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, AntG.keys.keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, AntG.keys.keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, AntG.mouse.mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, AntG.mouse.mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_OUT, AntG.mouse.mouseOutHandler);
			stage.addEventListener(MouseEvent.MOUSE_OVER, AntG.mouse.mouseOverHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, AntG.mouse.mouseWheelHandler);
			
			AntG.debugger.perfomance.start();
			
			_isCreated = true;
			switchState(new _initialState());
			start();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Запускает процессинг игрового движка.
		 */
		public function start():void
		{
			if (!_isStarted && _isCreated)
			{
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				_isStarted = true;
			}
		}
		
		/**
		 * Останавливает процессинг игрового движка.
		 */
		public function stop():void
		{
			if (_isStarted && _isCreated)
			{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				_isStarted = false;
			}
		}
		
		/**
		 * Переключает игровые состояния.
		 * 
		 * @param	aState	 Новое состояние на которое необходимо произвести переключение.
		 */
		public function switchState(aState:AntState):void
		{
			addChild(aState);
			if (state != null)
			{
				state.dispose();
				swapChildren(state, aState);
				removeChild(state);
			}
			
			state = aState;
			state.create();
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Основной обработчик.
		 */
		protected function enterFrameHandler(event:Event):void
		{
			// Рассчет времени между кадрами.
			var ct:uint = getTimer();
			var ems:uint = ct - _total;
			AntG.debugger.perfomance.ratingTotal.add(ems);
			_elapsed = ems / 1000;
			_total = ct;
			AntG.elapsed = (_elapsed > AntG.maxElapsed) ? AntG.maxElapsed : _elapsed;
			AntG.elapsed *= AntG.timeScale;
			
			// Процессинг содержимого игры.
			AntG.updateInput();
			AntG.updateSounds();
			//if (_paused)
			//{
				/*
					TODO 
				*/
			//}
			//else
			//{
				AntBasic._numOfActive = 0;
				
				state.preUpdate();
				state.update();
				state.postUpdate();
			//}
			
			// Расчет времени ушедшего на процессинг.
			var updCt:uint = getTimer();
			AntG.debugger.perfomance.ratingUpdate.add(updCt - ct);
			
			// Рендер графического контента.
			AntBasic._numOfVisible = 0;
			AntBasic._numOnScreen = 0;
			
			// Подготовка камер к рендеру.
			var cam:AntCamera;
			var n:int = AntG.cameras.length;
			for (var i:int = 0; i < n; i++)
			{
				cam = AntG.cameras[i] as AntCamera;
				if (cam != null)
				{
					cam.draw();
				}
			}
			
			// Рендер состояния.
			state.draw();
			
			// Рассчет времени ушедшего на рендер.
			var rndCt:uint = getTimer();
			AntG.debugger.perfomance.ratingRender.add(rndCt - updCt);
			
			// Процессинг физики.
			/*if (AntG.physics != null)
			{
				AntG.physics.update();
			}*/
			
			// Рассчет времени ушедшего на физику.
			AntG.debugger.perfomance.ratingPhysics.add(getTimer() - rndCt);
			AntG.debugger.update();
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет максимально допустимый FPS.
		 */
		public function set framerate(value:uint):void
		{
			_framerate = value;
			if (stage != null)
			{
				stage.frameRate = _framerate;
			}
		}
		
		/**
		 * @private
		 */
		public function get framerate():uint
		{
			return _framerate;
		}
		
	}

}