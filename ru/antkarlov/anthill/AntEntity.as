package ru.antkarlov.anthill
{
	import flash.display.BitmapData;
	
	import ru.antkarlov.anthill.events.*;
	import ru.antkarlov.anthill.debug.AntDrawer;
	import ru.antkarlov.anthill.utils.AntColor;
	
	/**
	 * Базовый класс для визуальных объектов которые можно вкладывать друг в друга.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  26.08.2012
	 */
	public class AntEntity extends AntBasic implements IBubbleEventHandler
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
		 * Указатель на родителя в которую была помещена сущность. 
		 * Если <code>null</code> то сущность не добавлена в структуру.
		 * @default    null
		 */
		public var parent:AntEntity;
		
		/**
		 * Массив дочерних сущностей. Если <code>null</code> то сущность не имеет детей.
		 * @default    null
		 */
		public var children:Array;
		
		/**
		 * Количество дочерних сущностей.
		 * @default    0
		 */
		public var numChildren:int;
		
		/**
		 * Флаг определяющий будут воскрешены вложенные сущности при вызове метода <code>revive()</code>
		 * @default    false
		 */
		public var autoReviveChildren:Boolean;
		
		/**
		 * Аналог атрибута <code>tag</code> в <code>AntBasic</code>. 
		 * Рекомендуется использовать для сортировки.
		 * @default    0
		 */
		public var z:int;
		
		/**
		 * Локальная позициия по X.
		 * @default    0
		 */
		public var x:Number;
		
		/**
		 * Локальная позиция по Y.
		 * @default    0
		 */
		public var y:Number;
		
		/**
		 * Глобальная позиция по X.
		 * Рассчитывается автоматически относительно родительской сущности.
		 * @default    0
		 */
		public var globalX:Number;
		
		/**
		 * Глобальная позиция по Y.
		 * Рассчитывается автоматически относительно родительской сущности.
		 * @default    0
		 */
		public var globalY:Number;
		
		/**
		 * Размер по ширине.
		 * @default    0
		 */
		public var width:Number;
		
		/**
		 * Размер по высоте.
		 * @default    0
		 */
		public var height:Number;
		
		/**
		 * Локальный угол поворота сущности.
		 * @default    0
		 */
		public var angle:Number;
		
		/**
		 * Глобальный угол поворота сущности.
		 * Рассчитывается автоматически относительно родительской сущности.
		 * @default    0
		 */
		public var globalAngle:Number;
		
		/**
		 * Осевая точка сущности.
		 * @default    (0,0)
		 */
		public var origin:AntPoint;
		
		/**
		 * Масштаб сущности по горизонтали.
		 * @default    1
		 */
		public var scaleX:Number;
		
		/**
		 * Масштаб сущности по вертикали.
		 * @default    1
		 */
		public var scaleY:Number;
		
		/**
		 * Скорость движения сущности.
		 * Рассчитывается автоматически если <code>moves=true</code> исходя из:
		 * <code>acceleration</code>, <code>drag</code> и <code>maxVelocity</code>.
		 * @default    (0,0)
		 */
		public var velocity:AntPoint;
		
		/**
		 * Ускорение сущности. 
		 * Применяется автоматически к скорости если <code>moves=true</code>.
		 * @default    (0,0)
		 */
		public var acceleration:AntPoint;
		
		/**
		 * Замедление сущности.
		 * Применяется автоматически к скорости если <code>moves=true</code>.
		 * @default    (0,0)
		 */
		public var drag:AntPoint;
		
		/**
		 * Максимально допустимая скорость.
		 * Применяется автоматически к скорости если <code>moves=true</code>.
		 * @default    (10000,10000)
		 */
		public var maxVelocity:AntPoint;
		
		/**
		 * Скорость вращения сущности.
		 * Рассчитывается автоматически если <code>moves=true</code> исходя из:
		 * <code>angularAcceleration</code>, <code>angularDrag</code> и <code>maxAngularVelocity</code>.
		 * @default    0
		 */
		public var angularVelocity:Number;
		
		/**
		 * Ускорение вращения сущности.
		 * Применяется автоматически к скорости вращения если <code>moves=true</code>.
		 * @default    0
		 */
		public var angularAcceleration:Number;
		
		/**
		 * Замедление вращения сущности.
		 * Применяется автоматически к скорости вращения если <code>moves=true</code>.
		 * @default    0
		 */
		public var angularDrag:Number;
		
		/**
		 * Максимально допустимая скорость вращения сущности.
		 * Применяется автоматически к скорости вращения если <code>moves=true</code>.
		 * @default    0
		 */
		public var maxAngularVelocity:Number;
		
		/**
		 * Флаг определяющий является ли сущность движемым объектом. 
		 * Используется для активации стандартного алгоритма рассчета скоростей для движения и вращения сущности.
		 * @default    false
		 */
		public var moves:Boolean;
		
		/**
		 * Массив вершин определяющих прямоугольник сущности исходя из положения и размеров с учетом угла поворота.
		 * Вложенные сущности не влияют на размеры прямоугольника сущности.
		 */
		public var vertices:Vector.<AntPoint>;
		
		/**
		 * Прямоугольник определяющий занимаемую область.
		 * При рассчете прямоугольника, дочерние сущности не учитываются.
		 */
		public var bounds:AntRect;
		
		/**
		 * Фактор прокручивания сущности. Используется для расчета положения сущности исходя из положения камеры. 
		 * Если фактор прокручивания равен (1,1) то скорость прокручивания будет равна скорости движения камеры, то есть 1 к 1.
		 * @default    (1,1)
		 */
		public var scrollFactor:AntPoint;
		
		/**
		 * Объем жизни сущности. Используйте на свое усмотрение.
		 * Для нанесения урона можно использовать метод <code>hurt(aDamage:Number):Boolean</code>.
		 * @default    0
		 */
		public var health:Number;
		
		/**
		 * Указатель на маску которая применена к сущности.
		 * @default    null
		 */
		public var mask:AntMask;
		
		//---------------------------------------
		// PROTECTED VARIABLES
		//---------------------------------------
		
		/**
		 * Содержит старое значение положения сущности. 
		 * Используется для оптимизации рассчетов.
		 */
		protected var _oldPosition:AntPoint;
		
		/**
		 * Содержит старое значение размера сущности.
		 * Используется для оптимизации рассчетов.
		 */
		protected var _oldSize:AntPoint;
		
		/**
		 * Содержит старое значение масштабирования.
		 * Используется для оптимизации рассчетов.
		 */
		protected var _oldScale:AntPoint;
		
		/**
		 * Содержит старое значение угла поворота. 
		 * Используется для оптимизации рассчетов.
		 */
		protected var _oldAngle:Number;
		
		/**
		 * Помошник для сортировки вложенных сущностей. 
		 * Содержит имя атрибута по которому производится сортировка.
		 */
		protected var _sortIndex:String;
		
		/**
		 * Помошник для сортировки вложенных сущностей.
		 * Содержит порядок сортировки (по убываюни или по возрастанию).
		 */
		protected var _sortOrder:int;
		
		/**
		 * Содержит номер объекта если он вложен в другую сущность.
		 * Номером объекта является его номер в очереди обработки. 
		 * Номер объекта рассчитывается каждый раз при вызове метода <code>preUpdate()</code>.
		 * @default    -1
		 */
		internal var _depth:int;
		
		/**
		 * Используется для автоматического рассчета номеров в очереди обработки объектов.
		 */
		static internal var DEPTH_ID:int = 0;
		
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
			numChildren = 0;
			autoReviveChildren = false;
			_depth = -1;
            
			z = 0;
			x = 0;
			y = 0;
			globalX = 0;
			globalY = 0;
			width = 0;
			height = 0;
			angle = 0;
			globalAngle = 0;
			origin = new AntPoint();
			scaleX = 1;
			scaleY = 1;
            
			velocity = new AntPoint();
			acceleration = new AntPoint();
			drag = new AntPoint();
			maxVelocity = new AntPoint(10000, 10000);
            
			angularVelocity = 0;
			angularAcceleration = 0;
			angularDrag = 0;
			maxAngularVelocity = 10000;
            
			moves = false;
            
			vertices = new Vector.<AntPoint>(4, true);
			var i:int = 0;
			while (i < 4)
			{
				vertices[i++] = new AntPoint();
			}
			
			bounds = new AntRect();
			scrollFactor = new AntPoint(1, 1);
            
			health = 1;

			_oldPosition = new AntPoint(-1, -1);
			_oldSize = new AntPoint(-1, -1);
			_oldScale = new AntPoint(-1, -1);
			_oldAngle = -1;
			_sortIndex = null;
			_sortOrder = ASCENDING;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			kill();
			
			if (children != null)
			{
				var entity:AntEntity;
				var i:int = 0;
				while (i < numChildren)
				{
					entity = children[i++] as AntEntity;
					if (entity != null)
					{
						entity.destroy();
					}
				}
				
				children.length = 0;
				numChildren = 0;
				_sortIndex = null;
			}
			
			if (parent != null)
			{
				parent.remove(this);
			}
			
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function kill():void
		{
			if (children != null)
			{
				var entity:AntEntity;
				var i:int = 0;
				while (i < numChildren)
				{
					entity = children[i++] as AntEntity;
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
		override public function revive():void
		{
			super.revive();

			if (autoReviveChildren && children != null)
			{
				var entity:AntEntity;
				var i:int = 0;
				while (i < numChildren)
				{
					entity = children[i++] as AntEntity;
					if (entity != null && !entity.exists)
					{
						entity.revive();
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function preUpdate():void
		{
			super.preUpdate();
			_depth = DEPTH_ID++;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
			updateMotion();

			if (parent == null)
			{
				globalX = x /*+ axis.x*/;
				globalY = y /*+ axis.y*/;
				globalAngle = angle;
			}
			
			if (mask != null)
			{
				mask.update();
			}
			
			updateChildren();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw(aCamera:AntCamera):void
		{
			/*
				Примечание: Самой сущности нет необходимости перерассчитывать boundsRect, поскольку
				сущность не является визуальным объектом и не имеет размеров. Потомки должны 
				самостоятельно следить за обновлением boundsRect.
			*/
			//updateBounds();
			
			if (mask != null)
			{
				mask.updatePosition(this, aCamera);
				aCamera.beginDrawMask(mask);
				drawChildren(aCamera);
				aCamera.endDrawMask(mask);
			}
			else
			{
				drawChildren(aCamera);
			}
			
			super.draw(aCamera);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function debugDraw(aCamera:AntCamera):void
		{
			if (AntG.debugDrawer == null)
			{
				return;
			}
			
			var i:int = 1;
			var p:AntPoint = new AntPoint();
			var drawer:AntDrawer = AntG.debugDrawer;
			if (drawer.showBorders)
			{
				toScreenPosition(vertices[0].x, vertices[0].y, aCamera, p);
				drawer.moveTo(p.x, p.y);
				while (i < 4)
				{
					toScreenPosition(vertices[i].x, vertices[i].y, aCamera, p);
					drawer.lineTo(p.x, p.y, AntColor.LIME);
					i++;
				}
				toScreenPosition(vertices[0].x, vertices[0].y, aCamera, p);
				drawer.lineTo(p.x, p.y, AntColor.LIME);
			}
			
			if (drawer.showBounds)
			{
				toScreenPosition(bounds.x, bounds.y, aCamera, p);
				drawer.drawRect(p.x, p.y, bounds.width, bounds.height, AntColor.FUCHSIA);
			}
			
			if (drawer.showAxis)
			{
				toScreenPosition(globalX, globalY, aCamera, p);
				drawer.drawAxis(p.x, p.y, AntColor.AQUA);
			}
			
			// Отрисовка детей.
			if (children != null)
			{
				i = 0;
				var entity:AntEntity;
				while (i < numChildren)
				{
					entity = children[i++] as AntEntity;
					if (entity != null && entity.exists && 
						entity.visible && entity.allowDebugDraw)
					{
						entity.debugDraw(aCamera);
					}
				}
			}
		}
		
		/**
		 * Устанавливает (сбрасывает) позицию и угол.
		 * 
		 * @param	aX	 Новая позиция по X.
		 * @param	aY	 Новая позиция по Y.
		 * @param	aAngle	 Новый угол в градусах.
		 */
		public function reset(aX:Number = 0, aY:Number = 0, aAngle:Number = 0):void
		{
			x = aX;
			y = aY;
			angle = aAngle;
			
			if (parent != null)
			{
				globalX = parent.globalX + x /*+ axis.x*/;
				globalY = parent.globalY + y /*+ axis.y*/;
				globalAngle = parent.globalAngle + angle;
			}
			else
			{
				globalX = x /*+ axis.x*/;
				globalY = y /*+ axis.y*/;
				globalAngle = angle;
			}
			
			updateChildren();
			updateBounds();
		}
		
		/**
		 * Сортировка дочерних сущностей по указанному атрибуту.
		 * 
		 * @param	aIndex	 Имя атрибута по которму следует выполнить сортировку.
		 * @param	aOrder	 Порядок сортировки.
		 */
		public function sort(aIndex:String = "y", aOrder:int = ASCENDING):void
		{
			if (children != null)
			{
				_sortIndex = aIndex;
				_sortOrder = aOrder;
				children.sort(sortHandler);
			}
		}
		
		/**
		 * Добавляет дочернюю сущность.
		 * 
		 * @param	aEntity	 Сущность которую необходимо добавить.
		 * @return		Возвращает указатель на добавленную сущность.
		 */
		public function add(aEntity:AntEntity):AntEntity
		{
			// Если сущность не имела детей.
			if (children == null)
			{
				children = [];
			}
			
			// Если сущность уже добавлена.
			if (children.indexOf(aEntity) > -1)
			{
				return aEntity;
			}
			
			// Если сущность является дочерним объектом другой сущности.
			if (aEntity.parent != null)
			{
				aEntity.parent.remove(aEntity);
			}
			
			// Обновляем положение добавляемой сущности и добавляем указатель на родителя (себя).
			aEntity.parent = this;
			aEntity.locate(globalX, globalY, globalAngle);
			
			// Ищем пустую ячейку.
			var i:int = 0;
			var n:int = children.length;
			while (i < n)
			{
				if (children[i] == null)
				{
					children[i] = aEntity;
					return aEntity;
				}
				i++;
			}
			
			// Добавляем в конец массива детей.
			children[n] = aEntity;
			numChildren++;
			return aEntity;
		}
		
		/**
		 * Удаляет дочернюю сущность.
		 * 
		 * @param	aEntity	 Сущность которую необходимо удалить.
		 * @param	aSplice	 Если true то элемент массива так же будет удален.
		 * @return		Возвращает указатель на удаленную сущность.
		 */
		public function remove(aEntity:AntEntity, aSplice:Boolean = false):AntEntity
		{
			if (children == null)
			{
				return aEntity;
			}
			
			var i:int = children.indexOf(aEntity);
			if (i < 0 || i >= children.length)
			{
				return aEntity;
			}
			
			children[i] = null;
			aEntity.parent = null;
			aEntity._depth = -1;
			
			if (aSplice)
			{
				children.splice(i, 1);
				numChildren--;
			}
			
			return aEntity;
		}
		
		/**
		 * Проверяет является ли указанная сущность ребенком текущей.
		 * 
		 * @param	aEntity	 Сущность наличие которой необходимо проверить.
		 * @return		Возвращает true если указанная сущность была ранее добавлена.
		 */
		public function contains(aEntity:AntEntity):Boolean
		{
			if (children == null)
			{
				return false;
			}
			
			return (children.indexOf(aEntity) >= 0) ? true : false;
		}
		
		/**
		 * Переиспользование дочерних сущностей.
		 * 
		 * <p>Возвращает свободную (<code>!exists</code>) дочернюю сущность соотвествующую указанному классу.
		 * Если свободных сущностей нет, то автоматически будет создан и добавлен новый экземпляр 
		 * указанного класса. Иначе, если класс не указан, то вернет <code>null</code>.</p>
		 * 
		 * <p>Примечание: Если метод возвращает ранее использованную сущность, то перед её повторным использованием
		 * следует убедится что она существует (<code>exists</code>) и при необходимости воскресить методом 
		 * <code>revive()</code>.</p>
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <listing>
		 * var newObj:MyGameObject = defGroup.recycle(MyGameObject) as MyGameObject;
		 * if (!newObj.exists) {
		 *   --Объект следует воскресить.
		 *   newObj.revive();
		 * } else {
		 *   --Иначе новый объект.
		 * }
		 * </listing>
		 * 
		 * @param	aClass	 Класс объекта который необходимо переработать.
		 * @return		Возвращает свободный экземпляр указанного класса или новый если свободных нет.
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
		 * Заменяет указанную сущность на новую.
		 * 
		 * @param	aOldEntity	 Сущность которую необходимо заменить.
		 * @param	aNewEntity	 Сущность на которую необходимо заменить.
		 * @return		Возвращает указатель на новую сущность.
		 */
		public function replace(aOldEntity:AntEntity, aNewEntity:AntEntity):AntEntity
		{
			if (children == null)
			{
				return aNewEntity;
			}
			
			var i:int = children.indexOf(aOldEntity);
			if (i >= 0 && i < children.length)
			{
				if (aNewEntity.parent != null && aNewEntity.parent != this)
				{
					aNewEntity.parent.remove(aNewEntity);
					aNewEntity.parent = this;
				}
				
				children[i] = aNewEntity;
				aNewEntity.locate(globalX, globalY, globalAngle);
				aOldEntity.parent = null;
			}
			
			return aNewEntity;
		}
		
		/**
		 * Меняет указанные сущности местами.
		 * 
		 * @param	aEntityA	 Первая сущность.
		 * @param	aEntityB	 Вторая сущность.
		 */
		public function swap(aEntityA:AntEntity, aEntityB:AntEntity):void
		{
			if (children == null)
			{
				return;
			}
			
			var iA:int = children.indexOf(aEntityA);
			var iB:int = children.indexOf(aEntityB);
			if (iA >= 0 && iA < children.length && iB >= 0 && iB < children.length)
			{
				children[iA] = aEntityB;
				children[iB] = aEntityA;
			}
		}
		
		/**
		 * Удаляет все вложенные сущности.
		 * 
		 * @param	aDestroy	 Флаг определяющий следует ли вызвать метод destroy() перед удалением.
		 */
		public function removeAll(aDestroy:Boolean = true):void
		{
			if (children == null)
			{
				return;
			}
			
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null)
				{
					if (aDestroy)
					{
						entity.destroy();
					}
					
					entity.parent = null;
					entity._depth = -1;
				}
				children[i] = null;
			}
			
			children.length = 0;
			numChildren = 0;
		}
		
		/**
		 * Извлекает первую попавшующся свободную сущность соответствующую указанному классу.
		 * 
		 * @param	aClass	 Класс сущности которую необходимо получить.
		 * @return		Вернет null если свободных сущностей нет.
		 */
		public function getAvailable(aClass:Class = null):AntEntity
		{
			if (children == null)
			{
				return null;
			}

			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && !entity.exists && ((aClass == null) || (entity is aClass)))
				{
					return entity;
				}
			}

			return null;
		}
		
		/**
		 * Извлекает первую попавшуюся существующую сущность
		 * 
		 * @param	aClass	 Класс сущности которую необходимо получить.
		 * @return		Вернет null если нет существующих сущностей указанного класса (если указан).
		 */
		public function getExtant(aClass:Class = null):AntEntity
		{
			if (children == null)
			{
				return null;
			}
			
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && ((aClass == null) || (entity is aClass)))
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает первую попавшуюся существующую и "живую" сущность.
		 * 
		 * @param	aClass	 Класс сущности которую необходимо получить.
		 * @return		Вернет null если нет "живых" сущностей указанного класса (если указан).
		 */
		public function getAlive(aClass:Class = null):AntEntity
		{
			if (children == null)
			{
				return null;
			}
			
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && entity.exists && entity.alive && 
					((aClass == null) || (entity is aClass)))
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает первую попавшуюся "мертвую" сущность.
		 * 
		 * @param	aClass	 Класс сущности которую необходимо получить.
		 * @return		Вернет null если нет "мертвых" сущностей указанного класса (если указан).
		 */
		public function getDead(aClass:Class = null):AntEntity
		{
			if (children == null)
			{
				return null;
			}
			
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && !entity.alive && ((aClass == null) || (entity is aClass)))
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Определяет количество "живых" дочерних сущностей.
		 * 
		 * @return		Количество "живых" сущностей.
		 */
		public function numLiving():int
		{
			if (children == null)
			{
				return -1;
			}
			
			var entity:AntEntity;
			var num:int = 0;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && entity.exists && entity.alive)
				{
					num++;
				}
			}
			
			return num;
		}
		
		/**
		 * Определяет количество "мертвых" дочерних сущностей.
		 * 
		 * @return		Количество "мертвых" сущностей.
		 */
		public function numDead():int
		{
			if (children == null)
			{
				return -1;
			}
			
			var entity:AntEntity;
			var num:int = 0;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && !entity.alive)
				{
					num++;
				}
			}
			
			return num;
		}
		
		/**
		 * Извлекает случайную дочернюю сущность.
		 * 
		 * @param	aClass	 Класс сущности которую необходимо получить.
		 * @param	aExistsOnly	 Флаг определяющий следует ли учитывать при выборе свободные сущности.
		 * @return		Возвращает случайную сущность указанного класса (если указан).
		 */
		public function getRandom(aClass:Class = null, aExistsOnly:Boolean = true):AntEntity
		{
			if (children == null)
			{
				return null;
			}
			
			var entity:AntEntity;
			var exists:Array = [];
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null)
				{
					if (aExistsOnly && entity.exists && ((aClass == null) || (entity is aClass)))
					{
						exists[exists.length] = entity;
					}
					else if (!aExistsOnly && ((aClass == null) || (entity is aClass)))
					{
						exists[exists.length] = entity;
					}
				}
			}
			
			entity = exists[AntMath.randomRangeInt(0, exists.length)] as AntEntity;
			i = 0;
			var n:int = exists.length;
			while (i < n)
			{
				exists[i++] = null;
			}
			
			exists.length = 0;
			return entity;
		}
		
		/**
		 * Извлекает дочернюю сущность по её тэгу.
		 * 
		 * @param	aTag	 Уникальный идентификатор сущности.
		 * @return		Возвращает null если сущности с указанным тэгом нет во вложении.
		 */
		public function getByTag(aTag:int):AntEntity
		{
			if (children == null)
			{
				return null;
			}
			
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && entity.tag == aTag)
				{
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Извлекает массив дочерних сущностей по их тэгу.
		 * 
		 * @param	aTag	 Уникальный индентификатор сущности.
		 * @param	aResult	 Массив в который будет помещен результат.
		 * @return		Массив сущностей соотвествующих уникальному тэгу.
		 */
		public function queryByTag(aTag:int, aResult:Array = null):Array
		{
			if (children == null)
			{
				return null;
			}
			
			if (aResult == null)
			{
				aResult = [];
			}
			
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null && entity.tag == aTag)
				{
					aResult[aResult.length] = entity;
				}
			}
			
			return aResult;
		}
		
		/**
		 * Устанавливает значение переменной по её имени для всех вложенных объектов.
		 * 
		 * @param	aVariableName	 Имя переменной для которой необходимо установить значение.
		 * @param	aValue	 Значение которое будет установлено.
		 * @param	aRecurse	 Флаг определяющий необходимость установки значения для вложенных объектов,
		 * по умолчанию равен <code>true</code> - это означает, что для всех объектов внутри этой сущности, 
		 * которые имеют вложения, будет так же вызыван метод <code>setCall()</code>.
		 */
		public function setAll(aVariableName:String, aValue:Object, aRecurse:Boolean = true):void
		{
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null)
				{
					if (aRecurse && entity.isGroup)
					{
						entity.setAll(aVariableName, aValue, aRecurse);
					}
					else
					{
						entity[aVariableName] = aValue;
					}
				}
			}
		}
		
		/**
		 * Вызывает метод по его имени для всех вложенных объектов.
		 * 
		 * @param	aFunctionName	 Имя метода который необходимо вызывать.
		 * @param	aArgs	 Массив аргументов которые могут быть переданы в вызываемый метод.
		 * @param	aRecurse	 Флаг определяющий необходмиость вызова метода для вложенных объектов,
		 * по умолчанию равен <code>true</code> - это означает, что для всех объектов внутри этой сущности, 
		 * которые имеют вложения, будет так же вызван метод <code>callAll()</code>.
		 */
		public function callAll(aFunctionName:String, aArgs:Array = null, aRecurse:Boolean = true):void
		{
			var entity:AntEntity;
			var i:int = 0;
			while (i < numChildren)
			{
				entity = children[i++] as AntEntity;
				if (entity != null)
				{
					if (aRecurse && entity.isGroup)
					{
						entity.callAll(aFunctionName, aArgs, aRecurse);
					}
					else if (entity[aFunctionName] is Function)
					{
						(entity[aFunctionName] as Function).apply(this, aArgs);
					}
				}
			}
		}
		
		/**
		 * Проверяет попадает ли указанные координаты в прямоугольник сущности.
		 * <p>Примечание: Для невизуальной сущности прямоугольник не рассчитывается. 
		 * Данный метод корректно работает для визуальных объектов.</p>
		 * 
		 * @param	aX	 Положение точки по X.
		 * @param	aY	 Положение точки по Y.
		 * @return		Вернет true если точка находится внутри прямоугольника сущности.
		 */
		public function hitTest(aX:Number, aY:Number):Boolean
		{
			var n:int = vertices.length;
			var res:Boolean = false;
			
			for (var i:int = 0, j:int = n - 1; i < n; j = i++)
			{
				if (((vertices[i].y > aY) != (vertices[j].y > aY)) && 
					(aX < (vertices[j].x - vertices[i].x) * (aY - vertices[i].y) / (vertices[j].y - vertices[i].y) + vertices[i].x))
				{
					res = !res;
				}
			}
			
			return res;
		}
		
		/**
		 * Проверяет попадает ли указанная точка в прямоугольник сущности.
		 * 
		 * @return		Возвращает true если точка попадает в прямоугольник кнопки.
		 */
		public function hitTestPoint(aPoint:AntPoint):Boolean
		{
			return hitTest(aPoint.x, aPoint.y);
		}
		
		/**
		 * Проверяет попадает ли сущность на экран указанной камеры. 
		 * Если камера не указана то используется камера по умолчанию.
		 * <p>Примечание: Для невизуальной сущности проверка будет некорректной
		 * поскольку bounds не рассчитывается.</p>
		 * 
		 * @param	aCamera	 Камера для которой нужно проверить видимость.
		 * @return		Возвращает true если попадает в экран указанной камеры.
		 */
		public function onScreen(aCamera:AntCamera = null):Boolean
		{
			if (aCamera == null)
			{
				aCamera = AntG.getCamera();
			}
			
			return bounds.intersects(aCamera.scroll.x * -1 * scrollFactor.x, aCamera.scroll.y * -1 * scrollFactor.y,
				aCamera.width / aCamera.zoom, aCamera.height / aCamera.zoom);
		}
		
		/**
		 * Вычисляет экранные координаты сущности для указанной камеры.
		 * Если камера не указана то используется камера по умолчанию.
		 * 
		 * @param	aCamera	 Камера для которой необходимо рассчитать экранные координаты.
		 * @param	aResult	 Указатель на точку куда может быть записан результат.
		 * @return		Экранные координаты сущности.
		 */
		public function getScreenPosition(aCamera:AntCamera = null, aResult:AntPoint = null):AntPoint
		{
			return toScreenPosition(globalX, globalY, aCamera, aResult);
		}
		
		/**
		 * Переводит указанные координаты в экранные.
		 * Если камера не указана то используется камера по умолчанию.
		 * 
		 * @param	aX	 Координата точки по X.
		 * @param	aY	 Координата точки по Y.
		 * @param	aCamera	 Камера для которой необходимо рассчитать экранные координаты.
		 * @param	aResult	 Указатель на точку куда может быть записан результат.
		 * @return		Экранные координаты сущности.
		 */
		protected function toScreenPosition(aX:Number, aY:Number, aCamera:AntCamera = null, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			if (aCamera == null)
			{
				aCamera = AntG.getCamera();
			}
			
			aResult.x = aX + aCamera.scroll.x * scrollFactor.x;
			aResult.y = aY + aCamera.scroll.y * scrollFactor.y;
			return aResult;
		}
		
		/**
		 * Наносит урон.
		 * 
		 * @param	damage	 Размер наносимого урона.
		 * @return		Возвращает true если сущность была убита.
		 */
		public function hurt(aDamage:Number):Boolean
		{
			health -= aDamage;
			if (health <= 0)
			{
				kill();
				return true;
			}
			
			return false;
		}
		
		/**
		 * Обновляет положение и размеры прямоугольника определяющего занимаемую область в игровом мире.
		 */
		public function updateBounds():void
		{
			// Если объект не повернут, но изменилось положение или размер, то выполняем упрощенный прерасчет без учета поворота.
			if (globalAngle == 0 && (!_oldPosition.equal(globalX, globalY) || 
				!_oldSize.equal(width, height) || !_oldScale.equal(scaleX, scaleY)))
			{
				calcBounds();
			}
			// Если объект повернут и если изменилось только его положение, то быстро обновляем положение границ.
			else if (_oldAngle == globalAngle && !_oldPosition.equal(globalX, globalY) && 
				_oldSize.equal(width, height) && _oldScale.equal(scaleX, scaleY))
			{
				moveBounds();
			}
			// Если предыдущие условия не сработали и что-то изменилось, то выполняем полный перерассчет прямоугольника.
			else if (_oldAngle != globalAngle || !_oldPosition.equal(globalX, globalY) ||
				!_oldSize.equal(width, height) || !_oldScale.equal(scaleX, scaleY))
			{
				rotateBounds();
			}
		}
		
		//---------------------------------------
		// IBubbleEventHandler Implementation
		//---------------------------------------

		//import ru.antkarlov.anthill.events.IBubbleEventHandler;
		
		/**
		 * @inheritDoc
		 */
		public function onEventBubbled(aEvent:IEvent):Boolean
		{
			/*
				Перекройте этот метод чтобы перехватить и обработать всплывающее сообщение.
			*/
			
			return true;
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Обработка дочерних сущностей.
		 */
		protected function updateChildren():void
		{
			if (children != null)
			{
				var entity:AntEntity;
				var i:int = 0;
				while (i < numChildren)
				{
					entity = children[i++] as AntEntity;
					if (entity != null && entity.exists)
					{
						/*
							HINT Если сущность двигается и использует updateMotion то после рассчета новой позиции
							она сама обновит свои глобальные координаты согласно родителю.
						*/
						if (!entity.moves)
						{
							entity.locate(globalX, globalY, globalAngle);
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
		}
		
		/**
		 * Отрисовка дочерних сущностей.
		 */
		protected function drawChildren(aCamera:AntCamera):void
		{
			if (children != null)
			{
				var entity:AntEntity;
				var i:int = 0;
				while (i < numChildren)
				{
					entity = children[i++] as AntEntity;
					if (entity != null && entity.exists && entity.visible)
					{
						entity.draw(aCamera);
					}
				}
			}
		}
		
		/**
		 * Простой рассчет занимаемого сущностью прямоугольника без учета угла поворота.
		 */
		protected function calcBounds():void
		{
			vertices[0].set(globalX + origin.x * scaleX, globalY + origin.y * scaleY); // top left
			vertices[1].set(globalX + width * scaleX + origin.x * scaleX, globalY + origin.y * scaleY); // top right
			vertices[2].set(globalX + width * scaleX + origin.x * scaleX, globalY + height * scaleY + origin.y * scaleY); // bottom right
			vertices[3].set(globalX + origin.x * scaleX, globalY + height * scaleY + origin.y * scaleY); // bottom left			
			var tl:AntPoint = vertices[0];
			var br:AntPoint = vertices[2];
			bounds.set(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
			saveOldPosition();
		}
		
		/**
		 * Простой перерассчет занимаемого сущностью прямоугольника при условии что угол и размеры сущности не изменились.
		 * Обновляется только положение.
		 */
		protected function moveBounds():void
		{
			var mx:Number = globalX - _oldPosition.x;
			var my:Number = globalY - _oldPosition.y;
			bounds.x += mx;
			bounds.y += my;
			
			var p:AntPoint;
			var i:int = 0;
			while (i < 4)
			{
				p = vertices[i];
				p.x += mx;
				p.y += my;
				i++;
			}
			
			saveOldPosition();
		}
		
		/**
		 * Полный перерассчет занимаемого сущностью прямоугольника с учетом угла, размеров и положения.
		 */
		protected function rotateBounds():void
		{
			vertices[0].set(globalX + origin.x * scaleX, globalY + origin.y * scaleY); // top left
			vertices[1].set(globalX + width * scaleX + origin.x * scaleX, globalY + origin.y * scaleY); // top right
			vertices[2].set(globalX + width * scaleX + origin.x * scaleX, globalY + height * scaleY + origin.y * scaleY); // bottom right
			vertices[3].set(globalX + origin.x * scaleX, globalY + height * scaleY + origin.y * scaleY); // bottom left
			
			var dx:Number;
			var dy:Number;
			var p:AntPoint = vertices[0];
			var maxX:Number = p.x;
			var maxY:Number = p.y;
			p = vertices[2];
			var minX:Number = p.x;
			var minY:Number = p.y;
			var rad:Number = -globalAngle * Math.PI / 180; // Radians
			
			var i:int = 0;
			while (i < 4)
			{
				p = vertices[i];
				dx = globalX + (p.x - globalX) * Math.cos(rad) + (p.y - globalY) * Math.sin(rad);
				dy = globalY - (p.x - globalX) * Math.sin(rad) + (p.y - globalY) * Math.cos(rad);
				maxX = (dx > maxX) ? dx : maxX;
				maxY = (dy > maxY) ? dy : maxY;
				minX = (dx < minX) ? dx : minX;
				minY = (dy < minY) ? dy : minY;
				p.x = dx;
				p.y = dy;
				i++;
			}
			
			bounds.set(minX, minY, maxX - minX, maxY - minY);
			saveOldPosition();
		}
		
		/**
		 * Перерасчитывает глобальное позиционирование сущности согласно родительским координатам и углу.
		 * 
		 * @param	aX	 Глобальное положение родителя по X.
		 * @param	aY	 Глобальное положение родителя по Y.
		 * @param	aAngle	 Глобальный угол родителя.
		 */
		protected function locate(aX:Number, aY:Number, aAngle:Number):void
		{
			var rad:Number = aAngle / 180 * Math.PI;
			var px:Number = x; // + origin.x;
			var py:Number = y; // + origin.y;
			var dx:Number = px * Math.cos(rad) - py * Math.sin(rad);
			var dy:Number = px * Math.sin(rad) + py * Math.cos(rad);
			
			globalX = aX + dx;
			globalY = aY + dy;
			globalAngle = aAngle + angle;
		}
		
		/**
		 * Рассчет скорости движения и вращения сущности.
		 */
		protected function updateMotion():void
		{
			if (moves)
			{
				// Рассчет скорости вращения
				var vc:Number;
				vc = (AntMath.calcVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngularVelocity) - angularVelocity) * 0.5;

				angularVelocity += vc;
				angle = AntMath.normAngleDeg(angle + angularVelocity * AntG.elapsed);
				angularVelocity += vc;

				// Рассчет скорости движения по x
				vc = (AntMath.calcVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x) * 0.5;
				velocity.x += vc;
				var dx:Number = velocity.x * AntG.elapsed;
				velocity.x += vc;

				// Рассчет скорости движения по y
				vc = (AntMath.calcVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y) * 0.5;
				velocity.y += vc;
				var dy:Number = velocity.y * AntG.elapsed;
				velocity.y += vc;

				x += dx;
				y += dy;
				
				if (parent != null)
				{
					locate(parent.globalX, parent.globalY, parent.globalAngle);
				}
			}		
		}
		
		/**
		 * Сохраняет предыдущие значения положения и угла для оптимизации рассчетов.
		 */
		protected function saveOldPosition():void
		{
			_oldPosition.set(globalX, globalY);
			_oldSize.set(width, height);
			_oldScale.set(scaleX, scaleY);
			_oldAngle = globalAngle;
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
		 * Возвращает глубину обработки и рендера для сущности.
		 */
		public function get depth():int
		{
			return _depth;
		}
		
		/**
		 * Определяет имеются ли в сущности дочерние сущности.
		 */
		public function get isGroup():Boolean
		{
			return (children != null) ? true : false;
		}
		
		/**
		 * Определяет реагирует ли сущность на позиционирование камеры.
		 */
		public function get isScrolled():Boolean { return (scrollFactor.x == 0 && scrollFactor.y == 0) ? false : true; }
		public function set isScrolled(value:Boolean):void
		{
			scrollFactor.x = scrollFactor.y = (value) ? 1 : 0;
		}
		
	}

}