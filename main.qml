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
            RowLayout {
                Button {
                    Layout.fillWidth: true
                    text: "Settings"
                    Settings {
                        id: settings
                    }
                    onClicked: settings.open()
                }

                Button {
                    Layout.fillWidth: true
                    text: "Reload"
                    onClicked: shaderModel.syncModel()
                }
            }

            TreeView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: treeViewShaderVariables
                model: ShaderModel {
                    id: shaderModel
                    shaderProgram: ShaderProgram {
                        id: shaderProg
                        vertexShaderCode: loadSource(settings.settings.vertexShaderFilename)
                        onVertexShaderCodeChanged: shaderModel.syncModel()
                        geometryShaderCode: loadSource(settings.settings.geometryShaderFilename)
                        onGeometryShaderCodeChanged: shaderModel.syncModel()
                        tessellationControlShaderCode: loadSource(settings.settings.tesselationControlShaderFilename)
                        onTessellationControlShaderCodeChanged: shaderModel.syncModel()
                        tessellationEvaluationShaderCode: loadSource(settings.settings.tesselationEvaluationShaderFilename)
                        onTessellationEvaluationShaderCodeChanged: shaderModel.syncModel()
                        fragmentShaderCode: loadSource(settings.settings.fragmentShaderFilename)
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
                    width: treeViewShaderVariables.width
                           - colName.width
                           - colType.width
                           - colDatatype.width
                           - 3
                    delegate: delegateManager.autoSelectComponent
                }
            }
            ShaderUniformDelegate {
                property var params: []
                property var currentScene
                id: delegateManager
                onParameterChange: {
                    if(currentScene) {
                        for (var i in currentScene.parameters) {
                            if ( currentScene.parameters[i].name === name ) {
                                currentScene.parameters[i].value = value
                            }
                        }
                    }
                }

                onParameterAddedOrRemoved: {
                    sceneParent.children = ""
                    var paramsString = "parameters: ["
                    for(var i=0 ; i < parameters.length-1 ; i++) {
                        paramsString += "Parameter { name:\"" + parameters[i].name + "\"; value: " + parameters[i].initialValueAsText + " },"
                    }
                    paramsString += "Parameter { name:\"" + parameters[parameters.length-1].name + "\"; value: " + parameters[i].initialValueAsText + " }]"
                    var sampleSceneWithParams = sceneTemplate.replace("/*${PARAMETERS}*/", paramsString)
                    delegateManager.currentScene = Qt.createQmlObject(sampleSceneWithParams, sceneParent)//, {"shaderProgram":shaderModel.shaderProgram})
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
