package ru.antkarlov.anthill
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Базовый прелодаер для вашего приложения. 
	 * 
	 * <p>Чтобы реализовать свой анимированный прелоадер, унаследуйте от этого класса
	 * свой прелоадер и перекройте метод <code>update()</code>, в этом методы вы можете
	 * реализовать свою анимированную полосу загрузки. В качестве аргумента в метод 
	 * <code>update()</code> передается текущий процент хода загрузки в промежутке от 0 до 1.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  23.08.2012
	 */
	public class AntPreloader extends MovieClip
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Имя класса который будет создан после завершения загрузки флешки.
		 */
		public var entryClass:String;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntPreloader()
		{
			super();
			
			stop();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Выполняется каждый кадр.
		 * 
		 * @param	aPercent	 Текущий процент загруженного контента от 0 до 1.
		 */
		public function update(aPercent:Number):void
		{
			/*
				Реализация стандартной полосы загрузки.
				Чтобы создать свой визуальный стиль загрузчика,
				перекройте этот метод.
			*/ 
			graphics.clear();
			
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			graphics.lineStyle(1, 0x000000);
			graphics.moveTo(sw * 0.5 - 50, sh * 0.5 + 5);
			graphics.lineTo(sw * 0.5 + 50, sh * 0.5 + 5);
			
			graphics.beginFill(0x000000, 1);
			graphics.drawRect(sw * 0.5 - 50, sh * 0.5, 100 * aPercent, 5);
			graphics.endFill();
		}
		
		/**
		 * Выполняется когда загрузка флешки завершена.
		 */
		public function completed():void
		{
			graphics.clear();
			stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			nextFrame();
			initialize();
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обработчик события ENTER_FRAME для слежения за процессом загрузки.
		 */
		protected function enterFrameHandler(event:Event):void
		{
			update(root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal);
			if (framesLoaded == totalFrames)
			{
				completed();
			}
		}
		
		/**
		 * Инициализация основного класса приложения.
		 */
		protected function initialize():void
		{
			var mainClass:Class = Class(getDefinitionByName(entryClass));
			if (mainClass)
			{
				var app:Object = new mainClass();
				addChild(app as DisplayObject);
			}
		}
		
		/**
		 * Возвращает домен первого и второго уровня на котором размещена программа.
		 * 
		 * <p>Внимание: Если игра размещена на домене третьего уровня то результатом работы будет имя домена первого уровня и второго уровня,
		 * то есть если ваша игра размещена на "http://subdomain.domain.com/", то результат будет равен "domain.com".</p>
		 * 
		 * @return		Вернет local если флешка запущена на локальном компьютере или домен первого и второго уровня "domain.com".
		 */
		protected function getHome():String
		{
			var url:String = loaderInfo.loaderURL;
			var urlStart:Number = url.indexOf("://") + 3;
			var urlEnd:Number = url.indexOf("/", urlStart);
			var home:String = url.substring(urlStart, urlEnd);
			var LastDot:Number = home.lastIndexOf(".") - 1;
			var domEnd:Number = home.lastIndexOf(".", LastDot) + 1;
			home = home.substring(domEnd, home.length);
			home = home.split(":")[0];			
			return (home == "") ? "local" : home;
		}
		
		/**
		 * Реализация элементарного сайтлока.
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <listing>
		 * if (atHome([ "local", "mygreatsite.com" ])) {
		 *   ..start game here
		 * } else { 
		 *   ..show warning message
		 * }
		 * </listing>
		 * 
		 * @param	aHomes	 Список доменов на запуск программы разрешен.
		 * @return		Возвращает true если программа находится на одном из разрешенных доменов.
		 */
		protected function atHome(aHomes:Array):Boolean
		{
			return (aHomes.indexOf(getHome()) > -1);
		}
		
	}

}