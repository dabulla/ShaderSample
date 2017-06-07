import QtQuick 2.2
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0
import QtQuick.Scene3D 2.0

import fhac 1.0

Scene3D {
    property string modelSource
//    property string vertexShader
//    property string fragmentShader
    // must be available to update parameters
    property alias parameters: renderPass1.parameters
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

        Material {
            id: material
            effect: Effect {
                techniques: [
                    Technique {
                        id: technique1
                        parameters: [ Parameter {
                                name: "diffuseTex"
                                value: Texture2D {
                                    minificationFilter: Texture.LinearMipMapLinear
                                    magnificationFilter: Texture.Linear
                                    wrapMode {
                                        x: WrapMode.Repeat
                                        y: WrapMode.Repeat
                                    }
                                    generateMipMaps: true
                                    maximumAnisotropy: 16.0
                                    TextureImage {
                                        source: "qrc:/textures/75692-diffuse.jpg"
                                    }
                                }
                            },
                            Parameter {
                                name: "specularTex"
                                value: Texture2D {
                                    minificationFilter: Texture.LinearMipMapLinear
                                    magnificationFilter: Texture.Linear
                                    wrapMode {
                                        x: WrapMode.Repeat
                                        y: WrapMode.Repeat
                                    }
                                    generateMipMaps: true
                                    maximumAnisotropy: 16.0
                                    TextureImage {
                                        source: "qrc:/textures/75692-specular.jpg"
                                    }
                                }
                            }
                        ]
                        renderPasses: [ RenderPass {
                            id: renderPass1
                            /*${PARAMETERS}*/
                            shaderProgram: ShaderProgram {
                                id: shaderProg
                                /*${VS}*/
                                /*${FS}*/
                                /*${GS}*/
                                /*${TCS}*/
                                /*${TES}*/
                                /*${CS}*/
                            }
                            renderStates: [
                                DepthTest { depthFunction: DepthTest.Less }
                            ]
                        } ]
                    }
                ]
            }

        }

        HelperGridMesh {
            id: gridMesh
        }
        Transform {
            id: gridTransform
            matrix: {
                var m = Qt.matrix4x4()
                m.translate(Qt.vector3d(0, -5, 0));
                return m;
            }
        }
        Entity {
            id: gridEntity
            components: [ gridMesh, phong, gridTransform ]
        }
        Mesh {
            id: mesh
            source: "file://" + scene3d.modelSource
            primitiveType: Mesh.Points
        }
        Transform {
            id: transform
            property real userAngle: 0.0
            matrix: {
                var m = Qt.matrix4x4()
                m.rotate(userAngle, Qt.vector3d(0, 1, 0))
                m.translate(Qt.vector3d(0, -10, 0));
                m.scale(100.0)
                return m;
            }
        }

        NumberAnimation {
            target: transform
            property: "userAngle"
            duration: 10000
            from: 0
            to: 360

            loops: Animation.Infinite
            running: true
        }

        Entity {
            id: entity
            components: [ mesh, material, transform ]
        }
        PhongMaterial {
            id: phong
        }
    }
}
