package ru.antkarlov.anthill
{
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * Используется для растеризации и хранения растровых последовательностей.
	 * <p>Класс реализован на основе класса от Scmorr (http://flashgameblogs.ru/blog/actionscript/667.html).</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  20.08.2012
	 */
	public class AntAnimation extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		protected static const INDENT_FOR_FILTER:int = 64;
		protected static const INDENT_FOR_FILTER_DOUBLED:int = INDENT_FOR_FILTER * 2;
		protected static const DEST_POINT:Point = new Point();
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Глобальное имя анимации.
		 */
		public var name:String;
		
		/**
		 * Массив битмапов анимации.
		 */
		public var frames:Array;
		
		/**
		 * Массив смещений по X для каждого из кадров анимации.
		 */
		public var offsetX:Array;
		
		/**
		 * Массив смещений по Y для каждого из кадров анимации.
		 */
		public var offsetY:Array;
		
		/**
		 * Общее количество кадров анимации.
		 */
		public var totalFrames:int;
		
		/**
		 * Максимальная ширина кадров анимации.
		 */
		public var width:int;
		
		/**
		 * Максимальная высота кадров анимации.
		 */
		public var height:int;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntAnimation(aName:String = "noname")
		{
			super();
			
			name = aName;
			frames = [];
			offsetX = [];
			offsetY = [];
			totalFrames = 0;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Создает анимацию из указанного клипа.
		 * 
		 * @param	aClip	 Клип из которого необходимо создать растровую анимацию.
		 */
		public function makeAnimation(aClip:MovieClip):void
		{
			totalFrames = aClip.totalFrames;
			
			var rect:Rectangle;
			var flooredX:int;
			var flooredY:int;
			var mtx:Matrix = new Matrix();
			var scratchBitmapData:BitmapData = null;
			
			for (var i:int = 1; i <= totalFrames; i++)
			{
				aClip.gotoAndStop(i);
				childNextFrame(aClip);
				rect = aClip.getBounds(aClip);
                rect.width = Math.ceil(rect.width) + INDENT_FOR_FILTER_DOUBLED;
                rect.height = Math.ceil(rect.height) + INDENT_FOR_FILTER_DOUBLED;
                
                flooredX = AntMath.floor(rect.x) - INDENT_FOR_FILTER;
                flooredY = AntMath.floor(rect.y) - INDENT_FOR_FILTER;
                mtx.tx = -flooredX;
                mtx.ty = -flooredY;

                scratchBitmapData = new BitmapData(rect.width, rect.height, true, 0);
                scratchBitmapData.draw(aClip, mtx);
                
                var trimBounds:Rectangle = scratchBitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
                trimBounds.x -= 1;
                trimBounds.y -= 1;
                trimBounds.width += 2;
                trimBounds.height += 2;
                
                var bmpData:BitmapData = new BitmapData(trimBounds.width, trimBounds.height, true, 0);
                bmpData.copyPixels(scratchBitmapData, trimBounds, DEST_POINT);
                
                flooredX += trimBounds.x;
                flooredY += trimBounds.y;

                frames[frames.length] = bmpData;
                offsetX[offsetX.length] = flooredX;
                offsetY[offsetY.length] = flooredY;
				
				width = (width < trimBounds.width) ? trimBounds.width : width;
				height = (height < trimBounds.height) ? trimBounds.height : height;

                scratchBitmapData.dispose();
			}
		}
		
		/**
		 * Уничтожает анимацию.
		 */
		public function dispose():void
		{
			var bmpd:BitmapData;
			var n:int = frames.length;
			for (var i:int = 0; i < n; i++)
			{
				bmpd = frames[i] as BitmapData;
				if (bmpd != null)
				{
					bmpd.dispose();
				}
				
				frames[i] = null;
			}
			
			frames.length = 0;
			offsetY.length = 0;
			offsetY.length = 0;
		}
		
		/**
		 * Создает дубликат текущей анимации только с указанными кадрами.
		 * 
		 * @param	aFrames	 Номера кадров которые необходимо включить в новую анимацию.
		 * @param	aName	 Имя новой анимации, если не указано, то будет использовано имя оригинальной анимации.
		 * @param	aCopy	 Если true то будут созданы новые экземпляры кадров, иначе будут использоваться указатели на кадры из оригинальной анимации.
		 * @return		Возвращает новый экземпляр текущей анимации (дубликат).
		 */
		public function dublicateWithFrames(aFrames:Array, aName:String = null, aCopy:Boolean = false):AntAnimation
		{
			var newAnim:AntAnimation = new AntAnimation((aName == null) ? name : aName);
			newAnim.width = width;
			newAnim.height = height;
			newAnim.totalFrames = aFrames.length;
			
			var rect:Rectangle = new Rectangle();
			var origBmp:BitmapData;
			var newBmp:BitmapData;
			var n:int = aFrames.length;
			var frame:int;
			for (var i:int = 0; i < n; i++)
			{
				frame = aFrames[i];
				
				if (aCopy)
				{
					origBmp = frames[frame] as BitmapData;
					rect.x = rect.y = 0;
					rect.width = origBmp.width;
					rect.height = origBmp.height;
					newBmp = new BitmapData(rect.width, rect.height, true, 0);
					newBmp.copyPixels(origBmp, rect, DEST_POINT);
					newAnim.frames[newAnim.frames.length] = newBmp;
				}
				else
				{
					newAnim.frames[newAnim.frames.length] = frames[frame];
				}
				
				newAnim.offsetX = offsetX[frame];
				newAnim.offsetY = offsetY[frame];
			}
			
			return newAnim;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Переводит на один кадр вперед указанный клип.
		 * 
		 * @param	aClip	 Для которого необходимо переключить текущий кадр.
		 */
		protected function childNextFrame(aClip:MovieClip):void
		{
			var childClip:MovieClip;
			var n:int = aClip.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				childClip = aClip.getChildAt(i) as MovieClip;
				if (childClip != null)
				{
					childNextFrame(childClip);
					childClip.nextFrame();
				}
			}
		}

	}

}