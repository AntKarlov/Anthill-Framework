package ru.antkarlov.anthill
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.sampler.*;
	import ru.antkarlov.anthill.utils.AntFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Данный класс используется для растеризации векторных клипов и для последующего их хранения в памяти.
	 * 
	 * <p>Воспроизведением и отрисовкой анимаций занимается класс <code>AntActor</code>. Так же в данном классе
	 * реализован кэш анимаций который позволяет хранить уникальные экземпляры анимаций для многократного одновременного
	 * использования.</p>
	 * 
	 * <p>Класс реализован на основе класса от Scmorr (http://gamedevblogs.ru/blog/actionscript/667.html).</p>
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
		public var frames:Vector.<BitmapData>;
		
		/**
		 * Массив смещений по X для каждого из кадров анимации.
		 */
		public var offsetX:Vector.<Number>;
		
		/**
		 * Массив смещений по Y для каждого из кадров анимации.
		 */
		public var offsetY:Vector.<Number>;
		
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
			frames = new <BitmapData>[];
			offsetX = new <Number>[];
			offsetY = new <Number>[];
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
		 * Создает растровую однокадровую анимацию из указанного спрайта.
		 * 
		 * @param	aSprite	 Спрайт из которого необходимо создать растровую анимацию.
		 */
		public function makeFromSprite(aSprite:Sprite):void
		{
			totalFrames = 1;
			
			var rect:Rectangle;
			var flooredX:int;
			var flooredY:int;
			var mtx:Matrix = new Matrix();
			var scratchBitmapData:BitmapData = null;
			
			rect = aSprite.getBounds(aSprite);
			rect.width = Math.ceil(rect.width) + INDENT_FOR_FILTER_DOUBLED;
			rect.height = Math.ceil(rect.height) + INDENT_FOR_FILTER_DOUBLED;
			
			flooredX = Math.floor(rect.x) - INDENT_FOR_FILTER;
			flooredY = Math.floor(rect.y) - INDENT_FOR_FILTER;
			mtx.tx = -flooredX;
			mtx.ty = -flooredY;
			
			scratchBitmapData = new BitmapData(rect.width, rect.height, true, 0);
			scratchBitmapData.draw(aSprite, mtx);
			
			var trimBounds:Rectangle = scratchBitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			trimBounds.x -= 1;
			trimBounds.y -= 1;
			trimBounds.width += 2;
			trimBounds.height += 2;
			
			var bmpData:BitmapData = new BitmapData(trimBounds.width, trimBounds.height, true, 0);
			bmpData.copyPixels(scratchBitmapData, trimBounds, DEST_POINT);
			
			flooredX += trimBounds.x;
			flooredY += trimBounds.y;
			
			frames[0] = bmpData;
			offsetX[0] = flooredX;
			offsetY[0] = flooredY;
			
			width = (width < trimBounds.width) ? trimBounds.width : width;
			height = (height < trimBounds.height) ? trimBounds.height : height;
			
			scratchBitmapData.dispose();
		}
		
		/**
		 * Создает растровую анимацию из указанного клипа.
		 * 
		 * @param	aClip	 Клип из которого необходимо создать растровую анимацию.
		 * @param	aIndent	 Отступ необходимый для избежания возможного обрезания сглаживаемых объектов.
		 */
		public function makeFromMovieClip(aClip:MovieClip, aIndent:int = 2):void
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
				rect = aClip.getBounds(aClip);
				rect.width = Math.ceil(rect.width) + INDENT_FOR_FILTER_DOUBLED;
				rect.height = Math.ceil(rect.height) + INDENT_FOR_FILTER_DOUBLED;
				
				flooredX = Math.floor(rect.x) - INDENT_FOR_FILTER;
				flooredY = Math.floor(rect.y) - INDENT_FOR_FILTER;
				mtx.tx = -flooredX;
				mtx.ty = -flooredY;
				
				scratchBitmapData = new BitmapData(rect.width, rect.height, true, 0);
				scratchBitmapData.draw(aClip, mtx);
				
				var trimBounds:Rectangle = scratchBitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
				if (aIndent != 0)
				{
					trimBounds.x -= aIndent;
					trimBounds.y -= aIndent;
					trimBounds.width += aIndent * 2;
					trimBounds.height += aIndent * 2;
				}
				
				if (trimBounds.width == 0 || trimBounds.height == 0)
				{
					trimBounds.width = 2;
					trimBounds.height = 2;
				}
				
				var bmpData:BitmapData = new BitmapData(trimBounds.width, trimBounds.height, true, 0);
				bmpData.copyPixels(scratchBitmapData, trimBounds, DEST_POINT);
				
				flooredX += trimBounds.x;
				flooredY += trimBounds.y;
				
				frames.push(bmpData);
				offsetX.push(flooredX);
				offsetY.push(flooredY);
				
				width = (width < trimBounds.width) ? trimBounds.width : width;
				height = (height < trimBounds.height) ? trimBounds.height : height;
				
				scratchBitmapData.dispose();
				aClip.gotoAndStop(++i);
				childNextFrame(aClip);
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
		 * @param	aSpaceOut	 Рамка вокруг изображения.
		 * @param	aSpaceIn	 Отступ между кадрами.
		 */
		public function makeFromGraphic(aGraphic:Class, aFrameWidth:int = 0, aFrameHeight:int = 0,
		 	aOriginX:int = 0, aOriginY:int = 0, aFlip:Boolean = false, aSpaceOut:int = 0, aSpaceIn:int = 0):void
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
				
				var numFramesX:int = Math.floor((pixels.width - aSpaceOut) / (aFrameWidth + aSpaceIn));
				var numFramesY:int = Math.floor((pixels.height - aSpaceOut) / (aFrameHeight + aSpaceIn));
				var rect:Rectangle = new Rectangle();
				rect.x = rect.y = 0;
				rect.width = aFrameWidth;
				rect.height = aFrameHeight;
				
				var n:int = numFramesX * numFramesY;
				var i:int = 0;
				while (i < n)
				{
					rect.y = Math.floor(i / numFramesX);
					rect.x = i - rect.y * numFramesX;
					//rect.x *= aFrameWidth;
					//rect.y *= aFrameHeight;
					rect.x = aSpaceOut + aFrameWidth * rect.x + aSpaceIn * rect.x;
					rect.y = aSpaceOut + aFrameHeight * rect.y + aSpaceIn * rect.y;
					
					var bmpData:BitmapData = new BitmapData(aFrameWidth, aFrameHeight, true, 0x00000000);
					bmpData.copyPixels(pixels, rect, DEST_POINT);
					
					//(aFlip) ? frames[n-i-1] = bmpData : frames[i] = bmpData;
					frames.push(bmpData);
					offsetX.push(aOriginX);
					offsetY.push(aOriginY);
					
					i++;
				}
				
				width = aFrameWidth;
				height = aFrameHeight;
			}
			else
			{
				frames.push(pixels);
				offsetX.push(aOriginX);
				offsetY.push(aOriginY);
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
			while (i < n)
			{
				if (aCopy)
				{
					origBmp = frames[ aFrames[i] ] as BitmapData;
					rect.x = rect.y = 0;
					rect.width = origBmp.width;
					rect.height = origBmp.height;
					newBmp = new BitmapData(rect.width, rect.height, true, 0);
					newBmp.copyPixels(origBmp, rect, DEST_POINT);
					newAnim.frames.push(newBmp);
				}
				else
				{
					newAnim.frames.push(frames[ aFrames[i] ]);
				}
				
				newAnim.offsetX.push(offsetX[ aFrames[i] ]);
				newAnim.offsetY.push(offsetY[ aFrames[i] ]);
				i++;
			}
			
			return newAnim;
		}
		
		/**
		 * @private
		 */
		public function get memSize():int
		{
			var totalSize:int = 0;
			const n:int = frames.length;
			for (var i:int = 0; i < n; i++)
			{
				totalSize += getSize(frames[i]);
			}
			
			return totalSize;
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
		protected static var _animations:AntStorage = new AntStorage();
		
		/**
		 * Списки хранят имя и количество использований для каждой из анимаций.
		 */
		protected static var _usedNames:Vector.<String> = new Vector.<String>();
		protected static var _usedCount:Vector.<int> = new Vector.<int>();
		
		/**
		 * Список временно удаленных анимаций доступных для восстановления при необходимости.
		 */
		protected static var _removedNames:Vector.<String> = new Vector.<String>();
		
		/**
		 * Список статических анимаций которые никогда не освобождаются.
		 */
		protected static var _staticNames:Vector.<String> = new Vector.<String>();
		
		/**
		 * Отмечает указанную анимацию как используемую кем-либо
		 * (увеличивает счетчик использований).
		 * 
		 * @param aKey Ключевое имя анимации.
		 */
		public static function useAnimation(aKey:String):void
		{
			var i:int = _usedNames.indexOf(aKey);
			if (i >= 0 && i < _usedNames.length)
			{
				_usedCount[i]++;
			}
			else
			{
				_usedNames[_usedNames.length] = aKey;
				_usedCount[_usedCount.length] = 1;
			}
		}
		
		/**
		 * Отмечает указанную анимацию как неиспользуемую кем-либо
		 * (уменьшает счетчик использований).
		 * 
		 * @param aKey Ключевое имя анимации.
		 */
		public static function unuseAnimation(aKey:String):void
		{
			var i:int = _usedNames.indexOf(aKey);
			if (i >= 0 && i < _usedNames.length)
			{
				var n:int = _usedCount[i] - 1;
				n = (n >= 0) ? n : 0;
				_usedCount[i] = n;
			}
		}
		
		/**
		 * Определяет является ли указанная анимация используемой кем-либо.
		 * 
		 * @param aKey Ключевое имя анимации.
		 */
		public static function isUsed(aKey:String):Boolean
		{
			var i:int = _usedNames.indexOf(aKey);
			return (i >= 0 && i < _usedNames.length && _usedCount[i] > 0);
		}
		
		/**
		 * Восстанавливает ранее удаленную анимацию.
		 * 
		 * @param aKey Ключевое имя анимации.
		 */
		public static function restoreAnimation(aKey:String):AntAnimation
		{
			var i:int = _removedNames.indexOf(aKey);
			if (i >= 0 && i < _removedNames.length)
			{
				var anim:AntAnimation;
				var clipClass:Class = getDefinitionByName(aKey) as Class;
				if (clipClass != null)
				{
					var clip:MovieClip = new clipClass();
					anim = new AntAnimation(aKey);
					anim.makeFromMovieClip(clip);
					//trace("Restored:", anim.name);
					return anim;
				}
				
				_removedNames.splice(i, 1);
			}
			
			return null;
		}
		
		/**
		 * Определяет является ли указанная анимация статической. Статические анимации
		 * не могут быть удалены из кэша как неиспользуемые.
		 * 
		 * @param aKey Ключевое имя анимации.
		 */
		public static function isStatic(aKey:String):Boolean
		{
			var i:int = _staticNames.indexOf(aKey);
			return (i >= 0 && i < _staticNames.length);
		}
		
		/**
		 * Добавляет анимацию в список не обработанных анимаций (не кэшированных).
		 * Анимация добалвенная таким образом в кэш, будет растерезирована на лету
		 * по мере необходимости.
		 * 
		 * @param aClass Класс анимации.
		 */
		public static function addNonCachedAnimation(aClass:Class):void
		{
			var key:String = getQualifiedClassName(aClass);
			_removedNames[_removedNames.length] = key;
		}
		
		/**
		 * Добавляет список анимаций в список необработанных анимаций (не кэшированных).
		 * Анимации добавленные таким образом в кэш, будут растерезированы на лету по
		 * мере необходимости.
		 * 
		 * @param aList Список классов анимаций.
		 */
		public static function addNonCachedAnimations(aList:Vector.<Class>):void
		{
			var i:int = 0;
			const n:int = aList.length;
			while (i < n)
			{
				addNonCachedAnimation(aList[i++]);
			}
		}
		
		/**
		 * Помещает анимацию в кэш.
		 * 
		 * @param	aAnim	 Анимация которую необходимо поместить в кэш.
		 * @param	aKey	 Имя под которой анимация будет доступна в кэше. Если имя не указана, то будет использовано имя из анимации.
		 */
		public static function addToCache(aAnim:AntAnimation, aKey:String = null, aIsStatic:Boolean = false):AntAnimation
		{
			var key:String = (aKey == null) ? aAnim.name : aKey;
			_animations.set(key, aAnim);
			
			if (aIsStatic)
			{
				_staticNames[_staticNames.length] = key;
			}
			
			return aAnim;
		}
		
		/**
		 * Маркирует указанную анимацию как статичную (неподлежащию удалению).
		 * 
		 * <p>Статичную анимацию можно удалить только методом removeFromCache() с флагом aForce равным true,
		 * либо предварительно снять флаг isStatic при помощи данного метода.</p>
		 * 
		 * @param	aKey	Имя анимации которую необходимо сделать статичной.
		 * @param	aIsStatic	Значение устанавливаемого флага.
		 */
		public static function markAnimationAsStatic(aKey:String, aIsStatic:Boolean):void
		{
			if (!aIsStatic)
			{
				var i:int = _staticNames.indexOf(aKey);
				if (i >= 0 && i < _staticNames.length)
				{
					_staticNames.splice(i, 1);
				}
			}
			else
			{
				_staticNames[_staticNames.length] = aKey;
			}
		}
		
		/**
		 * Извлекает анимацию из кэша.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо извлечь из кэша.
		 */
		public static function getFromCache(aKey:String):AntAnimation
		{
			if (!_animations.containsKey(aKey))
			{
				var anim:AntAnimation = restoreAnimation(aKey);
				if (anim == null)
				{
					throw new Error("AntAnimation: Missing animation \'" + aKey + "\'.");
					return null;
				}
				else
				{
					return addToCache(anim, aKey);
				}
			}
			
			return _animations.get(aKey) as AntAnimation;
		}
		
		/**
		 * Удаляет анимацию из кэша анимаций.
		 * 
		 * @param	aKey	 Имя анимации которую необходимо удалить.
		 * @param	aForce	Задает принудительное удаление не смотря на возможное использование удаляемой анимации.
		 * @return Возвращает true если анимация была успешно удалена из кэша.
		 */
		public static function removeFromCache(aKey:String, aForce:Boolean = false):Boolean
		{
			if (_animations.containsKey(aKey))
			{
				if (aForce || (!isUsed(aKey) && !isStatic(aKey)))
				{
					(_animations.remove(aKey) as AntAnimation).destroy();
					_removedNames[_removedNames.length] = aKey;
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Удаляет все анимации из кэша анимаций.
		 * 
		 * @param	aForce	Задает принудительную очистку кэша не смотря на возможное использование анимаций.
		 * @return Возвращает количество удаленных анимаций.
		 */
		public static function clearCache(aForce:Boolean = false):int
		{
			var count:int = 0;
			for (var animName:String in _animations)
			{
				if (removeFromCache(animName))
				{
					count++;
				}
			}
			
			return count;
		}
		
		/**
		 * Считает общий объем памяти занимаемый кэшем анимации в байтах.
		 * 
		 * <p>Чтобы преобразовать результат в Мб используйте метод:
		 * trace(AntFormat.formatSize(cs) + " Мб");</p>
		 * 
		 * @return Общий размер занимаемый анимациями в памяти.
		 */
		public static function getCacheSize():int
		{
			var totalSize:int = 0;
			var anim:AntAnimation;
			for (var p:String in _animations)
			{
				if (_animations[p] != null)
				{
					anim = _animations.get(p) as AntAnimation;
					if (anim != null)
					{
						totalSize += anim.memSize;
					}
				}
			}
			
			return totalSize;
		}
		
		/**
		 * Отладочный метод для получения информации о состоянии кэша анимаций.
		 */
		public static function getCacheStats():Array
		{
			var name:String;
			var res:Array = [];
			const n:int = _usedNames.length;
			for (var i:int = 0; i < n; i++)
			{
				name = _usedNames[i];
				if (_removedNames.indexOf(name) > -1)
				{
					res[res.length] = AntFormat.formatString("{0} - numOfUses: {1}", name, _usedCount[i]);
				}
				else
				{
					res[res.length] = AntFormat.formatString("{0} - Removed!", name);
				}
			}
			
			return res;
		}

	}

}