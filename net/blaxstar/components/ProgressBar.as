package net.blaxstar.components {
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.events.Event;

  import net.blaxstar.style.Style;

  /**
   * ...
   * @author Deron Decamp
   */
  public class ProgressBar extends Component {

    static private const START_WIDTH:uint = 140;
    static private const START_HEIGHT:uint = 5;

    private var _track:Sprite;
    private var _trackFill:Sprite;
    private var _percentLoaded:Number;

    public function ProgressBar(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
      super(parent, xpos, ypos);

    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children
     * and committing the visual changes to be written on the next frame.
     * created to be overridden.
     */
    override public function init():void {
      _width_ = START_WIDTH;
      _height_ = START_HEIGHT;
      _percentLoaded = 1;
      _track = new Sprite();
      _trackFill = new Sprite();
      drawTrack();
      drawTrackFill();

      super.init();
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {
      addChildAt(_track, 0);
      addChildAt(_trackFill, 1);

      super.addChildren();
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      drawTrack();
      drawTrackFill();
      super.draw(e);
    }

    /** END INTERFACE ===================== */

    public function set progress(val:uint):void {
      _percentLoaded = val;
      draw();
    }

    public function get progress():uint {
      return _percentLoaded;
    }

    private function drawTrack():void {
      _track.graphics.lineStyle(_height_, Style.SECONDARY_DARK.value, 1);
      _track.graphics.lineTo(_width_, 0);
    }

    private function drawTrackFill():void {
      _trackFill.graphics.lineStyle(_height_, Style.SECONDARY.value, 1);
      _trackFill.graphics.lineTo(_width_ * (_percentLoaded / 100), 0);
    }
  }

}