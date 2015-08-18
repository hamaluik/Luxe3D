package components;

import luxe.Component;
import luxe.Vector;
import luxe.Input;

class MouseRotate extends Component {

    var dragging : Bool = false;
    var mx : Float = 0;
    var my : Float = 0;
    var smooth : Float = 130;
    var mouse : Vector;
    var reference_rotation : Vector;

    override function init() {

        mouse = new Vector();
        reference_rotation = new Vector();

    } //init

    override function onmousedown(e:MouseEvent) {
        mouse = e.pos;
        dragging = true;
        reference_rotation.x = rotation.x;
        reference_rotation.y = rotation.y;
    }

    override function onmouseup(e:MouseEvent) {

        mouse = e.pos;
        dragging = false;

    } //onmouseup

    override function onmousemove(e:MouseEvent) {

        mouse = e.pos;

    } //onmousemove

    override function update(dt:Float) {

        if(dragging) {

            mx = (Luxe.screen.h / 2 - mouse.y) / smooth;
            my = (Luxe.screen.w / 2 - mouse.x) / smooth;

            rotation.setFromEuler(new Vector(-mx, -my));
        }

    } //update


} //MouseRotate