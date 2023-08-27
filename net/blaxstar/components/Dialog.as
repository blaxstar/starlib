package net.blaxstar.components {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.geom.Rectangle;
  import flash.geom.Rectangle;
  import thirdparty.org.osflash.signals.Signal;

  /**
   * ...
   * @author Deron Decamp
   */
  public class Dialog extends Component {
    static public const OPTION_EMPHASIS_LOW:uint = 0;
    static public const OPTION_EMPHASIS_HIGH:uint = 1;
    // TODO: create a vector of dialogs that are inactive, and a variable for the current active dialog.
    // keep track of the currently active one via a `currentlyActive` property.
    // when a dialog is clicked (mousedown), move `currentlyActive` to the inactive vector, then set the clicked dialog to `currentlyActive`.
    // also bring the currently active to the front.
    // make it so that dialogs whose `draggable` property is set to false cannot participate in this behavior (just in case it is positioned above another displayobject).
    // also make a `pin()` method, which will always ensure the dialog is on top. only one dialog should be pinned at a time, since multiple cannot possibly be placed at the same index.
    protected var _titlePT:PlainText;
    protected var _messagePT:PlainText;
    private var _titleString:String;
    private var _messageString:String;
    private var _textContainer:VerticalBox;
    private var _dialogCard:Card;
    private var _draggable:Boolean;
    private var _prevParent:DisplayObjectContainer;
    private var _onClose:Signal;

    public function Dialog(parent:DisplayObjectContainer = null, title:String = '', message:String = '') {
      _titleString = title;
      _messageString = message;
      _onClose = new Signal();
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
      super(parent);
    }

    /** INTERFACE net.blaxstar.components.IComponent ===================== */

    /**
     * initializes the component by adding all the children
     * and committing the visual changes to be written on the next frame.
     * created to be overridden.
     */
    override public function init():void {

      super.init();
    }

    override protected function on_added(e:Event):void {
      super.on_added(e);
    }

    /**
     * initializes and adds all required children of the component.
     */
    override public function addChildren():void {

      _dialogCard = new Card(this, 0, 0, false);
      _textContainer = new VerticalBox(null, PADDING, PADDING);
      _dialogCard.addChildNative(_textContainer);
      _titlePT = new PlainText(_textContainer, 0, 0, _titleString);
      _titlePT.enabled = false;
      _messagePT = new PlainText(_textContainer, 0, 0, _messageString);
      _dialogCard.onResize.add(draw);
      _dialogCard.draggable = true;
    }

    /**
     * (re)draws the component and applies any pending visual changes.
     */
    override public function draw(e:Event = null):void {
      if (_titlePT.text != _titleString) _titlePT.text = _titleString;
      if (_messagePT.text != _messageString) _messagePT.text = _messageString;

      _width_ = _dialogCard.width;
      _height_ = _dialogCard.height;
      componentContainer.move(PADDING, _textContainer.y + _textContainer.height + PADDING);
      optionContainer.move(PADDING, _height_ - optionContainer.height);
      move((stage.nativeWindow.width / 2) - (_width_ / 2), (stage.nativeWindow.height / 2) - (_width_ / 2));

      super.draw(e);
    }

    override public function setSize(w:Number, h:Number):void {
      _dialogCard.setSize(w, h);
      super.setSize(w,h);
    }

    /** END INTERFACE ===================== */

    public function addComponent(val:DisplayObject):DisplayObject {
      return _dialogCard.addChildToContainer(val);
    }

    public function set title(val:String):void {
      _titleString = (val.length > 0) ? val : _titleString;
      commit();
    }

    public function get title():String {
      return _titleString;
    }

    public function set message(val:String):void {
      _messageString = (val.length > 0) ? val : _messageString;
      commit();
    }

    public function get message():String {
      return _messageString;
    }

    public function get onClose():Signal {
      return _onClose;
    }

    public function set viewableItems(val:uint):void {
      _dialogCard.viewableItems = val;
    }

    public function set maskThreshold(val:Number):void {
      _dialogCard.maskThreshold = val;
    }

    public function get draggable():Boolean {
      return _draggable;
    }

    public function set draggable(val:Boolean):void {
      _dialogCard.draggable = val;
    }

    public function addOption(name:String, action:Function = null, emphasis:uint = OPTION_EMPHASIS_LOW):Button {
      var b:Button = new Button(_dialogCard.optionContainer, 0, 0, name);
      if (action != null)
        b.addClickListener(action);
      if (emphasis == OPTION_EMPHASIS_LOW) {
        b.style = Button.DEPRESSED;
      }
      else if (emphasis == OPTION_EMPHASIS_HIGH) {
        b.style = Button.GROUNDED;
      }

      commit();
      return b;
    }

    public function close():void {
      if (parent) {
        parent.removeChild(this);
        _onClose.dispatch();
      }
    }

    public function open():void {
      if (_prevParent != null) {
        _prevParent.addChild(this);
      }
    }

    public function removeOptions():void {
      _dialogCard.optionContainer.removeChildren();
    }

    public function get active():Boolean {
      return parent && enabled;
    }

    public function get componentContainer():VerticalBox {
      return _dialogCard.componentContainer;
    }

    public function get optionContainer():HorizontalBox {
      return _dialogCard.optionContainer;
    }

    private function onAddedToStage(e:Event):void {
      _prevParent = parent;
    }
  }

}
