import QtQuick 2.2
import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0
import QtQuick.Scene3D 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQml 2.2
import Qt.labs.settings 1.0 as Labs

import fhac 1.0

ApplicationWindow {
    visible: true
    id: root
    width: 500
    height: 500
    SplitView {
        orientation: Qt.Horizontal
        anchors.fill: parent
        ColumnLayout {
            id: sidebar
            width: 400
            RowLayout {
                Button {
                    Layout.fillWidth: true
                    text: "Settings"
                    Settings {
                        id: settings
//                        onVertexShaderChanged: delegateManager.updateShader()
//                        onGeometryChanged: delegateManager.updateShader()
//                        onTesselationControlShaderChanged: delegateManager.updateShader()
//                        onTesselationEvaluationShaderChanged: delegateManager.updateShader()
//                        onFragmentShaderChanged: delegateManager.updateShader()
//                        onComputeShaderChanged: delegateManager.updateShader()
//                        onModelSourceChanged: if(delegateManager.currentScene) delegateManager.currentScene.modelSource = modelSource
                        onAccepted: {
                            //TODO: only if shader/model changed
                            delegateManager.updateShader()
                        }
                    }
                    Labs.Settings {
                        category: "shader_filenames"
                        property alias vertexShader: settings.vertexShader
                        property alias geometryShader: settings.geometryShader
                        property alias tesselationControlShader: settings.tesselationControlShader
                        property alias tesselationEvaluationShader: settings.tesselationEvaluationShader
                        property alias fragmentShader: settings.fragmentShader
                        property alias computeShader: settings.computeShader
                        property alias modelSource: settings.modelSource
                        property alias sidebarWidth: sidebar.width
                        property alias windowWidth: root.width
                        property alias windowHeight: root.height
                        Component.onCompleted: delegateManager.updateShader()
                    }
                    onClicked: settings.open()
                }

                Button {
                    Layout.fillWidth: true
                    text: "Reload"
                    onClicked: {
                        // ShaderModel syncs automatically when filename changes.
                        // This is the only place where it is forced (reload the file manually)
                        shaderModel.syncModel()
                        delegateManager.updateShader()
                    }
                }
            }

            TreeView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: treeViewShaderVariables
                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                model: ShaderModel {
                    id: shaderModel
                    vertexShader: settings.vertexShader
                    geometryShader: settings.geometryShader
                    tesselationControlShader: settings.tesselationControlShader
                    tesselationEvaluationShader: settings.tesselationEvaluationShader
                    fragmentShader: settings.fragmentShader
                }

                rowDelegate: Rectangle {
                    property var row: styleData.row
                    height: {
                        var datatype = treeViewShaderVariables.model.data (treeViewShaderVariables.model.index(row, 0), ShaderModel.ParameterDatatype);
                        var isSubroutine = treeViewShaderVariables.model.data (treeViewShaderVariables.model.index(row, 0), ShaderModel.ParameterIsSubroutine);
                        var h = delegateManager.heightOfType(datatype, isSubroutine)
                        return h
                    }
                }

                TableViewColumn {
                    id: colName
                    role: "name"
                    title: "name"
                    width: 60
                    resizable: true
                    delegate: Label {
                        text: styleData.value
                        font.capitalization: Font.Capitalize
                        clip: true
                    }
                }
                TableViewColumn {
                    id: colType
                    role: "type"
                    title: "type"
                    width: 50
                    resizable: true

                    delegate: Label {
                        text: styleData.value.toString()
                        clip: true
                    }
                }
                TableViewColumn {
                    id: colDatatype
                    role: "datatype"
                    title: "datatype"
                    width: 60
                    resizable: true
                    delegate: Label {
                        text: styleData.value.toString()
                        clip: true
                    }
                }
                TableViewColumn {
                    role: "data"
                    title: "data"
                    resizable: false
                    width: treeViewShaderVariables.contentItem.width
                           - colName.width
                           - colType.width
                           - colDatatype.width
                    delegate: delegateManager.autoSelectComponent
                }
            }
            ShaderUniformDelegateManager {
                property var params: []
                property var currentScene
                id: delegateManager
                Timer {
                    id: scheduleReloadSceneTimer
                    interval: 100
                    onTriggered: {
                        delegateManager.reloadScene()
                    }
                }

                function updateShader() {
                    // if several shaders change, this causes to only reload the scene once
                    scheduleReloadSceneTimer.start();
//                    //setting shaders here will cause Qt3D 5.9 to crash
//                    currentScene.vertexShader = vs
//                    currentScene.fragmentShader = fs
                }

                onParameterChange: {
                    if(currentScene) {
                        for (var i in currentScene.parameters) {
                            if ( currentScene.parameters[i].name === name ) {
                                currentScene.parameters[i].value = value
                            }
                        }
                    }
                }
                function reloadScene() {
                    if(!shaderModel.isValid) return
                    sceneParent.children = ""
                    delegateManager.sync()
                    var paramsString = "parameters: ["
                    for(var i=0 ; i < parameters.length-1 ; i++) {
                        paramsString += "Parameter { name:\"" + parameters[i].name + "\"; value: " + parameters[i].initialValueAsText + " },"
                    }
                    if(parameters.length > 0) {
                        paramsString += "Parameter { name:\"" + parameters[parameters.length-1].name + "\"; value: " + parameters[i].initialValueAsText + " }]"
                    } else {
                        paramsString += "]"
                    }

                    // Currently Scene3D/Qt3D must know all shader/shadeparameter at startup.
                    var sampleSceneWithParams = sceneTemplate.replace("/*${PARAMETERS}*/", paramsString)
                    sampleSceneWithParams = sampleSceneWithParams.replace("/*${VS}*/", "vertexShaderCode: Helper.readFile(\"" + shaderModel.vertexShader + "\")")
                    sampleSceneWithParams = sampleSceneWithParams.replace("/*${FS}*/", "fragmentShaderCode: Helper.readFile(\"" + shaderModel.fragmentShader + "\")")
                    if(shaderModel.geometryShader.length != 0) {
                        sampleSceneWithParams = sampleSceneWithParams.replace("/*${GS}*/", "geometryShaderCode: Helper.readFile(\"" + shaderModel.geometryShader + "\")")
                    }
                    if(shaderModel.tesselationControlShader.length != 0) {
                        sampleSceneWithParams = sampleSceneWithParams.replace("/*${TCS}*/", "tesselationControlShaderCode: Helper.readFile(\"" + shaderModel.tesselationControlShader + "\")")
                    }
                    if(shaderModel.tesselationEvaluationShader.length != 0) {
                        sampleSceneWithParams = sampleSceneWithParams.replace("/*${TES}*/", "tesselationEvaluationShaderCode: Helper.readFile(\"" + shaderModel.tesselationEvaluationShader + "\")")
                    }
                    if(shaderModel.computeShader.length != 0) {
                        sampleSceneWithParams = sampleSceneWithParams.replace("/*${CS}*/", "computeShaderCode: Helper.readFile(\"" + shaderModel.computeShader + "\")")
                    }
                    delegateManager.currentScene = Qt.createQmlObject(sampleSceneWithParams, sceneParent)//, {"modelSource": settings.modelSource})//, {"vertexShader":shaderModel.vertexShader, "fragmentShader": shaderModel.fragmentShader})
                    delegateManager.currentScene.modelSource = settings.modelSource
                }

//                onParameterAddedOrRemoved: {
//                    reloadScene()
//                }
            }
        }
        Item {
            id: sceneParent
            Layout.fillHeight: true
            Layout.minimumWidth: 50
        }
    }
}
