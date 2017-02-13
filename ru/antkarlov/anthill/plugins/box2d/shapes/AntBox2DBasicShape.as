package ru.antkarlov.anthill.plugins.box2d.shapes
{
	import ru.antkarlov.anthill.AntMath;
	import ru.antkarlov.anthill.plugins.box2d.*;
	
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Collision.Shapes.*;
	
	/**
	 * Базовый класс реализующий общие функции для всех видов форм.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DBasicShape extends Object
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на тело обладающим данной формой.
		 * @default    null
		 */
		protected var _ownerBody:AntBox2DBody;
		
		/**
		 * Оригинальный класс настроек формы для Box2D.
		 * @default    b2FixtureDef
		 */
		protected var _box2dFixtureDef:b2FixtureDef;
		
		/**
		 * Флаг опредялющий возможность обновления формы.
		 * @default    true
		 */
		protected var _allowRebuildShapes:Boolean;
		
		/**
		 * Позиция формы по горизонтали относительно тела.
		 * @default    0
		 */
		protected var _x:Number;
		
		/**
		 * Позиция формы по вертикали относительно тела.
		 * @default    0
		 */
		protected var _y:Number;
		
		/**
		 * Угол поворота прямоугольника в радианах.
		 * @default    0
		 */
		protected var _angle:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DBasicShape()
		{
			super();
			
			_ownerBody = null;
			
			_box2dFixtureDef = new b2FixtureDef();
			_box2dFixtureDef.density = 1.0;
			_box2dFixtureDef.friction = 0.3;
			_box2dFixtureDef.restitution = 0.2;
			_box2dFixtureDef.isSensor = false;
			
			_allowRebuildShapes = true;
			
			_x = 0;
			_y = 0;
			_angle = 0;
		}
		
		/**
		 * Освобождает используемые классом ресурсы.
		 */
		public function destroy():void
		{
			_ownerBody = null;
			_box2dFixtureDef = null;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Инициализирует все необходимые параметры для создания физического
		 * тела и возвращает указатель на класс настроек.
		 * 
		 * @param	aBody	 Тело для которого производится инициализация настроек.
		 * @return		Возвращает оригинальный класс настроек для создания тела в Box2D.
		 */
		public function getFixtureDef(aBody:AntBox2DBody):b2FixtureDef
		{
			// Форма определяется и назнчается в наследниках этого класса.
			// _box2dFixtureDef.shape = shapeDef;
			
			_ownerBody = aBody;
			_box2dFixtureDef.userData = aBody;
			_box2dFixtureDef.filter.groupIndex = aBody.groupIndex;
			
			if (aBody.collisionFlag != null)
			{
				_box2dFixtureDef.filter.categoryBits = aBody.collisionFlag.bits;
			}
			
			if (aBody.collidesWithFlags != null)
			{
				_box2dFixtureDef.filter.maskBits = aBody.collidesWithFlags.bits;
			}
			
			return _box2dFixtureDef;
		}
		
		/**
		 * Блокирует изменения формы. Вызовите данный метод если вам необходимо 
		 * изменить более одного параметра для уже инициализированной формы тела.
		 */
		public function beginChange():void
		{
			_allowRebuildShapes = false;
		}
		
		/**
		 * Применяет внесенные изменения к обладателю формы.
		 */
		protected function updateShapes():void
		{
			if (_allowRebuildShapes && _ownerBody != null)
			{
				_ownerBody.buildShapes();
			}
		}
		
		/**
		 * Разблокирует изменения формы и перестраивает её. Вызовите данный метод
		 * чтобы разблокировать и обновить форму если ранее вы заблокировали её.
		 */
		public function endChange():void
		{
			_allowRebuildShapes = true;
			updateShapes();
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет является ли форма сенсором.
		 */
		public function get isSensor():Boolean { return _box2dFixtureDef.isSensor; }
		public function set isSensor(value:Boolean):void
		{
			if (_box2dFixtureDef.isSensor != value)
			{
				_box2dFixtureDef.isSensor = value;
				updateShapes();
			}
		}
		
		/**
		 * Определяет плотность формы, влияет на общую массу тела.
		 */
		public function get density():Number { return _box2dFixtureDef.density; }
		public function set density(value:Number):void
		{
			if (_box2dFixtureDef.density != value)
			{
				_box2dFixtureDef.density = value;
				updateShapes();
			}
		}
		
		/**
		 * Определяет трение формы, влияет на скольжение тела.
		 */
		public function get friction():Number { return _box2dFixtureDef.friction; }
		public function set friction(value:Number):void
		{
			if (_box2dFixtureDef.friction)
			{
				_box2dFixtureDef.friction = value;
				updateShapes();
			}
		}
		
		/**
		 * Определяет эластичность формы, влияет на силу отскока тела.
		 */
		public function get restitution():Number { return _box2dFixtureDef.restitution; }
		public function set restitution(value:Number):void
		{
			if (_box2dFixtureDef.restitution != value)
			{
				_box2dFixtureDef.restitution = value;
				updateShapes();
			}
		}
		
		/**
		 * Определяет положение формы по горизонтали относительно тела.
		 */
		public function get x():Number { return _x; }
		public function set x(value:Number):void
		{
			if (_x != value)
			{
				_x = value;
				updateShapes();
			}
		}
		
		/**
		 * Определяет положение формы по вертикали относительно тела.
		 */
		public function get y():Number { return _y; }
		public function set y(value:Number):void
		{
			if (_y != value)
			{
				_y = value;
				updateShapes();
			}
		}
		
		/**
		 * Определяет угол поворота прямоугольника в радианах.
		 */
		public function get angle():Number { return _angle; }
		public function set angle(aValue:Number):void
		{
			if (_angle != aValue)
			{
				_angle = aValue;
				updateShapes();
			}
		}
		
		/**
		 * Определяет угол поворота прямоугольника в градусах.
		 */
		public function get angleDeg():Number { return AntMath.toDegrees(_angle); }
		public function set angleDeg(aValue:Number):void
		{
			_angle = AntMath.toRadians(aValue);
		}

	}

}