package com.ideas.tool {
    import flash.events.Event;
    import flash.text.TextField;
    public class TextFieldScroll extends TextField {
        private var postTimer:int = 0;
        private var preTimer:int = 0;
        public static const TIMER:int = 12;
        public function TextFieldScroll() {
            super();
            this.addEventListener(Event.REMOVED, onRemoved, false, 0, true);
        }
        override public function set width(value:Number):void {
            super.width = value;
            init();
        }
        override public function set text(value:String):void {
            super.text = value;
            init();
        }
        public function resetPos():void {
            postTimer = 0;
            preTimer = 0;
            this.scrollH = 0;
            init();
        }
        private function onTick(e:Event):void {
            preTimer++;
            if (preTimer > TIMER) {
                this.scrollH++;
            }
            if (this.scrollH >= this.maxScrollH) {
                postTimer++;
                if (postTimer > TIMER) {
                    this.scrollH = 0;
                    preTimer = 0;
                }
            } else {
                postTimer = 0
            }
            if (this.maxScrollH <= 0) {
                this.removeEventListener(Event.ENTER_FRAME, onTick);
            }
        }
        private function onRemoved(e:Event):void {
            this.removeEventListener(Event.ENTER_FRAME, onTick);
            this.removeEventListener(Event.REMOVED, onRemoved);
        }
        private function init():void {
            if (this.maxScrollH > 0) {
                this.addEventListener(Event.ENTER_FRAME, onTick, false, 0, true);
            }
        }
    }
}
