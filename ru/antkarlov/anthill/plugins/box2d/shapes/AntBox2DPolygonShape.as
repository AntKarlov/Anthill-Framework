package ru.antkarlov.anthill.plugins.box2d.shapes
{
	import ru.antkarlov.anthill.AntPoint;
	import ru.antkarlov.anthill.AntG;
	import ru.antkarlov.anthill.plugins.box2d.AntBox2DBody;
	
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	
	/**
	 * Класс реализующий возможность создания полиогональных форм для физических тел Box2D.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DPolygonShape extends AntBox2DBasicShape
	{
		/*
			TODO Сделать возможность вращения полигона.
		*/
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Список вершин полигона.
		 */
		protected var _vertices:Vector.<AntPoint>;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DPolygonShape()
		{
			super();
			_vertices = new Vector.<AntPoint>();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			clearVertices();
			_vertices = null;
			
			super.destroy();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function getFixtureDef(aBody:AntBox2DBody):b2FixtureDef
		{
			if (_vertices.length <= 2)
			{
				AntG.log("Warning: Can't to create polygon shape. Must be at least 3 vertices.", "error");
				return null;
			}
			
			var scale:Number = aBody.manager.scale;
			var vecVertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			var p:AntPoint;
			const n:int = _vertices.length;
			var i:int = 0;
			while (i < n)
			{
				p = _vertices[i++];
				vecVertices.push(new b2Vec2(p.x / scale, p.y / scale));
			}
			
			var shape:b2PolygonShape = new b2PolygonShape();
			shape.SetAsVector(vecVertices);
			
			_box2dFixtureDef.shape = shape;			
			return super.getFixtureDef(aBody);
		}
		
		/**
		 * Добавляет вершину.
		 * 
		 * @param	aX	 Позиция вершины по горизонтали.
		 * @param	aY	 Позиция вершины по вертикали.
		 */
		public function addVertex(aX:Number, aY:Number):void
		{
			_vertices.push(new AntPoint(aX, aY));
			updateShapes();
		}
		
		/**
		 * Удаляет вершину.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 */
		public function removeVertex(aIndex:int):void
		{
			if (aIndex >= 0 && aIndex < _vertices.length)
			{
				_vertices[aIndex] = null;
				_vertices.splice(aIndex, 1);
				updateShapes();
			}
		}
		
		/**
		 * Извлекает позицию вершины.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 * @param	aResult	 Точка в которую может быть записан результат работы метода.
		 * @return		Возвращает позицию вершины.
		 */
		public function getVertexPoint(aIndex:int, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			if (aIndex >= 0 && aIndex < _vertices.length)
			{
				aResult.x = _vertices[aIndex].x;
				aResult.y = _vertices[aIndex].y;
			}
			
			return aResult;
		}
		
		/**
		 * Устанавливает позицию вершины.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 * @param	aPoint	 Новая позиция вершины.
		 */
		public function setVertexPoint(aIndex:int, aPoint:AntPoint):void
		{
			if (aIndex >= 0 && aIndex < _vertices.length)
			{
				_vertices[aIndex].x = aPoint.x;
				_vertices[aIndex].y = aPoint.y;
				updateShapes();
			}
		}
		
		/**
		 * Извлекает позицию вершины по горизонтали.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 * @return		Возвращает позицию вершины по горизонтали.
		 */
		public function getVertexX(aIndex:int):Number
		{
			return (aIndex >= 0 && aIndex < _vertices.length) ? _vertices[aIndex].x : 0;
		}
		
		/**
		 * Устанавливает позицию вершины по горизонтали.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 * @param	aValue	 Новая позиция вершины по горизонтали.
		 */
		public function setVertexX(aIndex:int, aValue:Number):void
		{
			if (aIndex >= 0 && aIndex < _vertices.length)
			{
				_vertices[aIndex].x = aValue;
				updateShapes();
			}
		}
		
		/**
		 * Извлекает позицию вершины по вертикали.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 * @return		Возвращает позицию вершины по вертикали.
		 */
		public function getVertexY(aIndex:int):Number
		{
			return (aIndex >= 0 && aIndex < _vertices.length) ? _vertices[aIndex].y : 0;
		}
		
		/**
		 * Устанавливает позицию вершины по вертикали.
		 * 
		 * @param	aIndex	 Индекс вершины.
		 * @param	aValue	 Новая позиция вершины по вертикали.
		 */
		public function setVertexY(aIndex:int, aValue:Number):void
		{
			if (aIndex >= 0 && aIndex < _vertices.length)
			{
				_vertices[aIndex].y = aValue;
				updateShapes();
			}
		}
		
		/**
		 * Удаляет все вершины.
		 */
		public function clearVertices():void
		{
			const n:int = _vertices.length;
			var i:int = 0;
			while (i < n)
			{
				_vertices[i++] = null;
			}
			
			_vertices.length = 0;
		}
		
		/**
		 * Копирует параметры формы из указанного источника.
		 * 
		 * @param	aShape	 Форма значения которой необходимо скопировать.
		 * @return		Возвращает указатель на себя.
		 */
		public function copyFrom(aShape:AntBox2DPolygonShape):AntBox2DPolygonShape
		{
			clearVertices();
			
			var sourceVertices:Vector.<AntPoint> = aShape.vertices;
			const n:int = sourceVertices.length;
			var i:int = 0;
			while (i < n)
			{
				_vertices.push(new AntPoint(sourceVertices[i].x, sourceVertices[i].y));
				i++;
			}
			
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
		public function copy(aShape:AntBox2DPolygonShape = null):AntBox2DPolygonShape
		{
			if (aShape == null)
			{
				aShape = new AntBox2DPolygonShape();
			}
			
			aShape.copyFrom(this);
			return aShape;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Придоставляет доступ к массиву вершин.
		 */
		public function get vertices():Vector.<AntPoint> { return _vertices; }
		public function set vertices(value:Vector.<AntPoint>):void
		{
			_vertices = value;
			updateShapes();
		}
		
		/**
		 * Определяет количество вершин.
		 */
		public function get numVertices():int {	return _vertices.length; }

	}

}