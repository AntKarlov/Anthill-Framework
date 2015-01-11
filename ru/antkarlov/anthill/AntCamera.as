package ru.antkarlov.anthill
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;

	/**
	 * Реализует рендеринг всех визуальных сущностей.
	 * 
	 * <p>Чтобы реализовать перемещение камеры (скролл уровней), используйте атрибут <code>scroll</code>
	 * для перемещения камеры в игровом мире.</p>
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Anton Karlov
	 * @since  29.08.2012
	 */
	public class AntCamera extends AntBasic
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		/**
		 * Стиль слежения камеры: свободный стиль, по X и Y.
		 */
		public static const STYLE_FREELY:uint = 0;
		
		/**
		 * Стиль слежения камеры: горизонтальный, только по X.
		 */
		public static const STYLE_HORIZONTAL:uint = 1;
		
		/**
		 * Стиль слежения камеры: вертикальный, только по Y.
		 */
		public static const STYLE_VERTICAL:uint = 2;
		
		/**
		 * @private
		 */
		public static const ZOOM_STYLE_DEFAULT:String = "styleDefault";
		public static const ZOOM_STYLE_CENTER:String = "styleCenter";
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Положение камеры на экране Flash окна по X.
		 */
		public var x:Number;
		
		/**
		 * Положение камеры на экране Flash окна по Y.
		 */
		public var y:Number;
		
		/**
		 * Размер окна камеры по ширине.
		 */
		public var width:int;
		
		/**
		 * Размер окна камеры по высоте.
		 */
		public var height:int;
		
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
		 * Прямоугольник задающий границы для перемещения камеры.
		 * @default    null
		 */
		public var bounds:AntRect;
		
		/**
		 * Цель которую приследует камера.
		 * @default    null
		 */
		public var target:AntEntity;
		
		/**
		 * Стиль слежения за объектом.
		 * @default    STYLE_FREELY
		 */
		public var followStyle:uint;
		
		/**
		 * Фактор опережения камеры при движении за целью.
		 * @default    8
		 */
		public var leadingFactor:Number;
		
		/**
		 * Фактор отставания камеры при движении за целью.
		 * @default    0.25
		 */
		public var smoothFactor:Number;
		
		/**
		 * Свойство цели для преследования которое используется для определения его позиции по X.
		 * @default    "globalX"
		 */
		public var positionPropertyX:String;
		
		/**
		 * Свойство цели для преследования которое используется для определения его позиции по Y.
		 * @default    "globalY"
		 */
		public var positionPropertyY:String;
		
		/**
		 * Определяет следует ли при преследовании цели округлять координаты камеры.
		 * @default    false
		 */
		public var roundPosition:Boolean;
		
		/**
		 * Центр экрана.
		 */
		public var screenCenter:AntPoint;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Фактор увеличения изображения.
		 * @default    1
		 */
		protected var _zoom:Number;
		
		/**
		 * @private
		 */
		protected var _zoomStyle:String;
		
		/**
		 * Помшник для заливки буфера камеры цветом.
		 */
		protected var _flashRect:Rectangle;
		
		/**
		 * Битмап для вывода буффера камеры на экран стандартными средствами Flash.
		 */
		protected var _flashBitmap:Bitmap;
		internal var _flashSprite:Sprite;
		
		/**
		 * Помошник для рассчета новой позиции камеры.
		 */
		protected var _newPos:AntPoint;
		
		protected var _shaker:Vector.<AntPoint>;
		protected var _shakerIndex:int;
		protected var _shakerDelay:Number;
		protected var _isShake:Boolean;
		protected var _shakePos:AntPoint;
		
		internal var _isMasked:Boolean;
		internal var _maskOffset:AntPoint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntCamera(aX:Number, aY:Number, aWidth:int, aHeight:int, aZoom:Number = 1)
		{
			super();
			
			x = aX;
			y = aY;
			width = aWidth;
			height = aHeight;
			fillBackground = false;
			backgroundColor = 0xFF000000;
			scroll = new AntPoint();
			_zoom = aZoom;
			_zoomStyle = ZOOM_STYLE_DEFAULT;
			bounds = null;
			
			buffer = new BitmapData(width, height, true, backgroundColor); 
			_flashBitmap = new Bitmap(buffer);
			_flashBitmap.scaleX = _flashBitmap.scaleY = _zoom;
			_flashBitmap.x = -width * 0.5;
			_flashBitmap.y = -height * 0.5;
			
			screenCenter = new AntPoint(width * 0.5 * _zoom, height * 0.5 * _zoom);
			
			_flashSprite = new Sprite();
			_flashSprite.x = x + screenCenter.x;
			_flashSprite.y = y + screenCenter.y;
			_flashSprite.addChild(_flashBitmap);
			
			_flashRect = new Rectangle(0, 0, aWidth, aHeight);
			_newPos = new AntPoint();
			
			target = null;
			followStyle = STYLE_FREELY;
			leadingFactor = 8;
			smoothFactor = 0.25;
			positionPropertyX = "globalX";
			positionPropertyY = "globalY";
			roundPosition = false;
			
			_shaker = new Vector.<AntPoint>();
			_shakerIndex = 0;
			_isShake = false;
			
			_isMasked = false;
			_maskOffset = new AntPoint();
		}
		
		/**
		 * Уничтожает экземпляр камеры и осовобождает память.
		 */
		override public function destroy():void
		{
			target = null;
			AntG.removeCamera(this);
			
			buffer.dispose();
			buffer = null;
			
			if (_flashSprite.contains(_flashBitmap))
			{
				_flashSprite.removeChild(_flashBitmap);
			}
			_flashBitmap = null;
			
			if (_flashSprite.parent != null)
			{
				_flashSprite.parent.removeChild(_flashSprite);
			}
			_flashSprite = null;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function shake(aForce:Number = 4, aDuration:int = 4):void
		{
			_shaker.length = 0;
			var r:Number = Math.random();
			var p:AntPoint;
			for (var i:int = 0; i < aDuration; i++)
			{
				p = new AntPoint();
				//r = Math.random();
				if (i % 2 == 0)
				{
					p.x = (r > 0.5) ? -aForce * i : aForce * i;
					p.y = aForce * i;
				}
				else
				{
					p.x = (r > 0.5) ? aForce * i : -aForce * i;
					p.y = -aForce * i;
				}
				_shaker.push(p);
			}
			
			_shakerDelay = 0;
			_shakerIndex = _shaker.length-1;
			_shakePos = _shaker[_shakerIndex];
			_isShake = true;
		}
		
		/**
		 * Устанавливает цель за которой будет выполнятся слежение.
		 * 
		 * @param	aTarget	 Цель за которой будет выполнятся слежение.
		 * @param	aStyle	 Стиль слежения.
		 */
		public function follow(aTarget:AntEntity, aStyle:uint = STYLE_FREELY):void
		{
			target = aTarget;
			followStyle = aStyle;
		}
		
		/**
		 * Моментальное перемещение камеры к указанной точке.
		 * 
		 * @param	aPoint	 Точка к которой будет перемещена камера.
		 */
		public function focusOnPoint(aPoint:AntPoint):void
		{
			focusOn(aPoint.x, aPoint.y);
		}
		
		/**
		 * Моментальное перемещение камеры к указанным координатам.
		 * 
		 * @param	aX	 Новая позиция камеры по горизонтали.
		 * @param	aY	 Новая позиция камеры по вертикали.
		 */
		public function focusOn(aX:Number, aY:Number):void
		{
			aX += (aX > 0) ? 0.0000001 : -0.0000001;
			aY += (aY > 0) ? 0.0000001 : -0.0000001;
			_newPos.x = -(aX - width) - screenCenter.x;
			_newPos.y = -(aY - height) - screenCenter.y;
			
			if (bounds != null)
			{
				_newPos.x = limitByX(_newPos.x);
				_newPos.y = limitByY(_newPos.y);
			}
			
			scroll.x = _newPos.x;
			scroll.y = _newPos.y;
		}
		
		/**
		 * Устанавливает ограничение для перемещения камеры.
		 * 
		 * @param	aLowerX	 Минимально допустимая позиция камеры по X (обычно это 0).
		 * @param	aLowerY	 Минимально допустимая позиция камеры по Y (обычно это 0).
		 * @param	aUpperX	 Максимально допустимая позиция камеры по X (обычно это ширина уровня).
		 * @param	aUpperY	 Максимально допустимая позиция камеры по Y (обычно это высота уровня).
		 */
		public function setBounds(aLowerX:int, aLowerY:int, aUpperX:int, aUpperY:int):void
		{
			if (bounds == null)
			{
				bounds = new AntRect();
			}
			
			bounds.set(aLowerX, aLowerY, aUpperX, aUpperY);
			update();
		}
		
		/**
		 * Обработка действий камеры.
		 */
		override public function update():void
		{
			if (_flashSprite.visible != visible)
			{
				_flashSprite.visible = visible;
			}
			
			if (!exists || !active)
			{
				return;
			}
			
			if (target != null)
			{
				switch (followStyle)
				{
					case STYLE_FREELY :
						_newPos.x = (scroll.x - (-target[positionPropertyX] + screenCenter.x - (target.velocity.x * AntG.elapsed) * leadingFactor)) * smoothFactor;
						_newPos.y = (scroll.y - (-target[positionPropertyY] + screenCenter.y - (target.velocity.y * AntG.elapsed) * leadingFactor)) * smoothFactor;
					break;
					
					case STYLE_HORIZONTAL :
						_newPos.x = (scroll.x - (-target[positionPropertyX] + screenCenter.x - (target.velocity.x * AntG.elapsed) * leadingFactor)) * smoothFactor;
					break;
					
					case STYLE_VERTICAL :
						_newPos.y = (scroll.y - (-target[positionPropertyY] + screenCenter.y - (target.velocity.y * AntG.elapsed) * leadingFactor)) * smoothFactor;
					break;
				}
				
				_newPos.set(scroll.x - _newPos.x, scroll.y - _newPos.y);
				updateShaker(_newPos);
				
				if (bounds != null)
				{
					_newPos.x = limitByX(_newPos.x);
					_newPos.y = limitByY(_newPos.y);
				}
				
				if (roundPosition)
				{
					scroll.x = Math.round(_newPos.x);
					scroll.y = Math.round(_newPos.y);
				}
				else
				{
					scroll.x = _newPos.x;
					scroll.y = _newPos.y;
				}
			}
			else if (bounds != null)
			{
				updateShaker(scroll);
				
				scroll.x = limitByX(scroll.x);
				scroll.y = limitByY(scroll.y);
				
				if (roundPosition)
				{
					scroll.x = Math.round(scroll.x);
					scroll.y = Math.round(scroll.y);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function updateShaker(aSource:AntPoint):void
		{
			if (_isShake)
			{
				_shakerDelay -= 2 * AntG.elapsed;
				if (_shakerDelay <= 0)
				{
					if (_shakerIndex < 0)
					{
						_isShake = false;
					}
					else
					{
						_shakePos = _shaker[_shakerIndex];
					}

					_shakerIndex--;
					_shakerDelay = 0.08;
				}

				aSource.x = AntMath.lerp(aSource.x + _shakePos.x, aSource.x, 0.5);
				aSource.y = AntMath.lerp(aSource.y + _shakePos.y, aSource.y, 0.5);
			}
		}
		
		/**
		 * Отрисовка буфера камеры на экран.
		 */
		/*public function draw():void
		{
			buffer.unlock();
			buffer.lock();
			
			if (fillBackground)
			{
				buffer.fillRect(_flashRect, backgroundColor);
			}
		}*/
		
		/**
		 * @private
		 */
		public function beginDraw():void
		{
			buffer.lock();
			if (fillBackground)
			{
				buffer.fillRect(_flashRect, backgroundColor);
			}
		}
		
		/**
		 * @private
		 */
		public function endDraw():void
		{
			buffer.unlock();
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет сглаживание для буфера камеры.
		 * @default    false
		 */
		public function get smoothing():Boolean { return _flashBitmap.smoothing; }
		public function set smoothing(aValue:Boolean):void
		{
			_flashBitmap.smoothing = aValue;
		}
		
		/**
		 * Определяет тип приближения камеры.
		 * @default    ZOOM_STYLE_DEFAULT
		 */
		public function get zoomStyle():String { return _zoomStyle; }
		public function set zoomStyle(aValue:String):void
		{
			_zoomStyle = aValue;
			switch (_zoomStyle)
			{
				case ZOOM_STYLE_CENTER :
					_flashBitmap.x = -width * 0.5 * _zoom;
					_flashBitmap.y = -height * 0.5 * _zoom;
				break;
				
				default :
					_flashBitmap.x = -width * 0.5;
					_flashBitmap.y = -height * 0.5;
				break;
			}
		}
		
		/**
		 * Определяет уровень приближения камеры.
		 * @default    1
		 */
		public function get zoom():Number { return _zoom; }
		public function set zoom(aValue:Number):void
		{
			_zoom = aValue;
			_flashBitmap.scaleX = _flashBitmap.scaleY = _zoom;
			
			if (_zoomStyle == ZOOM_STYLE_CENTER)
			{
				_flashBitmap.x = -width * 0.5 * _zoom;
				_flashBitmap.y = -height * 0.5 * _zoom;
			}
		}
		
		/**
		 * Возвращает указатель на Sprite камеры.
		 */
		public function get screenSprite():Sprite
		{
			return _flashSprite;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Определяет начало отрисовки сущности использующей маску.
		 * 
		 * @param	aMask	 Указатель на маску которая будет временно применена к камере.
		 */
		internal function beginDrawMask(aMask:AntMask):void
		{
			if (!_isMasked)
			{
				buffer = aMask.buffer;
				_maskOffset.set(aMask.globalX, aMask.globalY);
				_isMasked = true;
			}
		}
		
		/**
		 * Определяет окончание отрисовки сущности использующей маску.
		 * 
		 * @param	aMask	 Указатель на маску которая ранее была применена к камере.
		 */
		internal function endDrawMask(aMask:AntMask):void
		{
			if (_isMasked)
			{
				buffer = _flashBitmap.bitmapData;
				aMask.drawTo(buffer);
				_isMasked = false;
			}
		}
		
		/**
		 * Ограничивает значение по горизонтали согласно заданным границам.
		 * 
		 * @param	aValue	 Новая позиция по горизонтали.
		 * @return		Если новая позиция вышла за пределы границы, то вернет крайнюю доступную позицию.
		 */
		protected function limitByX(aValue:Number):Number
		{
			if (aValue > bounds.left)
			{
				aValue = bounds.left;
			}
			else if (AntMath.abs(aValue) > bounds.right - width)
			{
				aValue = -(bounds.right - width);
			}
			
			return aValue;
		}
		
		/**
		 * Ограничивает значение по вертикали согласно заданным границам.
		 * 
		 * @param	aValue	 Новая позиция по вертикали.
		 * @return		Если новая позиция вышла за пределы границы, то вернет крайнюю доступную позицию.
		 */
		protected function limitByY(aValue:Number):Number
		{
			if (aValue > bounds.top)
			{
				aValue = bounds.top;
			}
			else if (AntMath.abs(aValue) > bounds.bottom - height)
			{
				aValue = -(bounds.bottom - height);
			}
			
			return aValue;
		}
		
		/**
		 * @private
		 */
		public function get sprite():Sprite
		{
			return _flashSprite;
		}

	}

}