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

Scene3D {
    // "C:/develop/ShaderSample/shader/pointcloud.frag"
    property string vertexShader
    property string fragmentShader
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
//                                graphicsApiFilter {
//                                    api: GraphicsApiFilter.OpenGL
//                                    profile: GraphicsApiFilter.CoreProfile
//                                    majorVersion: 3
//                                    minorVersion: 1
//                                }
                        renderPasses: [ RenderPass {
                            id: renderPass1
                            /*${PARAMETERS}*/
                            shaderProgram: ShaderProgram {
                                id: shaderProg
                                vertexShaderCode: Helper.readFile(/*${VS}*/)
                                fragmentShaderCode: Helper.readFile(/*${FS}*/)
                                geometryShaderCode: Helper.readFile(/*${GS}*/)
                                tessellationControlShaderCode: Helper.readFile(/*${TCS}*/)
                                tessellationEvaluationShaderCode: Helper.readFile(/*${TES}*/)
                                computeShaderCode: Helper.readFile(/*${CS}*/)
                            }
                            renderStates: [
                                DepthTest { depthFunction: DepthTest.Less }
                            ]
                        } ]
                    }
                ]
            }

        }

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
