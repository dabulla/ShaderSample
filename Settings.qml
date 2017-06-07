import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

Dialog {
    width: 800
    property alias vertexShader: vsTf.text
    property alias geometryShader: gsTf.text
    property alias tesselationControlShader: tcsTf.text
    property alias tesselationEvaluationShader: tesTf.text
    property alias fragmentShader: fsTf.text
    property alias computeShader: csTf.text
    property alias modelSource: modelTf.text

    FileDialog {
        id: vertexShaderFiledialog
        title: "Vertexshader"
        nameFilters: [ "GLSL Vertexshader files (*.vs *.vert *.glsl)", "GLSL files (*.glsl)", "GLSL Vertexshader files (*.vs *.vert)", "All files (*)"]
        onFileUrlChanged: vsTf.text = fileUrl.toString().replace("file://", "")
        folder: vsTf.text
    }
    FileDialog {
        id: geometryShaderFiledialog
        title: "Geometryshader"
        nameFilters: [ "GLSL Geometryshader files (*.gs *.geom *.glsl)", "GLSL files (*.glsl)", "GLSL Geometryshader files (*.gs *.geom)", "All files (*)"]
        onFileUrlChanged: gsTf.text = fileUrl.toString().replace("file://", "")
        folder: gsTf.text
    }
    FileDialog {
        id: tcsShaderFiledialog
        title: "Tesselation Control Shader"
        nameFilters: [ "GLSL Tesselation Control Shader files (*.tcs *.glsl)", "GLSL files (*.glsl)", "GLSL Tesselation Control Shader files (*.tcs)", "All files (*)"]
        onFileUrlChanged: tcsTf.text = fileUrl.toString().replace("file://", "")
        folder: tcsTf.text
    }
    FileDialog {
        id: tesShaderFiledialog
        title: "Tesselation Evaluation Shader"
        nameFilters: [ "GLSL Tesselation Evaluation Shader files (*.tes *.glsl)", "GLSL files (*.glsl)", "GLSL Tesselation Evaluation Shader files (*.tes)", "All files (*)"]
        onFileUrlChanged: tesTf.text = fileUrl.toString().replace("file://", "")
        folder: tesTf.text
    }
    FileDialog {
        id: fragmentShaderFiledialog
        title: "Fragmentshader"
        nameFilters: [ "GLSL Fragmentshader files (*.fs *.frag *.glsl)", "GLSL files (*.glsl)", "GLSL Fragmentshader files (*.fs *.frag)", "All files (*)"]
        onFileUrlChanged: fsTf.text = fileUrl.toString().replace("file://", "")
        folder: fsTf.text
    }
    FileDialog {
        id: computeShaderFiledialog
        title: "Computeshader"
        nameFilters: [ "GLSL Computeshader files (*.cs *.comp *.glsl)", "GLSL files (*.glsl)", "GLSL Fragmentshader files (*.cs *.comp)", "All files (*)"]
        onFileUrlChanged: fsTf.text = fileUrl.toString().replace("file://", "")
        folder: fsTf.text
    }
    FileDialog {
        id: modelFiledialog
        nameFilters: [
            "All supported formats ( *.fbx *.obj *.ply *.stl )",
            "Autodesk ( .fbx )",
//            "Collada ( .dae )",
//            "glTF ( .gltf, .glb )",
//            "Blender 3D ( .blend )",
//            "3ds Max 3DS ( .3ds )",
//            "3ds Max ASE ( .ase )",
            "Wavefront Object ( .obj )",
//            "Industry Foundation Classes (IFC/Step) ( .ifc )",
//            "XGL ( .xgl,.zgl )",
            "Stanford Polygon Library ( .ply )",
//            "*AutoCAD DXF ( .dxf )",
//            "LightWave ( .lwo )",
//            "LightWave Scene ( .lws )",
//            "Modo ( .lxo )",
            "Stereolithography ( .stl )",
//            "DirectX X ( .x )",
//            "AC3D ( .ac )",
//            "Milkshape 3D ( .ms3d )",
//            "* TrueSpace ( .cob,.scn )",
//            "Quake I ( .mdl )",
//            "Quake II ( .md2 )",
//            "Quake III Mesh ( .md3 )",
//            "Quake III Map/BSP ( .pk3 )",
//            "* Return to Castle Wolfenstein ( .mdc )",
//            "Doom 3 ( .md5* )",
//            "*Valve Model ( .smd,.vta )",
//            "*Open Game Engine Exchange ( .ogex )",
//            "*Unreal ( .3d )",
//            "BlitzBasic 3D ( .b3d )",
//            "Quick3D ( .q3d,.q3s )",
//            "Neutral File Format ( .nff )",
//            "Sense8 WorldToolKit ( .nff )",
//            "Object File Format ( .off )",
//            "PovRAY Raw ( .raw )",
//            "Terragen Terrain ( .ter )",
//            "3D GameStudio (3DGS) ( .mdl )",
//            "3D GameStudio (3DGS) Terrain ( .hmp )",
//            "Izware Nendo ( .ndo )",
            "All files (*)" ]
        onFileUrlChanged: modelTf.text = fileUrl.toString().replace("file://", "") //TODO: Windows
        folder: modelTf.text
    }

    ColumnLayout {
        anchors.fill: parent
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            Label {
                text: "Vertex Shader"
            }
            TextField {
                id: vsTf
                Layout.fillWidth: true
            }
            Button {
                text: "..."
                onClicked: vertexShaderFiledialog.open()
            }
            Label {
                text: "Geometry Shader"
            }
            TextField {
                id: gsTf
                Layout.fillWidth: true
            }
            Button {
                text: "..."
                onClicked: geometryShaderFiledialog.open()
            }
            Label {
                text: "Tesselation Control Shader"
            }
            TextField {
                id: tcsTf
                Layout.fillWidth: true
            }
            Button {
                text: "..."
                onClicked: tcsShaderFiledialog.open()
            }
            Label {
                id: longestLabelOfFirstColumn
                text: "Tesselation Evaluation Shader"
            }
            TextField {
                id: tesTf
                Layout.fillWidth: true
            }
            Button {
                text: "..."
                onClicked: tesShaderFiledialog.open()
            }
            Label {
                text: "Fragment Shader"
            }
            TextField {
                id: fsTf
                Layout.fillWidth: true
            }
            Button {
                text: "..."
                onClicked: fragmentShaderFiledialog.open()
            }
            Label {
                text: "Compute Shader"
            }
            TextField {
                id: csTf
                Layout.fillWidth: true
            }
            Button {
                text: "..."
                onClicked: computeShaderFiledialog.open()
            }
            Item { Layout.columnSpan: 3; height: 5 }
            Label {
                text: "Model"
            }
            TextField {
                id: modelTf
                Layout.fillWidth: true
            }
            Button {
                id: lastColumnItem
                text: "..."
                onClicked: modelFiledialog.open()
            }
        }
        Item { Layout.fillWidth: true; height: 5 }
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: lastColumnItem.width
            columns: 6
            Label {
                text: "Primitive Type"
                Layout.minimumWidth: longestLabelOfFirstColumn.width
            }
            ComboBox {
                id: primitiveTypeCb
                Layout.fillWidth: true
                Layout.minimumWidth: 120
                model: [ "Points",
                         "Lines", "LineLoop", "LineStrip",
                         "Triangles", "TriangleStrip", "TriangleFan",
                         "LinesAdjacency", "TrianglesAdjacency", "LineStripAdjacency", "TriangleStripAdjacency",
                         "Patches"]
                currentIndex: 4 //Triangles
            }
            Label {
                text: "Rotate Model"
            }
            CheckBox {
                id: rotateCb
            }
            Label {
                enabled: rotateCb.checked
                text: "Rotation Speed"
            }
            Slider {
                enabled: rotateCb.checked
                id: rotateSlider
                minimumValue: 0.01
                maximumValue: 2
                Layout.fillWidth: true
            }
            Item { Layout.columnSpan: 6; height: 1 }
            Label {
                text: "Show Grid"
            }
            CheckBox {
                checked: true
                id: showGridCb
            }
            Label {
                text: "Grid Spacing"
                enabled: showGridCb.checked
            }
            TextField {
                id: gridSpace
                text: "1"
                validator: IntValidator {}
                enabled: showGridCb.checked
            }
            Label {
                text: "Grid Lines"
                enabled: showGridCb.checked
            }
            TextField {
                id: gridlines
                text: "20"
                validator: IntValidator {}
                enabled: showGridCb.checked
                Layout.fillWidth: true
            }
        }
    }
}
