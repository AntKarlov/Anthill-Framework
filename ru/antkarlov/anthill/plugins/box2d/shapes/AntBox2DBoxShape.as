package ru.antkarlov.anthill.plugins.box2d.shapes
{
	import ru.antkarlov.anthill.AntMath;
	import ru.antkarlov.anthill.plugins.box2d.AntBox2DBody;
	
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * Класс реализующий возможность создания прямоугольных форм для физических тел Box2D.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DBoxShape extends AntBox2DBasicShape
	{
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Ширина прямоугольника.
		 * @default    20
		 */
		protected var _width:Number;
		
		/**
		 * Высота прямоугольника.
		 * @default    20
		 */
		protected var _height:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DBoxShape()
		{
			super();
			
			_width = 20;
			_height = 20;
			_angle = 0;
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
			var shape:b2PolygonShape = new b2PolygonShape();
			if (_x != 0 || _y != 0 || _angle != 0)
			{
				var pos:b2Vec2 = new b2Vec2(_x / scale, _y / scale);
				shape.SetAsOrientedBox(_width * 0.5 / scale, _height * 0.5 / scale, pos, _angle);
			}
			else
			{
				shape.SetAsBox(_width * 0.5 / scale, _height * 0.5 / scale);
			}
			
			_box2dFixtureDef.shape = shape;
			return super.getFixtureDef(aBody);
		}
		
		/**
		 * Копирует параметры формы из указанного источника.
		 * 
		 * @param	aShape	 Форма значения которой необходимо скопировать.
		 * @return		Возвращает указатель на себя.
		 */
		public function copyFrom(aShape:AntBox2DBoxShape):AntBox2DBoxShape
		{
			_width = aShape.width;
			_height = aShape.height;
			_angle = aShape.angle;
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
		public function copy(aShape:AntBox2DBoxShape = null):AntBox2DBoxShape
		{
			if (aShape == null)
			{
				aShape = new AntBox2DBoxShape();
			}
			
			aShape.copyFrom(this);
			return aShape;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет ширину прямоугольника.
		 */
		public function get width():Number { return _width;	}
		public function set width(aValue:Number):void
		{
			if (_width != aValue)
			{
				_width = aValue;
				updateShapes();
			}
		}
		
		/**
		 * Определяет высоту прямоугольника.
		 */
		public function get height():Number { return _height; }
		public function set height(aValue:Number):void
		{
			if (_height != aValue)
			{
				_height = aValue;
				updateShapes();
			}
		}
		
	}

}