package ru.antkarlov.anthill
{
	import ru.antkarlov.anthill.*;
	import ru.antkarlov.anthill.debug.AntDrawer;
	import ru.antkarlov.anthill.utils.AntColor;
	
	import flash.geom.Rectangle;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	/**
	 * Используется для создания и работы с тайловыми картами. Присуствует два режима работы с тайловыми картами:
	 * растеризация графики и разрезание на тайлы из клипа и классические тайловые карты.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Антон Карлов
	 * @since  07.09.2012
	 */
	public class AntTileMap extends AntEntity
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		
		/**
		 * Событие выполняющееся при запуске процесса кэширования.
		 */
		public var eventStart:AntEvent;
		
		/**
		 * Событие выполняющееся при каждом шаге кэширования.
		 * <p>Внимание: В качестве атрибута в функцию передается 
		 * процент выполненной работы: <code>function yourFunc(percent:int):void { trace(percent); }</code></p>
		 */
		public var eventProcess:AntEvent;
		
		/**
		 * Событие выполняющееся при завершении процесса кэширования.
		 */
		public var eventComplete:AntEvent;
		
		/**
		 * Список всех тайлов, используется для доступа к тайлам по индексу.
		 */
		public var tiles:Array;
		
		/**
		 * Смещение центра для всех тайлов. Следует указывать для классической 
		 * тайловой карты в том случае, если нулевая точка в графическом представлении 
		 * (тайлсете) не в левом верхнем углу.
		 * <p>Например, вам необходимо сделать так чтобы у тайлов нулевая точка была в центре тайла,
		 * предположим, что тайлы имеют размер 64x64, в этом случае необходимо задать <code>tileAxisOffset.set(32, 32);</code></p>
		 * @default (0,0)
		 */
		public var tileAxisOffset:AntPoint;
		
		/**
		 * Определяет сколько тайлов кэшируется за один шаг. Чем больше шаг тем быстрее выполняется кэширование,
		 * но чем больше размер тайлов, тем меньшее количество тайлов следует кэшировать за один шаг.
		 * @default    10
		 */
		public var numPerStep:int;
		
		/**
		 * Определяет следует ли использовать быстрый способ отрисовки тайлов. Быстрый способ отрисовки
		 * игнорирует сортировку тайлов и рисует только те тайлы, которые видят камеры. Рекомендуется использовать
		 * для тайловых кэшированных из клипов.
		 * @default    false
		 */
		public var drawQuickly:Boolean;
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Указатель на анимацию созданную тайловой картой при кэшировании клипа.
		 * @default    null
		 */
		protected var _internalTileSet:AntAnimation;
		
		/**
		 * Указатель на анимацию добавленную в тайловую карту для графического представления тайлов (тайлсет).
		 * @default    null
		 */
		protected var _externalTileSet:AntAnimation;
		
		/**
		 * Размер тайлов по ширине.
		 * @default    32
		 */
		protected var _tileWidth:int;
		
		/**
		 * Размер тайлов по высоте.
		 * @default    32
		 */
		protected var _tileHeight:int;
		
		/**
		 * Количество строк.
		 * @default    8
		 */
		protected var _numRows:int;
		
		/**
		 * Количество столбцов.
		 * @default    8
		 */
		protected var _numCols:int;
		
		/**
		 * Общее количество тайлов.
		 * @default    64
		 */
		protected var _numTiles:int;
		
		/**
		 * Очередь клипов для растеризации.
		 */
		protected var _queue:Vector.<Object>;
		
		/**
		 * Индекс текущего клипа для растеризации.
		 */
		protected var _queueIndex:int;
		
		/**
		 * Экземпляр текущего растеризируемого клипа.
		 */
		protected var _clip:MovieClip;
		
		/**
		 * Индекс текущего растеризируемого тайла.
		 */
		protected var _tileIndex:int;
		
		/**
		 * Общее количество тайлов текущего клипа для растеризации.
		 */
		protected var _tilesTotal:int;
		
		/**
		 * Количество строк в текущем клипе для растеризации.
		 */
		protected var _clipRows:int;
		
		/**
		 * Количество столбцов в текущем клипе для растеризации.
		 */
		protected var _clipCols:int;
		
		/**
		 * Смещение тайлов по X.
		 */
		protected var _tileOffsetX:int;
		
		/**
		 * Смещение тайлов по Y.
		 */
		protected var _tileOffsetY:int;
		
		/**
		 * Текущий процесс хода кэширования.
		 */
		protected var _processCurrent:int;
		
		/**
		 * Общий процесс для хода кэширования.
		 */
		protected var _processTotal:int;
		
		/**
		 * Флаг определяющий началось ли кэширование.
		 */
		protected var _cacheStarted:Boolean;
		
		/**
		 * Флаг определяющий завершилось ли кэширование.
		 */
		protected var _cacheFinished:Boolean;
		
		/**
		 * Помошник для растеризации тайлов.
		 */
		protected var _rect:Rectangle;
		
		/**
		 * Помошник для растеризации тайлов.
		 */
		protected var _matrix:Matrix;
		
		/**
		 * Помошник для быстрой отрисовки тайлов.
		 */
		protected var _topLeft:AntPoint;
		
		/**
		 * Помошник для быстрой отрисовки тайлов.
		 */
		protected var _bottomRight:AntPoint;
		
		/**
		 * Помошник для быстрой отрисовки тайлов.
		 */
		protected var _curPoint:AntPoint;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function AntTileMap()
		{
			super();
			
			eventStart = new AntEvent();
			eventProcess = new AntEvent();
			eventComplete = new AntEvent();
			tiles = [];
			tileAxisOffset = new AntPoint();
			numPerStep = 10;
			drawQuickly = false;
			
			children = [];
			numChildren = 0;
			
			_tileWidth = 32;
			_tileHeight = 32;
			
			_numRows = 8;
			_numCols = 8;
			
			_queue = new <Object>[];
			_clip = null;
			_tileIndex = 0;
			_tilesTotal = 0;
			_queueIndex = 0;
			_clipRows = 0;
			_clipCols = 0;
			_tileOffsetX = 0;
			_tileOffsetY = 0;
			
			_processCurrent = 0;
			_processTotal = 0;
			
			_cacheStarted = false;
			_cacheFinished = false;
			
			_rect = new Rectangle();
			_matrix = new Matrix();
			
			_topLeft = new AntPoint();
			_bottomRight = new AntPoint();
			_curPoint = new AntPoint();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			eventStart.clear();
			eventProcess.clear();
			eventComplete.clear();
			
			eventStart = null;
			eventProcess = null;
			eventComplete = null;
			
			if (_internalTileSet != null)
			{
				_internalTileSet.destroy();
				_internalTileSet = null;
			}
			
			_externalTileSet = null;
			super.destroy();
			tiles = null;
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function kill():void
		{
			var i:int = 0;
			var n:int = tiles.length;
			while (i < n)
			{
				tiles[i] = null;
				i++;
			}
			
			super.kill();
		}
		
		/**
		 * Добавляет клип в очередь для разрезания на плитки и растеризации.
		 * 
		 * <p>Если необходимо собрать тайловую карту из нескольких клипов, то необходимо указывать смещение и область тайловой карты в которую
		 * будет произведена растеризация. Например, есть два клипа размером 640x640 пикселей, которые необходимо разрезать на тайлы размером 64 пикселя
		 * и объеденить все это в одной тайловой карте.</p>
		 * 
		 * <p>Пример использования:</p>
		 * 
		 * <listing>
		 * var tileMap:AntTileMap = new AntTileMap();
		 * tileMap.setMapSize(20, 10);
		 * tileMap.setTileSize(64, 64);
		 * // Содержимое первого клипа будет размещено в: по высоте с 0 по 10 тайлы; и по ширине с 0 по 10 тайлы.<br>
		 * tileMap.addClip(MyLevelA_mc, 0, 0, 10, 10);
		 * // Содержимое второго клипа размещено в: по высоте с 0 по 10 тайлы; и по ширине с 10 по 20 тайлы.<br>
		 * tileMap.addClip(MyLevelB_mc, 10, 0, 20, 10);
		 * tileMap.cacheClips();
		 * </listing>
		 * 
		 * @param	aClipClass	 Класс клипа содержимое которого будет растеризировано и разрезано на тайлы.
		 * @param	aLeft	 Задает левую границу с которой начнется запись тайлов.
		 * @param	aTop	 Задает верхнюю границу с которой начнется запись тайлов.
		 * @param	aRight	 Задает правую границу по которую будет выполнятся запись тайлов.
		 * @param	aBottom	 Задает нижнию границу по которую будет выполнятся запись тайлов.
		 */
		public function addClip(aClipClass:Class, aLeft:int = -1, aTop:int = -1, aRight:int = -1, aBottom:int = -1):void
		{
			var areaLower:AntPoint = (aLeft < 0 && aTop < 0) ? new AntPoint(0, 0) : new AntPoint(aLeft, aTop);
			var areaUpper:AntPoint = (aRight < 0 && aBottom < 0) ? new AntPoint(_numCols, _numRows) : new AntPoint(aRight, aBottom);		
			_queue.push({ clipClass:aClipClass, areaLower:areaLower, areaUpper:areaUpper });
		}
		
		/**
		 * Запускает процесс растеризации тайловой карты из добавленных ранее клипов.
		 */
		public function cacheClips():void
		{
			if (_queue.length == 0)
			{
				AntG.log("WARNING: Unable to perform caching. Don't have clips for caching.", "error");
				return;
			}
			
			if (_cacheStarted)
			{
				AntG.log("WARNING: Unable to perform caching. Another clip in processing.", "error");
				return;
			}
			
			kill();
			revive();
			
			_queueIndex = -1;
			_processCurrent = 0;
			_cacheStarted = true;
			_cacheFinished = false;
			
			eventStart.send();
			resetTileSet();
			cacheClip();
		}
		
		/**
		 * Быстрый спосбо создания тайловой карты из указанного клипа. Не позволяет отслеживать
		 * ход выполнения кэширования и при больших объемах графики может привести к аварийному 
		 * завершению скрипта из-за большой задержки. Так же не подходит для создания тайловой 
		 * карты из нескольких клипов. Следует использовать только для маленьких тайловых карт
		 * и отладки.
		 * 
		 * @param	aClipClass	 Класс клипа содержимое которого будет растеризировано и разрезано на тайлы.
		 * @return		Возвращает указатель на анимацию с растеризированной графикой уровня.
		 */
		public function cacheClipQuickly(aClipClass:Class):AntAnimation
		{
			if (!(aClipClass is MovieClip))
			{
				return null;
			}
			
			kill();
			resetTileSet();
			
			var clip:MovieClip = new (aClipClass as MovieClip);
			var tileX:int = 0;
			var tileY:int = 0;
			var tile:AntActor;
			var bmpData:BitmapData;
			
			var i:int = 0;
			while (i < _numTiles)
			{
				tileY = AntMath.floor(i / _numCols);
				tileX = i - tileY * _numCols;
				
				_rect.x = tileX * _tileWidth;
				_rect.y = tileY * _tileHeight;
				
				bmpData = new BitmapData(_tileWidth, _tileHeight, true, 0);
				_matrix.identity();
				_matrix.translate(-_rect.x, -_rect.y);
				bmpData.draw(clip, _matrix);
				
				_internalTileSet.frames[i] = bmpData;
				_internalTileSet.offsetX[i] = 0;
				_internalTileSet.offsetY[i] = 0;
				
				tile = recycle(AntActor) as AntActor;
				if (!tile.exists)
				{
					tile.revive();
				}
				
				tile.active = false;
				tile.addAnimation(_internalTileSet);
				tile.gotoAndStop(i + 1);
				tile.x = _rect.x;
				tile.y = _rect.y;
				tiles[i] = tile;
				add(tile);
				i++;
			}
			
			revive();
			return _internalTileSet;
		}
		
		/**
		 * Устанавливает новый размер тайловой карты.
		 * 
		 * @param	aCols	 Количество столбцов (ячеек по ширине).
		 * @param	aRows	 Количество строк (ячеек по высоте).
		 */
		public function setMapSize(aCols:int, aRows:int):void
		{
			_numCols = aCols;
			_numRows = aRows;
			_numTiles = _numCols * _numRows;
			updateSettings();
		}
		
		/**
		 * Устанавливает новый размер тайла.
		 * 
		 * @param	aWidth	 Размер тайла по ширине.
		 * @param	aHeight	 Размер тайла по высоте.
		 */
		public function setTileSize(aWidth:int, aHeight:int):void
		{
			_tileWidth = aWidth;
			_tileHeight = aHeight;
			updateSettings();
		}
		
		/**
		 * Устанавливает графическое представление тайлов из анимации.
		 * 
		 * @param	aAnimation	 Анимация кадры которой представляют собой вариации тайлов. 
		 */
		public function setTileSet(aAnimation:AntAnimation):void
		{
			_externalTileSet = aAnimation;
			var actor:AntActor;
			var i:int = 0;
			while (i < numChildren)
			{
				actor = children[i] as AntActor;
				if (actor != null)
				{
					actor.clearAnimations();
					actor.addAnimation(_externalTileSet);
					actor.gotoAndStop(1);
				}
				i++;
			}
			
			if (_internalTileSet != null)
			{
				_internalTileSet.destroy();
				_internalTileSet = null;
			}
		}
		
		/**
		 * Устанавливает графическое представление тайлов из анимации находящейся в кэше анимаций.
		 * 
		 * @param	aKey	 Имя анимации в кэше анимаций.
		 */
		public function setTileSetFromCache(aKey:String):void
		{
			setTileSet(AntAnimation.fromCache(aKey));
		}
		
		/**
		 * Устанавливает фактор прокрутки для всех тайлов.
		 * 
		 * @param	aX	 Коэфицент прокрутки по X.
		 * @param	aY	 Коэфицент прокрутки по Y.
		 */
		public function setScrollFactor(aX:Number = 1, aY:Number = 1):void
		{
			var actor:AntActor;
			var i:int = 0;
			while (i < numChildren)
			{
				actor = children[i] as AntActor;
				if (actor != null)
				{
					actor.scrollFactor.set(aX, aY);
				}
				i++;
			}
			
			scrollFactor.set(aX, aY);
		}
		
		/**
		 * Переключает кадр тайла по его индексу.
		 * 
		 * @param	aIndex	 Индекс тайла для которого необходимо переключить кадр.
		 * @param	aFrame	 Номер кадра на который необходимо переключится.
		 */
		public function switchFrame(aIndex:int, aFrame:int):void
		{
			if (aIndex < 0 || aIndex >= tiles.length)
			{
				return;
			}
			
			var actor:AntActor = tiles[aIndex] as AntActor;
			if (actor != null && actor.exists)
			{
				actor.gotoAndStop(aFrame);
			}
		}
		
		/**
		 * Возвращает индекс тайла по координатам ячейки.
		 * 
		 * @param	aX	 Координата ячейки по X.
		 * @param	aY	 Координата ячейки по Y.
		 * @return		Возвращает индекс тайла от 0 до numTiles - 1.
		 */
		public function getIndex(aX:int, aY:int):int
		{
			return AntMath.trimToRange(_numCols * aY + aX, 0, _numTiles - 1);
		}
		
		/**
		 * Возвращает индекс тайла по произвольным координатам в пикселях.
		 * 
		 * @param	aX	 Позиция в пикселях по X.
		 * @param	aY	 Позиция в пикселях по Y.
		 * @return		Возвращает индекс тайла от 0 до numTiles - 1.
		 */
		public function getIndexByPosition(aX:Number, aY:Number):int
		{
			var tileX:int = AntMath.floor((aX - globalX + tileAxisOffset.x) / _tileWidth);
			var tileY:int = AntMath.floor((aY - globalY + tileAxisOffset.y) / _tileHeight);
			return getIndex(AntMath.trimToRange(tileX, 0, _numCols - 1), AntMath.trimToRange(tileY, 0, _numRows - 1));
		}
		
		/**
		 * Возвращает коордианты ячейки по индексу тайла.
		 * 
		 * @param	aIndex	 Индекс тайла.
		 * @param	aResult	 Точка куда может быть записан результат.
		 * @return		Возвращает координаты ячейки.
		 */
		public function getCoordinates(aIndex:int, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			aIndex = AntMath.trimToRange(aIndex, 0, _numTiles - 1);
			aResult.y = AntMath.floor(aIndex / _numCols);
			aResult.x = aIndex - aResult.y * _numCols;
			
			return aResult;
		}
		
		/**
		 * Возвращает позицию ячейки в пикселях по индексу тайла.
		 * 
		 * @param	aIndex	 Индекс тайла.
		 * @param	aResult	 Точка куда может быть записан результат.
		 * @return		Возвращает позицию ячейки в пикселях.
		 */
		public function getPosition(aIndex:int, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			getCoordinates(aIndex, aResult);
			aResult.x = aResult.x * _tileWidth + x - tileAxisOffset.x;
			aResult.y = aResult.y * _tileHeight + y - tileAxisOffset.y;
			return aResult;
		}
		
		/**
		 * @private
		 */
		public function getGlobalPosition(aIndex:int, aResult:AntPoint = null):AntPoint
		{
			if (aResult == null)
			{
				aResult = new AntPoint();
			}
			
			getPosition(aIndex, aResult);
			if (parent != null)
			{
				aResult.x += parent.globalX;
				aResult.y += parent.globalY;
			}
			return aResult;
		}
		
		/**
		 * @private
		 */
		public function getMyTile(aIndex:int, aClass:Class = null):AntEntity
		{
			if (aIndex < 0 || aIndex >= tiles.length)
			{
				return null;
			}
			
			var point:AntPoint = getCoordinates(aIndex);			
			var tile:AntEntity = tiles[aIndex];
			if (tile == null)
			{
				if (aClass != null)
				{
					tile = recycle(aClass) as AntActor;
					if (!tile.exists)
					{
						tile.revive();
						var ind:int = tiles.indexOf(tile);
						if (ind >= 0 && ind < tiles.length)
						{
							tiles[ind] = null;
						}
					}

					tile.reset(point.x * _tileWidth, point.y * _tileHeight);
					tiles[aIndex] = tile;
					return tile;
				}
				
				return null;
			}
			
			return tile;
		}
		
		/**
		 * Безопасное извлечение тайла из карты по индексу.
		 * 
		 * <p>Примечание: Вернет <code>null</code> если указанный индекс тайла выходит за пределы карты или если тайл не существует.
		 * С флагом <code>aAutoCreate = true</code>, вернет <code>null</code> только в случае выхода индекса за пределы тайловой карты.</p>
		 * 
		 * @param	aIndex	 Индекс тайла который необходимо получить.
		 * @param	aAutoCreate	 Флаг активирующий автоматическое создание тайла по индексу если тайла не существует.
		 * @return		Возвращает указатель на тайл по индексу. 
		 */
		public function getTile(aIndex:int, aAutoCreate:Boolean = false):AntActor
		{
			if (aIndex < 0 || aIndex >= tiles.length)
			{
				return null;
			}
			
			var point:AntPoint = getCoordinates(aIndex);			
			var tile:AntActor = tiles[aIndex] as AntActor;
			if (tile == null)
			{
				if (aAutoCreate)
				{
					tile = recycle(AntActor) as AntActor;
					if (!tile.exists)
					{
						tile.revive();
						tile.clearAnimations();
						
						var ind:int = tiles.indexOf(tile);
						if (ind >= 0 && ind < tiles.length)
						{
							tiles[ind] = null;
						}
					}

					if (_externalTileSet != null)
					{
						tile.addAnimation(_externalTileSet);
						tile.gotoAndStop(1);
					}
					
					tile.active = false;
					tile.reset(point.x * _tileWidth, point.y * _tileHeight);
					tiles[aIndex] = tile;
					return tile;
				}
				
				return null;
			}
			
			return tile;
		}
		
		/**
		 * @private
		 */
		public function queryRectIndexes(aFirstIndex:int, aLastIndex:int, aResult:Array = null):Array
		{
			if (aResult == null)
			{
				aResult = [];
			}
			
			if (aFirstIndex == aLastIndex)
			{
				aResult[aResult.length] = aFirstIndex;
				return aResult;
			}
			
			var tmp:Number = 0;
			var lowerPos:AntPoint = getCoordinates(aFirstIndex);
			var upperPos:AntPoint = getCoordinates(aLastIndex);
			
			if (upperPos.x < lowerPos.x)
			{
				tmp = upperPos.x;
				upperPos.x = lowerPos.x;
				lowerPos.x = tmp;
			}
			
			if (upperPos.y < lowerPos.y)
			{
				tmp = upperPos.y;
				upperPos.y = lowerPos.y;
				lowerPos.y = tmp;
			}
			
			var i:int;
			var j:int;
			if (lowerPos.y == upperPos.y)
			{
				for (i = lowerPos.x; i <= upperPos.x; i++)
				{
					aResult[aResult.length] = getIndex(i, lowerPos.y);
				}
			}
			else
			{
				for (i = lowerPos.y; i <= upperPos.y; i++)
				{
					for (j = lowerPos.x; j <= upperPos.x; j++)
					{
						aResult[aResult.length] = getIndex(j, i);
					}
				}
			}
			
			return aResult;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw(aCamera:AntCamera):void
		{
			if (drawQuickly)
			{
				drawQuick(aCamera);
			}
			else
			{
				super.draw(aCamera);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function debugDraw(aCamera:AntCamera):void
		{
			var p1:AntPoint = new AntPoint();
			var p2:AntPoint = new AntPoint();
			var drawer:AntDrawer = AntG.debugDrawer;
			if (drawer.showGrid)
			{
				var i:int = 0;
				for (i = 0; i < _numRows + 1; i++)
				{
					p1.x = globalX + aCamera.scroll.x * scrollFactor.x - tileAxisOffset.x;
					p2.x = globalX + _tileWidth * _numCols + aCamera.scroll.x * scrollFactor.x - tileAxisOffset.x;
					p1.y = p2.y = globalY + _tileHeight * i + aCamera.scroll.y * scrollFactor.y - tileAxisOffset.y;
					drawer.drawLine(p1.x, p1.y, p2.x, p2.y, AntColor.GRAY);
				}
				
				for (i = 0; i < _numCols + 1; i++)
				{
					p1.x = p2.x = globalX + _tileWidth * i + aCamera.scroll.x * scrollFactor.x - tileAxisOffset.x;
					p1.y = globalY + aCamera.scroll.y * scrollFactor.y - tileAxisOffset.y;
					p2.y = globalY + _tileHeight * _numRows + aCamera.scroll.y * scrollFactor.y - tileAxisOffset.y;
					drawer.drawLine(p1.x, p1.y, p2.x, p2.y, AntColor.GRAY);
				}
			}
			
			super.debugDraw(aCamera);
		}
		
		//---------------------------------------
		// PROTECTED METHODS
		//---------------------------------------
		
		/**
		 * Быстрая отрисовка только тех тайлов которые попадают в поле видимости камер.
		 * Другие тайлы полностью игнорируются.
		 */
		protected function drawQuick(aCamera:AntCamera):void
		{
			var dx:Number = aCamera.scroll.x * -1 * scrollFactor.x;
			var dy:Number = aCamera.scroll.y * -1 * scrollFactor.y;
			
			getCoordinates(getIndexByPosition(dx, dy), _topLeft);
			getCoordinates(getIndexByPosition(dx + aCamera.width, dy + aCamera.height), _bottomRight);
								
			_bottomRight.increment(1);
			var numX:int = _bottomRight.x - _topLeft.x;
			var numY:int = _bottomRight.y - _topLeft.y;
			var total:int = numX * numY;
			
			_curPoint.copyFrom(_topLeft);
			var i:int = 0;
			var tile:AntActor;
			while (i < total)
			{
				tile = tiles[getIndex(_curPoint.x, _curPoint.y)] as AntActor;
				if (tile != null && tile.exists && tile.visible)
				{
					tile.updateBounds();
					tile.drawActor(aCamera);
				}
				
				_curPoint.x++;
				if (_curPoint.x >= _bottomRight.x)
				{
					_curPoint.x = _topLeft.x;
					_curPoint.y++;
				}
				i++;
			}
		}
		
		/**
		 * Сбрасывает текущий тайлсет.
		 */
		protected function resetTileSet():void
		{
			if (_internalTileSet != null)
			{
				_internalTileSet.destroy();
			}
			
			_internalTileSet = new AntAnimation("TileMap");
			_internalTileSet.width = _rect.width = _tileWidth;
			_internalTileSet.height = _rect.height = _tileHeight;
			_internalTileSet.frames = new Array(_numTiles);
			_internalTileSet.offsetX = new Array(_numTiles);
			_internalTileSet.offsetY = new Array(_numTiles);
			_internalTileSet.totalFrames = _processTotal = numTilesForCaching();
		}
		
		/**
		 * Обновляет настройки карты.
		 */
		protected function updateSettings():void
		{
			width = _numCols * _tileWidth;
			height = _numRows * _tileHeight;
			
			var i:int = 0;
			var n:int = tiles.length;
			var tile:AntActor;
			
			if (tiles.length < _numTiles)
			{
				tiles.length = _numTiles;
			}
			else if (tiles.length > _numTiles)
			{
				i = _numTiles - 1;
				while (i < n)
				{
					tile = tiles[i] as AntActor;
					if (tile != null)
					{
						tile.destroy();
					}
					
					tiles[i] = null;
					i++;
				}
				
				tiles.length = _numTiles;
			}
			
			var pos:AntPoint = new AntPoint();
			i = 0;
			while (i < n)
			{
				getCoordinates(i, pos);
				tile = tiles[i] as AntActor;
				if (tile != null)
				{
					tile.x = pos.x * _tileWidth;
					tile.y = pos.y * _tileHeight;
				}
				i++;
			}
		}
		
		/**
		 * Кэширует очередной клип из очереди клипов.
		 */
		protected function cacheClip():void
		{
			_queueIndex++;
			var o:Object = _queue[_queueIndex];
			
			_clipCols = o.areaUpper.x - o.areaLower.x;
			_clipRows = o.areaUpper.y - o.areaLower.y;
			_tileOffsetX = o.areaLower.x;
			_tileOffsetY = o.areaLower.y;
			_tileIndex = 0;
			_tilesTotal = (o.areaUpper.x - o.areaLower.x) * (o.areaUpper.y - o.areaLower.y);
			_clip = new (o.clipClass as Class);
			step();
		}
		
		/**
		 * Шаг кэширования.
		 */
		protected function step():void
		{
			var tileX:int = 0;
			var tileY:int = 0;
			
			var n:int = _tileIndex + numPerStep;
			n = (n >= _tilesTotal) ? _tilesTotal : n;
			
			var bmpData:BitmapData;
			var tile:AntActor;
			
			for (var i:int = _tileIndex; i < n; i++)
			{
				tileY = AntMath.floor(i / _clipCols);
				tileX = i - tileY * _clipCols;
				
				_rect.x = tileX * _tileWidth;
				_rect.y = tileY * _tileHeight;
				
				bmpData = new BitmapData(_tileWidth, _tileHeight, true, 0);
				_matrix.identity();
				_matrix.translate(-_rect.x, -_rect.y);
				bmpData.draw(_clip, _matrix);
				
				_internalTileSet.frames[i] = bmpData;
				_internalTileSet.offsetX[i] = 0;
				_internalTileSet.offsetY[i] = 0;
				
				tile = recycle(AntActor) as AntActor;
				if (!tile.exists)
				{
					tile.revive();
				}
				
				tile.active = false;
				tile.addAnimation(_internalTileSet);
				tile.gotoAndStop(i + 1);
				tile.x = _rect.x + _tileOffsetX * _tileWidth;
				tile.y = _rect.y + _tileOffsetY * _tileHeight;
				tiles[i] = tile;
				add(tile);
				_processCurrent++;
			}
			
			_tileIndex = n;
			eventProcess.send([ AntMath.toPercent(_processCurrent, _processTotal) ]);
			
			if (_tileIndex == _tilesTotal)
			{
				if (_queueIndex + 1 >= _queue.length)
				{
					_queue.length = 0;
					_clip = null;
					
					_cacheFinished = true;
					_cacheStarted = false;
					
					eventComplete.send();
				}
				else
				{
					cacheClip();
				}
			}
			else
			{
				setTimeout(step, 1);
			}
		}
		
		/**
		 * Считает общее количество тайлов для кэширования.
		 */
		protected function numTilesForCaching():int
		{
			var sum:int = 0;
			var i:int = 0;
			var n:int = _queue.length;
			var o:Object;
			while (i < n)
			{
				o = _queue[i++];
				if (o != null)
				{
					sum += (o.areaUpper.x - o.areaLower.x) * (o.areaUpper.y - o.areaLower.y);
				}
			}
			
			return sum;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * Количество столбцов.
		 */
		public function get numCols():int
		{
			return _numCols;
		}
		
		/**
		 * Количество строк.
		 */
		public function get numRows():int
		{
			return _numRows;
		}
		
		/**
		 * Количество тайлов.
		 */
		public function get numTiles():int
		{
			return _numTiles;
		}
		
		/**
		 * Ширина тайлов.
		 */
		public function get tileWidth():int
		{
			return _tileWidth;
		}
		
		/**
		 * Высота тайлов.
		 */
		public function get tileHeight():int
		{
			return _tileHeight;
		}
		
		/**
		 * @private
		 */
		public function get mapWidth():int
		{
			return _numCols * _tileWidth;
		}
		
		/**
		 * @private
		 */
		public function get mapHeight():int
		{
			return _numRows * _tileHeight;
		}
	
	}

}