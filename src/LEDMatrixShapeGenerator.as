package {

import com.bit101.components.Text;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.system.System;
import flash.text.TextExtent;
import flash.text.TextField;
import flash.text.engine.DigitCase;

import uk.co.soulwire.gui.SimpleGUI;

[SWF(backgroundColor="0x000000")]
public class LEDMatrixShapeGenerator extends Sprite {

    [Embed(source="assets/pf_ronda_seven.swf", symbol="PF Ronda Seven")]
    private static var RONDA:Class;


    private static const LCD_WIDTH:uint = 24;
    private static const LCD_HEIGHT:uint = 16;

    private var _simpleGui:SimpleGUI;

    private var _circles:Vector.<Sprite> = new Vector.<Sprite>();
    private var _lightingUp:Boolean;

    private var _fileReference:FileReference = new FileReference();
    private var _bitmapLoader:Loader = new Loader();

    private var _infoTextField:Text = new Text();


    public var ignoreColor:uint = 0x000000;

    public function LEDMatrixShapeGenerator() {

        createDebugGui();
        createMatrix();

        _bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapLoaded);
    }

    private function onBitmapLoaded(event:Event):void {

        var bitmap:Bitmap = Bitmap(_bitmapLoader.content);

        if(bitmap.bitmapData.width == LCD_WIDTH && bitmap.bitmapData.height == LCD_HEIGHT)
        {
            for(var i:uint = 0; i < _circles.length; i++)
            {
                if(bitmap.bitmapData.getPixel(i % LCD_WIDTH, Math.floor(i / LCD_WIDTH)) == ignoreColor)
                {
                    _circles[i].alpha = 0.2;

                }
                else
                {
                    _circles[i].alpha = 1;
                }
            }
        }
    }

    private function createDebugGui():void
    {

        _simpleGui = new SimpleGUI(this);
        _simpleGui.addButton("all off", {callback:onAllOff});
        _simpleGui.addButton("all on", {callback:onAllOn});
        _simpleGui.addColumn();
        _simpleGui.addColour("ignoreColor", {"label":"ignore color"});
        _simpleGui.addFileChooser("bitmap", _fileReference, onFileLoaded, [new FileFilter("bitmap",  "*.jpg;*.gif;*.png;*.bmp")], {width:70});
        _simpleGui.addColumn();
        _simpleGui.addButton("export", {callback:onExport});
       _simpleGui.show();

        var text:Text = new Text(this,  0, 320,  "Click and drag on the matrix to change led's state. Export button copies variable's code that you can feed to matrix.drawBitmap(). Bitmap size must be 24x16 px. Every color that's different than ignoreColor value would be treated as led on.");
        text.editable = false;
        text.selectable = false;
        text.setSize(500, 80);
        text.textField.background = false;
        text.textField.backgroundColor = 0x0;
        text.textField.border = false;
        text.enabled = false;
        text.draw();
    }

    private function onFileLoaded():void {

       _bitmapLoader.loadBytes(_fileReference.data);
    }

    private function onAllOn():void {

        for each(var circle:Sprite in _circles) circle.alpha = 1;
    }

    private function onAllOff():void {

        for each(var circle:Sprite in _circles) circle.alpha = 0.2;
    }

    private function onExport():void {

        var upperHalfOfTheScreen:Vector.<String> = new Vector.<String>();
        var lowerHalfOfTheScreen:Vector.<String> = new Vector.<String>();

        for(var col:uint = LCD_WIDTH; col >0 ; col--)
        {
            lowerHalfOfTheScreen.push(get1x8ColumnAt(col - 1, LCD_HEIGHT/2));
            upperHalfOfTheScreen.push(get1x8ColumnAt(col - 1, 0));
        }

        var matrix:String = lowerHalfOfTheScreen.join(",") + "," + upperHalfOfTheScreen.join(",");

        System.setClipboard( "static unsigned char PROGMEM shape[] = {"+matrix+"};");
    }

    private function get1x8ColumnAt(x:uint,  y:uint):String
    {
       var column:String = "B";

        for(var i:uint = 0; i < 8; i ++)
        {
            var circle:Sprite = getCircleAt(x,  y + i);
            column +=  circle.alpha == 1 ? "1" : "0";
        }

        return column;
    }

    private function getCircleAt(x:uint,  y:uint):Sprite
    {
        return _circles[x + y * LCD_WIDTH];
    }

    private function createMatrix():void {

        for(var y:uint = 0; y < LCD_HEIGHT; y ++)
        {
            for(var x:uint = 0; x < LCD_WIDTH; x ++)

          {

               var circle:Sprite = createCircle();
                circle.x = 90+ (x+1) * 12;
                circle.y = 100+(y+1) * 12;
                circle.addEventListener(MouseEvent.MOUSE_DOWN, onCircleMouseDown);
                circle.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
                addChild(circle);


                _circles.push(circle);
            }
        }
    }

    private function onRollOver(event:MouseEvent):void {

        if(event.buttonDown)
        {
            var circle:Sprite = event.target as Sprite;
            circle.alpha = _lightingUp ? 1 : 0.2;
        }
    }

     private function onCircleMouseDown(event:MouseEvent):void {

       var circle:Sprite = event.target as Sprite;

        if(circle.alpha == 1) {
            circle.alpha = 0.2;
        }
        else if(circle.alpha < 1)
        {
            circle.alpha = 1;
        }

       _lightingUp = circle.alpha == 1;
    }

    private function createCircle():Sprite
    {

        var circle:Sprite = new Sprite();
        circle.graphics.beginFill(0xff0000);
        circle.graphics.drawCircle(0,0,5);
        circle.graphics.endFill();
        circle.filters = [new GlowFilter(0xff0000, 0.6, 4, 4, 3)];


        return circle;
    }
}
}
