package ru.antkarlov.anthill.plugins.box2d.shapes
{
	import ru.antkarlov.anthill.plugins.box2d.AntBox2DBody;
	
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * Класс реализующий возможность создания круглых форм для физических тел Box2D.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DCircleShape extends AntBox2DBasicShape
	{
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Радиус формы.
		 * @default    20
		 */
		protected var _radius:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DCircleShape()
		{
			super();
			
			_radius = 20;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function getFixtureDef(aBody:AntBox2DBody):b2FixtureDef
		{
			var scale:Number = aBody.manager.scale;
			var shape:b2CircleShape = new b2CircleShape(_radius / scale);
			shape.SetLocalPosition(new b2Vec2(_x / scale, _y / scale));
			
			_box2dFixtureDef.shape = shape;
			return super.getFixtureDef(aBody);
		}
		
		/**
		 * Копирует параметры формы из указанного источника.
		 * 
		 * @param	aShape	 Форма значения которой необходимо скопировать.
		 * @return		Возвращает указатель на себя.
		 */
		public function copyFrom(aShape:AntBox2DCircleShape):AntBox2DCircleShape
		{
			_radius = aShape.radius;
			_x = aShape.x;
			_y = aShape.y;
			
			_box2dFixtureDef.density = aShape.density;
			_box2dFixtureDef.friction = aShape.friction;
			_box2dFixtureDef.restitution = aShape.restitution;
			_box2dFixtureDef.isSensor = aShape.isSensor;
			
			updateShapes();
			return this;
		}
		
		/**
		 * Копирует параметры формы в новый или указанный объект.
		 * 
		 * @param	aShape	 Форма в которую необходимо скопировать значения текущей формы.
		 * @return		Возвращает указатель на новую форму.
		 */
		public function copy(aShape:AntBox2DCircleShape = null):AntBox2DCircleShape
		{
			if (aShape == null)
			{
				aShape = new AntBox2DCircleShape();
			}
			
			aShape.copyFrom(this);
			return aShape;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Орпеделяет радиус формы.
		 */
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void
		{
			if (_radius != value)
			{
				_radius = value;
				updateShapes();
			}
		}

	}

}