package ru.antkarlov.anthill
{
	import XML;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	 * Данный класс позволяет работать с коллекцией маленьких изображений укомплектованных на одной
	 * большой картинке. Данный способ работы ориентирован в большей степени для быстрой работы
	 * с аппаратными рендерами, но поскольку пока Anthill не поддерживает аппаратное ускорение — 
	 * работа с атласами позволит вам оптимизировать работу с растровой графикой и анимацией.
	 * 
	 * <p>Для наибольшей совместимости с уже известными инструментами для создания текстурных
	 * атласов, формат данных поизаимствован у <a href="http://www.sparrow-framework.org">Sparrow Framework</a>. Таким образом для создания
	 * своих текстурных атласов вы можете использовать любые известные иструменты. Например, 
	 * скрипт для создания атласов размещенный на официальном сайте Sparrow или встроенный пакер
	 * в Adobe Flash CS6, а так-же любые другие сторонние утилиты такие как <a href="http://www.texturepacker.com">Texture Packer</a>.</p>
	 * 
	 * <p>Данный класс ожидает такой формат данных:</p>
	 * 
	 * <listing>
	 * &lt;TextureAtlas imagePath='atlas.png'&gt;
	 * &lt;SubTexture name='texture_1' x='0'  y='0' width='50' height='50'/&gt;
	 * &lt;SubTexture name='texture_2' x='50' y='0' width='20' height='30'/&gt;
	 * &lt;/TextureAtlas&gt;
	 * </listing>
	 * 
	 * @author Антон Карлов
	 * @since  29.01.2013
	 */
	public class AntAtlas extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		protected static const DEST_POINT:Point = new Point();
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет масштаб атласа.
		 * @default    1
		 */
		public var scale:Number;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Текстура атласа.
		 */
		protected var _atlasBitmapData:BitmapData;
		
		/**
		 * Координаты и размеры регионов на атласе (положение и размеры спрайтов).
		 */
		protected var _atlasRegions:AntStorage;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntAtlas(aGraphic:Class, aAtlasXML:XML = null)
		{
			super();
			scale = 1;
			
			_atlasBitmapData = (new aGraphic).bitmapData;
			_atlasRegions = new AntStorage();
			
			if (aAtlasXML != null)
			{
				parseAtlasXML(aAtlasXML);
			}
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Загружает информацию об атласе из XML.
		 * 
		 * @param	aAtlasXML	 Указатель на XML данные для загрузки.
		 */
		public function parseAtlasXML(aAtlasXML:XML):void
		{
			for each (var subTexture:XML in aAtlasXML.SubTexture)
			{
				var name:String = subTexture.attribute("name");
				var x:Number = parseFloat(subTexture.attribute("x")) / scale;
				var y:Number = parseFloat(subTexture.attribute("y")) / scale;
				var width:Number = parseFloat(subTexture.attribute("width")) / scale;
				var height:Number = parseFloat(subTexture.attribute("height")) / scale;
				var region:Rectangle = new Rectangle(x, y, width, height);
				addRegion(name, region);
			}
		}
		
		/**
		 * Создает анимацию из спрайтов.
		 * 
		 * @param	aPrefix	 Префикс для имени спрайтов который будет учитыватся в выборке графики для анимации.
		 * @param	aName	 Имя анимации.
		 * @param	aOriginX	 Смещение кадров анимации относительно центра по X.
		 * @param	aOriginY	 Смещение кадров анимации относительно центра по Y.
		 * @return		Возвращает указатель на созданную анимацию.
		 */
		public function makeAnimation(aPrefix:String = "", aName:String = null, aOriginX:int = 0, aOriginY:int = 0):AntAnimation
		{
			var anim:AntAnimation = new AntAnimation(aName);
			var bitmaps:Vector.<BitmapData> = getBitmaps(aPrefix);
			
			var i:int = 0;
			var n:int = bitmaps.length;
			while (i < n)
			{
				anim.frames[anim.frames.length] = bitmaps[i];
				anim.offsetX[anim.offsetX.length] = aOriginX;
				anim.offsetY[anim.offsetY.length] = aOriginY;
				i++;
			}
			
			anim.totalFrames = anim.frames.length;
			return anim;
		}
		
		/**
		 * Извлекает битмап спрайта из атласа с указанным именем.
		 * 
		 * @param	aName	 Имя спрайта битмап которого необходимо получить.
		 * @return		Возвращает указатель на битмап спрайта.
		 */
		public function getBitmap(aName:String):BitmapData
		{
			var region:Rectangle = _atlasRegions.get(aName);
			if (region == null)
			{
				return null;
			}
			
			var bmpData:BitmapData = new BitmapData(region.width, region.height, true, 0);
			bmpData.copyPixels(_atlasBitmapData, region, DEST_POINT);
			return bmpData;
		}
		
		/**
		 * Извлекает битмапы в именах которых встречается указанный префикс.
		 * 
		 * @param	aPrefix	 Префикс для имени спрайтов который будет учитыватся в выборке графики.
		 * @param	aResult	 Указатель на массив в который может быть записан результат.
		 * @return		Возвращает массив указателей на битмапы.
		 */
		public function getBitmaps(aPrefix:String = "", aResult:Vector.<BitmapData> = null):Vector.<BitmapData>
		{
			if (aResult == null)
			{
				aResult = new <BitmapData>[];
			}
			
			var names:Vector.<String> = getNames(aPrefix);
			for each (var name:String in names)
			{
				aResult.push(getBitmap(name));
			}
			
			return aResult;
		}
		
		/**
		 * Извлекает имена спрайтов в которых встречается указанный префикс.
		 * 
		 * @param	aPrefix	 Префикс который должен встречатся в именах спрайтов.
		 * @param	aResult	 Указатель на массив в который может быть записан результат.
		 * @return		Возвращает массив имен.
		 */
		public function getNames(aPrefix:String = "", aResult:Vector.<String> = null):Vector.<String>
		{
			if (aResult == null)
			{
				aResult = new <String>[];
			}
			
			for (var name:String in _atlasRegions)
			{
				if (name.indexOf(aPrefix) == 0)
				{
					aResult.push(name);
				}
			}
			
			aResult.sort(Array.CASEINSENSITIVE);
			return aResult;
		}
		
		/**
		 * Добавляет новый регион для текущего атласа.
		 * 
		 * @param	aName	 Имя региона (спрайта).
		 * @param	aRegion	 Прямоугольник определяющий положение и размеры спрайта в атласе.
		 * @param	aFrame	 Прямоугольник определяющий положение и размеры кадра в атласе.
		 */
		public function addRegion(aName:String, aRegion:Rectangle):void
		{
			_atlasRegions.set(aName, aRegion);
		}
		
		/**
		 * Извлекает регион с указанным именем.
		 * 
		 * @param	aName	 Имя региона (спрайта) позицию и размеры которого необходимо получить.
		 * @return		Возвращает прямоугольник определяющий положение и размеры региона (спрайта).
		 */
		public function getRegion(aName:String):Rectangle
		{
			return _atlasRegions.get(aName);
		}
				
		/**
		 * Удаляет регион с указанным именем.
		 * 
		 * @param	aName	 Имя региона (спрайта) информацию о котором необходимо удалить.
		 */
		public function removeRegion(aName:String):void
		{
			_atlasRegions.remove(aName);
		}
		
		/**
		 * Возвращает указатель на битмап атласа.
		 */
		public function get atlasBitmapData():BitmapData
		{
			return _atlasBitmapData;
		}

	}

}