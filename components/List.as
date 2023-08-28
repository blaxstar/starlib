package net.blaxstar.components {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.utils.Dictionary;

  import net.blaxstar.style.Style;

  /**
   * ...
   * @author Deron Decamp
   */
  public class List extends Component {
    private const PADDING:uint = 7;

    private var _listWidth:uint;
    private var _itemHeight:uint;
    private var _items:Vector.<ListItem>;
    private var _itemsCache:Dictionary;
    private var _itemContainer:VerticalBox;
    private var _maxVisible:uint;
    private var _selectionIndicator:Sprite;
    private var _selectedItem:ListItem;
    private var _useSelectionIndicator:Boolean;
    private var _alternatingColors:Boolean;
    private var _customDelegates:Vector.<Function>;
    private var _defaultFill:uint;

    public function List(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, altColors:Boolean = false) {
      super(parent, xpos, ypos);
      _alternatingColors = altColors;
      _defaultFill = Style.SURFACE.value;
    }

    override public function init():void {
      _width_ = _listWidth = 200;
      _height_ = _itemHeight = 35;
      _items = new Vector.<ListItem>();
      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {
      _itemContainer = new VerticalBox();
      _itemContainer.spacing = 0;
      super.addChild(_itemContainer);
      super.addChildren();
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      if (_itemContainer.numChildren > 0) {
        _itemContainer.removeChildren();
      }
      
      for (var i:uint; i < _items.length; i++) {
        _itemContainer.addChild(_items[i]);
        if (_alternatingColors) {
          if (i % 2 == 0)
            _items[i].fillColor = Style.SURFACE.tint().value;
        }
        _width_ = Math.max(_listWidth, _items[i].labelComponent.width + 10);

      }
      _height_ = _itemContainer.height;
      deselectAllItems();
      super.draw();
    }

    override public function updateSkin():void {
      _defaultFill = Style.SURFACE.value;
    }

    private function deselectAllItems():void {

      for (var i:uint = 0; i < _items.length; i++) {
        _items[i].fillColor = _defaultFill;
      }
      applyShadow();
    }

    override public function addChild(child:DisplayObject):DisplayObject {
      if (child is ListItem) {
        addItem(child as ListItem);
      }
      return child;
    }

    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
      if (child is ListItem) {
        addItemAt(child as ListItem, index);
      }
      return child;
    }

    public function addItem(li:ListItem):List {
      if (!_itemsCache)
        _itemsCache = new Dictionary();
      if (li != null) {
        if (_itemsCache[li.linkageid]) {
          _items.push(li);
        }
        else {
          _itemsCache[li.linkageid] = li;
          _items.push(li);
          li.setSize(_listWidth, _itemHeight + PADDING);
          li.onResize.add(onItemResize);
          li.onRollOver.add(onItemRollOver);
          li.onRollOut.add(onItemRollOut);
          li.onClick.add(onItemClick);
          li.mouseChildren = false;
          if (_customDelegates) {
            for (var j:uint = 0; j < _customDelegates.length; j++) {
              li.onClick.add(_customDelegates[j]);
            }
          }
          _itemContainer.addChild(li);
        }
        draw();
      }
      return this;
    }
    
    public function multiAddByStringArray(itemStringArray:Array):void {
      for (var i:uint = 0; i < itemStringArray.length; i++) {
        if (itemStringArray[i] is String) {
          addItem(new ListItem(null,0,0,itemStringArray[i]));
        }
      }
    }

    public function getCachedItemByID(id:uint):ListItem {
      var li:ListItem;
      // for .. in required, since dictionary has no length prop.
      // maybe create a length prop in this class later? would definitely improve performance
      for (var item:String in _itemsCache) {
        if (_itemsCache[item].linkageid == id) {
          li = _itemsCache[item] as ListItem;
          break;
        }
      }
      return li;
    }

    public function hideList(e:MouseEvent = null):void {
      this.visible = false;
    }

    public function setSelection(itemIndex:uint):void {
      selectItem(_itemContainer.getChildAt(itemIndex) as ListItem);
    }

    public function addClickDelegate(func:Function):void {
      _customDelegates ||= new Vector.<Function>();
      _customDelegates.push(func);
      for (var i:uint; i < _items.length; i++) {
        _items[i].onClick.add(func);
      }
    }

    public function removeClickDelegate(func:Function):void {
      for (var i:uint; i < _items.length; i++) {
        _items[i].onClick.remove(func);
      }
    }

    private function onItemRollOut(e:MouseEvent):void {
      deselectAllItems();
    }

    private function onItemRollOver(e:MouseEvent = null):void {
      var li:ListItem = (e.currentTarget as ListItem);
      deselectAllItems();
      selectItem(li);
    }

    private function selectItem(li:ListItem):void {
      li.fillColor = (Style.CURRENT_THEME == Style.DARK) ? Style.GLOW.value : Style.GLOW.tint().value;
      applyShadow();
    }

    public function clear():void {
      _items.length = 0;
      draw();
    }

    public function get numItems():uint {
      return _itemContainer.numChildren;
    }

    override public function set width(value:Number):void {
      _listWidth = value;
      super.width = value;
    }

    public function set itemHeight(val:Number):void {
      if (val > 0)
        _itemHeight = val;
      draw();
    }

    private function onItemClick(e:MouseEvent):void {
      _selectedItem = e.currentTarget as ListItem;
      hideList();
    }

    private function onItemResize(e:Event = null):void {
      draw();
    }

    private function addSelectionIndicatorListeners():void {
      for (var i:uint = 0; i < _items.length; i++) {
        _items[i].onClick.add(onItemClick);
      }
    }

    private function removeSelectionIndicatorListeners():void {
      for (var i:uint = 0; i < _items.length; i++) {
        _items[i].onClick.remove(onItemClick);
      }
    }

    public function addItemAt(li:ListItem, index:uint = 0):List {
      if (li) {
        _items.splice(index, 0, li);
        commit;
      }
      return this;
    }

    public function get selectedItem():ListItem {
      return _selectedItem;
    }

    public function set useSelectionIndicator(val:Boolean):void {
      _useSelectionIndicator = val;
      if (_useSelectionIndicator)
        addSelectionIndicatorListeners();
      else
        removeSelectionIndicatorListeners();
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);

      for (var i:uint = 0; i < _itemContainer.numChildren; i++) {
        var child:ListItem = ListItem(_itemContainer.getChildAt(i));
        child.onResize.remove(onItemResize);
        child.onClick.remove(onItemClick);
      }
    }

    public function getItemAt(itemIndex:uint):ListItem {
      return _items[itemIndex];
    }
  }

}