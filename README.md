# starlib
### utility library for as3
## libraries used:
* [as3_msgpack_starlib](https://github.com/dyxribo/as3_msgpack_starlib) (for secure socket data transfer)

# starcomps
AS3 components inspired by Google's material design.

libraries used:
* [as3_signals_starlib](https://github.com/dyxribo/as3_signals_starlib) (faster alternative to events)
* [greensock_as3_starlib](https://github.com/dyxribo/greensock_as3_starlib) (most animations)
* [as3_svg_renderer_starlib](https://github.com/dyxribo/as3_svg_renderer_starlib) (for Icon component)


## PREVIEW
_example of components in use_

[![STARLIB](https://i.stack.imgur.com/Vp2cE.png)](https://github.com/blaxstar/starlib/assets/6477128/2d4f1948-1da8-4192-92bc-82f2059c5f66)










## COMPLETED COMPONENTS

* **INPUT TEXTFIELD** - an input textfield component with support for suggestions
* **INPUT TEXT AREA** - a multiline textfield for large bodies of text
* **BUTTON** - a simple animated button with 2 styles. supports the icon class to create icon buttons.
* **CHECKBOX / RADIO BOX** - a checkbox with a unique style. can be organized into groups similar to radio buttons.
* **CONTEXT MENU** - a menu that has support for automatic list caching and named groups (contexts).
* **ICON** - an SVG icon that can load SVG XML data on the fly. has support for changing color and size.
* **PROGRESS BAR** - a simple progress bar. 
* **PLAIN TEXT** - a simple, static text block. supports color and multiline properties.
* **DIALOG** - a fully featured ui dialog. has built-in support for title display & message display (plaintext) as well as action buttons (the button component). can be dragged using the draggable property, and also has automatic resource management when multiple dialogs are in use.
* **CARD** - a card container. it can be dragged using the draggable property. it has a VerticalBox component that automatically organizes children in a vertical list. can be used with a HorizontalBox component for complex layouts.
* **LIST** - a cacheable list. can be hidden or shown via show_list() or hide_list(). also has a useful is_showing boolean property.
* **SCROLLBAR CONTROL** - a plain scrollbar control. can be auto attached to a display object. use listeners to update position when the target is moved.
* **SUGGESTITRON** - A suggestions generator. generates a vector of list items to be used with a list. 
* **UINT STEPPER** - a simple uint stepper that counts from 0 to uint.MAX_VALUE.
* **CHIP** - a chip/tag component. can be removed with the default trash button and is immediately prepared for garbage collection.
* **DROPDOWN SELECTOR** - a dropdown selector. you can provide a list of items to choose from and retrieve the current value through the value property.
* **LED** - a toggleable circle LED. can be resized and set to flash, which will toggle it on/off every half second (500ms).
* **DIVIDER** - a divider component. can be vertical or horizontal.

These classes might still need work as I find bugs here and there, but the ones listed are at least usable for most projects.
they currently only support proprietary light and dark themes. will be updated as time goes on. 
Feel free to take a look at the `Example.as` file in the root of this repo, which was used for the video example above. It's fairly well commented.

COMING NEXT
============
* SLIDER
* TOOLTIP
* MENU
* SIDE NAV
*	EXTENDOCARD
*	SLIDE TOGGLE
*	HTML TABLE
*	TABBED VIEWER
*	BADGE
*	SNACKBAR
*	BOTTOM SHEET
*	FORM
*	GRID LIST
*	PAGINATOR
*	DATE PICKER
*	PROGRESS SPINNER


