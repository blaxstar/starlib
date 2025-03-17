package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import net.blaxstar.starlib.components.Button;
    import net.blaxstar.starlib.components.Checkbox;
    import net.blaxstar.starlib.components.Chip;
    import net.blaxstar.starlib.components.ContextMenu;
    import net.blaxstar.starlib.components.Dialog;
    import net.blaxstar.starlib.components.Divider;
    import net.blaxstar.starlib.components.Dropdown;
    import net.blaxstar.starlib.components.HorizontalBox;
    import net.blaxstar.starlib.components.Icon;
    import net.blaxstar.starlib.components.InputTextArea;
    import net.blaxstar.starlib.components.InputTextField;
    import net.blaxstar.starlib.components.LED;
    import net.blaxstar.starlib.components.PlainText;
    import net.blaxstar.starlib.components.ProgressBar;
    import net.blaxstar.starlib.components.ScrollbarControl;
    import net.blaxstar.starlib.components.Stepper;
    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.debug.console.Termini;
    import net.blaxstar.starlib.gui.CheckeredSurface;
    import net.blaxstar.starlib.input.InputEngine;
    import net.blaxstar.starlib.style.Color;
    import net.blaxstar.starlib.style.Font;
    import net.blaxstar.starlib.style.Style;

    import com.lorentz.processing.ProcessExecutor;

    public class Main extends Sprite {
        public function Main() {
            addEventListener(Event.ADDED_TO_STAGE, init);

        }

        private function init(e:Event):void {
            /** First things first! we need to initialize the library. the SVG loader, Style class for most components, and input listeners need a reference to the main stage/main class, so we pass those here. also, the DebugDaemon, a class that writes logs and errors about the state of components in this library, needs a reference to the stage to get the native window, so it can write its log quickly before the app closes. previously, this was 3 seperate calls, but now it has been simplified down to one: */
            Starlib.init(this, stage, true, "starlib_playground_log_file");

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
            // we can make icon buttons:
            var icon_btn:Button = new Button(h_icon_set);
            icon_btn.icon = Icon.NEW_CONTENT;
            /** we can also set icon sizes and color. buttons take RGBA to make it simpler than providing hex, but SVGs use hex color codes. luckily we have an easy method for getting that: */
            icon_btn.set_size(35, 35);
            icon_btn.icon_color = Color.TEAL;
            gamepad_icon.set_color(Color.PRODUCT_RED.to_hex_string());
            var flex_text:PlainText = new PlainText(h_icon_set, 0, 0, "<= colored and resized manually! :)");
            flex_text.format(Font.H5);
            flex_text.color = Color.TEAL.value;
            /** the svg renderer applies color using hex strings. luckily we have a useful utility method to get that built into the RGB class: */
            /** Icon.setSVGXML allows drawing an icon from an SVG XML string. the Icon class has some of these built in from google's material components, so we'll use 5 of those: */
            heart_icon.set_svg_xml(Icon.HEART);
            download_icon.set_svg_xml(Icon.DOWNLOAD);
            gamepad_icon.set_svg_xml(Icon.VG_CONTROLLER);
            ccheck_icon.set_svg_xml(Icon.CHECKMARK_CIRCLED);
            /** the addChild method of the Dialog component automatically adds the object to a child of the Dialog instead, which is actually just a vertical box. same as HorizontalBox above, just vertical. combining these two makes UI layouts much easier to work with! */
            dialog_1.addChild(h_icon_set);

            /** a simple dropdown selector. you can either make list items manually, or pass an array of strings to delegate their creation to the dropdown: */
            var ddown:Dropdown = new Dropdown(dialog_1);
            ddown.multi_add_string_array(["much, except it ain't", "work, except it's honest"]);

            /** a simple checkbox. its look is a bit different! */
            var cbx:Checkbox = new Checkbox(dialog_1);
            cbx.label = "single box";

            /** it also has support for groups, similar to radio buttons. */
            var radio_box_container:HorizontalBox = new HorizontalBox(dialog_1);
            var radio_box_0:Checkbox = new Checkbox(radio_box_container);
            var radio_box_1:Checkbox = new Checkbox(radio_box_container);
            var radio_box_2:Checkbox = new Checkbox(radio_box_container);
            radio_box_0.group = 1;
            radio_box_1.group = 1;
            radio_box_2.group = 1;
            radio_box_2.label = "radio box";
            /** a simple divider. can be horizontal or vertical. */
            var dvd:Divider = new Divider(dialog_1, 0, 0, Divider.ORIENTATION_HORIZONTAL, 250);

            /** i don't know why, but this might be my favorite component. it's a simple blinking LED indicator. use it for anything really. if you set is_flashing to true, it will blink on a 1 second interval until you set it back to false. you can manually toggle the light and set the color too. */
            var led:LED = new LED(null, 0, 0, Color.PRODUCT_BLUE.value);
            var progled_container:HorizontalBox = new HorizontalBox(dialog_1);
            /** a simple and clean progress bar. use the `progress` property to move the bar according to loader progress. uses uint instead of floating point numbers, so just increment until progress is 100:  */
            var pb:ProgressBar = new ProgressBar(progled_container);
            var intvl:int;
            var progress:Function = function():void {
                if (pb.progress >= 100) {
                    clearInterval(intvl);
                    progress_btn.enabled = true;
                    led.is_flashing = false;
                    led.on_color = Color.PRODUCT_GREEN.value;
                    led.turn_on();
                } else {
                    pb.progress += 1
                }
            };
            var set_intvl:Function = function():void {
                progress_btn.enabled = false;
                pb.reset();
                led.on_color = Color.PRODUCT_BLUE.value;
                led.is_flashing = true;
                intvl = setInterval(progress, 20);
            };

            var progress_btn:Button = dialog_1.add_button("RESTART PROGRESSBAR", set_intvl);
            set_intvl();
            progled_container.addChild(led);

            /** a simple uint stepper. counts from 0 to uint.MAX_VALUE (4.294967295E9). you can retrieve the current value using its `value` property. */
            var stp:Stepper = new Stepper(dialog_1);

            /** chips, for tags and metadata display (at least, that's usually what they're used for). you can retrieve the label string using the label_string property. also has a generic `data` property for storing data for an individual chip. */
            var chp_container:HorizontalBox = new HorizontalBox(dialog_1);
            var chip0:Chip = new Chip(chp_container, 0, 0, "TAG0");
            var chip1:Chip = new Chip(chp_container, 0, 0, "TAG1");
            var chip2:Chip = new Chip(chp_container, 0, 0, "THISISALONGTAGRIGHTHEREOKAY");


            /** Dialogs also have an `add_button` convinience method for adding dialog options for a prompt or what have you. you can set the name, listener and style all from instantiation. button.DEPRESSED is a flat button with no border, while GROUNDED has a border. you can use them to give a sense of button priority: */
            dialog_0.add_button("it aint much", null, Button.DEPRESSED);
            dialog_0.add_button("its honest work", null, Button.GROUNDED);

            /** a simple context menu. allows for string array adds as well as tuple adds (string, function). the list options can be cached using a boolean argument when hiding the list as to resuse objects and not be wasteful with memory. you can even name the lists you cache (i've named them "contexts" to match the idea of a context menu). the default context is named "default" and will be used by default if no contexts are added or specified. when loading and applying contexts, list items from previous contexts can be cached and restored automatically on load, saving memory and time. */
            var context_menu:ContextMenu = new ContextMenu(this);
            var show_context_menu:Function = function(e:MouseEvent):void {
                e.preventDefault();
                stage.removeEventListener(MouseEvent.RIGHT_CLICK, show_context_menu);
                stage.addEventListener(MouseEvent.CLICK, hide_context_menu);
                context_menu.show();
                context_menu.move(mouseX, mouseY);
            }
            var hide_context_menu:Function = function(e:MouseEvent):void {
                e.preventDefault();
                stage.removeEventListener(MouseEvent.CLICK, hide_context_menu);
                stage.addEventListener(MouseEvent.RIGHT_CLICK, show_context_menu);
                context_menu.hide(true);
            }

            context_menu.hide();
            context_menu.add_context_array(["one", "two", "three"], "default", function(e:MouseEvent):void {
                trace("clicked");
            });

            // and extremely simple, padded divider. can be oriented vertically or horizontally. 
            var vdiv:Divider = new Divider(null, 0, 0, 1);
            var dialog_2:Dialog = new Dialog(this);
            dialog_2.auto_resize = true;
            dialog_2.title = "DIVIDER COMPONENT TEST";
            dialog_2.move(400, 400);
            dialog_2.addChild(vdiv);
            dialog_2.add_button("CHANGE ORIENTATION", function(e:MouseEvent):void {
                vdiv.set_orientation(vdiv.orientation == 0 ? 1 : 0);
            })

            /** a suggestion enabled input text area. you can supply some data for it to look through and it will automatically look for matching (or near matching) labels. you can supply this data either one by one using InputTextField.add_suggestion(), or you can use InputTextField.suggestion_store and pass in a stringified JSON object. each item in the object should consist of one normal key which will be used as the label. the value of that key can be any generic object or object dirivative. the data will be passed to the suggestion list item so you can access it on click. oh, and keyboard navigation is supported too. */
            InputEngine.instance().init(stage, true);
            var text_area:InputTextArea = new InputTextArea();
            var autocomplete:InputTextField = new InputTextField();
            autocomplete.suggestion_store = JSON.stringify({dat0: "thisisthedata", dat2: "howmuchwoodwouldawoodchuckchuckifawoodchuckcouldchuckwood"});
            var dialog_3:Dialog = new Dialog(this);
            dialog_3.auto_resize = true;
            dialog_3.title = "AUTOCOMPLETE + TEXT AREA TEST";
            dialog_3.move(500, 400);
            text_area.set_size(200, 100);
            dialog_3.addChild(autocomplete);
            dialog_3.addChild(text_area);
            autocomplete.showing_suggestions = true;

            /** a scrollbar. i truly underestimated the work that goes into scrollbars and positioning and orientation etc... but it works, for now. esentially, you just need some scrollable content that is larger than its container, otherwise the scrollbar will not show. once you add it to a container, simple create a new ScrollbarControl and pass in a reference to the content, a displayobject whose bounds will act as the viewport, and a parent for where to place the scrollbar itself. once you move the scrollbar moved where you want it, scroll away. if you have the auto_attach property enabled, it will auto attach to the side/bottom of the viewport when scrollbar.draw() is called. you can add an event listener to automate this for your own use cases. */
            var scrollcard:Dialog = new Dialog(this, "SCROLLBAR TEST");
            scrollcard.auto_resize = false;
            var scrollcard_content:InputTextArea = new InputTextArea(scrollcard);
            scrollcard.set_size(400, 500);
            scrollcard.move(500, 10);
            scrollcard_content.set_size(80, 1000);
            var scrollbar:ScrollbarControl = new ScrollbarControl(scrollcard_content, scrollcard, this, true, false);
            // you can update the position automatically like so:
            //scrollbar.auto_attach = true;
            //scrollbar.draw() <-- you can use it with a listener as well, since it accepts any Event object.

            // ah, yes, the debug console. now admittedly, this isn't a component. but it earns an honorary mention! it is a slim, horizontal console that appears at the top of the screen when you press the trigger key (by default it's set to tilde, but you can change this.) there are a few commands already built in such as add and grep (which supports local files and multiline text!) but i've created the ConsoleCommand class to be as extensible as possible. it's a very powerful tool for debugging at runtime, especially in game development-- see if you can't come up with your own ideas and mods!
            var debug_console:Termini = new Termini(stage);
            addChild(debug_console);

            stage.addEventListener(MouseEvent.RIGHT_CLICK, show_context_menu);
        }

    }
}
