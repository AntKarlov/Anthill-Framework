package ru.antkarlov.anthill.plugins.box2d.models
{
	import flash.utils.getQualifiedClassName;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import ru.antkarlov.anthill.plugins.box2d.shapes.*;
	import ru.antkarlov.anthill.plugins.box2d.joints.*;

	public class AntModelManager extends Object
	{
		private var _shapeProperties:Vector.<String>;
		private var _jointProperties:Vector.<String>;
		
		private var _models:Vector.<AntModelData>;
		private var _numModels:int;
		
		private var _jointComponents:Vector.<Class>;
		private var _jointDefs:Vector.<Class>;
		private var _numJoints:int;
		
		private var _shapeComponents:Vector.<Class>;
		private var _shapeDefs:Vector.<Class>;
		private var _numShapes:int;
		
		/**
		 * @constructor
		 */
		public function AntModelManager()
		{
			super();
			
			_shapeProperties = new <String>[ "density", "friction", "restitution", "isSensor" ];
			_jointProperties = new <String>[ "lowerAngle", "upperAngle", "enableLimit", "motorSpeed", "maxMotorTorque", "enableMotor", "weakness" ];
			
			_models = new <AntModelData>[];
			_numModels = 0;
			
			_jointComponents = new <Class>[];
			_jointDefs = new <Class>[];
			_numJoints = 0;
			
			_shapeComponents = new <Class>[];
			_shapeDefs = new <Class>[];
			_numShapes = 0;
		}
		
		/**
		 * Регистрирует компонент для формы. Необходимо чтобы связывать компоненты в Flash IDE
		 * с определенными формами.
		 * 
		 * @param	aComponentClass	 Класс компонента который используется во Flash IDE.
		 * @param	aShapeClass	 Класс формы который используется в Anthill.
		 */
		public function registerShapeComponent(aComponentClass:Class, aShapeClass:Class):void
		{
			if (!isRegisteredShape(aComponentClass))
			{
				_shapeComponents[_numShapes] = aComponentClass;
				_shapeDefs[_numShapes++] = aShapeClass;
			}
		}
		
		/**
		 * Определяет был ли ранее зарегестрирован указанный компонент.
		 * 
		 * @param	aComponentClass	 Класс компонента который используется во Flash IDE.
		 * @return		Возвращает true если компонент был зарегистрирован ранее.
		 */
		public function isRegisteredShape(aComponentClass:Class):Boolean
		{
			var i:int = _shapeComponents.indexOf(aComponentClass);
			return (i >= 0 && i < _numShapes);
		}
		
		/**
		 * Регистрирует компонент для соеденения. Необходимо чтобы связывать компоненты в Flash IDE
		 * с определенными соеденениями.
		 * 
		 * @param	aComponentClass	 Класс компонента который используется во Flash IDE.
		 * @param	aJointClass	 Класс соеденения который используется в Anthill.
		 */
		public function registerJointComponent(aComponentClass:Class, aJointClass:Class):void
		{
			if (!isRegisteredJoint(aComponentClass))
			{
				_jointComponents[_numJoints] = aComponentClass;
				_jointDefs[_numJoints++] = aJointClass;
			}
		}
		
		/**
		 * Определяет был ли ранее зарегестрирован указанный компонент.
		 * 
		 * @param	aComponentClass	 Класс компонента который используется во Flash IDE.
		 * @return		Возвращает true если компонент был зарегистрирован ранее.
		 */
		public function isRegisteredJoint(aComponentClass:Class):Boolean
		{
			var i:int = _jointComponents.indexOf(aComponentClass);
			return (i >= 0 && i < _numJoints);
		}
		
		/**
		 * Создает модель состояющую из разных частей. Каждую часть тела должен представлять
		 * клип или компонент которые предварительно должны быть зарегистрированы в AntModelManager.
		 * 
		 * @param	aClip	 Класс клипа из содержимого которого необходимо создать модель.
		 * @param	aModelName	 Уникальное имя модели по которому потом к ней можно получить доступ.
		 */
		public function addModelFromClip(aClip:Class, aModelName:String = null):void
		{
			var clip:Sprite;
			var mc:MovieClip = new aClip();
			if (aModelName == null)
			{
				aModelName = getQualifiedClassName(aClip);
			}
			
			var model:AntModelData = new AntModelData(aModelName);
			
			var i:int = 0;
			const n:int = mc.numChildren;
			while (i < n)
			{
				clip = mc.getChildAt(i++) as Sprite;
				if (clip != null)
				{
					if (!makeShapeFromClip(model, clip))
					{
						makeJointFromClip(model, clip);
					}
				}
			}
			
			_models[_numModels++] = model;
		}
		
		/**
		 * Извлекает модель по имени.
		 * 
		 * @param	aModelName	 Имя модели которую необходимо получить.
		 * @return		Возвращает null если модели с указанным именем не существует.
		 */
		public function getModel(aModelName:String):AntModelData
		{
			var i:int = 0;
			var model:AntModelData;
			while (i < _numModels)
			{
				model = _models[i++];
				if (model.name == aModelName)
				{
					return model;
				}
			}
			
			return null;
		}
		
		/**
		 * Создает форму из указанного клипа.
		 * 
		 * @param	aModel	 Модель в которую будет добавлена созданная форма.
		 * @param	aClip	 Клип на основе которого будет создана форма.
		 * @return		Возвращает true если модель была успешно создана.
		 */
		private function makeShapeFromClip(aModel:AntModelData, aClip:Sprite):Boolean
		{
			var shapeClass:Class = getShapeClassForComponent(aClip);
			if (shapeClass != null)
			{
				var shape:AntBox2DBasicShape = new shapeClass();
				var shapeName:String = (aClip.hasOwnProperty("alias")) ? aClip["alias"] : "nonameShape";

				if (shape is AntBox2DBoxShape)
				{
					makeAsBox(shape as AntBox2DBoxShape, aClip);
				}
				else if (shape is AntBox2DCircleShape)
				{
					makeAsCircle(shape as AntBox2DCircleShape, aClip);
				}

				aModel.addShape(shape, shapeName);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Создает модель как коробку.
		 * 
		 * @param	aShape	 Форма для которой необходимо задать параметры коробки.
		 * @param	aClip	 Клип с которого будут взяты параметры коробки.
		 */
		private function makeAsBox(aShape:AntBox2DBoxShape, aClip:Sprite):void
		{
			aShape.angleDeg = aClip.rotation;
			aClip.rotation = 0;
			aShape.x = aClip.x;
			aShape.y = aClip.y;
			aShape.width = aClip.width;
			aShape.height = aClip.height;
			
			applyShapeProperties(aShape, aClip);
		}
		
		/**
		 * Создает модель как круг.
		 * 
		 * @param	aShape	 Форма для которой необходимо задать параметры круга.
		 * @param	sClip	 Клип с которого будут взяты параметры круга.
		 */
		private function makeAsCircle(aShape:AntBox2DCircleShape, aClip:Sprite):void
		{
			aShape.x = aClip.x;
			aShape.y = aClip.y;
			aShape.radius = (aClip.width >= aClip.height) ? aClip.width : aClip.height;
			aShape.radius *= 0.5;
			
			applyShapeProperties(aShape, aClip);
		}
		
		/**
		 * Применяет дополнительные параметры для формы.
		 * 
		 * @param	aShape	 Форма для которой необходимо применить дополнительные параметры.
		 * @param	aClip	 Колип с которого будут взяты дополнительные параметры.
		 */
		private function applyShapeProperties(aShape:AntBox2DBasicShape, aClip:Sprite):void
		{
			var i:int = 0;
			const n:int = _shapeProperties.length;
			var propertyName:String;
			while (i < n)
			{
				propertyName = _shapeProperties[i++];
				if (aClip.hasOwnProperty(propertyName))
				{
					aShape[propertyName] = aClip[propertyName];
				}
			}
		}
		
		/**
		 * Ищет и возращает класс формы подходящий для указанного клипа.
		 * 
		 * @param	aClip	 Клип для которого необходимо получить ранее зарегистрированную форму.
		 * @return		Вернет null если подходящая форма для клипа не будет найдена.
		 */
		private function getShapeClassForComponent(aClip:Sprite):Class
		{
			for (var i:int = 0; i < _numShapes; i++)
			{
				if (aClip is _shapeComponents[i])
				{
					return _shapeDefs[i];
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		private function makeJointFromClip(aModel:AntModelData, aClip:Sprite):Boolean
		{
			var jointClass:Class = getJointClassForComponent(aClip);
			if (jointClass != null)
			{
				var joint:AntBox2DBasicJoint = new jointClass();
				var jointName:String = (aClip.hasOwnProperty("alias")) ? aClip["alias"] : "nonameJoint";
				
				if (joint is AntBox2DRevoluteJoint)
				{
					makeAsRevoluteJoint(joint as AntBox2DRevoluteJoint, aClip);
				}
				
				aModel.addJoint(joint, jointName);
				return true;
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		private function makeAsRevoluteJoint(aJoint:AntBox2DRevoluteJoint, aClip:Sprite):void
		{
			aJoint.x = aClip.x;
			aJoint.y = aClip.y;

			applyJointProperties(aJoint, aClip);
		}
		
		/**
		 * @private
		 */
		public function applyJointProperties(aJoint:AntBox2DBasicJoint, aClip:Sprite):void
		{
			var i:int = 0;
			const n:int = _jointProperties.length;
			var propertyName:String;
			while (i < n)
			{
				propertyName = _jointProperties[i++];
				if (aClip.hasOwnProperty(propertyName))
				{
					aJoint[propertyName] = aClip[propertyName];
					//trace("AntModelManager::applyJointProperties()", propertyName, aClip[propertyName]);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function getJointClassForComponent(aClip:Sprite):Class
		{
			for (var i:int = 0; i < _numJoints; i++)
			{
				if (aClip is _jointComponents[i])
				{
					return _jointDefs[i];
				}
			}
			
			return null;
		}
		
		
		
	}

}