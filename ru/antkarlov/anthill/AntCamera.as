package ru.antkarlov.anthill
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;

	/**
	 * Реализует рендеринг всех визуальных сущностей.
	 * <p>Чтобы реализовать перемещение камеры (скролл уровней), используйте атрибут <code>scroll</code>
	 * для перемещения камеры в игровом мире.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  29.08.2012
	 */
	public class AntCamera extends Sprite
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Флаг определяющий следует ли выполнять заливку цветом в буфер камеры перед рендером объектов.
		 * @default    false
		 */
		public var fillBackground:Boolean;
		
		/**
		 * Цвет заливки.
		 * @default    0xFF000000
		 */
		public var backgroundColor:uint;
		
		/**
		 * Содержит смещение камеры относительно игрового мира.
		 * Чтобы прокручивать игровые миры, достаточно менять значения <code>scroll.x</code> и <code>scroll.y</code>.
		 * @default    (0,0)
		 */
		public var scroll:AntPoint;
		
		/**
		 * Основной буфер камеры куда производится отрисовка всех визуальных объектов.
		 */
		public var buffer:BitmapData;
		
		/**
		 * Фактор увеличения изображения.
		 * @default    1
		 */
		public var zoom:int;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Помшник для заливки буфера камеры цветом.
		 */
		protected var _flashRect:Rectangle;
		
		/**
		 * Битмап для вывода буффера камеры на экран стандартными средствами Flash.
		 */
		protected var _bitmap:Bitmap;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntCamera(aWidth:int, aHeight:int, aZoom:int = 1)
		{
			super();
			
			fillBackground = false;
			backgroundColor = 0xFF000000;
			scroll = new AntPoint();
			zoom = aZoom;
			
			_bitmap = new Bitmap(new BitmapData(aWidth, aHeight, true, backgroundColor));
			_bitmap.scaleX = _bitmap.scaleY = zoom;
			addChild(_bitmap);
			
			buffer = _bitmap.bitmapData;
			buffer.lock();
			
			_flashRect = new Rectangle(0, 0, aWidth, aHeight);
		}
		
		/**
		 * Уничтожает экземпляр камеры и осовобождает память.
		 */
		public function destroy():void
		{
			AntG.removeCamera(this);
			
			buffer.unlock();
			buffer.dispose();
			buffer = null;
			
			if (contains(_bitmap))
			{
				removeChild(_bitmap);
			}
			_bitmap = null;
			
			if (parent != null)
			{
				parent.removeChild(this);
			}
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Обработка действий камеры.
		 */
		public function update():void
		{
			//
		}
		
		/**
		 * Отрисовка буфера камеры на экран.
		 */
		public function draw():void
		{
			buffer.unlock();
			buffer.lock();
			
			if (fillBackground)
			{
				buffer.fillRect(_flashRect, backgroundColor);
			}
		}

	}

}