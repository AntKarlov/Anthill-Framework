package ru.antkarlov.anthill.plugins.box2d
{
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2ManifoldPoint;
	import Box2D.Collision.b2WorldManifold;
	
	/**
	 * Description
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  22.09.2013
	 */
	public class AntBox2DContact extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на тело которое столкнулось.
		 */
		public var collider:AntBox2DBody;
		
		/**
		 * Указатель на тело с которым столкнулись.
		 */
		public var collidee:AntBox2DBody;
		
		/**
		 * Указатель на оригинальные опции тела которое столкнулось.
		 */
		public var colliderFixture:b2Fixture;
		
		/**
		 * Указатель на оригинальные опции тела с которым столкнулись.
		 */
		public var collideeFixture:b2Fixture;
		
		/**
		 * Положение точки контакта по X в пикселях.
		 */
		public var positionX:Number;
		
		/**
		 * Положение точки контакта по Y в пикселях.
		 */
		public var positionY:Number;
		
		/**
		 * @private
		 */
		public var normalX:Number;
		public var normalY:Number;
		
		/**
		 * Сила контакта (столкновения).
		 * Сила контакта может быть известна только в методе postSolveContact().
		 */
		public var impulse:Number;
		
		/**
		 * Равно TRUE если этот контакт происходит.
		 */
		public var isTouching:Boolean;
		
		/**
		 * Равно TRUE если этот контакт генерирует события для последующего 
		 * продолжения симуляции (не прекратился).
		 */
		public var isContinuous:Boolean;
		
		/**
		 * Равно TRUE если контакт произошел с сенсором.
		 */
		public var isSensor:Boolean;
		
		private var _worldManifold:b2WorldManifold;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private static const MAX_CACHE_CAPACITY:int = 100;
		private static var _cache:Vector.<AntBox2DContact>;
		private static var _numCacheItems:int = 0;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntBox2DContact(aContact:b2Contact = null)
		{
			super();
			_worldManifold = new b2WorldManifold();
			(aContact != null) ? setData(aContact) : resetData();
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Устанавливает данные для контакта.
		 * 
		 * @param	aContact	 Оригинальный класс контакта Box2D.
		 */
		public function setData(aContact:b2Contact):void
		{
			colliderFixture = aContact.GetFixtureA();
			collideeFixture = aContact.GetFixtureB();
			collider = colliderFixture.GetUserData() as AntBox2DBody;
			collidee = collideeFixture.GetUserData() as AntBox2DBody;
			
			var scale:Number = (collider != null) ? collider.manager.scale : (collidee != null) ? collidee.manager.scale : 30;
			
			aContact.GetWorldManifold(_worldManifold);			
			if (_worldManifold.m_points.length > 0)
			{
				positionX = _worldManifold.m_points[0].x * scale;
				positionY = _worldManifold.m_points[0].y * scale;
			}

			impulse = 0;
			normalX = _worldManifold.m_normal.x;
			normalY = _worldManifold.m_normal.y;
			isTouching = aContact.IsTouching();
			isContinuous = aContact.IsContinuous();
			isSensor = aContact.IsSensor();
		}
		
		/**
		 * Сбрасывает все данные для контакта.
		 */
		public function resetData():void
		{
			colliderFixture = null;
			collideeFixture = null;
			collider = null;
			collidee = null;

			positionX = 0;
			positionY = 0;
			
			impulse = 0;
			isTouching = false;
			isContinuous = false;
			isSensor = false;
		}
		
		/**
		 * Копирует данные контакта из другого экземпляра.
		 * 
		 * @param	aContact	 Контакт данные которого необходимо скопировать.
		 */
		public function copyFrom(aContact:AntBox2DContact):void
		{
			colliderFixture = aContact.colliderFixture;
			collideeFixture = aContact.collideeFixture;
			collider = aContact.collider;
			collidee = aContact.collidee;

			positionX = aContact.positionX;
			positionY = aContact.positionY;

			impulse = aContact.impulse;
			isTouching = aContact.isTouching;
			isContinuous = aContact.isContinuous;
			isSensor = aContact.isSensor;
		}
		
		//---------------------------------------
		// CACHE
		//---------------------------------------
		
		/**
		 * Извлекает свободный контакт из кэша. Если кэш не инициализирован
		 * или пуст, то вернется новый экземпляр контакта.
		 */
		public static function get():AntBox2DContact
		{
			// Если кэш еще не инициализирован.
			if (_cache == null)
			{
				return new AntBox2DContact();
			}
			
			// Если в кэше есть контакты.
			if (_numCacheItems > 0)
			{
				_numCacheItems--;
				var res:AntBox2DContact = _cache[_numCacheItems];
				_cache[_numCacheItems] = null;
				return res;
			}
			
			// Кэш пустой.
			return new AntBox2DContact();
		}
		
		/**
		 * Помещает ранее использованный контакт в кэш. Перед помещением контакта
		 * в кэш, все его данные будут обнулены.
		 */
		public static function set(aContact:AntBox2DContact):void
		{
			// Если кэш еще не инициализирован.
			if (_cache == null)
			{
				_cache = new Vector.<AntBox2DContact>(MAX_CACHE_CAPACITY, true);
				_cache[_numCacheItems] = aContact;
				_numCacheItems++;
				return;
			}
			
			// Если в кэше есть свободные места.
			if (_numCacheItems < MAX_CACHE_CAPACITY)
			{
				_cache[_numCacheItems] = aContact;
				_numCacheItems++;
			}
		}
		
		/**
		 * Возвращает количество контактов находящихся в кэше.
		 */
		public static function get numCacheItems():int { return _numCacheItems; }

	}

}