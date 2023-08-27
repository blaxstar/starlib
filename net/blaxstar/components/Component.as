package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.filters.DropShadowFilter;

  import net.blaxstar.math.Arithmetic;

  import thirdparty.org.osflash.signals.Signal;
  import thirdparty.org.osflash.signals.natives.NativeSignal;
  import net.blaxstar.style.Style;

  /**
   * Base Component Class.
   * @author Deron D. (decamp.deron@gmail.com)
   */
  public class Component extends Sprite implements IComponent {

    static protected var _resizeEvent_:Event;

    static public const DRAW:String = "draw";
    static public const PADDING:uint = 10;

    static public var totalComponents:uint;
    static public var lscmp:Vector.<Component>;

    private var _functionQueue:Vector.<Function>;
    private var _paramQueue:Vector.<Array>;

    protected var _id_:uint;
    protected var _width_:Number;
    protected var _height_:Number;
    protected var _enabled_:Boolean;
    protected var _isShowingBounds_:Boolean;

    public var onEnterFrame:NativeSignal;
    public var onResize:NativeSignal;
    public var onDraw:Signal;
    public var onAdded:NativeSignal;

    /**
     * creates a base Component.
     * @param parent  displayobject container to add the component to.
     * @param xpos  x position of the new component.
     * @param ypos  y position of the new component.
     */
    public function Component(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
      // component tracking
      if (lscmp == null) {
        lscmp = new Vector.<Component>();
        totalComponents = 0;
      }
      lscmp.push(this);
      _id_ = totalComponents++;
      // components are enabled by default.
      _enabled_ = true;
      // move the component's anchor to the correct position...
      move(xpos, ypos);
      // initialize the component...
      init();
      // then add it to parent if parent isn't null.
      if (parent != null) {
        parent.addChild(this);
      }
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children and committing the visual changes to be written on the next frame. created to be overridden.
     */
    public function init():void {
      _functionQueue = new Vector.<Function>();
      _paramQueue = new Vector.<Array>();
      if (!onEnterFrame)
        onEnterFrame = new NativeSignal(this, Event.ENTER_FRAME, Event);
      if (!onAdded)
        onAdded = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
      if (!onResize) {
        _resizeEvent_ = new Event(Event.RESIZE);
        onResize = new NativeSignal(this, Event.RESIZE, Event);
      }
      if (!onDraw)
        onDraw = new Signal();
      addChildren();
      onAdded.addOnce(on_added);
      onEnterFrame.add(checkQueue);
      Style.ON_THEME_UPDATE.add(draw);
    }

    protected function on_added(e:Event):void {
      draw();
    }
    /**
     * queues a function for later execution.
     * @param func  function to be queued.
     * @param ...rest an array of parameters required by the function.
     */
    protected function queueFunction(func:Function, ...rest):void {
      _functionQueue.push(func);
      if (!rest || !rest.length) {
        _paramQueue.push([]);
      }
      else {
        _paramQueue.push(rest);
      }
    }

    /**
     * checks if there are any queued functions available, and attempts to execute them.
     * @param e event param, typically an ENTER_FRAME event.
     */
    protected function checkQueue(e:Event):void {
      if (!_functionQueue.length || !_paramQueue.length)
        return;
      for (var i:uint = 0; i < _functionQueue.length; i++) {
        _functionQueue[i].call(this, _paramQueue[i]);
        _functionQueue.splice(i, 1);
        _paramQueue[i].splice(i, 1);
      }
    }

    /**
     * base method for initializing and adding children of the component. created to be overridden.
     */
    public function addChildren():void {
      // trace('on added triggered from ' + this.toString());
    }

    /**
     * base method for (re)drawing the component itself. created to be overridden.
     */
    public function draw(e:Event = null):void {
      // dispatches a DRAW event
      // onEnterFrame.remove(draw);
      updateSkin();
      if (isShowingBounds)
        updateBounds();
      onDraw.dispatch();
    }

    /** END INTERFACE ===================== */

    public function updateSkin():void {

    }

    /**
     * marks the component for redraw on the next frame.
     * this minimizes the processing load per frame, improving performance.
     */
    public function commit():void {
      onEnterFrame.addOnce(draw);
    }

    /**
     * move the component to the specified x and y position. the positions will be rounded to the nearest integer.
     * @param    xpos    new x position of the component.
     * @param    ypos    new y position of the component.
     */
    public function move(xpos:Number, ypos:Number):void {
      x = Arithmetic.round(xpos);
      y = Arithmetic.round(ypos);
    }

    /**
     * set the width and height of the component, marking it for a redraw on the next frame.
     * @param    w    new width of the component.
     * @param    h    new height of the component.
     */
    public function setSize(w:Number, h:Number):void {
      _width_ = w;
      _height_ = h;
      draw();
      onResize.dispatch(_resizeEvent_);
    }

    /**
     * apply a pre-created dropshadow filter effect on the component.
     */
    public function applyShadow():void {
      filters = [new DropShadowFilter(4, 90, 0, 0.3, 7, 7, .6)];
    }

    /**
     * initialize the stage for proper alignment and scaling of objects.
     * @param    stage the stage of the current window.
     */
    public static function initStage(stage:Stage):void {
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
    }

    override public function get width():Number {
      return _width_;
    }

    override public function set width(value:Number):void {
      _width_ = value;
      commit();
      onResize.dispatch(_resizeEvent_);
    }

    override public function get height():Number {
      return _height_;
    }

    override public function set height(value:Number):void {
      _height_ = value;
      commit();
      onResize.dispatch(_resizeEvent_);
    }

    override public function set x(value:Number):void {
      super.x = Arithmetic.round(value);
    }

    override public function set y(value:Number):void {
      super.y = Arithmetic.round(value);
    }

    public function get id():uint {
      return _id_;
    }

    public function get isShowingBounds():Boolean {
      return _isShowingBounds_;
    }

    public function set isShowingBounds(value:Boolean):void {
      var g:Graphics = this.graphics;

      if (value == true && _width_) {
        if (_isShowingBounds_)
          return;
        else {
          g.lineStyle(1, 0xFF0000, 0.8, true);
          g.drawRect(0, 0, _width_, _height_);
          _isShowingBounds_ = true;
          onDraw.add(updateBounds);
          onResize.add(updateBounds);
        }
      }
      else if (value == false) {
        if (!_isShowingBounds_)
          return;
        else {
          g.clear();
          _isShowingBounds_ = false;
        }
      }
    }

    protected function updateBounds(e:Event = null):void {
      graphics.clear();
      _isShowingBounds_ = false;
      isShowingBounds = true;
    }

    public function set enabled(val:Boolean):void {
      _enabled_ = mouseEnabled = mouseChildren = tabEnabled = val;

      alpha = _enabled_ ? 1.0 : 0.5;
    }

    public function get enabled():Boolean {
      return _enabled_;
    }

    public function destroy(e:Event = null):void {
      IEventDispatcher(e.currentTarget).removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
    }

  }

}
