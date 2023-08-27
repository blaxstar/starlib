package net.blaxstar.components {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;

  import net.blaxstar.style.Style;

  import thirdparty.org.osflash.signals.Signal;

  public class ScrollbarControl extends Component {
    private const XMIN:uint = 0;
    private const YMIN:uint = 0;
    private const THICKNESS:uint = 10;

    private var _track:Sprite;
    private var _grip:Sprite;
    private var _vertical:Boolean;
    private var _content:DisplayObject;
    private var _viewport:DisplayObject;
    private var _yOffset:uint;
    private var _yMax:uint;
    private var _xOffset:uint;
    private var _xMax:uint;
    private var _scrollRatio:Number;
    private var _gripUpColor:uint;
    private var _gripDownColor:uint;
    private var onScroll:Signal;

    public function ScrollbarControl(parent:DisplayObjectContainer = null, content:DisplayObject = null, viewport:DisplayObject = null, vertical:Boolean = true) {
      _vertical = vertical;
      _content = content;
      _viewport = viewport;
      super(parent);
    }

    override public function init():void {
      _width_ = _height_ = 0;
      _track = new Sprite();
      _grip = new Sprite();
      onScroll = new Signal(Number);
      _gripUpColor = Style.SECONDARY.value;
      _gripDownColor = Style.SECONDARY_LIGHT.value;
      super.init();
    }

    override public function draw(e:Event = null):void {

      if (_vertical) {
        _width_ = THICKNESS;
        _height_ = _viewport.height;
      }
      else {
        _width_ = _viewport.width;
        _height_ = THICKNESS;
      }

      drawTrack();
      drawGrip();

      attach();
      _grip.addEventListener(MouseEvent.MOUSE_DOWN, onGripDown);
    }

    private function drawTrack():void {
      _track.graphics.clear();
      _track.graphics.beginFill(Style.SECONDARY_DARK.value);
      _track.graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
      _track.graphics.endFill();
      if (!_track.parent)
        addChild(_track);
    }

    private function drawGrip(isDown:Boolean = false):void {
      // (re)draw the grip
      var cornerRadius:Number = (_vertical) ? _width_ / 2 : _height_ / 2;
      _grip.graphics.clear();
      _grip.graphics.beginFill((isDown) ? _gripDownColor : _gripUpColor);
      _grip.graphics.drawRoundRect(0, 0, _width_, _height_, cornerRadius, cornerRadius);
      _grip.graphics.endFill();
      updateScrollBarSize();
      if (!_grip.parent)
        addChild(_grip);

      _grip.addEventListener(MouseEvent.MOUSE_DOWN, onGripDown);
      _grip.addEventListener(MouseEvent.RELEASE_OUTSIDE, onGripUp);
      _grip.addEventListener(MouseEvent.MOUSE_UP, onGripUp);
    }

    private function attach():void {
      // if content is vertical
      if (_vertical) {

        x = _viewport.x + _viewport.width - _width_;
        y = _viewport.y;
        // only show the scrollbar if the content is taller than the viewport, and apply scroll listeners.
        if (_content.y + _content.height > _viewport.y + _viewport.height) {
          this.visible = true;
          onScroll.add(scroll);
        }
        else
          this.visible = false;
      }
      else {
        // same thing but horizontally 👇
        x = _viewport.x;
        y = _viewport.y + _viewport.height - _width_;

        if (_content.x + _content.width > _viewport.x + _viewport.width) {
          this.visible = true;
          onScroll.add(scroll);
        }
        else
          this.visible = false;
      }

      drawTrack();
      drawGrip();
    }

    private function updateScrollBarSize():void {
      _scrollRatio ||= _content.height / _viewport.height;
      var scrollThumbHeight:Number = Math.max(20, _height_ / _scrollRatio);
      _grip.height = scrollThumbHeight;
    }

    private function scroll(percent:Number):void {
      // stay calm and ✨ s c r o l l ✨
      var currentRect:Rectangle = (_content.scrollRect) ? _content.scrollRect : new Rectangle(0, 0, _content.width, _content.height);
      if (_vertical)
        currentRect.y = (_grip.y / (_height_)) * _content.height;
      else
        currentRect.x = -(_grip.x / _width_) * _content.width;
      _content.scrollRect = currentRect;
    }

    private function onGripUp(e:MouseEvent):void {
      // redraw to show that the grip is released after being pressed.
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveGrip);
      drawGrip();
    }

    private function onGripDown(e:MouseEvent):void {
      // start moving the grip if the grip is being pressed down...
      stage.addEventListener(MouseEvent.MOUSE_MOVE, moveGrip);

      // ...then redraw to show that the grip is being pressed.
      drawGrip(true);

      // again, draw it horizontally unless stated otherwise.
      if (_vertical) {
        // limit the drag distance of the grip to the height of the track (while accounting for the grip, of course)
        _yMax = height - _grip.height;
        // also account for the location of the mouse, relative to the grip's position.
        _yOffset = mouseY - _grip.y;
      }
      else {
        // do the same thing as above but horizontally 👇
        _xMax = width - _grip.width;
        // that includes the mouse location!
        _xOffset = mouseX - _grip.x;
      }
    }

    private function moveGrip(e:MouseEvent):void {
      // move the grip (and content) based on the scrollbar's orientation.
      if (_vertical) {
        // move the content up or down. get the ratio of the grip y to track length, then multiply it by the content height.
        // _viewport.y = (_grip.y / _height_) * _contentBounds.height;
        // account for the y offset of the mouse
        _grip.y = mouseY - _yOffset;

        // force the grip to stay within bounds 🔒
        if (_grip.y <= YMIN)
          _grip.y = YMIN;
        if (_grip.y >= _yMax)
          _grip.y = _yMax;

        // dispatch the scroll percentage as the grip slides.
        onScroll.dispatch(_grip.y + YMIN / (_yMax - YMIN));
      }
      else {
        // move the content left or right. get the ratio of the grip x to track length, then multiply by the content width.
        // _viewport.x = -(_grip.y / _width_) * _contentBounds.width;
        // account for the x offset instead of y since we're horizontal!
        _grip.x = mouseX - _xOffset;

        // force the grip to stay within bounds, horizontal edition
        if (_grip.x <= XMIN)
          _grip.x = XMIN;
        if (_grip.x >= _xMax)
          _grip.x = _xMax;

        // dispatch the scroll percentage as the grip slides.
        onScroll.dispatch(_grip.x + XMIN / (_xMax - XMIN));
      }
      // make sure to render after this event.
      e.updateAfterEvent();
    }

    public function set scrollRatio(val:Number):void {
      _scrollRatio = val;
      commit();
    }
  }
}