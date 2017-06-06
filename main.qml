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
                id: treeViewShaderVariables
                model: ShaderModel {
                    id: shaderModel
                    shaderProgram: ShaderProgram {
                        id: shaderProg
                        vertexShaderCode: loadSource("qrc:/shader/pointcloud.vert")
                        onVertexShaderCodeChanged: shaderModel.syncModel()
                        fragmentShaderCode: loadSource("qrc:/shader/pointcloud.frag")
                        onFragmentShaderCodeChanged: shaderModel.syncModel()
                    }
                }

                rowDelegate: Rectangle {
                    property var row: styleData.row
                    height: {
                        var datatype = treeViewShaderVariables.model.data (treeViewShaderVariables.model.index(row, 0), ShaderModel.ParameterDatatype);
                        var h = delegateManager.heightOfType(datatype, false) //TODO: subroutine
                        return h
                    }
                }

                TableViewColumn {
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
                    resizable: true
                    delegate: delegateManager.autoSelectComponent
                }
            }
            ShaderUniformDelegate {
                property var params: []
                property var currentScene
                id: delegateManager
                target: delegateManager
                parametersProperty: "params"
                onBeforeParameterChange: {
                    sceneParent.children = ""
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

                onAfterParameterChange: {
                    var paramsString = "parameters: ["
                    for(var i=0 ; i < params.length-1 ; i++) {
                        paramsString += "Parameter { name:\"" + params[i].name + "\"; value: " + valueAsText + " },"
                    }
                    paramsString += "Parameter { name:\"" + params[params.length-1].name + "\"; value: " + valueAsText + " }]"
                    var sampleSceneWithParams = sceneTemplate.replace("/*${PARAMETERS}*/", paramsString)
                    delegateManager.currentScene = Qt.createQmlObject(sampleSceneWithParams, sceneParent)
                }
            }
        }
        Item {
            id:sceneParent
            Layout.fillHeight: true
            Layout.minimumWidth: 50
        }
    }
}
