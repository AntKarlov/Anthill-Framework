package ru.antkarlov.anthill
{
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	/**
	 * Данный класс используется для растеризации векторных клипов и для последующего их хранения в памяти.
	 * 
	 * <p>Воспроизведением и отрисовкой анимаций занимается класс <code>AntActor</code>. Так же в данном классе
	 * реализован кэш анимаций который позволяет хранить уникальные экземпляры анимаций для многократного одновременного
	 * использования.</p>
	 * 
	 * <p>Класс реализован на основе класса от Scmorr (http://flashgameblogs.ru/blog/actionscript/667.html).</p>
	 * 
	 * @see	AntActor Класс для воспроизведения и рендера анимаций.
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
		 * Массив кадров.
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
		 * Уничтожает анимацию.
		 */
		public function destroy():void
		{
			var bmpd:BitmapData;
			var i:int = 0;
			var n:int = frames.length;
			while (i < n)
			{
				bmpd = frames[i] as BitmapData;
				if (bmpd != null)
				{
					bmpd.dispose();
				}
				
				frames[i] = null;
				i++;
			}
			
			frames.length = 0;
			offsetY.length = 0;
			offsetY.length = 0;
		}
		
		/**
		 * Создает растровую анимацию из указанного клипа.
		 * 
		 * @param	aClip	 Клип из которого необходимо создать растровую анимацию.
		 */
		public function makeFromMovieClip(aClip:MovieClip):void
		{
			totalFrames = aClip.totalFrames;
			
			var rect:Rectangle;
			var flooredX:int;
			var flooredY:int;
			var mtx:Matrix = new Matrix();
			var scratchBitmapData:BitmapData = null;
			
			var i:int = 1;
			while (i <= totalFrames)
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
				i++;
			}
		}
		
		/**
		 * Создает анимацию из изображения.
		 * 
		 * @param	aGraphic	 Класс растрового изображения.
		 * @param	aFrameWidth	 Размер кадра по ширине.
		 * @param	aFrameHeight	 Размер кадра по высоте.
		 * @param	aOriginX	 Смещение кадров относительно центра координат по X.
		 * @param	aOriginY	 Смещение кадров относительно центра координат по Y.
		 * @param	aFlip	 Определяет необходимость зеркального отражения кадров по горизонтали.
		 */
		public function makeFromGraphic(aGraphic:Class, aFrameWidth:int = 0, aFrameHeight:int = 0,
		 	aOriginX:int = 0, aOriginY:int = 0, aFlip:Boolean = false):void
		{
			var pixels:BitmapData = (new aGraphic).bitmapData;
			if (aFlip)
			{
				var newPixels:BitmapData = new BitmapData(pixels.width, pixels.height, true, 0x00000000);
				var mtx:Matrix = new Matrix();
				mtx.scale(-1, 1);
				mtx.translate(newPixels.width, 0);
				newPixels.draw(pixels, mtx);
				pixels = newPixels;
			}
			
			if (aFrameWidth > 0 || aFrameHeight > 0)
			{
				aFrameWidth = (aFrameWidth <= 0) ? pixels.width : aFrameWidth;
				aFrameHeight = (aFrameHeight <= 0) ? pixels.height : aFrameHeight;
				
				var numFramesX:int = AntMath.floor(pixels.width / aFrameWidth);
				var numFramesY:int = AntMath.floor(pixels.height / aFrameHeight);
				var rect:Rectangle = new Rectangle();
				rect.x = rect.y = 0;
				rect.width = aFrameWidth;
				rect.height = aFrameHeight;
				
				var n:int = frames.length = numFramesX * numFramesY;
				var i:int = 0;
				while (i < n)
				{
					rect.y = AntMath.floor(i / numFramesX);
					rect.x = i - rect.y * numFramesX;
					rect.x *= aFrameWidth;
					rect.y *= aFrameHeight;
					
					var bmpData:BitmapData = new BitmapData(aFrameWidth, aFrameHeight, true, 0x00000000);
					bmpData.copyPixels(pixels, rect, DEST_POINT);
					
					(aFlip) ? frames[n-i-1] = bmpData : frames[i] = bmpData;
					/*frames[frames.length] = bmpData;*/
					offsetX[offsetX.length] = aOriginX;
					offsetY[offsetY.length] = aOriginY;
					
					i++;
				}
				
				width = aFrameWidth;
				height = aFrameHeight;
			}
			else
			{
				frames[frames.length] = pixels;
				offsetX[offsetX.length] = aOriginX;
				offsetY[offsetY.length] = aOriginY;
				width = pixels.width;
				height = pixels.height;
			}
			
			totalFrames = frames.length;
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
			var i:int = 0;
			var n:int = aFrames.length;
			var frame:int;
			while (i < n)
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
				i++;
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
			var i:int = 0;
			var n:int = aClip.numChildren;
			while (i < n)
			{
				childClip = aClip.getChildAt(i) as MovieClip;
				if (childClip != null)
				{
					childNextFrame(childClip);
					childClip.nextFrame();
				}
				i++;
			}
		}
		
		//---------------------------------------
		// ANIMATION CACHE
		//---------------------------------------
		
		/**
		 * Кэш анимаций.
		 */
		protected static var _animationCache:AntStorage = new AntStorage();
		
		/**
		 * Помещает анимацию в кэш.
		 * 
		 * @param	aAnim	 Анимация которую необходимо поместить в кэш.
		 * @param	aKey	 Имя под которой анимация будет доступна в кэше. Если имя не указана, то будет использовано имя из анимации.
		 */
		public static function toCache(aAnim:AntAnimation, aKey:String = null):AntAnimation
		{
			_animationCache.set((aKey == null) ? aAnim.name : aKey, aAnim);
			return aAnim;
		}
		
		/**
		 * Извлекает анимацию из кэша.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо извлечь из кэша.
		 */
		public static function fromCache(aKey:String):AntAnimation
		{
			if (!_animationCache.containsKey(aKey))
			{
				throw new Error("AntAnimation: Missing animation \'" + aKey + "\'.");
			}

			return _animationCache.get(aKey) as AntAnimation;
		}
		
		/**
		 * Удаляет анимацию из кэша анимаций.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо удалить.
		 */
		public static function removeFromCache(aKey:String):void
		{
			if (_animationCache.containsKey(aKey))
			{
				(_animationCache.get(aKey) as AntAnimation).destroy();
				_animationCache.remove(aKey);
			}
		}

	}

}