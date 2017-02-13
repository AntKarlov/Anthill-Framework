package ru.antkarlov.anthill.plugins.box2d.models
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.plugins.box2d.shapes.*;
	import ru.antkarlov.anthill.plugins.box2d.joints.*;
	
	public class AntModelData extends Object
	{
		public var name:String;
		
		protected var _shapeDefs:Vector.<AntBox2DBasicShape>;
		protected var _shapeNames:Vector.<String>;
		protected var _numShapes:int;
		
		protected var _jointDefs:Vector.<AntBox2DBasicJoint>;
		protected var _jointNames:Vector.<String>;
		protected var _numJoints:int;
		
		private var _angle:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		
		/**
		 * @constructor
		 */
		public function AntModelData(aModelName:String)
		{
			super();
			
			name = aModelName;
			
			_shapeDefs = new <AntBox2DBasicShape>[];
			_shapeNames = new <String>[];
			_numShapes = 0;
			
			_jointDefs = new <AntBox2DBasicJoint>[];
			_jointNames = new <String>[];
			_numJoints = 0;
			
			resetTransform();
		}
		
		/**
		 * Добавлфет форму в модель.
		 * 
		 * @param	aShape	 Указатель на форму.
		 * @param	aName	 Уникальное имя формы.
		 */
		public function addShape(aShape:AntBox2DBasicShape, aName:String):void
		{
			_shapeDefs[_numShapes] = aShape;
			_shapeNames[_numShapes++] = aName;
		}
		
		/**
		 * Добавляет соеденение в модель.
		 * 
		 * @param	aJoint	 Указатель на джоинт.
		 * @param	aName	 Уникальное имя джоинта.
		 */
		public function addJoint(aJoint:AntBox2DBasicJoint, aName:String):void
		{
			_jointDefs[_numJoints] = aJoint;
			_jointNames[_numJoints++] = aName;
		}
		
		/**
		 * Применяет угол поворота для модели.
		 * 
		 * @param	aValue	 Новый угол поворота в градусах.
		 */
		public function applyRotation(aValue:Number):void
		{
			_angle = aValue;
		}
		
		/**
		 * Применяет трансформацию размеров для модели.
		 * 
		 * @param	aScaleX	 Трансформация по горизонтали.
		 * @param	aScaleY	 Трансформация по вертикали.
		 */
		public function applyScale(aScaleX:Number, aScaleY:Number = 1):void
		{
			_scaleX = aScaleX;
			_scaleY = aScaleY;
		}
		
		/**
		 * Сбрасывает все трансформации.
		 */
		public function resetTransform():void
		{
			_angle = 0;
			_scaleX = 1;
			_scaleY = 1;
		}
		
		/**
		 * Извлекает форму по индексу.
		 * 
		 * @param	aIndex	 Индекс модели в списке.
		 * @param	aClone	 Определяет необходимо получить копию модели или оригинал.
		 * @return		Возвращает null если формы с указанным индексом не существует.
		 */
		public function getShape(aIndex:int, aClone:Boolean = true):AntBox2DBasicShape
		{
			if (aIndex >= 0 && aIndex < _numShapes)
			{
				var newPos:AntPoint = new AntPoint();
				var basicShape:AntBox2DBasicShape = _shapeDefs[aIndex];
				if (basicShape is AntBox2DBoxShape)
				{
					var boxShape:AntBox2DBoxShape;
					boxShape = (aClone) ? (basicShape as AntBox2DBoxShape).copy() : basicShape as AntBox2DBoxShape;

					if (_angle != 0)
					{
						AntMath.rotateDeg(boxShape.x, boxShape.y, 0, 0, _angle, newPos);
						boxShape.x = newPos.x;
						boxShape.y = newPos.y;
						boxShape.angleDeg += _angle;
					}

					return boxShape;
				}
				else if (basicShape is AntBox2DCircleShape)
				{
					var circleShape:AntBox2DCircleShape;
					circleShape = (aClone) ? (basicShape as AntBox2DCircleShape).copy() : basicShape as AntBox2DCircleShape;

					if (_angle != 0)
					{
						AntMath.rotateDeg(circleShape.x, circleShape.y, 0, 0, _angle, newPos);
						circleShape.x = newPos.x;
						circleShape.y = newPos.y;
					}

					return circleShape;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает форму по имени.
		 * 
		 * @param	aShapeName	 Имя формы которую необходимо получить.
		 * @param	aClone	 Определяет необходимо ли получить копию модели или оригинал.
		 * @return		Возвращает null если формы с указанным именем не существует.
		 */
		public function getShapeByName(aShapeName:String, aClone:Boolean = true):AntBox2DBasicShape
		{	
			return getShape(_shapeNames.indexOf(aShapeName), aClone);
		}
		
		/**
		 * @private
		 */
		public function getAllShapes(aResult:Vector.<AntBox2DBasicShape> = null, aClone:Boolean = true):Vector.<AntBox2DBasicShape>
		{
			if (aResult == null)
			{
				aResult = new Vector.<AntBox2DBasicShape>();
			}
			
			var i:int = 0;
			while (i < _numShapes)
			{
				aResult.push(getShape(i++, aClone));
			}
			
			return aResult;
		}
		
		/**
		 * Извлекает соеденение по индексу в списке.
		 * 
		 * @param	aIndex	 Индекс соеденения в списке.
		 * @param	aClone	 Определяет необходимо ли получить копию соеденения или оригинал.
		 * @return		Возвращает null если джоинта не существует.
		 */
		public function getJoint(aIndex:int, aClone:Boolean = true):AntBox2DBasicJoint
		{
			if (aIndex >= 0 && aIndex < _numJoints)
			{
				var newPos:AntPoint = new AntPoint();
				var basicJoint:AntBox2DBasicJoint = _jointDefs[aIndex];
				if (basicJoint is AntBox2DRevoluteJoint)
				{
					var revoluteJoint:AntBox2DRevoluteJoint;
					revoluteJoint = (aClone) ? (basicJoint as AntBox2DRevoluteJoint).copy() : basicJoint as AntBox2DRevoluteJoint;

					if (_angle != 0)
					{
						AntMath.rotateDeg(revoluteJoint.x, revoluteJoint.y, 0, 0, _angle, newPos);
						revoluteJoint.x = newPos.x;
						revoluteJoint.y = newPos.y;
					}

					return revoluteJoint;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает соеденение по имени.
		 * 
		 * @param	aJointName	 Имя соеденения.
		 * @param	aClone	 Определяет необходимо ли получить копию соеденения или оригинал.
		 * @return		Возвращает null если джоинта с указанным именем не существует.
		 */
		public function getJointByName(aJointName:String, aClone:Boolean = true):AntBox2DBasicJoint
		{
			return getJoint(_jointNames.indexOf(aJointName), aClone);
		}
		
		/**
		 * Определяет количество форм в модели.
		 */
		public function get numShapes():int
		{
			return _numShapes;
		}
		
		/**
		 * Определяет количество соеденений в модели.
		 */
		public function get numJoints():int
		{
			return _numJoints;
		}
	
	}

}

