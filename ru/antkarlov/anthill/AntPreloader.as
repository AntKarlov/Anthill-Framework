package ru.antkarlov.anthill
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Простой прелоадер. От этого класса следует наследовать свой прелоадер.
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
			// Стандартная полоса загрузки.
			graphics.clear();
			
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			graphics.lineStyle(1, 0x000000);
			graphics.moveTo(sw * 0.5 - 50, sh * 0.5 + 5);
			graphics.lineTo(sw * 0.5 + 50, sh * 0.5 + 5);
			
			graphics.beginFill(0x000000, 1);
			graphics.drawRect(sw * 0.5 - 50, sh, 100 * aPercent, 5);
			graphics.endFill();
			
			/*graphics.beginFill(0xC2758B, 1);
			graphics.drawRect(0, stage.stageHeight / 2 - 10, stage.stageWidth * aPercent, 20);
			graphics.endFill();*/
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
		 * Возвращает домен на котором размещена флешка.
		 * <p>Внимание: Если флешка размещена на домене второго или третьего уровня то вернется имя домена первого уровня,
		 * то есть если ваша игра размещена на "http://cache.armorgames.com/", то результат будет "armorgames.com".</p>
		 * 
		 * @return		Вернет local если флешка запущена на локальном компьютере или адрес домена первого уровня "domain.com".
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
			return (home == "") ? "local" : home;
		}
		
		/**
		 * Реализация элементарного сайтлока. 
		 * Пример использования:
		 * <code>
		 * if (atHome([ "local", "mygreatsite.com" ])) {
		 *   // Можно играть.
		 * } else { 
		 *   // Нельзя играть
		 * }
		 * </code>
		 * 
		 * @param	aHomes	 Список доменов на которых флешке разрешено находится.
		 * @return		Возвращает true если флешка находится на одном из разрешенных доменов.
		 */
		protected function atHome(aHomes:Array):Boolean
		{
			return (aHomes.indexOf(getHome()) > -1) ? true : false;
		}
		
	}

}