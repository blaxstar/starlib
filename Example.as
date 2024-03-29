package {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.events.MouseEvent;
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import net.blaxstar.starlib.components.Dialog;
    import net.blaxstar.starlib.components.Icon;
    import flash.events.Event;
    import thirdparty.com.lorentz.processing.ProcessExecutor;
    import net.blaxstar.starlib.style.Style;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.components.HorizontalBox;
    import net.blaxstar.starlib.components.Button;
    import net.blaxstar.starlib.gui.CheckeredSurface;
    import net.blaxstar.starlib.components.Dropdown;
    import net.blaxstar.starlib.components.LED;
    import net.blaxstar.starlib.style.Color;
    import net.blaxstar.starlib.components.Stepper;
    import net.blaxstar.starlib.components.ScrollbarControl;
    import net.blaxstar.starlib.components.Chip;
    import net.blaxstar.starlib.components.ProgressBar;
    import flash.utils.setInterval;
    import flash.utils.clearInterval;
    import net.blaxstar.starlib.components.Divider;

    public class Main extends Sprite {
        public function Main() {
            addEventListener(Event.ADDED_TO_STAGE, init);

        }

        private function init(e:Event):void {
            /** the SVG loader and the Style class for most components need a reference to the main stage/main class, so we pass those here. */
            ProcessExecutor.instance.initialize(stage);
            Style.init(this);

            /** we can make the background a checkered surface, good for contrasting and visibility of certain objects. simply add the two lines below: */
            var cbg:CheckeredSurface = new CheckeredSurface();
            cbg.apply_to(this);

            /** to create a dialog, we just need the first line below. we can also give it an optional title and message, or even make it auto resize based on its contents: */
            var dialog_0:Dialog = new Dialog(this);
            dialog_0.title = "DIALOG TEST";
            dialog_0.message = "what is it?";
            dialog_0.auto_resize = true;

            /** multiple dialogs work well side by side. it has an option for nested dialogs, but for this example we'll keep it simple and add some components: */
            var dialog_1:Dialog = new Dialog(this);
            dialog_1.auto_resize = true;
            dialog_1.title = "COMPONENTS TEST";
            dialog_1.move(300, 300);

            /** a horizontal box keeps all the displayobjects you add neatly positioned horizontally at the same y position. the list is ordered by index, so first added item will show up first and so on. most components also have a `parent` argument to automatically add the component to the parent, which we'll do here for all the icons. */
            var h_icon_set:HorizontalBox = new HorizontalBox();
            var heart_icon:Icon = new Icon(h_icon_set);
            var download_icon:Icon = new Icon(h_icon_set);
            var gamepad_icon:Icon = new Icon(h_icon_set);
            var ccheck_icon:Icon = new Icon(h_icon_set);
            var new_content_icon:Icon = new Icon(h_icon_set);
            /** Icon.setSVGXML allows drawing an icon from an SVG XML string. the Icon class has some of these built in from google's material components, so we'll use 5 of those: */
            heart_icon.setSVGXML(Icon.HEART);
            download_icon.setSVGXML(Icon.DOWNLOAD);
            gamepad_icon.setSVGXML(Icon.VG_CONTROLLER);
            ccheck_icon.setSVGXML(Icon.CHECKMARK_CIRCLED);
            new_content_icon.setSVGXML(Icon.NEW_CONTENT);
            /** the addChild method of the Dialog component automatically adds the object to a child of the Dialog instead, which is actually just a vertical box. same as HorizontalBox above, just vertical. combining these two makes UI layouts much easier to work with! */
            dialog_1.addChild(h_icon_set);

            /** a simple dropdown selector. you can either make list items manually, or pass an array of strings to delegate their creation to the dropdown: */
            var ddown:Dropdown = new Dropdown(dialog_1);
            ddown.multi_add_string_array(['it aint much', 'but its honest work']);

            /** a simple divider. can be horizontal or vertical. */
            var dvd:Divider = new Divider(dialog_1, 0, 0, Divider.ORIENTATION_HORIZONTAL, 250);

            /** i don't know why, but this might be my favorite component. it's a simple blinking LED indicator. use it for anything really. if you set is_flashing to true, it will blink on a 1 second interval until you set it back to false. you can manually toggle the light and set the color too. */
            var led:LED = new LED(dialog_1, 0, 0, Color.PRODUCT_BLUE.value);
            led.is_flashing = true;

            /** a simple uint stepper. counts from 0 to uint.MAX_VALUE (4.294967295E9). you can retrieve the current value using its `value` property. */
            var stp:Stepper = new Stepper(dialog_1);

            /** chips, for tags and metadata display (at least, that's usually what they're used for). you can retrieve the label string using the label_string property. also has a generic `data` property for storing data for an individual chip. */
            var chp_container:HorizontalBox = new HorizontalBox(dialog_1);
            var chip0:Chip = new Chip(chp_container, 0, 0, "TAG0");
            var chip1:Chip = new Chip(chp_container, 0, 0, "TAG1");

            /** a simple and clean progress bar. use the `progress` property to move the bar according to loader progress. uses uint instead of floating point numbers, so just increment until progress is 100:  */
            var pb:ProgressBar = new ProgressBar(dialog_1);
            var intvl:int = setInterval(function():void {
                if (pb.progress >= 100) {
                    clearInterval(intvl);
                } else {
                    pb.progress += 10
                }
            }, 1000);

            /** Dialogs also have an `add_button` convinience method for adding dialog options for a prompt or what have you. you can set the name, listener and style all from instantiation. button.DEPRESSED is a flat button with no border, while GROUNDED has a border. you can use them to give a sense of button priority: */
            dialog_0.add_button("it aint much", null, Button.DEPRESSED);
            dialog_0.add_button("its honest work", null, Button.GROUNDED);

        }

    }
}
