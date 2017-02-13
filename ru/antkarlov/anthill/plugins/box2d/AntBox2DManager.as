package ru.antkarlov.anthill.plugins.box2d
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.plugins.*;
	import ru.antkarlov.anthill.signals.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.Joints.*;
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  25.09.2013
	 */
	public class AntBox2DManager extends Object implements IPlugin
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на физический мир.
		 * @default    null
		 */
		public var box2dWorld:b2World;
		
		/**
		 * Количество итераций для рассчета скоростей физического мира.
		 * @default    6
		 */
		public var velocityIterations:int;
		
		/**
		 * Количество итераций для рассчета позиций физического мира.
		 * @default    2
		 */
		public var positionIterations:int;
		
		/**
		 * Временной интервал для физический рассчетов.
		 * Используйте шаг 1.0 / 65.0 для 60fps.
		 * Используйте шаг 1.0 / 40.0 для 35fps.
		 * @default    0.025
		 */
		public var step:Number;
		
		/**
		 * Масштаб физического мира.
		 * @default    30
		 */
		public var scale:Number;
		
		/**
		 * @private
		 */
		public var eventBodyAdded:AntSignal;
		
		/**
		 * @private
		 */
		public var pause:Boolean;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		protected var _tag:String;
		protected var _priority:int;
		protected var _allowSleep:Boolean;
		protected var _gravity:b2Vec2;
		protected var _tm:AntTaskManager;
		protected var _debugDrawer:AntBox2DDrawer;
		protected var _isStopped:Boolean;
		
		/**
		 * Помошники для извлечения тел из физического мира по запросу.
		 */
		protected var _hitTestVec:b2Vec2;
		protected var _hitTestBody:b2Body;
		protected var _hitTestIncludeStatic:Boolean;
		protected var _hitTestCallbackFunc:Function;
		
		protected var _rayCastCallbackFunc:Function;
		
		/**
		 * Помошники для реализации взрыва.
		 */
		protected var _explosionPoint:b2Vec2;
		protected var _explosionForce:Number;
		protected var _explosionDamage:Number;
		protected var _explosionSource:b2Body;
		protected var _explosionRadius:Number;
		
		protected var _contactListener:b2ContactListener;
		protected var _contactFilter:b2ContactFilter;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DManager()
		{
			super();
			
			box2dWorld = null;
			velocityIterations = 6;
			positionIterations = 15;
			step = 1 / 40.0;
			scale = 30;
			
			eventBodyAdded = new AntSignal(b2Body);
			pause = false;
			
			_tag = null;
			_priority = 0;
			_gravity = new b2Vec2(0, 9.81);
			_tm = new AntTaskManager();
			_debugDrawer = null;
			_isStopped = true;
			_hitTestVec = new b2Vec2();
		}
		
		/**
		 * @private
		 */
		public function destroy():void
		{
			/*
				TODO 
			*/
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function create(aStart:Boolean = true, aContactListener:b2ContactListener = null,
			aContactFilter:b2ContactFilter = null):void
		{
			box2dWorld = new b2World(_gravity, _allowSleep);
			
			_contactListener = (aContactListener == null) ? new AntBox2DContactListener() : aContactListener;
			_contactFilter = (aContactFilter == null) ? new AntBox2DContactFilter() : aContactFilter;
			
			box2dWorld.SetContactListener(_contactListener);
			box2dWorld.SetContactFilter(_contactFilter);
			
			if (aStart)
			{
				start();
			}
		}
		
		/**
		 * @private
		 */
		public function kill():void
		{
			if (box2dWorld != null)
			{
				enableDebugDraw = false;
				box2dWorld.SetContactListener(null);
				box2dWorld.SetContactFilter(null);
				box2dWorld = null;
			}
		}
		
		/**
		 * @private
		 */
		public function revive():void
		{
			box2dWorld = new b2World(_gravity, _allowSleep);
			box2dWorld.SetContactListener(_contactListener);
			box2dWorld.SetContactFilter(_contactFilter);
		}
		
		/**
		 * @private
		 */
		public function start():void
		{
			if (_isStopped)
			{
				AntG.plugins.add(this);
				_isStopped = false;
			}
		}
		
		/**
		 * @private
		 */
		public function stop():void
		{
			if (!_isStopped)
			{
				AntG.plugins.remove(this);
				_isStopped = true;
			}
		}
		
		/**
		 * Создает физическое тело.
		 * 
		 * @param	aBodyDef	 Параметры физического тела.
		 * @return		Возвращает указатель на созданное физическое тело. Если тело не удалось создать, то вернет null.
		 */
		public function addBody(aBodyDef:b2BodyDef):b2Body
		{
			if (box2dWorld == null)
			{
				AntG.log("Warning: Can't to make the Box2D body. The Box2D world is not initialized.", "error");
				return null;
			}
			
			if (!box2dWorld.IsLocked())
			{
				return box2dWorld.CreateBody(aBodyDef) as b2Body;
			}
			else
			{
				_tm.addInstantTask(addBody, [ aBodyDef ]);
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		public function removeBody(aBody:b2Body):void
		{
			if (box2dWorld == null)
			{
				AntG.log("Warning: Can't to remove the Box2D body. The Box2D world is not initialized.", "error");
				return;
			}
			
			if (!box2dWorld.IsLocked())
			{
				var b:AntBox2DBody = aBody.GetUserData() as AntBox2DBody;
				if (b != null)
				{
					b.box2dBody = null;
				}
				
				aBody.SetUserData(null);
				box2dWorld.DestroyBody(aBody);
			}
			else
			{
				_tm.addInstantTask(removeBody, [ aBody ]);
			}
		}
		
		/**
		 * @private
		 */
		public function queryRect(aX1:Number, aY1:Number, aX2:Number, aY2:Number, aCallbackFunc:Function, aIncludeStatic:Boolean = false):void
		{
			_hitTestIncludeStatic = aIncludeStatic;
			_hitTestCallbackFunc = aCallbackFunc;
			
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(aX1 / scale, aY1 / scale);
			aabb.upperBound.Set(aX2 / scale, aY2 / scale);
			box2dWorld.QueryAABB(queryCallback, aabb);
		}
		
		/**
		 * @private
		 */
		public function queryCircle(aX:Number, aY:Number, aRadius:Number, aCallbackFunc:Function, aIncludeStatic:Boolean = false):void
		{
			aRadius /= scale;
			_hitTestVec.Set(aX / scale, aY / scale);
			_hitTestIncludeStatic = aIncludeStatic;
			_hitTestCallbackFunc = aCallbackFunc;
			
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(_hitTestVec.x - aRadius, _hitTestVec.y - aRadius);
			aabb.upperBound.Set(_hitTestVec.x + aRadius, _hitTestVec.y + aRadius);
			box2dWorld.QueryAABB(queryCallback, aabb);
		}
		
		/**
		 * @private
		 */
		protected function queryCallback(aFixture:b2Fixture):Boolean
		{
			var body:b2Body = aFixture.GetBody();
			var shape:b2Shape = aFixture.GetShape();
			if (body.GetType() != b2Body.b2_staticBody || _hitTestIncludeStatic)
			{
				if (_hitTestCallbackFunc != null)
				{
					_hitTestCallbackFunc.apply(this, [ body.GetUserData() as AntBox2DBody ]);
				}
			}

			return true;
		}
		
		/**
		 * @private
		 */
		public function getBodyByPosition(aX:Number, aY:Number, aIncludeStatic:Boolean = false):AntBox2DBody
		{
			var body:b2Body = getBox2DBodyByPosition(aX, aY, aIncludeStatic) as b2Body;
			if (body != null)
			{
				return body.GetUserData() as AntBox2DBody;
			}
			
			return null;
		}
		
		/**
		 * @private
		 */
		public function getBox2DBodyByPosition(aX:Number, aY:Number, aIncludeStatic:Boolean = false):b2Body
		{
			_hitTestVec.Set(aX / scale, aY / scale);
			_hitTestIncludeStatic = aIncludeStatic;
			_hitTestBody = null;
			
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(_hitTestVec.x - 0.001, _hitTestVec.y - 0.001);
			aabb.upperBound.Set(_hitTestVec.x + 0.001, _hitTestVec.y + 0.001);
			box2dWorld.QueryAABB(getBodyCallback, aabb);
			
			return _hitTestBody;
		}
		
		/**
		 * @private
		 */
		protected function getBodyCallback(aFixture:b2Fixture):Boolean
		{
			var body:b2Body = aFixture.GetBody();
			var shape:b2Shape = aFixture.GetShape();
			if (body.GetType() != b2Body.b2_staticBody || _hitTestIncludeStatic)
			{
				if (shape.TestPoint(body.GetTransform(), _hitTestVec))
				{
					_hitTestBody = aFixture.GetBody();
					return false;
				}
			}
			
			return true;
		}
		
		/**
		 * @private
		 */
		public function rayCastOne(aPointA:AntPoint, aPointB:AntPoint):AntBox2DBody
		{
			var fixture:b2Fixture = box2dWorld.RayCastOne(new b2Vec2(aPointA.x / scale, aPointA.y / scale), new b2Vec2(aPointB.x / scale, aPointB.y / scale));
			return (fixture != null) ? fixture.GetUserData() as AntBox2DBody : null;
		}
		
		/**
		 * @private
		 */
		public function rayCast(aCallBack:Function, aPointA:AntPoint, aPointB:AntPoint):void
		{
			_rayCastCallbackFunc = aCallBack;
			box2dWorld.RayCast(rayCastCallback, new b2Vec2(aPointA.x / scale, aPointA.y / scale), new b2Vec2(aPointB.x / scale, aPointB.y / scale));
		}
		
		/**
		 * @private
		 */
		private function rayCastCallback(aFixture:b2Fixture, aPoint:b2Vec2, aNormal:b2Vec2, aFraction:Number):Number
		{
			var body:b2Body = aFixture.GetBody();
			if (body.GetUserData() is AntBox2DBody && _rayCastCallbackFunc != null)
			{
				_rayCastCallbackFunc.apply(this, [ body.GetUserData() as AntBox2DBody ]);
			}
			return aFraction;
		}
		
		/**
		 * @private
		 */
		public function explosionFromBody(aSource:AntBox2DBody, aRadius:Number, aForce:Number, aDamage:Number = 0, 
			aIncludeStatic:Boolean = false):void
		{
			_hitTestIncludeStatic = aIncludeStatic;
			_explosionSource = aSource.box2dBody;
			if (_explosionSource != null)
			{
				_explosionPoint = _explosionSource.GetPosition();
				_explosionForce = aForce;
				_explosionDamage = aDamage;
				_explosionRadius = aRadius;

				aRadius /= scale;
				var pos:b2Vec2 = _explosionSource.GetPosition();
				var aabb:b2AABB = new b2AABB();
				aabb.lowerBound.Set(pos.x - aRadius, pos.y - aRadius);
				aabb.upperBound.Set(pos.x + aRadius, pos.y + aRadius);
				box2dWorld.QueryAABB(explosionCallback, aabb);
			}
		}
		
		/**
		 * @private
		 */
		protected function explosionCallback(aFixture:b2Fixture):Boolean
		{
			var body:b2Body = aFixture.GetBody();
			var shape:b2Shape = aFixture.GetShape();
			
			var force:b2Vec2 = new b2Vec2();
			
			if (body.GetType() != b2Body.b2_staticBody || _hitTestIncludeStatic)
			{
				var distIn:b2DistanceInput = new b2DistanceInput();
				distIn.transformA = _explosionSource.GetTransform();
				distIn.transformB = body.GetTransform();

				var proxyA:b2DistanceProxy = new b2DistanceProxy();
				proxyA.Set(_explosionSource.GetFixtureList().GetShape());
				distIn.proxyA = proxyA;
				
				var proxyB:b2DistanceProxy = new b2DistanceProxy();
				proxyB.Set(shape);
				distIn.proxyB = proxyB;

				distIn.useRadii = true;
				var distOut:b2DistanceOutput = new b2DistanceOutput();
				var cache:b2SimplexCache = new b2SimplexCache();
				cache.count = 0;

				b2Distance.Distance(distOut, cache, distIn);

				distOut.distance = (distOut.distance <= 1 && distOut.distance >= 0) ? 1 : distOut.distance;
				force.x = (body.GetPosition().x < _explosionSource.GetPosition().x) ? -_explosionForce / distOut.distance : _explosionForce / distOut.distance;
				force.y = (body.GetPosition().y < _explosionSource.GetPosition().y) ? -_explosionForce / distOut.distance : _explosionForce / distOut.distance;
				//force.x = (distOut.pointA.x < distOut.pointB.x) ? _explosionForce / distOut.distance : -_explosionForce / distOut.distance;
				//force.y = (distOut.pointA.y < distOut.pointB.y) ? _explosionForce / distOut.distance : -_explosionForce / distOut.distance;
				
				if (body.GetUserData() is AntBox2DBody)
				{
					var f:AntPoint = new AntPoint(force.x, force.y);
					var p:AntPoint = new AntPoint(distOut.pointB.x * scale, distOut.pointB.y * scale);
					var distPercent:Number = AntMath.toPercent(distOut.distance * scale, _explosionRadius);
					var damage:Number = _explosionDamage - AntMath.fromPercent(distPercent, _explosionDamage);
					(body.GetUserData() as AntBox2DBody).explode(_explosionSource.GetUserData() as AntBox2DBody, f, p, damage);
				}
				else
				{
					body.ApplyImpulse(force, distOut.pointB);
				}
			}
			
			return true;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------

		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function get gravityX():Number { return _gravity.x; }
		public function set gravityX(value:Number):void
		{
			_gravity.x = value;
			if (box2dWorld != null)
			{
				box2dWorld.SetGravity(_gravity);
			}
		}
		
		/**
		 * @private
		 */
		public function get gravityY():Number { return _gravity.y; }
		public function set gravityY(value:Number):void
		{
			_gravity.y = value;
			if (box2dWorld != null)
			{
				box2dWorld.SetGravity(_gravity);
			}
		}
		
		/**
		 * @private
		 */
		public function get enableDebugDraw():Boolean { return (_debugDrawer != null); }
		public function set enableDebugDraw(value:Boolean):void
		{
			if (_debugDrawer == null && value == true)
			{
				_debugDrawer = new AntBox2DDrawer(this);
				_debugDrawer.camera = AntG.getCamera();
			}
			else if (_debugDrawer != null && value == false)
			{
				_debugDrawer.destroy();
				_debugDrawer = null;
			}
		}
		
		/**
		 * @private
		 */
		public function get debugDrawer():AntBox2DDrawer { return _debugDrawer; }
		
		//---------------------------------------
		// IPlugin Implementation
		//---------------------------------------

		//import ru.antkarlov.anthill.plugins.IPlugin;
		public function get tag():String { return _tag; }
		public function set tag(aValue:String):void { _tag = aValue; }

		public function get priority():int { return _priority; }
		public function set priority(aValue:int):void { _priority = aValue; }

		public function update():void
		{
			if (box2dWorld != null)
			{
				if (!pause)
				{
					box2dWorld.Step(step, velocityIterations, positionIterations);
					box2dWorld.ClearForces();
				}
			}
		}

		public function draw(aCamera:AntCamera):void
		{
			if (_debugDrawer != null)
			{
				box2dWorld.DrawDebugData();
				_debugDrawer.update();
			}
		}

	}

}