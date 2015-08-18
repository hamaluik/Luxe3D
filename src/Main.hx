import components.MouseRotate;
import luxe.components.render.MeshComponent;
import luxe.Entity;
import luxe.Input;
import luxe.Mesh;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Vector;
import phoenix.Shader;

class Main extends luxe.Game {
    var parcel:Parcel;
    var object:Entity;
    var flatShader:Shader;
    var lightDirection:Vector;
    var lightAngle:Float = 0;
    var lightAngularSpeed:Float = Math.PI / 4;
    var lightPosition:Vector = new Vector(0, 0, 0);
    
    override function config(config:luxe.AppConfig) {
        config.preload.jsons.push({ id: 'assets/parcel.json' });
        
        config.render.depth_bits = 24;
        config.render.depth = true;
        
        return config;
    } //config

    override function ready() {
        // load our data!
        parcel = new Parcel();
        parcel.from_json(Luxe.resources.json("assets/parcel.json").asset.json);
        var progress = new ParcelProgress({
            parcel: parcel,
            oncomplete: onloaded
            });
        parcel.load();
    } //ready
    
    function onloaded(p:Parcel) {
        trace("Load complete, took " + p.time_to_load + " s!");
        trace(Luxe.resources.text("assets/test.ply"));
        trace(Luxe.resources.text("assets/test.obj"));
        trace(Luxe.resources.shader("flatshaded"));
        
        // load the object
        object = new Entity({ name: 'object' });
        var mesh:MeshComponent = new MeshComponent({ name: 'mesh' });
        mesh.mesh = PlyImporter.createMesh("assets/test.ply", {});
        flatShader = Luxe.resources.shader("flatshaded");
        lightDirection = new Vector(0, 1, 0).normalized;
        flatShader.set_vector3("lightDirection", lightDirection);
        flatShader.set_vector3("lightColour", new Vector(0.8, 0.6, 0.6));
        flatShader.set_vector3("ambientColour", new Vector(0.1, 0.1, 0.1));
        mesh.mesh.geometry.shader = flatShader;
        object.add(mesh);
        object.add(new MouseRotate({ name: 'rotate' }));
        
        // set up the camera
        Luxe.camera.view.set_perspective({
            far: 1000,
            near: 0.1,
            fov: 90,
            aspect: Luxe.screen.w / Luxe.screen.h
            });
        Luxe.camera.pos.set_xyz(0, 0, 5);
        Luxe.camera.view.target = mesh.pos;
    }

    override function onkeyup(e:KeyEvent) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
    } //onkeyup

    override function update(dt:Float) {
        if(lightDirection != null) {
            lightAngle += lightAngularSpeed * dt;
            if(lightAngle >= 2 * Math.PI) {
                lightAngle -= 2 * Math.PI;
            }
            
            lightPosition.x = 2 * Math.cos(lightAngle);
            lightPosition.y = 2 * Math.sin(lightAngle);
            lightDirection = object.pos.clone().subtract(lightPosition).normalized;
            
            flatShader.set_vector3("lightDirection", lightDirection);
        }
    } //update
} //Main
