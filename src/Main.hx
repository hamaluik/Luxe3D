import components.MouseRotate;
import luxe.Camera;
import luxe.components.render.MeshComponent;
import luxe.Entity;
import luxe.Input;
import luxe.Mesh;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Vector;
import luxe.Visual;
import phoenix.RenderTexture;
import phoenix.Shader;
import phoenix.Batcher;
import snow.modules.opengl.GL;

class Main extends luxe.Game {
    var parcel:Parcel;

    var object:Entity;
    var plane:Entity;

    var flatShader:Shader;

    var lightDirection:Vector;
    var lightAngle:Float = 0;
    var lightAngularSpeed:Float = Math.PI / 4;
    var lightPosition:Vector = new Vector(0, 0, 0);

    var mainCamera = Luxe.camera;

    var shadowCamera:Camera;
    var shadowTexture:RenderTexture;
    var shadowShader:Shader;

    var previewMesh:Mesh;

    var colorBlack:luxe.Color = new luxe.Color(1, 0, 1, 1);
    
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
        
        // load the object
        object = new Entity({ name: 'object' });
        var mesh:MeshComponent = new MeshComponent({ name: 'mesh' });
        mesh.mesh = PlyImporter.createMesh("assets/test.ply", {});
        flatShader = Luxe.resources.shader("flatshaded");
        lightDirection = new Vector(0, 1, 0).normalized;
        flatShader.set_vector3("lightDirection", lightDirection);
        flatShader.set_vector3("lightColour", new Vector(0.9, 0.9, 0.9));
        flatShader.set_vector3("ambientColour", new Vector(0.1, 0.1, 0.1));
        mesh.mesh.geometry.shader = flatShader;
        object.add(mesh);
        object.add(new MouseRotate({ name: 'rotate' }));
        object.pos.set_xyz(0, 0, 1);

        // load the plane
        plane = new Entity({ name: 'plane' });
        var planeMesh:MeshComponent = new MeshComponent({ name: 'mesh' });
        planeMesh.mesh = PlyImporter.createMesh('assets/waterplane.ply', {});
        planeMesh.mesh.geometry.shader = flatShader;
        plane.add(planeMesh);
        plane.pos.set_xyz(0, 0, 0);
        plane.scale.set_xyz(10, 10, 10);
        
        // set up the camera
        Luxe.camera.view.set_perspective({
            far: 1000,
            near: 0.1,
            fov: 90,
            aspect: Luxe.screen.w / Luxe.screen.h
            });
        Luxe.camera.pos.set_xyz(0, -5, 1.5);
        Luxe.camera.view.target = plane.pos;

        // load the shad shader
        shadowShader = Luxe.resources.shader("depth");

        // position a camera in the same way as the light
        shadowCamera = new Camera({
            name: "shadowCamera",
            projection: phoenix.Camera.ProjectionType.ortho,
            near: 0.01,
            far: 1000,
            depth_test: true
        });
        shadowCamera.pos.set_xyz(0, 0, 10);
        shadowCamera.view.target = new Vector(0, 0, 0);

        // create a render texture for the shadows
        shadowTexture = new RenderTexture({
            id: 'shadowTexture',
            width: 512,
            height: 512,
            type: phoenix.Texture.TextureType.tex_2D,
            format: GL.RGBA,
            data_type: GL.UNSIGNED_BYTE,
            filter_min: phoenix.Texture.FilterType.nearest,
            filter_mag: phoenix.Texture.FilterType.nearest,
            clamp_s: phoenix.Texture.ClampType.edge,
            clamp_t: phoenix.Texture.ClampType.edge
        });

        previewMesh = PlyImporter.createMesh("assets/shadowpreview.ply", {
            texture: shadowTexture
        });
    }

    override function onkeyup(e:KeyEvent) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
    } //onkeyup

    override function onprerender() {
        if(shadowTexture == null) return;
        Luxe.camera = shadowCamera;
        Luxe.renderer.target = shadowTexture;
        Luxe.renderer.clear(colorBlack);
        Luxe.renderer.batcher.shader_override = shadowShader;
        Luxe.renderer.batcher.draw();
        Luxe.renderer.batcher.shader_override = null;
        Luxe.renderer.target = null;
        Luxe.camera = mainCamera;
    } // onprerender

    override function update(dt:Float) {
        
    } //update
} //Main
