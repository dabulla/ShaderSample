import QtQuick 2.2
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0
import QtQuick.Scene3D 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQml 2.2

import fhac 1.0

Item {
    SplitView {
        orientation: Qt.Horizontal
        anchors.fill: parent
        ColumnLayout {
            width: 400
            Button {
                Layout.fillWidth: true
                text: "Reload"
                onClicked: shaderModel.syncModel()
            }

            TreeView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ShaderModel {
                    id: shaderModel
                    shaderProgram: ShaderProgram {
                        id: shaderProg
                        vertexShaderCode: loadSource("qrc:/shader/pointcloud.vert")
                        fragmentShaderCode: loadSource("qrc:/shader/pointcloud.frag")
                    }
                }

                rowDelegate: Rectangle {
                    height: 100
                }

                TableViewColumn {
                    role: "name"
                    title: "name"
                    width: 60
                    resizable: true
                    delegate: Label {
                        verticalAlignment:  Text.AlignVCenter
                        text: styleData.value
                    }
                }
                TableViewColumn {
                    role: "type"
                    title: "type"
                    width: 50
                    resizable: true
                    delegate: Label {
                        verticalAlignment:  Text.AlignVCenter
                        text: styleData.value.toString()
                    }
                }
                TableViewColumn {
                    role: "datatype"
                    title: "datatype"
                    width: 60
                    resizable: true
                    delegate: Component {
                            Label {
                            verticalAlignment:  Text.AlignVCenter
                            text: styleData.value.toString()
                        }
                    }
                }
                TableViewColumn {
                    role: "data"
                    title: "data"
                    resizable: true
                    delegate: delegateManager.autoSelectComponent
                }
            }
        }
        ShaderUniformDelegate {
            property var params
            id: delegateManager
            target: delegateManager
            parametersProperty: "params"
            onParametersChanging: {
                sceneParent.children = ""
            }

            onParametersChangedFinished: {
                sceneCompo.createObject(sceneParent, {parameters:params})
            }
        }
        Item {
            id:sceneParent
            Layout.fillHeight: true
            Layout.minimumWidth: 50
        }

        Component {
            id: sceneCompo
        Scene3D {
            property var parameters
            anchors.fill: parent
            id: scene3d
            focus: true
            aspects: ["input", "logic"]
            cameraAspectRatioMode: Scene3D.AutomaticAspectRatio

            Entity {
                id: sceneRoot

                Camera {
                    id: camera
                    projectionType: CameraLens.PerspectiveProjection
                    fieldOfView: 45
                    aspectRatio: 16/9
                    nearPlane : 0.1
                    farPlane : 1000.0
                    position: Qt.vector3d( 0.0, 0.0, -40.0 )
                    upVector: Qt.vector3d( 0.0, 1.0, 0.0 )
                    viewCenter: Qt.vector3d( 0.0, 0.0, 0.0 )
                }

                OrbitCameraController {
                    camera: camera
                }

                components: [
                    RenderSettings {
                        activeFrameGraph: Viewport {
                            id: viewport
                            normalizedRect: Qt.rect(0.0, 0.0, 1.0, 1.0) // From Top Left
                            RenderSurfaceSelector {
                                CameraSelector {
                                    id : cameraSelector
                                    camera: camera
                                    FrustumCulling {
                                        ClearBuffers {
                                            buffers : ClearBuffers.ColorDepthBuffer
                                            clearColor: Qt.rgba(0.2,0.4,0.6,1.0)
                                            NoDraw {}
                                        }
                                        TechniqueFilter {
                                            id: techniqueFilter
                                            RenderStateSet {
                                                renderStates: [
                                                    //PointSize { sizeMode: PointSize.Fixed; value: 5.0 }, // exception when closing application in qt 5.7
                                                    PointSize { sizeMode: PointSize.Programmable }, //supported since OpenGL 3.2
                                                    DepthTest { depthFunction: DepthTest.Less }
                                                    //DepthMask { mask: true }
                                                ]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    // Event Source will be set by the Qt3DQuickWindow
                    InputSettings { }
                ]

//                PhongMaterial {
//                    id: material
//                }

                Material {
                    id: material
                    effect: Effect {
                        techniques: [
                            Technique {
                                id: technique1
//                                graphicsApiFilter {
//                                    api: GraphicsApiFilter.OpenGL
//                                    profile: GraphicsApiFilter.CoreProfile
//                                    majorVersion: 3
//                                    minorVersion: 1
//                                }
                                property var params: []
                                Instantiator {
                                    id: parameterInstantiator
                                    property int numberOfEditableParameters: scene3d.parameters.length
                                    Parameter {
                                        name: scene3d.parameters[index].name
                                        value: scene3d.parameters[index].value
                                    }
                                    onObjectAdded: {
                                        console.log("dbg " + object.name + " " + object.value)
                                        technique1.params.push(object)
                                    }
                                }
                                Component.onCompleted: {
                                    var renderPassObj = renderPassCompo.createObject(technique1, {parameters:technique1.params})
                                    console.log("instantiated" + renderPassObj.parameters.length);
                                    technique1.renderPasses.push(renderPassObj)
                                }

                                Component {
                                    id: renderPassCompo
                                RenderPass {
                                    id: renderPass1
//                                        Component.onCompleted: {
//                                            technique1.renderPasses.push(renderPass1)
////                                            for(var k=0; k< scene3d.parameters.length ; ++k) {
////                                                console.log("DBG" + k)
////                                                renderPass1.parameters.push(scene3d.parameters[k])
////                                            }
//                                        }

                                    //parameters: []
//                                        parameters: parameterInstantiator//[ Parameter { name:"theColor"; value:0.5 } ]
                                    shaderProgram: ShaderProgram {
                                        id: shaderProg
                                        vertexShaderCode: loadSource("qrc:/shader/pointcloud.vert")
                                        fragmentShaderCode: loadSource("qrc:/shader/pointcloud.frag")
//                                            vertexShaderCode: "#version 150 core" + "\n" +
//                                            "in vec3 vertexPosition;" + "\n" +
//                                            "out vec3 worldPosition;" + "\n" +
//                                            "uniform mat4 modelMatrix;" + "\n" +
//                                            "uniform mat4 mvp;" + "\n" +
//                                            "" + "\n" +
//                                            "void main()" + "\n" +
//                                            "{" + "\n" +
//                                            "    // Transform position, normal, and tangent to world coords" + "\n" +
//                                            "    worldPosition = vec3(modelMatrix * vec4(vertexPosition, 1.0));" + "\n" +
//                                            "" + "\n" +
//                                            "    // Calculate vertex position in clip coordinates" + "\n" +
//                                            "    gl_Position = mvp * vec4(worldPosition, 1.0);" + "\n" +
//                                            "}"
//                                            fragmentShaderCode: "#version 150 core" + "\n" +
//                                            "" + "\n" +
//                                            "uniform vec3 maincolor;" + "\n" +
//                                            "out vec4 fragColor;" + "\n" +
//                                            "" + "\n" +
//                                            "void main()" + "\n" +
//                                            "{" + "\n" +
//                                            "    //output color from material" + "\n" +
//                                            "    fragColor = vec4(1.0);" + "\n" +
//                                            "}"
                                    }
                                    renderStates: [
                                        DepthTest { depthFunction: DepthTest.Less }
                                    ]
                                }
                                }
                                renderPasses: [

                                ]
                            }
                        ]
                    }
//                    parameters: [
//                            Parameter {
//                                name: "maincolor"
//                                value: Qt.vector3d(1, 0, 0)
//                            }
//                        ]
                }


//                Material {
//                    id: material
//                    effect: Effect {
//                        techniques: [
//                            Technique {
//                                id: pointsTechnique
//                                filterKeys: [ FilterKey { name: "test"; value: "yes" }]
//                                renderPasses: RenderPass {
//                                    shaderProgram: ShaderProgram {
//                                        vertexShaderCode: loadSource("qrc:/shader/pointcloud.vert")
//                                        fragmentShaderCode: loadSource("qrc:/shader/pointcloud.frag")
//                                    }
//                                    renderStates: [
//                                        DepthTest { depthFunction: DepthTest.Less }
//                                    ]
//                                }
//                            }
//                        ]
//                    }
//                }















                TorusMesh {
                    id: torusMesh
                    radius: 5
                    minorRadius: 1
                    rings: 100
                    slices: 20
                }

                Transform {
                    id: torusTransform
                    scale3D: Qt.vector3d(1.5, 1, 0.5)
                    rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), 45)
                }

                Entity {
                    id: torusEntity
                    components: [ torusMesh, material, torusTransform ]
                }

                SphereMesh {
                    id: sphereMesh
                    radius: 3
                }

                Transform {
                    id: sphereTransform
                    property real userAngle: 0.0
                    matrix: {
                        var m = Qt.matrix4x4();
                        m.rotate(userAngle, Qt.vector3d(0, 1, 0));
                        m.translate(Qt.vector3d(2, 0, 0));
                        return m;
                    }
                }

                NumberAnimation {
                    target: sphereTransform
                    property: "userAngle"
                    duration: 1000
                    from: 0
                    to: 360

                    loops: Animation.Infinite
                    running: true
                }

                Entity {
                    id: sphereEntity
                    components: [ sphereMesh, phong, sphereTransform ]
                }
                PhongMaterial {
                    id: phong
                }
            }
        }
        }
    }
}
