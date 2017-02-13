package ru.antkarlov.anthill.plugins.box2d
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.signals.AntSignal;
	import ru.antkarlov.anthill.plugins.box2d.shapes.*;
	import ru.antkarlov.anthill.plugins.box2d.joints.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.Joints.*;
	
	public class AntBox2DBody extends AntActor
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const STATIC:String = "static";
		public static const KINEMATIC:String = "kinematic";
		public static const DYNAMIC:String = "dynamic";
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на оригинальное тело Box2D.
		 * @default    null
		 */
		public var box2dBody:b2Body;
		
		/**
		 * Указатель на физический менеджер.
		 * @default    null
		 */
		public var manager:AntBox2DManager;
		
		public var eventPreSolveContact:AntSignal;
		public var eventBeginContact:AntSignal;
		public var eventEndContact:AntSignal;
		public var eventPostSolveContact:AntSignal;
		public var eventJointBreaks:AntSignal;
		public var eventExplode:AntSignal;
		
		public var allowPreSolveContacts:Boolean;
		public var allowPostSolveContacts:Boolean;
		public var allowBeginContacts:Boolean;
		public var allowEndContacts:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Тип тела: STATIC, KINEMATIC, DYNAMIC.
		 * @default    STATIC
		 */
		protected var _kind:String;
		
		/**
		 * Оригинальные настройки тела для Box2D.
		 * @default    b2BodyDef
		 */
		protected var _box2dBodyDef:b2BodyDef;
		
		/**
		 * Помошник для определения скорости тела.
		 * @default    b2Vec2
		 */
		protected var _box2dVelocity:b2Vec2;
		
		/**
		 * Помошник для определения позиции тела.
		 * @default    b2Vec2
		 */
		protected var _box2dPosition:b2Vec2;
		
		/**
		 * Определяет флаг тела для фильтрации столкновений.
		 * @default    null
		 */
		protected var _collisionFlag:AntBox2DFlag;
		
		/**
		 * Список влагов других тел с которыми данное тело должно сталкиваться.
		 * @default    null
		 */
		protected var _collidesWithFlags:AntBox2DFlag;
		
		/**
		 * Определяет группу в которую входит тело. Используется для фильтрации столкновений.
		 * @default    0
		 */
		protected var _groupIndex:int;
		
		/**
		 * Список форм.
		 * @default    Vector.<AntBox2DBasicShape>
		 */
		protected var _shapes:Vector.<AntBox2DBasicShape>;
		
		/**
		 * Определяет может ли тело двигаться.
		 * @default    true
		 */
		protected var _canMove:Boolean;
		
		/**
		 * Определяет может ли тело вращатся.
		 * @default    true
		 */
		protected var _canRotate:Boolean;
		
		/**
		 * Определяет может ли тело "засыпать".
		 * @default    true
		 */
		protected var _canSleep:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DBody()
		{
			super();
			
			_kind = STATIC;
			_box2dBodyDef = new b2BodyDef();
			_box2dBodyDef.userData = this;
			
			_box2dVelocity = new b2Vec2();
			_box2dPosition = new b2Vec2();
			
			_collisionFlag = null;
			_collidesWithFlags = null;
			_groupIndex = 0;
			
			_shapes = new Vector.<AntBox2DBasicShape>();
			
			_canMove = true;
			_canRotate = true;
			_canSleep = true;
			
			eventPreSolveContact = new AntSignal(AntBox2DBody, AntBox2DContact);
			eventBeginContact = new AntSignal(AntBox2DBody, AntBox2DContact);
			eventEndContact = new AntSignal(AntBox2DBody, AntBox2DContact);
			eventPostSolveContact = new AntSignal(AntBox2DBody, AntBox2DContact);
			eventJointBreaks = new AntSignal(AntBox2DBody, AntBox2DBasicJoint);
			eventExplode = new AntSignal(AntBox2DBody, AntBox2DBody, AntPoint, AntPoint, Number);
			
			allowPreSolveContacts = false;
			allowPostSolveContacts = false;
			allowBeginContacts = true;
			allowEndContacts = true;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Создает физическое тело.
		 * 
		 * @param	aManager	 Указатель на менеджер физического мира. Если менеджер не указан
		 * то будет произведена попытка поиска менеджера среди активных и не активных плагинов.
		 */
		public function create(aManager:AntBox2DManager = null):void
		{
			if (aManager == null)
			{
				var plg:Array = AntG.plugins.get(AntBox2DManager);
				if (plg.length >= 1)
				{
					aManager = plg[0] as AntBox2DManager;
				}
				
				if (aManager == null)
				{
					AntG.log("Warning: Can't create AntBox2DBody because AntBox2DManager not exists!", "error");
					return;
				}
			}
			
			manager = aManager;
			
			_box2dBodyDef.angle = angle * (Math.PI / 180);
			_box2dBodyDef.position.Set(x / manager.scale, y / manager.scale);
			
			switch (_kind)
			{
				case DYNAMIC : _box2dBodyDef.type = b2Body.b2_dynamicBody; break;
				case KINEMATIC : _box2dBodyDef.type = b2Body.b2_kinematicBody; break;
				default : _box2dBodyDef.type = b2Body.b2_staticBody; break;
			}
			
			box2dBody = manager.addBody(_box2dBodyDef);
			buildShapes();
			
			revive();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function kill():void
		{
			if (box2dBody != null)
			{
				manager.removeBody(box2dBody);
			}
			
			velocity.x = 0;
			velocity.y = 0;
			angularVelocity = 0;
			super.kill();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			updateBody();
			super.update();
		}
		
		/**
		 * Вызывается автоматически во время происхождения и существования контактов
		 * с другими телами, ДО того как они будут решены.
		 * 
		 * @param	aContact	 Информация о контакте.
		 */
		public function preSolveContact(aContact:AntBox2DContact):void
		{
			/*
				Перекройте этот метод в потомке этого класса чтобы получать
				информацию о контактах прежде чем они будут решены физическим миром. 
				
				Примечание: Если вы хотите сохранить информацию о контакте, то не сохраняйте
				указатель на aContact, так как информация в нем будет обнулена сразу же 
				после вызова этого метода. Скопируйте данные контакта чтобы их сохранить.
				
				Внимание: По умолчанию вызов этого метода отключен. Чтобы включить вызов
				этого метода классом AntBox2DContactListener, установите флаг тела 
				allowPreSolveContact равным TRUE.
			*/
			
			eventPreSolveContact.dispatch(this, aContact);
		}
		
		/**
		 * Вызывается автоматически во время происхождения контакта с другим телом.
		 * 
		 * @param	aContact	 Информация о контакте.
		 */
		public function beginContact(aContact:AntBox2DContact):void
		{
			/*
				Перекройте этот метод в потомке этого класса чтобы получать
				информацию о контактах когда они возникают.
				
				Примечание: Если вы хотите сохранить информацию о контакте, то не сохраняйте
				указатель на aContact, так как информация в нем будет обнулена сразу же 
				после вызова этого метода. Скопируйте данные контакта чтобы их сохранить.
			*/
				
			eventBeginContact.dispatch(this, aContact);
		}
		
		/**
		 * Вызывается автоматически во время исчезновения контакта с другим телом.
		 */
		public function endContact(aContact:AntBox2DContact):void
		{
			/*
				Перекройте этот метод в потомке этого класса чтобы получать
				информацию о контактах когда они исчезают.
				
				Примечание: Если вы хотите сохранить информацию о контакте, то не сохраняйте
				указатель на aContact, так как информация в нем будет обнулена сразу же 
				после вызова этого метода. Скопируйте данные контакта чтобы их сохранить.
			*/
				
			eventEndContact.dispatch(this, aContact);
		}
		
		/**
		 * Вызывается автоматически во время происхождения и существования контактов
		 * с другими телами, ПОСЛЕ того как они будут решены.
		 * 
		 * <p>Внимание: Только в этом методе вы можете узнать информацию об импульсе
		 * контакта.</p>
		 * 
		 * @param	aContact	 Информация о контакте.
		 */
		public function postSolveContact(aContact:AntBox2DContact):void
		{
			/*
				Перекройте этот метод в потомке этого класса чтобы получать
				информацию о контактах после того как были решены физическим миром.
				
				Примечание: Если вы хотите сохранить информацию о контакте, то не сохраняйте
				указатель на aContact, так как информация в нем будет обнулена сразу же 
				после вызова этого метода. Скопируйте данные контакта чтобы их сохранить.
				
				Внимание: По умолчанию вызов этого метода отключен. Чтобы включить вызов
				этого метода классом AntBox2DContactListener, установите флаг тела 
				allowPostSolveContact равным TRUE.
			*/
			
			eventPostSolveContact.dispatch(this, aContact);
		}
		
		/**
		 * Вызывается когда соеденение разрывается методом breakJoint().
		 * 
		 * @param	aJoint	 Указатель на соеденение которое рвется.
		 */
		public function jointBreaks(aJoint:AntBox2DBasicJoint):void
		{
			/*
				Перекройте этот метод в потомке этого класса чтобы получать
				информацию о рвущихся соеденениях от перегрузки или ручном разрыве.
			*/
			
			eventJointBreaks.dispatch(this, aJoint);
		}
		
		/**
		 * Вызывается когда объект попадает в поле взрыва.
		 * 
		 * @param	aSource	 Тело которое является источником взрыва.
		 * @param	aForce	 Сила импульса от взрывной волны.
		 * @param	aPoint	 Точка в которую получен импульс от взрывной волны.
		 */
		public function explode(aSource:AntBox2DBody, aForce:AntPoint, aPoint:AntPoint, aDamage:Number = 0):void
		{
			/*
				Перекройте этот метод в потомке класса чтобы получать информацию
				о полученном уроне в момент взрыва других объектов.
			*/
			
			applyImpulse(aForce.x, aForce.y, aPoint.x, aPoint.y);
			eventExplode.dispatch(this, aSource, aForce, aPoint, aDamage);
		}
		
		/**
		 * Строит фигуру физического тела на основе вложенных форм.
		 */
		public function buildShapes():void
		{
			if (box2dBody != null)
			{
				var fixture:b2Fixture = box2dBody.GetFixtureList();
				var next:b2Fixture;
				while (fixture)
				{
					next = fixture.GetNext();
					box2dBody.DestroyFixture(fixture);
					fixture = next;
				}
				
				if (_shapes != null)
				{
					var shape:AntBox2DBasicShape;
					const n:int = _shapes.length;
					var i:int = 0;
					while (i < n)
					{
						shape = _shapes[i++];
						if (shape != null)
						{
							box2dBody.CreateFixture(shape.getFixtureDef(this));
						}
					}
				}
				
				updateMass();
			}
		}
		
		/**
		 * Обновляет массу тела с учетом заданных параметров.
		 */
		protected function updateMass():void
		{
			if (box2dBody != null)
			{
				if (_canMove)
				{
					box2dBody.ResetMassData();
				}
				
				if (!_canMove || !_canRotate)
				{
					var mass:b2MassData = new b2MassData();
					mass.center = box2dBody.GetLocalCenter();
					mass.mass = (_canMove) ? box2dBody.GetMass() : 0;
					mass.I = (_canRotate) ? box2dBody.GetInertia() : 0;
					box2dBody.SetMassData(mass);
				}
			}
		}
		
		/**
		 * Применяет флаг идентифицирующий тело для фильтрации столкновений.
		 * 
		 * <p>Если какое-либо другое тело будет иметь в списке collidesFlags флаг
		 * равный указанному флагу, то эти тела будут сталкиваться друг с другом.</p>
		 * 
		 * @param	aFlag	 Флаг индентифицирующий тело для фильтрации столкновений.
		 */
		public function applyCollisionFlag(aFlag:String):void
		{
			_collisionFlag = new AntBox2DFlag(aFlag);
			buildShapes();
		}
		
		/**
		 * Применяет флаги определяющие с какими телами будет сталкиваться данное тело.
		 * 
		 * <p>Если какое-либо другое тело будет иметь collisionFlag равный одному из 
		 * перечисленных флагов, то текущее тело будет с ним сталкиваться.</p>
		 * 
		 * @param	aArgs	 Список флагов.
		 */
		public function applyCollidesFlags(...aArgs):void
		{
			var arr:Array = (aArgs.length == 1 && aArgs[0] is Array) ? aArgs[0] : aArgs;
			_collidesWithFlags = new AntBox2DFlag(arr);
			buildShapes();
		}
		
		/**
		 * Применяет к телу сразу несколько форм.
		 * 
		 * @param	aShapes	 Список форм которые необходимо применить к телу.
		 */
		public function applyShapes(...aArgs):void
		{
			var aShapes:Array = (aArgs.length == 1 && aArgs[0] is Array) ? aArgs[0] : aArgs;
			
			var n:int = 0;
			var i:int = 0;
			var shape:AntBox2DBasicShape;
			
			if (_shapes == null)
			{
				_shapes = new Vector.<AntBox2DBasicShape>();
			}
			else
			{
				n = _shapes.length;
				while (i < n)
				{
					shape = _shapes[i];
					if (shape != null)
					{
						shape.destroy();
					}
					
					_shapes[i] = null;
					i++;
				}
			}
			
			_shapes.length = 0;
			n = aShapes.length;
			i = 0;
			while (i < n)
			{
				shape = aShapes[i++] as AntBox2DBasicShape;
				if (shape != null)
				{
					_shapes.push(shape);
				}
			}
			
			buildShapes();
		}
		
		/**
		 * Будит или усыпляет тело.
		 * 
		 * @param	aValue	 Значение определяющее пробудить тело или усыпить.
		 */
		public function applyAwake(aValue:Boolean):void
		{
			if (box2dBody != null)
			{
				box2dBody.SetAwake(aValue);
			}
		}
		
		/**
		 * Применяет импульс к указанной точки тела.
		 * 
		 * @param	aImpulseX	 Горизонтальный импульс kg-m/s.
		 * @param	aImpulseY	 Вертикальный импульс kg-m/s.
		 * @param	aPointX	 Глобальная точка по X к которой будет применен импульс.
		 * @param	aPointY	 Глобальная точка по Y к которой будет применем импульс.
		 */
		public function applyImpulse(aImpulseX:Number, aImpulseY:Number, aPointX:Number = 0, aPointY:Number = 0):void
		{
			if (box2dBody != null)
			{
				var hitPoint:b2Vec2;
				var hitForce:b2Vec2 = new b2Vec2(aImpulseX, aImpulseY);
				
				if (aPointX == 0 && aPointY == 0)
				{
					hitPoint = box2dBody.GetWorldCenter();
				}
				else
				{
					hitPoint = new b2Vec2(aPointX / manager.scale, aPointY / manager.scale);
				}
				
				box2dBody.ApplyImpulse(hitForce, hitPoint);
			}
		}
		
		/**
		 * Применяет силу к телу в указанную точку.
		 * 
		 * @param	aForceX	 Горизонтальная сила в ньютонах.
		 * @param	aForceY	 Вертикальная сила в ньютонах.
		 * @param	aPointX	 Глобальная точка по X к которой будет применена скорость.
		 * @param	aPointY	 Глобальная точка по Y к которой будет применема скорость.
		 */
		public function applyForce(aForceX:Number, aForceY:Number, aPointX:Number = 0, aPointY:Number = 0):void
		{
			if (box2dBody != null)
			{
				var hitPoint:b2Vec2;
				var hitForce:b2Vec2 = new b2Vec2(aForceX, aForceY);
				
				if (aPointX == 0 && aPointY == 0)
				{
					hitPoint = box2dBody.GetWorldCenter();
				}
				else
				{
					hitPoint = new b2Vec2(aPointX / manager.scale, aPointY / manager.scale);
				}
				
				box2dBody.ApplyForce(hitForce, hitPoint);
			}
		}
		
		/**
		 * Примеяет силу вращения.
		 * 
		 * @param	aTorque	 Сила вращения.
		 */
		public function applyTorque(aTorque:Number):void
		{
			if (box2dBody != null)
			{
				box2dBody.ApplyTorque(aTorque);
			}
		}
		
		/**
		 * Применяет скорость вращения в радианах в секунду.
		 * 
		 * @param	aAngularVelocity	 Скорость вращения.
		 */
		public function applyAngularVelocity(aAngularVelocity:Number):void
		{
			if (box2dBody != null)
			{
				box2dBody.SetAngularVelocity(aAngularVelocity);
			}
		}
		
		/**
		 * Применяет векторную скорость к физическому телу.
		 * 
		 * @param	aX	 Горизонтальная скорость.
		 * @param	aY	 Вертикальная скорость.
		 */
		public function applyVelocity(aX:Number, aY:Number):void
		{
			velocity.x = aX;
			velocity.y = aY;
			
			if (box2dBody != null)
			{
				_box2dVelocity.Set(aX, aY);
				box2dBody.SetLinearVelocity(_box2dVelocity);
			}
		}
		
		/**
		 * Применяет горизонтальную скорость к физическому телу.
		 * 
		 * @param	aValue	 Новое значение горизонтальной скорости.
		 */
		public function applyVelocityX(aValue:Number):void
		{
			if (box2dBody != null)
			{
				_box2dVelocity = box2dBody.GetLinearVelocity();
				_box2dVelocity.x = velocity.x = aValue;
				box2dBody.SetLinearVelocity(_box2dVelocity);
			}
		}
		
		/**
		 * Применяет вертикальную скорость к физическому телу.
		 * 
		 * @param	aValue	 Новое значение вертикальной скорости.
		 */
		public function applyVelocityY(aValue:Number):void
		{
			if (box2dBody != null)
			{
				_box2dVelocity = box2dBody.GetLinearVelocity();
				_box2dVelocity.y = velocity.y = aValue;
				box2dBody.SetLinearVelocity(_box2dVelocity);
			}
		}
		
		/**
		 * Устанавливает новую позицию для тела.
		 * 
		 * @param	aX	 Новое положение по X.
		 * @param	aY	 Новое положение по Y.
		 */
		public function applyPosition(aX:Number, aY:Number):void
		{
			x = aX;
			y = aY;
			
			if (box2dBody != null)
			{
				_box2dPosition.x = aX / manager.scale;
				_box2dPosition.y = aY / manager.scale;
				box2dBody.SetPosition(_box2dPosition);
			}
		}
		
		/**
		 * @private
		 */
		public function applyAngle(aAngle:Number):void
		{
			angle = aAngle;
			
			if (box2dBody != null)
			{
				box2dBody.SetAngle(AntMath.toRadians(aAngle));
			}
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Синхронизирует физическое тело и его визуальный образ.
		 */
		protected function updateBody():void
		{
			if (box2dBody != null)
			{
				_box2dPosition = box2dBody.GetPosition();
				x = _box2dPosition.x * manager.scale;
				y = _box2dPosition.y * manager.scale;
				
				_box2dVelocity = box2dBody.GetLinearVelocity();
				velocity.x = _box2dVelocity.x;
				velocity.y = _box2dVelocity.y;
				
				angularVelocity = box2dBody.GetAngularVelocity();
				
				if (_canRotate)
				{
					angle = box2dBody.GetAngle() / Math.PI * 180 % 360;
				}
			}
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет может ли тело двигаться.
		 */
		public function get canMove():Boolean { return _canMove; }
		public function set canMove(value:Boolean):void
		{
			if (_canMove != value)
			{
				_canMove = value;
				updateMass();
			}
		}
		
		/**
		 * Определяет может ли тело вращатся.
		 */
		public function get canRotate():Boolean { return _canRotate; }
		public function set canRotate(value:Boolean):void
		{
			if (_canRotate != value)
			{
				_canRotate = value;
				updateMass();
			}
		}
		
		/**
		 * Определяет может ли тело "засыпать".
		 */
		public function get canSleep():Boolean { return _canSleep; }
		public function set canSleep(value:Boolean):void
		{
			if (_canSleep != value)
			{
				_canSleep = value;
				_box2dBodyDef.allowSleep = value;
				
				if (box2dBody != null)
				{
					box2dBody.SetSleepingAllowed(value);
				}
			}
		}
		
		/**
		 * Определяет является ли тело быстро движущимся объектом.
		 */
		public function get isBullet():Boolean { return _box2dBodyDef.bullet; }
		public function set isBullet(value:Boolean):void 
		{
			if (_box2dBodyDef.bullet != value)
			{
				_box2dBodyDef.bullet = value;
				if (box2dBody != null)
				{
					box2dBody.SetBullet(value);
				}
			}
		}
		
		/**
		 * Определяет произвольное количество форм для тела.
		 */
		public function get shapes():Vector.<AntBox2DBasicShape> { return _shapes; }
		public function set shapes(value:Vector.<AntBox2DBasicShape>):void
		{
			_shapes = value;
			buildShapes();
		}
		
		/**
		 * Определяет флаг столкновения для тела.
		 */
		public function get collisionFlag():AntBox2DFlag { return _collisionFlag; }
		public function set collisionFlag(value:AntBox2DFlag):void
		{
			_collisionFlag = value;
			buildShapes();
		}
		
		/**
		 * Определяет флаги других тел с которыми текущее тело должно сталкиваться.
		 */
		public function get collidesWithFlags():AntBox2DFlag { return _collidesWithFlags; }
		public function set collidesWithFlags(value:AntBox2DFlag):void
		{
			_collidesWithFlags = value;
			buildShapes();
		}
		
		/**
		 * Определяет группу тела, используется для фильтрации столкновений.
		 */
		public function get groupIndex():int { return _groupIndex; }
		public function set groupIndex(value:int):void
		{
			if (_groupIndex != value)
			{
				_groupIndex = value;
				buildShapes();
			}
		}
		
		/**
		 * Определяет тип тела.
		 */
		public function get kind():String { return _kind; }
		public function set kind(value:String):void
		{
			if (_kind != value)
			{
				_kind = value;
				buildShapes();
			}
		}
		
		/**
		 * @private
		 */
		public function get objectMask():AntBox2DFlag
		{
			return _collidesWithFlags;
		}

	}

}