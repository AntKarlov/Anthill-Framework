package ru.antkarlov.anthill
{
	/**
	 * Базовый класс для визуальных и перемещаемых объектов, а так же для
	 * тех объектов с которыми можно работать как с группами.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  26.08.2012
	 */
	public class AntEntity extends AntBasic
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		/**
		 * Константа для определения способа сортировки по возрастанию.
		 */
		public static const ASCENDING:int = -1;
		
		/**
		 * Констатна для определения способа сортировки по убыванию.
		 */
		public static const DESCENDING:int = 1;
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Указатель на родительскую сущность в которую была помещена текущая сущность. 
		 * Если <code>null</code> то текущая сущность не является вложением.
		 * @default    null
		 */
		public var parent:AntEntity;
		
		/**
		 * Массив вложенных сущностей. Если <code>null</code>, значит вложенных сущностей нет.
		 * @default    null
		 */
		public var children:Array;
		
		/**
		 * Количество вложенных сущностей.
		 * @default    0
		 */
		public var length:int;
		
		/**
		 * Положение сущности по X.
		 * @default    0
		 */
		public var x:Number;
		
		/**
		 * Положение сущности по Y.
		 * @default    0
		 */
		public var y:Number;
		
		/**
		 * Ширина сущности. Вложенные сущности не влияют на размер сущности родителя.
		 * @default    0
		 */
		public var width:Number;
		
		/**
		 * Высота сущности. Вложенные сущности не влияют на высоту сущности родителя.
		 * @default    0
		 */
		public var height:Number;
		
		/**
		 * Осъ сущности вокруг которой она вращается.
		 * @default    0,0
		 */
		public var axis:AntPoint;
		
		/**
		 * Прямоугольник определяющий область занимаемую сущностью.
		 * При рассчете прямоугольника, вложенные сущности не учитываются. 
		 * Прямоугольник рассчитывается автоматически перед отрисовкой объекта.
		 */
		public var bounds:AntRect;
		
		/**
		 * Масштабирование сущности.
		 * При масштабировании объекта скорость отрисовки существенно снижается.
		 * @default    1,1
		 */
		public var scale:AntPoint;
		
		/**
		 * Скорость сущности.
		 * Скорость может рассчитывается автоматически исходя из <code>acceleration</code>, <code>drag</code> и <code>maxVelocity</code>.
		 * @default    0,0
		 */
		public var velocity:AntPoint;
		
		/**
		 * Ускорение сущности. Воздействует каждый кадр на скорость.
		 * @default    0,0
		 */
		public var acceleration:AntPoint;
		
		/**
		 * Замедление сущности. Воздействует каждый кадр на скорость.
		 * @default    0,0
		 */
		public var drag:AntPoint;
		
		/**
		 * Максимально допустимая скорость.
		 * @default    10000,10000
		 */
		public var maxVelocity:AntPoint;
		
		/**
		 * Угол поворота сущности в градусах.
		 * @default    0
		 */
		public var angle:Number;
		
		/**
		 * Скорость вращения.
		 * Скорость вращения может рассчитывается автоматически исходя из <code>angularAcceleration</code>, <code>angularDrag</code> и <code>maxAngular</code>.
		 * @default    value
		 */
		public var angularVelocity:Number;
		
		/**
		 * Ускорение вращения сущности. Воздействует каждый кадр на скорость вращения.
		 * @default    0
		 */
		public var angularAcceleration:Number = 0;
		
		/**
		 * Замедление вращения сущности. Воздействует каждый кадр на скорость вращения.
		 * @default    0
		 */
		public var angularDrag:Number;
		
		/**
		 * Максимальная скорость вращения сущности.
		 * @default    10000
		 */
		public var maxAngular:Number;
		
		/**
		 * Флаг определяющий является ли сущность движемым объектом.
		 * Если <code>moves = true</code>, то для сущности применяется автоматический рассчет скорости движения и вращения исходя из соотвествующих параметров.
		 * @default    false
		 */
		public var moves:Boolean;
		
		/**
		 * Массив координат вершин определяющих прямоугольник сущности исходя из положения и размеров с учетом угла поворота.
		 * Вложенные сущности не влияют на размеры прямоугольника сущности. Прямоугольник рассчитывается исходя из положения и размеров.
		 */
		public var vertices:Array;
		
		/**
		 * Фактор прокручивания сущности. 
		 * Используется для расчета положения сущности исходя из положения камеры. 
		 * Если фактор прокручивания равен x:1, y:1 то скорость прокручивания будет равна скорости движения камеры, то есть 1 к 1.
		 * @default    1,1
		 */
		public var scrollFactor:AntPoint;
		
		/**
		 * Объем жизни сущности, используется на усмотрение разработчика. 
		 * Для нанесения урона используйте метод <code>hurt(aDamage:Number):Boolean</code>.
		 * @default    1
		 */
		public var health:Number;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Определяет имеет ли сущность вложенные объекты.
		 * @default    false
		 */
		protected var _isGroup:Boolean;
		
		/**
		 * Содержит последнее значение угла поворота. Используется для оптимизации рассчетов.
		 * @default    0
		 */
		protected var _lastAngle:Number;
		
		/**
		 * Содержит последнее значение положения сущности. Используется для оптимизации рассчетов.
		 */
		protected var _lastPosition:AntPoint;
		
		/**
		 * Имя поля по которому производится сортировка.
		 */
		protected var _sortIndex:String;
		
		/**
		 * Порядок сортировки.
		 */
		protected var _sortOrder:int;
		
		/**
		 * @private
		 */
		protected var _isVisual:Boolean;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntEntity()
		{
			super();
			
			parent = null;
			children = null;
			length = 0;
			
			x = 0;
			y = 0;
			width = 0;
			height = 0;
			axis = new AntPoint();
			bounds = new AntRect();
			scale = new AntPoint(1, 1);
			velocity = new AntPoint();
			acceleration = new AntPoint();
			drag = new AntPoint();
			maxVelocity = new AntPoint(10000, 10000);
			
			angle = 0;
			angularVelocity = 0;
			angularAcceleration = 0;
			angularDrag = 0;
			maxAngular = 10000;
			moves = false;
            
			scrollFactor = new AntPoint(1, 1);
			health = 1;
			
			vertices = new Array(4);
			for (var i:int = 0; i < 4; i++)
			{
				vertices[i] = new AntPoint();
			}
			
			_isGroup = false;
			_lastAngle = angle;
			_lastPosition = new AntPoint(0, 0);
			
			_sortIndex = null;
			_sortOrder = ASCENDING;
			_isVisual = false;
		}
		
		/**
		 * Устанавливает позицию.
		 * 
		 * @param	aX	 Новая позиция по X.
		 * @param	aY	 Новая позиция по Y.
		 */
		public function reset(aX:Number = 0, aY:Number = 0):void
		{
			x = aX;
			y = aY;
			
			velocity.set();
			angularVelocity = 0;
			
			if (_isGroup)
			{
				var mx:Number;
				var my:Number;

				if (x != _lastPosition.x || y != _lastPosition.y)
				{
					mx = x - _lastPosition.x;
					my = y - _lastPosition.y;
				}
				else
				{
					return;
				}

				var entity:AntEntity;
				var n:int = children.length;
				for (var i:int = 0; i < n; i++)
				{
					entity = children[i] as AntEntity;
					if (entity != null && entity.exists)
					{
						if (entity.isGroup)
						{
							entity.reset(entity.x + mx, entity.y + my);
						}
						else
						{
							entity.x += mx;
							entity.y += my;
						}
					}
				}
			}
			
			if (!_isVisual)
			{
				saveLastPosition();
			}
		}
		
		/**
		 * Устанавливает угол поворота.
		 * 
		 * @param	aAngle	 Новый угол поворота в градусах.
		 */
		public function resetRotation(aAngle:Number = 0):void
		{
			angle = aAngle;
			
			if (!_isGroup)
			{
				return;
			}
			
			var point:AntPoint = new AntPoint();
			var diff:Number;
			if (aAngle != _lastAngle)
			{
				diff = aAngle - _lastAngle;
				
				var entity:AntEntity;
				var n:int = children.length;
				for (var i:int = 0; i < n; i++)
				{
					entity = children[i];
					if (entity != null && entity.exists)
					{
						if (entity._isGroup)
						{
							entity.resetRotation(aAngle);
						}
						else
						{
							AntMath.rotateDeg(entity.x, entity.y, x /*+ axis.x*/, y /*+ axis.y*/, diff, point);
							entity.x = point.x;
							entity.y = point.y;
							entity.angle += diff;
						}
					}
				}
			}
			
			saveLastPosition();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			kill();
			
			if (_isGroup)
			{
				var entity:AntEntity;
				for (var i:int = 0; i < length; i++)
				{
					entity = children[i] as AntEntity;
					if (entity != null)
					{
						entity.dispose();
					}
				}
				
				children.length = length = 0;
				children = null;
				_sortIndex = null;
			}
			
			if (parent != null)
			{
				parent.remove(this);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function kill():void
		{
			if (_isGroup)
			{
				var entity:AntEntity;
				for (var i:int = 0; i < length; i++)
				{
					entity = children[i] as AntEntity;
					if (entity != null && entity.exists)
					{
						entity.kill();
					}
				}
			}
			
			super.kill();
		}
			
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
			updateMotion();
			
			if (_isGroup)
			{
				updateChildren();
				rotateChildren();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void
		{
			if (_isGroup)
			{
				var entity:AntEntity;
				for (var i:int = 0; i < length; i++)
				{
					entity = children[i] as AntEntity;
					if (entity != null && entity.exists && entity.visible)
					{
						entity.draw();
					}
				}
			}
		}
		
		/**
		 * Сортировка сущности по указанному параметру.
		 * 
		 * @param	aIndex	 Имя параметра по которому будет выполнена сортировка.
		 * @param	aOrder	 Способ сортировки - по возрастанию или убыванию.
		 */
		public function sort(aIndex:String = "y", aOrder:int = ASCENDING):void
		{
			_sortIndex = aIndex;
			_sortOrder = aOrder;
			children.sort(sortHandler);
		}
		
		/**
		 * Добавляет указанную сущность в текущую сущность.
		 * 
		 * @param	aEntity	 Сущность которую необходимо добавить.
		 * @return		Возвращает указатель на добавленную сущность.
		 */
		public function add(aEntity:AntEntity):AntEntity
		{
			// Если до этого момента сущность не имела детей, то переключаем в режим группы.
			if (children == null)
			{
				children = [];
				length = 0;
				_isGroup = true;
			}
			
			// Если добавляемый объект уже был ранее добавлен, игнорируем.
			if (children.indexOf(aEntity) >= 0)
			{
				return aEntity;
			}
			
			// Если добавляемый объект состоит в другой группе, то удаляем его от туда.
			if (aEntity.parent != null)
			{
				aEntity.parent.remove(aEntity);
			}
			
			// Указатель на родительский объект (на себя).
			aEntity.parent = this;
			if (length >= 1)
			{
				aEntity.angle += angle;
				aEntity.x += x;
				aEntity.y += y;
			}
			
			// Ищем пустую ячейку в массиве.
			var n:int = children.length;
			for (var i:int = 0; i < n; i++)
			{
				if (children[i] == null)
				{
					children[i] = aEntity;
					return aEntity;
				}
			}
			
			// Добавляем в конец массива.
			children[n] = aEntity;
			length = n + 1;
			
			return aEntity;
		}
		
		/**
		 * Удаляет указанную сущность из текущей.
		 * 
		 * @param	aEntity	 Сущность которую необходимо удалить.
		 * @param	aSplice	 Если true то ячейка в которой располагалась удаляемая сущность, так же будет удалена.
		 * @return		Возвращает указатель на удаленную сущность.
		 */
		public function remove(aEntity:AntEntity, aSplice:Boolean = false):AntEntity
		{
			if (!_isGroup)
			{
				return null;
			}
			
			var index:int = children.indexOf(aEntity);
			if (index < 0 || index >= children.length)
			{
				return null;
			}
			
			children[index] = null;
			aEntity.parent = null;
				
			if (aSplice)
			{
				children[index].splice(index, 1);
				length--;
			}
			
			return aEntity;
		}
		
		/**
		 * Проверяет добавлена ли указанная сущность в текущую сущность.
		 * 
		 * @param	aEntity	 Сущность наличие которой необходимо проверить.
		 * @return		Возвращает true если указанная сущность уже добавлена в текущую сущность.
		 */
		public function contains(aEntity:AntEntity):Boolean
		{
			if (!_isGroup)
			{
				return false;
			}
			
			return (children.indexOf(aEntity) >= 0) ? true : false;
		}
		
		/**
		 * Переиспользование сущности из вложенных в текущую сущность.
		 * 
		 * <p>Если класс необходимой сущности не указан, то метод вернет первую попавшуюся сущность которая временно не существует
		 * <code>exist = false</code>, или <code>null</code> если сущностей нет. Если указан класс необходимой сущности, то в случае
		 * отсуствия временно не существующих сущностей указанного класса, то будет создан новый экземпляр указанного класса и 
		 * автоматически добавлен в текущую сущность.</p>
		 * 
		 * <p>Примечание: Если метод возвращает ранее использованную сущность, то перед использованием необходимо воскресить сущность
		 * методом <code>revive()</code>. Проверить необходимость вызова метода <code>revive()</code> можно через флаг <code>exists</code>.</p>
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <p><code>var myEntity:MyGameObject = layer.recycle(MyGameObject) as MyGameObject;
		 * if (myEntity.exist == false)
		 * {
		 * 	// Ранее использованная сущность.
		 * 	myEntity.revive();
		 * }
		 * else
		 * {
		 * 	// Новая сущность.
		 * }</code></p>
		 * 
		 * @param	aClass	 Класс объекта который необходимо переиспользовать.
		 * @return		Возвращает более не используемый объект из вложенных, либо новый объект, если свободных не оказалось.
		 */
		public function recycle(aClass:Class = null):AntEntity
		{
			var entity:AntEntity = getAvailable(aClass);
			if (entity != null)
			{
				return entity;
			}
			
			if (aClass == null)
			{
				return null;
			}
			
			entity = new aClass();
			return (entity is AntEntity) ? add(entity) : null;
		}
		
		/**
		 * Заменяет старую сущность на новую.
		 * 
		 * @param	oldEntity	 Старая сущность которую необходимо заменить.
		 * @param	newEntity	 Новая сущность на которую необходимо заменить.
		 * @return		Возвращает true если замена произведена успешно.
		 */
		public function replace(oldEntity:AntEntity, newEntity:AntEntity):Boolean
		{
			if (!_isGroup)
			{
				return false;
			}
			
			var index:int = children.indexOf(oldEntity);
			if (index < 0 || index >= children.length)
			{
				return false;
			}
			
			children[index] = newEntity;
			newEntity.parent = this;
			oldEntity.parent = null;
			return true;
		}
		
		/**
		 * Меняет местами указанные сущности.
		 * 
		 * @param	aEntity	 Первая сущность.
		 * @param	bEntity	 Вторая сущность.
		 * @return		Возвращает true если смена мест была произведена успешно.
		 */
		public function swap(aEntityA:AntEntity, aEntityB:AntEntity):Boolean
		{
			if (!_isGroup)
			{
				return false;
			}
			
			var indexA:int = children.indexOf(aEntityA);
			var indexB:int = children.indexOf(aEntityB);
			if (indexA > -1 && indexB > -1)
			{
				children[indexA] = aEntityB;
				children[indexB] = aEntityA;
				return true;
			}
			
			return false;
		}
		
		/**
		 * Удаляет все вложенные сущности, но не освобождает их.
		 */
		public function clear():void
		{
			if (!_isGroup)
			{
				return;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null)
				{
					entity.parent = null;
				}
				children[i] = null;
			}
			
			children.length = 0;
			length = 0;
		}
		
		/**
		 * Извлекает первую попавшуюся временно не существующую сущность соотвествующую указанному классу.
		 * 
		 * @param	aClass	 Класс сущнности которую необходимо получить.
		 * @return		Вернет сущность флаг exist = false, или null если свободных сущностей нет указанного класса нет.
		 */
		public function getAvailable(aClass:Class = null):AntEntity
		{
			if (!_isGroup)
			{
				return null;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && !entity.exists && ((aClass == null) || (entity is aClass)))
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает первую попавшуюся сущность во вложении.
		 * 
		 * @param	aClass	 Класс сущности которую необходимо получить.
		 * @return		Вернет null если во вложении нет сущностей вообще или сущности указанного класса.
		 */
		public function getExtant(aClass:Class = null):AntEntity
		{
			if (!_isGroup)
			{
				return null;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && ((aClass == null) || (entity is aClass)))
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает первую попавшуюся существующую "живую" сущность во вложении.
		 * 
		 * @return		Вернет null если существующих "живых" сущностей в группе нет.
		 */
		public function getAlive():AntEntity
		{
			if (!_isGroup)
			{
				return null;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && entity.exists && entity.alive)
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает первую попавшуюся "мертвую" сущность.
		 * 
		 * @return		Вернет null если "мертвых" сущностей в группе нет.
		 */
		public function getDead():AntEntity
		{
			if (!_isGroup)
			{
				return null;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && !entity.alive)
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Определяет количество "живых" вложенных сущностей.
		 * 
		 * @return		Количество "живых" сущностей.
		 */
		public function numLiving():int
		{
			if (!_isGroup)
			{
				return -1;
			}
			
			var entity:AntEntity;
			var num:int = 0;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && entity.exists && entity.alive)
				{
					num++;
				}
			}
			
			return num;
		}
		
		/**
		 * Определяет количество "мертвых" вложенных сущностей.
		 * 
		 * @return		Количество "мертвых" сущностей.
		 */
		public function numDead():int
		{
			if (!_isGroup)
			{
				return -1;
			}
			
			var entity:AntEntity;
			var num:int = 0;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && !entity.alive)
				{
					num++;
				}
			}
			
			return num;
		}
		
		/**
		 * Извлекает случайную вложенную сущность.
		 */
		public function getRandom():AntEntity
		{
			/*
				TODO Сделать так чтобы пустые ячейки игнорировались.
			*/
			return children[AntMath.randomRangeInt(0, length)] as AntEntity;
		}
		
		/**
		 * Извлекает сущность по её тэгу.
		 * 
		 * @param	aTag	 Уникальный идентификатор сущности.
		 * @return		Возвращает null если сущности с указанным тэгом нет во вложении.
		 */
		public function getByTag(aTag:int):AntEntity
		{
			if (!_isGroup)
			{
				return null;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && entity.tag == aTag)
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Возвращает список сущностей по их тэгу.
		 * 
		 * @param	aTag	 Уникальный индентификатор сущности.
		 * @param	aResult	 Массив в который будет помещен результат.
		 * @return		Массив сущностей соотвествующих уникальному тэгу.
		 */
		public function queryByTag(aTag:int, aResult:Array = null):Array
		{
			if (!_isGroup)
			{
				return null;
			}
			
			if (aResult == null)
			{
				aResult = [];
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && entity.tag == aTag)
				{
					aResult[aResult.length] = entity;
				}
			}
			
			return aResult;
		}
				
		/**
		 * Вычисляет экранные координаты сущности для указанной камеры. 
		 * <p>Если камера не указана, то используется камера по умолчанию.</p>
		 * 
		 * @param	aCamera	 Камера для которой необходимо получить экранные координаты сущности.
		 * @param	aResult	 Указатель на точку куда может быть записан результат.
		 * @return		Экранные координаты сущности или -1,-1 если нет ни одной камеры.
		 */
		public function getScreenPosition(aCamera:AntCamera = null, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			if (aCamera == null)
			{
				aCamera = AntG.getDefaultCamera();
			}
			
			aResult.x = x + aCamera.scroll.x * scrollFactor.x;
			aResult.y = y + aCamera.scroll.y * scrollFactor.y;
			
			return aResult;
		}
		
		/**
		 * Вычисляет экранные координаты указанной точки для указанной камеры. 
		 * <p>Примечание: Если камера не указана то используется камера по умолчанию.</p>
		 * 
		 * @param	aX	 Координата точки по X.
		 * @param	aY	 Координата точки по Y.
		 * @param	aCamera	 Камера для которой необходимо получить экранные координаты.
		 * @param	aResult	 Указатель на точку куда может быть записан результат.
		 * @return		Экранные координаты точки или -1,-1 если нет ни одной камеры.
		 */
		public function toScreenPosition(aX:Number, aY:Number, aCamera:AntCamera = null, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			if (aCamera == null)
			{
				aCamera = AntG.getDefaultCamera();
				if (aCamera == null)
				{
					return new AntPoint(-1, -1);
				}
			}
			
			aResult.x = aX + aCamera.scroll.x * scrollFactor.x;
			aResult.y = aY + aCamera.scroll.y * scrollFactor.y;
			
			return aResult;
		}
		
		/**
		 * Проверяет попадает ли сущность на экран указанной камеры.
		 * <p>Примечание: Поскольку сама сущность не имеет графического представления, то она не может попадать 
		 * в экран камеры, поэтому метод сущности всегда возвращает false. Классы потомки имеющие графический 
		 * контент перекрывают этот метод.</p>
		 * 
		 * @return		Всегда возвращает false.
		 */
		public function onScreen(aCamera:AntCamera = null):Boolean
		{
			return false;
		}
		
		/**
		 * Проверяет попадает ли указанная точка в прямоугольник заданный вершинами.
		 * ВНИМАНИЕ
		 * 
		 * @return		Возвращает true если точка попадает в прямоугольник кнопки.
		 */
		public function intersectsPoint(aPoint:AntPoint):Boolean
		{
			var n:int = vertices.length;
			var res:Boolean = false;
			
			for (var i:int = 0, j:int = n - 1; i < n; j = i++)
			{
				if (((vertices[i].y > aPoint.y) != (vertices[j].y > aPoint.y)) && 
					(aPoint.x < (vertices[j].x - vertices[i].x) * (aPoint.y - vertices[i].y) / (vertices[j].y - vertices[i].y) + vertices[i].x))
				{
					res = !res;
				}
			}
			
			return res;
		}
		
		/**
		 * Наносит урон.
		 * 
		 * @param	damage	 Размер наносимого урона.
		 * @return		Возвращает true если сущность была убита.
		 */
		public function hurt(damage:Number):Boolean
		{
			health -= damage;
			if (health <= 0)
			{
				kill();
				return true;
			}
			
			return false;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
				
		/**
		 * Процессинг вложенных сущностей.
		 */
		protected function updateChildren():void
		{
			if (!_isGroup)
			{
				return;
			}
			
			var mx:Number;
			var my:Number;
			var moved:Boolean = false;
			
			if (x != _lastPosition.x || y != _lastPosition.y)
			{
				moved = true;
				mx = x - _lastPosition.x;
				my = y - _lastPosition.y;
			}
			
			var entity:AntEntity;
			for (var i:int = 0; i < length; i++)
			{
				entity = children[i] as AntEntity;
				if (entity != null && entity.exists)
				{
					if (moved)
					{
						if (entity.isGroup)
						{
							entity.reset(entity.x + mx, entity.y + my);
						}
						else
						{
							entity.x += mx;
							entity.y += my;
						}
					}
					
					if (entity.active)
					{
						entity.preUpdate();
						entity.update();
						entity.postUpdate();
					}
				}
			}
		}
		
		/**
		 * Вращение вложенных сущностей.
		 */
		protected function rotateChildren():void
		{
			if (!_isGroup)
			{
				return;
			}
			
			if (angle != _lastAngle)
			{
				var diff:Number = angle - _lastAngle;
				var point:AntPoint = new AntPoint();
				
				var entity:AntEntity;
				for (var i:int = 0; i < length; i++)
				{
					entity = children[i];
					if (entity != null && entity.exists)
					{
						if (entity.isGroup)
						{
							entity.resetRotation(angle);
						}
						else
						{
							AntMath.rotateDeg(entity.x, entity.y, x /*+ axis.x*/, y /*+ axis.y*/, diff, point);
							entity.x = point.x;
							entity.y = point.y;
							entity.angle += diff;
						}
					}
				}
			}
			
			if (!_isVisual)
			{
				saveLastPosition();
			}
		}
				
		/**
		 * Рассчет скорости движения и вращения сущности исходя из соотвествующих параметров.
		 */
		protected function updateMotion():void
		{
			if (!moves)
			{
				return;
			}
			
			// Рассчет скорости вращения
			var vc:Number;
			vc = (calcVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular) - angularVelocity) * 0.5;
			
			angularVelocity += vc;
			angle += angularVelocity * AntG.elapsed;
			angle = AntMath.normAngleDeg(angle);
			angularVelocity += vc;
			
			// Рассчет скорости движения по x
			vc = (calcVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x) * 0.5;
			velocity.x += vc;
			var dx:Number = velocity.x * AntG.elapsed;
			velocity.x += vc;
			
			// Рассчет скорости движения по y
			vc = (calcVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y) * 0.5;
			velocity.y += vc;
			var dy:Number = velocity.y * AntG.elapsed;
			velocity.y += vc;
			
			x += dx;
			y += dy;
		}
		
		/**
		 * Рассчет скорости.
		 * 
		 * @param	aVelocity	 Текущая скорость.
		 * @param	aAcceleration	 Ускорение.
		 * @param	aDrag	 Замедление.
		 * @param	aMax	 Максимально допустимая скорость.
		 * @return		Возвращает новую скорость на основе входящих параметров.
		 */
		protected function calcVelocity(aVelocity:Number, aAcceleration:Number = 0, 
			aDrag:Number = 0, aMax:Number = 10000):Number
		{
			/*
				TODO Перенести этот метод в класс AntMath?
			*/
			if (aAcceleration != 0)
			{
				aVelocity += aAcceleration * AntG.elapsed;
			}
			else if (aDrag != 0)
			{
				var dv:Number = aDrag * AntG.elapsed;
				if (aVelocity - dv > 0)
				{
					aVelocity -= dv;
				}
				else if (aVelocity + dv < 0)
				{
					aVelocity += dv;
				}
				else
				{
					aVelocity = 0;
				}
			}
			
			if (aVelocity != 0 && aMax != 10000)
			{
				if (aVelocity > aMax)
				{
					aVelocity = aMax;
				}
				else if (aVelocity < -aMax)
				{
					aVelocity = -aMax;
				}
			}
			
			return aVelocity;
		}
		
		/**
		 * Сохраняет текущий угол и положение сущности для оптимизации перерасчетов.
		 */
		protected function saveLastPosition():void
		{
			_lastAngle = angle;
			_lastPosition.x = x;
			_lastPosition.y = y;
		}
		
		/**
		 * Помошник для сортировки вложенных сущностей.
		 */
		protected function sortHandler(aEntity1:AntEntity, aEntity2:AntEntity):int
		{
			if (aEntity1[_sortIndex] < aEntity2[_sortIndex])
			{
				return _sortOrder;
			}
			else if (aEntity1[_sortIndex] > aEntity2[_sortIndex])
			{
				return -_sortOrder;
			}
			
			return 0;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Определяет имеет ли сущность вложения.
		 */
		public function get isGroup():Boolean
		{
			return _isGroup;
		}
		
		/**
		 * Определяет возможность прокрутки сущности.
		 */
		public function set scrolled(value:Boolean):void
		{
			scrollFactor.x = scrollFactor.y = (value) ? 1 : 0;
		}
		
		public function get scrolled():Boolean
		{
			return (scrollFactor.x == 0 && scrollFactor.y == 0) ? false : true;
		}

	}

}