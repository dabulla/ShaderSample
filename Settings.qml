import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0 as Labs

Dialog {
    width: 800
    readonly property var settings: settings
    Labs.Settings {
        id: settings
        property alias vertexShaderFilename: vsTf.text
        property alias geometryShaderFilename: gsTf.text
        property alias tesselationControlShaderFilename: tcsTf.text
        property alias tesselationEvaluationShaderFilename: tesTf.text
        property alias fragmentShaderFilename: fsTf.text
    }

    FileDialog {
        id: vertexShaderFiledialog
        nameFilters: [ "GLSL files (*.glsl)", "GLSL Vertexshader files (*.vs *.vert)", "All files (*)"]
        onFileUrlChanged: vsTf.text = fileUrl
        folder: vsTf.text
    }
    FileDialog {
        id: geometryShaderFiledialog
        nameFilters: [ "GLSL files (*.glsl)", "GLSL Fragmentshader files (*.gs *.geom)", "All files (*)"]
        onFileUrlChanged: gsTf.text = fileUrl
        folder: gsTf.text
    }
    FileDialog {
        id: tcsShaderFiledialog
        nameFilters: [ "GLSL files (*.glsl)", "GLSL Fragmentshader files (*.tcs)", "All files (*)"]
        onFileUrlChanged: tcsTf.text = fileUrl
        folder: tcsTf.text
    }
    FileDialog {
        id: tesShaderFiledialog
        nameFilters: [ "GLSL files (*.glsl)", "GLSL Fragmentshader files (*.tes)", "All files (*)"]
        onFileUrlChanged: tesTf.text = fileUrl
        folder: tesTf.text
    }
    FileDialog {
        id: fragmentShaderFiledialog
        nameFilters: [ "GLSL files (*.glsl)", "GLSL Fragmentshader files (*.fs *.frag)", "All files (*)"]
        onFileUrlChanged: fsTf.text = fileUrl
        folder: fsTf.text
    }

    GridLayout {
        columns: 3
        anchors.fill: parent
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
    }
}
