package com.ideas.gui {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import com.ideas.gui.buttons.SearchButton;

    public class SearchScreen extends Sprite {
        public static const SEARCH:String = "SEARCH";
        public static const WIDTH:int = 160;
        public static const HEIGHT:int = 60;
        public static const OFFSET:int = 10;
        private var _pickRegExp:RegExp = new RegExp("", "gi");
        private var _inputText:TextField = new TextField();
        private var searchButton:SearchButton = new SearchButton(HEIGHT - OFFSET * 2, HEIGHT - OFFSET * 2);
        public function SearchScreen() {
            this.addChild(_inputText);
            this.addChild(searchButton);
            searchButton.addEventListener(MouseEvent.CLICK, onSearch);
            _inputText.defaultTextFormat = new TextFormat("_sans", 24, 0);
            _inputText.addEventListener(Event.CHANGE, onChange);
            _inputText.alpha = 0.5
            _inputText.width = WIDTH - HEIGHT - OFFSET;
            _inputText.height = HEIGHT - OFFSET * 2
            _inputText.type = TextFieldType.INPUT;
            _inputText.x = OFFSET
            _inputText.y = OFFSET + 5;
            _inputText.needsSoftKeyboard = true;
            searchButton.x = WIDTH - HEIGHT + OFFSET;
            searchButton.y = OFFSET;
            this.graphics.clear();
            this.graphics.lineStyle(0, 0xcccccc, 1, true);
            var mtrx:Matrix = new Matrix();
            mtrx.createGradientBox(HEIGHT, HEIGHT, Math.PI / 2, 0, 0);
            this.graphics.beginGradientFill("linear", [ 0x555555, 0x0 ], [ 0.5, 0.5 ], [ 0, 0xff ], mtrx);
            this.graphics.drawRoundRectComplex(0, 0, WIDTH, HEIGHT, 0, 0, 10, 10);
            this.graphics.endFill();
            this.graphics.beginFill(0xffffff, 0.5);
            this.graphics.drawRect(OFFSET, OFFSET, WIDTH - HEIGHT - OFFSET, HEIGHT - OFFSET * 2);
            this.graphics.endFill();
            this.cacheAsBitmap = true;
        }
        private function onSearch(e:Event):void {
            this.dispatchEvent(new Event(SEARCH))
        }
        private function onChange(e:Event):void {
            _pickRegExp = new RegExp(_inputText.text, "gi"); // case insensetive
        }
        public function getText():String {
            return _inputText.text;
        }
        public function get pickRegExp():RegExp {
            return _pickRegExp;
        }
        public function get inputText():TextField {
            return _inputText;
        }
    }
}
