package net.blaxstar.starlib.components {
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import net.blaxstar.starlib.utils.Strings;

    import thirdparty.com.lorentz.SVG.data.style.StyleDeclaration;
    import thirdparty.com.lorentz.SVG.display.SVGDocument;
    import thirdparty.com.lorentz.SVG.display.base.SVGElement;
    import thirdparty.com.lorentz.SVG.events.SVGEvent;
    import thirdparty.com.lorentz.SVG.utils.DisplayUtils;
    import thirdparty.org.osflash.signals.Signal;
    import thirdparty.org.osflash.signals.natives.NativeSignal;
    import flash.utils.Dictionary;
    import flash.display.Graphics;

    /**
     * ...
     * @author Deron Decamp
     */
    public class Icon extends FunctionQueueableComponent {
        static public const ICON_LOADED:String = "icon_loaded";
        static public const X3_DOT_MENU:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M10 16q-.625 0-1.062-.438Q8.5 15.125 8.5 14.5t.438-1.062Q9.375 13 10 13t1.062.438q.438.437.438 1.062t-.438 1.062Q10.625 16 10 16Zm0-4.5q-.625 0-1.062-.438Q8.5 10.625 8.5 10t.438-1.062Q9.375 8.5 10 8.5t1.062.438q.438.437.438 1.062t-.438 1.062q-.437.438-1.062.438ZM10 7q-.625 0-1.062-.438Q8.5 6.125 8.5 5.5t.438-1.062Q9.375 4 10 4t1.062.438q.438.437.438 1.062t-.438 1.062Q10.625 7 10 7Z"/></svg>';
        static public const ACCESSIBILITY:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M10 5.5q-.729 0-1.24-.51-.51-.511-.51-1.24t.51-1.24Q9.271 2 10 2t1.24.51q.51.511.51 1.24t-.51 1.24q-.511.51-1.24.51ZM7.5 17.75V8.104q-1.146-.083-2.26-.333-1.115-.25-2.24-.542l.375-1.396Q5 6.271 6.656 6.51q1.656.24 3.344.24t3.344-.24q1.656-.239 3.281-.677L17 7.229q-1.125.292-2.24.542-1.114.25-2.26.333v9.646H11l-.188-4.625H9.208L9 17.75Z"/></svg>';
        static public const SEARCH:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M765-144 526-383q-30 22-65.792 34.5T384.035-336Q284-336 214-406t-70-170q0-100 70-170t170-70q100 0 170 70t70 170.035q0 40.381-12.5 76.173T577-434l239 239-51 51ZM384-408q70 0 119-49t49-119q0-70-49-119t-119-49q-70 0-119 49t-49 119q0 70 49 119t119 49Z"/></svg>';
        static public const BACKUP_CLOUD:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M5 16q-1.667 0-2.833-1.177Q1 13.646 1 11.979q0-1.583 1.073-2.739Q3.146 8.083 4.729 8q.479-1.792 1.948-2.896Q8.146 4 10 4q2.229 0 3.865 1.427Q15.5 6.854 15.5 9q1.458 0 2.479 1.021Q19 11.042 19 12.479q0 1.459-1.021 2.49Q16.958 16 15.5 16h-4.75q-.625 0-1.062-.438-.438-.437-.438-1.062v-3.625l-1.188 1.187L7 11l3-3 3 3-1.062 1.062-1.188-1.187V14.5h4.75q.833 0 1.417-.583.583-.584.583-1.417 0-.833-.583-1.417-.584-.583-1.417-.583H14V9q0-1.521-1.198-2.51Q11.604 5.5 10 5.5q-1.625 0-2.75 1.177T5.896 9.5H5q-1.042 0-1.771.729Q2.5 10.958 2.5 12q0 1.042.729 1.771.729.729 1.771.729h2.75V16Zm5-5.125Z"/></svg>';
        static public const BOOKMARK:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M5.917 14.812 10 13.083l4.083 1.729V4.25H5.917ZM4.167 17.5v-15h11.666v15L10 14.979Zm1.75-13.25h8.166H10Z"/></svg>';
        static public const BUG_REPORT:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M10 17q-1.25 0-2.271-.677T6.292 14.5H4V13h2v-1.25H4v-1.5h2V9H4V7.5h2.292q.166-.542.541-.979.375-.438.855-.771L6 4.062 7.062 3l2.105 2.083q.416-.104.843-.104.428 0 .844.104L12.938 3 14 4.062 12.312 5.75q.48.333.834.771.354.437.562.979H16V9h-2v1.25h2v1.5h-2V13h2v1.5h-2.292q-.416 1.146-1.437 1.823Q11.25 17 10 17Zm0-1.5q1.021 0 1.74-.729.718-.729.76-1.771V9q.042-1.042-.698-1.771-.74-.729-1.781-.729-1.063 0-1.781.729Q7.521 7.958 7.5 9v4q-.021 1.042.708 1.771.73.729 1.792.729ZM8.5 13h3v-1.5h-3Zm0-2.5h3V9h-3Zm1.5.542Z"/></svg>';
        static public const CALENDAR:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M7.521 13.812q-.875 0-1.49-.614-.614-.615-.614-1.49t.614-1.489q.615-.615 1.49-.615t1.489.615q.615.614.615 1.489 0 .875-.615 1.49-.614.614-1.489.614ZM2.5 18.333V3.417h2.417v-1.75h1.75v1.75h6.666v-1.75h1.75v1.75H17.5v14.916Zm1.75-1.75h11.5V8.375H4.25Zm0-9.958h11.5V5.167H4.25Zm0 0V5.167v1.458Z"/></svg>';
        static public const CHECKMARK:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m8.229 14.062-3.521-3.541L5.75 9.479l2.479 2.459 6.021-6L15.292 7Z"/></svg>';
        static public const CHECKMARK_CIRCLED:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m8.938 13 4.958-4.938L12.833 7l-3.895 3.875-1.771-1.75-1.063 1.063ZM10 18q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const CLOSE:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M6.062 15 5 13.938 8.938 10 5 6.062 6.062 5 10 8.938 13.938 5 15 6.062 11.062 10 15 13.938 13.938 15 10 11.062Z"/></svg>';
        static public const DELETE:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M4.146 17.5V5.125h-.813v-1.75h4.209V2.5h4.916v.875h4.209v1.75h-.834V17.5Zm1.75-1.75h8.187V5.125H5.896ZM7.458 14h1.75V6.875h-1.75Zm3.313 0h1.75V6.875h-1.75ZM5.896 5.125V15.75Z"/></svg>';
        static public const DONATE:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M9.292 15.5h1.396v-.979q1.02-.167 1.687-.875T13.042 12q0-.938-.573-1.604-.573-.667-1.761-1.104-1.27-.459-1.677-.782-.406-.322-.406-.843 0-.417.365-.688.364-.271.948-.271.583 0 1.02.282.438.281.584.76l1.229-.521q-.25-.687-.802-1.156-.552-.469-1.281-.594V4.5H9.312v1q-.937.208-1.5.802-.562.594-.562 1.386 0 .937.635 1.593.636.657 2.011 1.136.937.333 1.364.708.428.375.428.875 0 .542-.438.906-.438.365-1.083.365-.688 0-1.219-.459-.531-.458-.719-1.187l-1.291.542q.25.875.874 1.489.626.615 1.48.844ZM10 18q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const DOWNLOAD:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M10 13.271 5.708 8.979l1.25-1.25 2.167 2.167V3.333h1.75v6.563l2.167-2.167 1.25 1.25Zm-6.667 3.396V12.5h1.75v2.417h9.834V12.5h1.75v4.167Z"/></svg>';
        static public const EDIT:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M4.25 15.75h1.229l7-7-1.229-1.229-7 7Zm11.938-8.208-3.73-3.73 2.271-2.27 3.729 3.729ZM2.5 17.5v-3.729l8.729-8.729 3.729 3.729L6.229 17.5Zm9.375-9.354-.625-.625 1.229 1.229Z"/></svg>';
        static public const ERROR:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M10 14q.312 0 .531-.219.219-.219.219-.531 0-.312-.219-.531-.219-.219-.531-.219-.312 0-.531.219-.219.219-.219.531 0 .312.219.531Q9.688 14 10 14Zm-.75-3h1.5V6h-1.5Zm.75 7q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const EXPAND_DOWN:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m10 13.062-5-5L6.062 7 10 10.938 13.938 7 15 8.062Z"/></svg>';
        static public const EXPAND_DOWN_CIRCLED:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m10 12 3-3H7Zm0 6q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const ARROW_BACK:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m10 16-6-6 6-6 1.062 1.062L6.875 9.25H16v1.5H6.875l4.187 4.188Z"/></svg>';
        static public const ARROW_FWD:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m10 16-1.062-1.062 4.187-4.188H4v-1.5h9.125L8.938 5.062 10 4l6 6Z"/></svg>';
        static public const FULLSCREEN:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M4 16v-4h1.5v2.5H8V16Zm0-8V4h4v1.5H5.5V8Zm8 8v-1.5h2.5V12H16v4Zm2.5-8V5.5H12V4h4v4Z"/></svg>';
        static public const FULLSCREEN_EXIT:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M7 15.5V13H4.5v-1.5h4v4Zm4.5 0v-4h4V13H13v2.5Zm-7-7V7H7V4.5h1.5v4Zm7 0v-4H13V7h2.5v1.5Z"/></svg>';
        static public const VG_CONTROLLER:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M3.938 16.667q-1.313 0-2.167-.917-.854-.917-.896-2.146 0-.166.021-.375.021-.208.062-.375l1.75-7Q3 4.75 3.906 4.042q.906-.709 2.032-.709h8.124q1.126 0 2.032.709.906.708 1.198 1.812l1.75 7q.041.188.073.386.031.198.031.385 0 1.25-.886 2.146-.885.896-2.198.896-.874 0-1.624-.459-.75-.458-1.126-1.25l-.583-1.208q-.104-.229-.302-.323t-.448-.094H8.021q-.25 0-.448.094t-.302.323l-.583 1.208q-.376.792-1.126 1.25-.75.459-1.624.459ZM4 14.917q.333 0 .635-.188.303-.187.49-.541L5.708 13q.334-.667.948-1.042.615-.375 1.365-.375h3.958q.729 0 1.354.386.625.385.979 1.031l.584 1.188q.187.354.489.541.303.188.636.188.5 0 .906-.355.406-.354.448-.916 0-.084-.01-.188-.011-.104-.032-.187l-1.75-6.979q-.145-.542-.562-.875-.417-.334-.959-.334H5.938q-.542 0-.969.334-.427.333-.552.875l-1.75 6.979q-.042.125-.042.354 0 .583.427.927.427.344.948.365Zm7.25-5.709q-.354 0-.615-.26-.26-.26-.26-.615 0-.354.26-.614.261-.261.615-.261t.615.261q.26.26.26.614 0 .355-.26.615-.261.26-.615.26Zm1.667-1.666q-.355 0-.615-.261-.26-.26-.26-.614 0-.355.26-.615t.615-.26q.354 0 .614.26.261.26.261.615 0 .354-.261.614-.26.261-.614.261Zm0 3.333q-.355 0-.615-.26-.26-.261-.26-.615t.26-.615q.26-.26.615-.26.354 0 .614.26.261.261.261.615t-.261.615q-.26.26-.614.26Zm1.666-1.667q-.354 0-.614-.26-.261-.26-.261-.615 0-.354.261-.614.26-.261.614-.261.355 0 .615.261.26.26.26.614 0 .355-.26.615t-.615.26Zm-7.5 1.25q-.271 0-.468-.198-.198-.198-.198-.468V9h-.792q-.271 0-.469-.198-.198-.198-.198-.469 0-.271.198-.468.198-.198.469-.198h.792v-.792q0-.271.198-.469.197-.198.468-.198t.469.198q.198.198.198.469v.792h.792q.27 0 .468.198.198.197.198.468t-.198.469Q8.812 9 8.542 9H7.75v.792q0 .27-.198.468t-.469.198Z"/></svg>';
        static public const HEART:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m10 17-1.042-.938q-2.083-1.854-3.437-3.177-1.354-1.323-2.136-2.354Q2.604 9.5 2.302 8.646 2 7.792 2 6.896q0-1.854 1.271-3.125T6.396 2.5q1.021 0 1.979.438.958.437 1.625 1.229.667-.792 1.625-1.229.958-.438 1.979-.438 1.854 0 3.125 1.271T18 6.896q0 .896-.292 1.729-.291.833-1.073 1.854-.781 1.021-2.145 2.365-1.365 1.344-3.49 3.26Zm0-2.021q1.938-1.729 3.188-2.948 1.25-1.219 1.989-2.125.74-.906 1.031-1.614.292-.709.292-1.396 0-1.229-.833-2.063Q14.833 4 13.604 4q-.729 0-1.364.302-.636.302-1.094.844L10.417 6h-.834l-.729-.854q-.458-.542-1.114-.844Q7.083 4 6.396 4q-1.229 0-2.063.833-.833.834-.833 2.063 0 .687.271 1.364.271.678.989 1.573.719.896 1.98 2.125Q8 13.188 10 14.979Zm0-5.5Z"/></svg>';
        static public const HEART_ADD:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M9 9.5ZM9 17l-2.25-2Q5.104 13.542 4 12.417q-1.104-1.125-1.771-2.063-.667-.937-.948-1.76Q1 7.771 1 6.896q0-1.854 1.26-3.125Q3.521 2.5 5.354 2.5q1.042 0 2.011.438.968.437 1.635 1.229.667-.792 1.604-1.229.938-.438 1.958-.438 1.626 0 2.844.99 1.219.989 1.511 2.51h-1.563q-.292-.875-1.042-1.438Q13.562 4 12.562 4q-1.187 0-1.822.594-.636.594-1.323 1.406h-.834q-.708-.833-1.364-1.417Q6.562 4 5.354 4q-1.187 0-2.021.833-.833.834-.833 2.063 0 .646.26 1.323.261.677.98 1.583.718.906 1.979 2.146 1.26 1.24 3.281 3.031.521-.458 1.531-1.354 1.011-.896 1.427-1.292l.167.167.365.365.364.364.167.167q-.438.416-.959.875l-.854.75Zm6.25-3.5v-2.25H13v-1.5h2.25V7.5h1.5v2.25H19v1.5h-2.25v2.25Z"/></svg>';
        static public const IMAGE:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M5.083 14.104h9.855L11.854 10l-2.458 3.292-1.854-2.48ZM2.5 17.5v-15h15v15Zm1.75-1.75h11.5V4.25H4.25Zm0-11.5v11.5Z"/></svg>';
        static public const LABEL:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M10.167 15.833v-1.75H12.5L15.375 10 12.5 5.917H4.25v2.25H2.5v-4h10.917L17.5 10l-4.083 5.833ZM9.812 10Zm-5.645 6.667v-2.5h-2.5v-1.75h2.5v-2.5h1.75v2.5h2.5v1.75h-2.5v2.5Z"/></svg>';
        static public const LOCK:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M3.333 18.333V6.667h2.459V5.042q0-1.771 1.218-2.99Q8.229.833 10 .833q1.771 0 2.99 1.219 1.218 1.219 1.218 2.99v1.625h2.459v11.666ZM7.542 6.667h4.916V5.042q0-1.021-.718-1.74-.719-.719-1.74-.719t-1.74.719q-.718.719-.718 1.74Zm-2.459 9.916h9.834V8.417H5.083ZM10 14.188q.708 0 1.198-.49t.49-1.198q0-.708-.49-1.198T10 10.812q-.708 0-1.198.49t-.49 1.198q0 .708.49 1.198t1.198.49Zm-4.917 2.395V8.417v8.166Z"/></svg>';
        static public const LOCK_OPEN:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M3.333 18.333V6.667h9.125V5.042q0-1.021-.718-1.74-.719-.719-1.74-.719t-1.74.719q-.718.719-.718 1.74h-1.75q0-1.771 1.218-2.99Q8.229.833 10 .833q1.771 0 2.99 1.219 1.218 1.219 1.218 2.99v1.625h2.459v11.666Zm1.75-1.75h9.834V8.417H5.083ZM10 14.188q.708 0 1.198-.49t.49-1.198q0-.708-.49-1.198T10 10.812q-.708 0-1.198.49t-.49 1.198q0 .708.49 1.198t1.198.49Zm-4.917 2.395V8.417v8.166Z"/></svg>';
        static public const MENU:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M3 14.5V13h14v1.5Zm0-3.75v-1.5h14v1.5ZM3 7V5.5h14V7Z"/></svg>';
        static public const MINUS:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M5 10.75v-1.5h10v1.5Z"/></svg>';
        static public const MINUS_CIRCLED:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M6 10.75h8v-1.5H6ZM10 18q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const NEW_CONTENT:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m15.5 7.979-1.104-2.396L12 4.5l2.396-1.104L15.5 1l1.083 2.396L18.979 4.5l-2.396 1.083Zm0 11-1.083-2.417L12 15.479l2.417-1.083 1.083-2.417 1.083 2.417L19 15.479l-2.417 1.083Zm-8-2.5L5.479 12 1 9.979l4.479-2.021L7.5 3.479l2.021 4.479L14 9.979 9.521 12Zm0-3.625.896-1.979 1.979-.896-1.979-.896L7.5 7.104l-.896 1.979-1.979.896 1.979.896ZM7.375 10Z"/></svg>';
        static public const NOTIFICATIONS:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M3.333 15.833v-1.75h1.646V8.354q0-1.708 1.042-3.052 1.041-1.344 2.687-1.76V1.667h2.584v1.875q1.646.416 2.677 1.76Q15 6.646 15 8.354v5.729h1.667v1.75ZM10 9.562Zm0 8.771q-.708 0-1.188-.479-.479-.479-.479-1.187h3.334q0 .708-.479 1.187-.48.479-1.188.479Zm-3.271-4.25h6.521V8.354q0-1.333-.938-2.291-.937-.959-2.312-.959-1.333 0-2.302.959-.969.958-.969 2.291Z"/></svg>';
        static public const NOTIFICATIONS_OFF:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m15 12.5-1.75-1.75V8.375q0-1.354-.948-2.312-.948-.959-2.302-.959-.542 0-1.01.177-.469.177-.823.407l-1.25-1.271q.354-.25.812-.511.459-.26.979-.364V1.667h2.584v1.875q1.625.416 2.666 1.75Q15 6.625 15 8.375Zm-5 5.833q-.688 0-1.177-.489-.49-.49-.49-1.177h3.334q0 .687-.49 1.177-.489.489-1.177.489Zm.708-10.125Zm-7.396 7.625v-1.75h1.667V8.354q0-.708.198-1.364.198-.657.573-1.261L7.021 7q-.146.312-.219.656-.073.344-.073.698v5.729h4.896L1.167 3.646l1.25-1.25 15.291 15.292-1.25 1.25-3.083-3.105Zm5.876-4.208Z"/></svg>';
        static public const PLUS:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M9.25 15v-4.25H5v-1.5h4.25V5h1.5v4.25H15v1.5h-4.25V15Z"/></svg>';
        static public const PLUS_CIRCLED:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M9.25 14h1.5v-3.25H14v-1.5h-3.25V6h-1.5v3.25H6v1.5h3.25Zm.75 4q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const SAVE_AS:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M2.5 17.5v-15h11.667L17.5 5.833v4.063l-1.75 1.75V6.604L13.396 4.25H4.25v11.5h7.417l-1.75 1.75Zm7.5-2.583q1.062 0 1.823-.761.76-.76.76-1.823 0-1.062-.76-1.823-.761-.76-1.823-.76-1.062 0-1.823.76-.76.761-.76 1.823 0 1.063.76 1.823.761.761 1.823.761ZM5.021 8.396h7.5V5.021h-7.5Zm7.229 10.771v-1.542l4.354-4.354 1.542 1.541-4.354 4.355Zm6.417-4.855-1.542-1.541.979-.979 1.542 1.541ZM4.25 15.75V4.25v7.396Z"/></svg>';
        static public const SETTINGS:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m7.646 18.333-.313-2.625q-.208-.125-.458-.27-.25-.146-.458-.271l-2.438 1.021-2.354-4.063 2.083-1.583V9.458L1.625 7.875l2.354-4.063 2.438 1.021q.208-.125.458-.27.25-.146.458-.271l.313-2.625h4.708l.313 2.625q.208.125.458.271.25.145.458.27l2.438-1.021 2.354 4.063-2.063 1.583v1.084l2.063 1.583-2.354 4.063-2.438-1.021q-.208.125-.458.271-.25.145-.458.27l-.313 2.625ZM10 12.979q1.229 0 2.104-.875T12.979 10q0-1.229-.875-2.104T10 7.021q-1.229 0-2.104.875T7.021 10q0 1.229.875 2.104t2.104.875Zm0-1.75q-.5 0-.865-.364-.364-.365-.364-.865t.364-.865q.365-.364.865-.364t.865.364q.364.365.364.865t-.364.865q-.365.364-.865.364ZM10.021 10Zm-.854 6.583h1.666l.25-2.166q.605-.167 1.167-.5.562-.334 1.021-.792l2.021.854.833-1.375-1.771-1.354q.104-.292.146-.604.042-.313.042-.646 0-.292-.042-.594t-.125-.635l1.771-1.375-.834-1.375-2.02.875q-.48-.479-1.032-.802-.552-.323-1.156-.49l-.271-2.187H9.167l-.271 2.187q-.604.167-1.156.49-.552.323-1.011.781l-2.021-.854-.833 1.375 1.75 1.354q-.083.333-.125.646-.042.312-.042.604t.042.594q.042.302.125.635l-1.75 1.375.833 1.375 2.021-.854q.459.458 1.011.781.552.323 1.156.49Z"/></svg>';
        static public const SHARE:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M14.5 18q-1.042 0-1.771-.729Q12 16.542 12 15.5q0-.167.021-.302.021-.136.062-.302l-4.958-3.021q-.313.333-.74.479-.427.146-.885.146-1.042 0-1.771-.729Q3 11.042 3 10q0-1.042.729-1.771Q4.458 7.5 5.5 7.5q.458 0 .885.156t.74.469l4.958-3.021q-.041-.166-.062-.302Q12 4.667 12 4.5q0-1.042.729-1.771Q13.458 2 14.5 2q1.042 0 1.771.729Q17 3.458 17 4.5q0 1.042-.729 1.771Q15.542 7 14.5 7q-.458 0-.885-.146t-.74-.479L7.917 9.396q.041.166.062.302Q8 9.833 8 10q0 .167-.021.302-.021.136-.062.302l4.958 3.021q.313-.354.74-.49.427-.135.885-.135 1.042 0 1.771.729.729.729.729 1.771 0 1.042-.729 1.771Q15.542 18 14.5 18Zm0-12.5q.417 0 .708-.292.292-.291.292-.708t-.292-.708Q14.917 3.5 14.5 3.5t-.708.292q-.292.291-.292.708t.292.708q.291.292.708.292Zm-9 5.5q.417 0 .708-.292.292-.291.292-.708t-.292-.708Q5.917 9 5.5 9t-.708.292Q4.5 9.583 4.5 10t.292.708Q5.083 11 5.5 11Zm9 5.5q.417 0 .708-.292.292-.291.292-.708t-.292-.708q-.291-.292-.708-.292t-.708.292q-.292.291-.292.708t.292.708q.291.292.708.292Zm0-12Zm-9 5.5Zm9 5.5Z"/></svg>';
        static public const STAR:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M6.917 14.5 10 12.146l3.083 2.354-1.166-3.792L15 8.5h-3.792L10 4.5l-1.208 4H5l3.083 2.208ZM10 18q-1.646 0-3.104-.625-1.458-.625-2.552-1.719t-1.719-2.552Q2 11.646 2 10q0-1.667.625-3.115.625-1.447 1.719-2.541Q5.438 3.25 6.896 2.625T10 2q1.667 0 3.115.625 1.447.625 2.541 1.719 1.094 1.094 1.719 2.541Q18 8.333 18 10q0 1.646-.625 3.104-.625 1.458-1.719 2.552t-2.541 1.719Q11.667 18 10 18Zm0-1.5q2.708 0 4.604-1.896T16.5 10q0-2.708-1.896-4.604T10 3.5q-2.708 0-4.604 1.896T3.5 10q0 2.708 1.896 4.604T10 16.5Zm0-6.5Z"/></svg>';
        static public const SYNC:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M4.729 12.792q-.333-.625-.531-1.323T4 10q0-2.521 1.771-4.292Q7.542 3.938 10.125 4L8.938 2.812 10 1.75l3 3-3 3-1.062-1.062L10.125 5.5q-1.958-.042-3.292 1.292Q5.5 8.125 5.5 10q0 .458.083.875.084.417.25.813ZM10 18.25l-3-3 3-3 1.062 1.062L9.875 14.5q1.958.042 3.292-1.292Q14.5 11.875 14.5 10q0-.458-.083-.875-.084-.417-.25-.813l1.104-1.104q.333.625.531 1.323T16 10q0 2.5-1.771 4.281Q12.458 16.062 9.875 16l1.187 1.188Z"/></svg>';
        static public const SYNC_FAIL:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M9.125 10.812V5.833h1.75v4.979ZM10 14.167q-.354 0-.615-.261-.26-.26-.26-.614t.26-.615q.261-.26.615-.26t.615.26q.26.261.26.615t-.26.614q-.261.261-.615.261Zm2.438-10.834H17.5v1.75h-2.229l.125.146q1.021.938 1.552 2.177.531 1.24.531 2.552 0 2.334-1.396 4.146-1.395 1.813-3.625 2.354v-1.833q1.5-.5 2.386-1.792.885-1.291.885-2.875 0-.916-.333-1.781-.334-.865-1.063-1.594l-.145-.145v1.958h-1.75ZM7.562 16.667H2.5v-1.75h2.229l-.146-.146q-1.021-.917-1.541-2.167-.521-1.25-.521-2.562 0-2.334 1.396-4.146 1.395-1.813 3.645-2.354v1.833q-1.5.521-2.395 1.802-.896 1.281-.896 2.865 0 .916.344 1.791.343.875 1.073 1.605l.124.124v-1.958h1.75Z"/></svg>';
        static public const SYNC_OFF:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m16 17.062-2.979-2.979q-.354.209-.729.386-.375.177-.792.281v-1.583q.104-.042.208-.094t.209-.094L5.958 7q-.208.438-.333.927-.125.49-.125 1.011 0 1 .406 1.854.406.854 1.094 1.458v-1.312h1.5v4h-4v-1.5h1.542q-.938-.834-1.49-1.99Q4 10.292 4 8.938q0-.834.219-1.605t.614-1.437L1.875 2.917l1.063-1.063L17.062 16Zm-.833-5.083-1.125-1.125q.208-.437.333-.916.125-.48.125-1 0-1-.406-1.865T13 5.604v1.334h-1.5v-4h4v1.5h-1.542q.938.833 1.49 1.989Q16 7.583 16 8.938q0 .833-.219 1.604-.219.77-.614 1.437ZM8.083 4.896 6.979 3.771q.354-.209.729-.375.375-.167.792-.271v1.583q-.104.042-.208.094t-.209.094Z"/></svg>';
        static public const THUMB_DOWN:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M.833 13.354V9.583L3.875 2.5h10.292v10.854l-5.875 5.813-1.625-1.625 1.104-4.188ZM12.396 4.25H5.042L2.583 9.938v1.666H10l-1.146 4.5 3.542-3.479Zm0 8.375V4.25Zm1.771.729-.021-1.75h2.437V4.25h-2.437V2.5h4.187v10.854Z"/></svg>';
        static public const THUMB_UP:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M5.833 17.5V6.646L11.708.833l1.625 1.625-1.104 4.188h6.938v3.771L16.125 17.5Zm1.771-1.75h7.354l2.459-5.688V8.396H10l1.146-4.5-3.542 3.479Zm0-8.375v8.375Zm-1.771-.729.021 1.75H3.417v7.354h2.437v1.75H1.667V6.646Z"/></svg>';
        static public const WARN:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m1 18 9-15 9 15Zm2.646-1.5h12.708L10 5.917Zm6.354-1q.312 0 .531-.219.219-.219.219-.531 0-.312-.219-.531Q10.312 14 10 14q-.312 0-.531.219-.219.219-.219.531 0 .312.219.531.219.219.531.219ZM9.25 13h1.5V9h-1.5Zm.75-1.792Z"/></svg>';
        static public const YOUTUBE_ADD:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="M12.771 14.458q-.542.021-1.042.032-.5.01-.896.01H10q-1.417 0-2.646-.042-1.062-.041-2.094-.104-1.031-.062-1.51-.187-.521-.146-.896-.511-.375-.364-.521-.885-.125-.459-.187-1.104-.063-.646-.104-1.25Q2 9.729 2 9q0-.729.042-1.417.041-.604.104-1.25.062-.645.187-1.104.146-.521.521-.885.375-.365.896-.511.479-.125 1.51-.187 1.032-.063 2.094-.104Q8.583 3.5 10 3.5q1.417 0 2.667.042 1.041.041 2.073.104 1.031.062 1.51.187.521.146.896.511.375.364.521.885.125.459.187 1.104.063.646.104 1.25Q18 8.271 18 9v.292q-.354-.146-.729-.219Q16.896 9 16.5 9q-1.667 0-2.833 1.167Q12.5 11.333 12.5 13q0 .375.073.74.073.364.198.718Zm-4.354-3.104L12.583 9 8.417 6.646ZM15.75 15.5v-1.75H14v-1.5h1.75V10.5h1.5v1.75H19v1.5h-1.75v1.75Z"/></svg>';
        static public const YOUTUBE_SEARCHED:String = '<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path d="m16.938 17-4.98-4.979q-.625.458-1.375.719Q9.833 13 9 13q-.771 0-1.458-.219-.688-.219-1.292-.614l1.104-1.105q.375.188.781.313.407.125.865.125 1.458 0 2.479-1.021Q12.5 9.458 12.5 8q0-1.458-1.021-2.479Q10.458 4.5 9 4.5q-1.458 0-2.479 1.021Q5.5 6.542 5.5 8l1.104-1.062L7.667 8l-2.834 2.833L2 8l1.062-1.062.938.958q.042-2.042 1.49-3.469T9 3q2.083 0 3.542 1.458Q14 5.917 14 8q0 .833-.26 1.583-.261.75-.719 1.375L18 15.938Z"/></svg>';

        static private const _ICON_CACHE:Dictionary = new Dictionary();

        private var _src:String;
        private var _doc:SVGDocument;
        private var _is_rendered:Boolean;
        private var _width_height_ratio:Number;

        public function Icon(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, url:String = '') {
            if (!Strings.is_empty_or_null(url))
                _src = url;
            super(parent, xpos, ypos);
        }

        /** INTERFACE net.blaxstar.starlib.components.IComponent ===================== */

        /**
         * initializes the component by adding all the children and committing the visual changes to be written on the next
         * frame. created to be overridden.
         */
        override public function init():void {
            on_enter_frame_signal = new NativeSignal(this, Event.ENTER_FRAME, Event);
            on_added_signal = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
            _resize_event_ = new Event(Event.RESIZE);
            on_resize_signal = new NativeSignal(this, Event.RESIZE, Event);
            on_draw_signal = new Signal();
            _width_ = _height_ = 16;

            _doc = new SVGDocument();
            _doc.addEventListener(SVGEvent.RENDERED, on_doc_parse);
            if (_src) {
                set_svg_xml(_src);
            }
        }

        private function on_doc_parse(e:SVGEvent = null):void {
            if (e) {
                _doc.removeEventListener(SVGEvent.RENDERED, on_doc_parse);
            }

            if (!doc_in_cache(_src)) {
                var clone:SVGDocument = _doc.clone() as SVGDocument;
                clone.autoAlign = true;
                _ICON_CACHE[src] = clone;
            }

            if (!_doc.parent) {
                add_children();
                on_added_signal.addOnce(draw);
            }

            _is_rendered = true;


            //_width_ = _doc.width;
            //_height_ = _doc.height;
            //_width_height_ratio = _height_ / _width_;
            set_color();
            dispatchEvent(new Event(ICON_LOADED));
            dispatchEvent(new Event(Event.RESIZE));
        }

        /**
         * initializes and adds all required children of the component.
         */
        override public function add_children():void {
            addChild(_doc);
            super.add_children();
            cacheAsBitmap = true;
        }

        /**
         * (re)draws the component and applies any pending visual changes.
         */
        override public function draw(e:Event = null):void {

            _doc.width = _width_;
            _doc.height = _height_;
            super.draw(e);
        }

        /** END INTERFACE ===================== */
        public function set_color(colorCode:String = 'FFFFFF'):void {
            if (colorCode.indexOf('#') < 0) {
                colorCode = '#' + colorCode;
            }
            var e:SVGElement = DisplayUtils.getSVGElement(_doc);
            e.style.setProperty('fill', colorCode);
        }

        public function set_svg_xml(svg_string:String):void {
            _is_rendered = false;
            _src = svg_string;

            if (doc_in_cache(src)) {
                removeChild(_doc);
                _doc = _ICON_CACHE[src];
                on_doc_parse(null);
            } else {
                _doc.autoAlign = true;
                _doc.addEventListener(SVGEvent.RENDERED, on_doc_parse);
                _doc.parse(svg_string);
            }
        }

        private function doc_in_cache(src:String):Boolean {
            return _ICON_CACHE.hasOwnProperty(src);
        }

        override public function set_size(w:Number, h:Number):void {
            if (!_is_rendered) {
                queue_function(set_size, w, h);
                return;
            }
            super.set_size(w, h);
        }

        public function get document():SVGDocument {
            return _doc;
        }

        public function get src():String {
            return _src;
        }
    }

}
