// from: https://gist.github.com/KeyMaster-/247fee525cf73d086dc3
// Keymaster-/PlyImporter.hx

package;
import luxe.Mesh;
import haxe.io.StringInput;
import luxe.options.MeshOptions;
import luxe.Vector;
import phoenix.Batcher;
import phoenix.geometry.Geometry;
import PlyParser;
import phoenix.geometry.Vertex;
import luxe.Log.*;
/**
 * Imports a Blender-exported .ply file
 */
class PlyImporter {
	
	//Usage: var m:Mesh = PlyImporter.createMesh('path/to/file.ply', {...});
	
	public static function createMesh(id:String, meshOptions:MeshOptions):Mesh {
		if (meshOptions == null) {
			throw "The importer requires non-null options at the moment";
		}
		
		//var fileString:String = Luxe.resources.text(id).asset.text;
        var res = Luxe.resources.text(id);
        assertnull(res, 'PlyImporter cannot find text resource named $id, is it loaded?');
        var fileString = res.asset.text;
		
		var input = new StringInput(fileString);
		var parser = new PlyParser(input);
		parser.read();
		
		var vertexElement:Element = parser.elements.get("vertex");
		var faceElement:Element = parser.elements.get("face");
		if (vertexElement == null) throw "The .ply file is missing a \'vertex\' element";
		if (faceElement == null) throw "The .ply file is missing a \'face\' element";
		
		//If the vertex element has a property named 'red', assume that the vertex includes vertex color data
		var hasVertexColor:Bool = Lambda.has(vertexElement.orderedPropNames, "red");
		
		//If the vertex element has a property named 's', assume that it has the 's' and 't' properties for UV coordinates
		var hasUVs:Bool = Lambda.has(vertexElement.orderedPropNames, "s");
		
		//Extract all vertices
		var vertices:Array<Vertex> = new Array<Vertex>();
		var v:Vertex;
		for (vertex in parser.data.get(vertexElement)) {
			v = new Vertex(new Vector());
			v.pos.x = vertex.x;
			v.pos.y = vertex.y;
			v.pos.z = vertex.z;
			v.normal.x = vertex.nx;
			v.normal.y = vertex.ny;
			v.normal.z = vertex.nz;
			if (hasVertexColor) {
				v.color.r = vertex.red / 255;
				v.color.g = vertex.green / 255;
				v.color.b = vertex.blue / 255;
			}
			if (hasUVs) {
				v.uv.uv0.u = vertex.s;
				v.uv.uv0.v = 1 - vertex.t;
			}
			vertices.push(v);
		}
		
		//Extract faces to lists of Ints
		var faces = new Array<Array<Int>>();
		for (face in parser.data.get(faceElement)) {
			var array = new Array<Int>();
			for (i in 0...face.vertex_indices.data.length) {
				array.push(Std.int(face.vertex_indices.data[i]));
			}
			faces.push(array);
		}
		
		var batcher = meshOptions.batcher == null ? Luxe.renderer.batcher : meshOptions.batcher;
		
		var geom:Geometry = new Geometry( { 
			batcher: batcher,
			texture:meshOptions.texture,
			primitive_type:PrimitiveType.triangles
		} );
		
		for (face in faces) {
			for (index in face) {
				geom.add(vertices[index]);
			}
		}
		
		meshOptions.geometry = geom;
		
		var mesh = new Mesh(meshOptions);
		return mesh;
	}
}