package net.blaxstar.components {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;

  import net.blaxstar.style.Style;

  import thirdparty.org.osflash.signals.natives.NativeSignal;

  /**
   * Card class, a component inspired by Google's Material Card. It can be used as a layout container for components.
   * @author SnaiLegacy
   */
  public class Card extends Component {
    static private const MIN_WIDTH:uint = 600;
    static private const MIN_HEIGHT:uint = 600;

    private var _cardBG:Sprite;
    protected var _componentContainer:VerticalBox;
    protected var _optionContainer:HorizontalBox;
    private var _autoResize:Boolean;
    private var _draggable:Boolean;
    private var _checkable:Boolean;
    private var _onMouseDown:NativeSignal;
    private var _onMouseUp:NativeSignal;
    private var _onClick:NativeSignal;

    /**
     *
     * @param    parent the parent object to add this card to.
     */
    public function Card(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, autoResize:Boolean = true) {
      _autoResize = autoResize;
      super(parent);
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children
     * and committing the visual changes to be written on the next frame.
     * created to be overridden.
     */
    override public function init():void {
      _width_ = MIN_WIDTH;
      _height_ = MIN_HEIGHT;
      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {
      _componentContainer = new VerticalBox();
      _optionContainer = new HorizontalBox();
      _cardBG = new Sprite();

      _componentContainer.width = 30;
      _componentContainer.spacing = 10;
      _optionContainer.spacing = 10;

      _cardBG.graphics.beginFill(Style.SURFACE.value, 1);
      _cardBG.graphics.drawRect(0, 0, 1, 1);
      _cardBG.graphics.endFill();

      super.addChild(_cardBG);
      super.addChild(_componentContainer);
      super.addChild(_optionContainer);
      applyShadow();

      super.addChildren();
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      // auto resize if enabled, and there are children present

      if (_autoResize) {
        var totalW:Number = (PADDING * 2) + Math.max(_componentContainer.width, _optionContainer.width);
        var totalH:Number = (PADDING * 2) + _componentContainer.height + _optionContainer.height;

        if (totalW > MIN_WIDTH)
          _width_ = totalW;
        if (totalH > MIN_HEIGHT)
          _height_ = totalH;
      }

      if (_cardBG) {
        drawBG();
        _optionContainer.move(PADDING, _height_ - PADDING - _optionContainer.height);
      }
      super.draw();
    }

    /** END INTERFACE ===================== */
    override public function updateSkin():void {
      drawBG();
    }

    // adds child to card, nesting it inside a layout container (Vertical Box).
    public function addChildNative(child:DisplayObject):flash.display.DisplayObject {
      return super.addChild(child);
    }

    override public function addChild(child:DisplayObject):flash.display.DisplayObject {
      return addChildToContainer(child);
    }

    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
      return addChildToContainer(child, index);
    }

    public function addChildToContainer(child:DisplayObject, index:int = -1):DisplayObject {
      if (index > -1)
        _componentContainer.addChildAt(child, index);
      else
        _componentContainer.addChild(child);
      commit();
      return child;
    }

    public function set viewableItems(val:Number):void {
      _componentContainer.viewableItems = val;
    }

    public function set maskThreshold(val:Number):void {
      _componentContainer.maskThreshold = val;
    }

    public function set autoResize(val:Boolean):void {
      _autoResize = val;
    }

    public function set draggable(val:Boolean):void {
      _draggable = val;
      if (_draggable) {
        if (!_onMouseDown)
          _onMouseDown = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
        _onMouseDown.add(onStartDrag);
      }
      else {
        if (!_onMouseDown)
          return;
        else
          _onMouseDown.remove(onStartDrag);
      }
    }

    public function get componentContainer():VerticalBox {
      return _componentContainer;
    }

    public function get optionContainer():HorizontalBox {
      return _optionContainer;
    }

    public function set checkable(val:Boolean):void {
      _checkable = val;
      if (_checkable) {
        if (!_onClick)
          _onClick = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
        _onClick.add(onSelect);
      }
    }

    private function drawBG():void {
      if (!_cardBG) return;

      _cardBG.graphics.clear();
      _cardBG.graphics.beginFill(Style.SURFACE.value, 1);
      _cardBG.graphics.lineStyle(0.5, Style.SURFACE.value, .2);
      _cardBG.graphics.drawRoundRect(0, 0, _width_, _height_, 7);
      _cardBG.graphics.endFill();
    }

    private function onSelect():void {
      // TODO (dyxribo): Implement selection property and indicator to Card

    }

    private function onStartDrag(e:MouseEvent = null):void {
      this.startDrag();
      if (!_onMouseUp)
        _onMouseUp = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent);
      _onMouseUp.add(onStopDrag);
    }

    private function onStopDrag(e:MouseEvent = null):void {
      this.stopDrag();
      if (!_onMouseDown)
        _onMouseDown = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
      _onMouseDown.add(onStartDrag);
    }

    override public function destroy(e:Event = null):void {
      super.destroy(e);
      if (_onMouseDown)
        _onMouseDown.removeAll();
      if (_onMouseUp)
        _onMouseUp.removeAll();
      if (_onClick)
        _onClick.removeAll();
    }

  }

}