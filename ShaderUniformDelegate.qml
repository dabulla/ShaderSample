import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import Qt3D.Render 2.0
import QtQml 2.2
import fhac 1.0
Item {
    id: root
    // For usage in a TableView. This needs styleData
    property alias autoSelectComponent: autoSelectComponent
    readonly property var parameters: []
    property var target
    property string parametersProperty: "parameters"

    function heightOfType(datatype, isSubroutine) {
        if(!datatype) return
        if( isSubroutine ) {

        } else {
            var singleHeight = 60;
            switch(datatype.valueOf()) {
                case ShaderParameterInfo.FLOAT:
                case ShaderParameterInfo.DOUBLE:
                    return singleHeight;
                case ShaderParameterInfo.FLOAT_VEC2:
                    return singleHeight+singleHeight*0.5;
                case ShaderParameterInfo.FLOAT_VEC3:
                    return singleHeight+singleHeight*0.5*2;
                case ShaderParameterInfo.FLOAT_VEC4:
                    return singleHeight+singleHeight*0.5*3;
                case ShaderParameterInfo.INT:
                    return singleHeight;
                case ShaderParameterInfo.BOOL:
                    return singleHeight*0.5;
                case ShaderParameterInfo.FLOAT_MAT4:
                case ShaderParameterInfo.SAMPLER_2D:
                default:
                    return singleHeight;
            }
        }
    }

    signal beforeParameterChange()
    signal afterParameterChange(string valueAsText)
    signal parameterChange(string name, var value)
    Item {
        id: priv
//        Instantiator {
//            id: parameterInstantiator
//            property int numberOfEditableParameters: 0
//            Parameter {
//                property bool initialized: false
//            }
//            onObjectAdded: root.parameters.push(object)
//            onObjectRemoved: {
//                var index = array.indexOf(object)
//                if( index === -1 )
//                    console.log("Removed non existent object, must never happen")
//                root.parameters.splice(index, 1)
//            }
//        }
        function setParameter(name, value, typename) {
            if( typeof value === "number" && isNaN(value)) return
            if( value === undefined) return
            var listChanged = false
            var found = false
            for (var i in root.target[root.parametersProperty]) {
                if ( root.target[root.parametersProperty][i].name === name ) {
                    root.target[root.parametersProperty][i].value = value
                    found = true
                    break;
                }
            }
            if (!found) {
                listChanged = true
                root.target[root.parametersProperty].push({"name": name, "value":value})
//                found = false
//                for (var i in root.target[root.parametersProperty]) {
//                    if ( !root.parameters[i].initialized ) {
//                        root.target[root.parametersProperty][i].name = name
//                        root.target[root.parametersProperty][i].value = value
//                        console.log("DBG: added and set " + name + " " + value)
//                        root.parameters[i].initialized = true
//                        console.log("DBG: added #" + parameterInstantiator.numberOfEditableParameters)
//                        found = true
//                        break;
//                    }
//                }
//                if(!found) {
//                    console.log("Error, could not add param")
//                }
            }
            if(listChanged) {
                root.beforeParameterChange();
            }
//            root.target[root.parametersProperty] = []
//            console.log("DBG: 1")
//            root.target[root.parametersProperty] = root.target[root.parametersProperty]
            if(listChanged) {
                var valueAsText;
                if(typename) {
                    switch(typename) {
                        case "double":
                            valueAsText =  value
                            break;
                        case "int":
                            valueAsText =  value
                            break;
                        case "bool":
                            valueAsText =  value
                            break;
                        case "QVector2D":
                            valueAsText =  "Qt.vector2d(" + value.r + "," + value.g + ")"
                            break;
                        case "QVector3D":
                            valueAsText =  "Qt.vector3d(" + value.r + "," + value.g + "," + value.b +")"
                            break;
                        case "QVector4D":
                            valueAsText =  "Qt.vector4d(" + value.r + "," + value.g + "," + value.b + ","+ value.a + ")"
                            break;
                        default:
                            valueAsText = "0"
                            console.log("WARN: please add a standard type to ShaderUniformDelegate for " + typename)
                    }
                } else {
                    valueAsText = "0"
                }
                root.afterParameterChange(valueAsText)
            }
            parameterChange(name, value)
        }
    }

    Component {
        id: autoSelectComponent
        Item {
            anchors.fill: parent
            id: item
            clip: true
            Component.onCompleted: {
                //styleData comes from TableView
                if( styleData.value.isSubroutine ) {
                    subroutineChooser.createObject(item, styleData.value)
                } else {
                    switch(styleData.value.datatype.valueOf()) {
                        case ShaderParameterInfo.FLOAT:
                        case ShaderParameterInfo.DOUBLE:
                            defaultFloatSlider.createObject(item, styleData.value)
                            break;
                        case ShaderParameterInfo.FLOAT_VEC2:
                            defaultVec2Control.createObject(item, styleData.value)
                            break;
                        case ShaderParameterInfo.FLOAT_VEC3:
                            defaultVec3Control.createObject(item, styleData.value)
                            break;
                        case ShaderParameterInfo.FLOAT_VEC4:
                            defaultVec4Control.createObject(item, styleData.value)
                            break;
                        case ShaderParameterInfo.INT:
                            var obj = defaultFloatSlider.createObject(item, styleData.value)
                            obj.isInt = true
                            break;
                        case ShaderParameterInfo.BOOL:
                            defaultBoolComponent.createObject(item, styleData.value)
                            break;
                        case ShaderParameterInfo.FLOAT_MAT4:
                            notAvaliableComponent.createObject(item, styleData.value)
                            break;
                        case ShaderParameterInfo.SAMPLER_2D:
                            notAvaliableComponent.createObject(item, styleData.value)
                            break;
                        default:
                            notAvaliableComponent.createObject(item, styleData.value)
                    }
                }
            }
        }
    }

    Component {
        id: subroutineChooser
        ColumnLayout {
            id:comp
            property var uniform
            property bool loading
            property bool isInt
            Component.onCompleted: {
                var newModel = [];
                for(var i = 0 ; i<uniform.subroutineValues.length ; ++i) {
                    newModel.push({text:uniform.subroutineValues[i]});
                }
                subroutineCb.model = newModel;
                if(uniform.initialized) {
                    comp.loading = true;
                    subroutineCb.currentIndex = uniform.subroutineValues.indexOf( uniform.value );
                    comp.loading = false;
                } else {
                    comp.loading = true;
                    subroutineCb.currentIndex = 0;
                    comp.loading = false;
                    uniform.initialized = true;
                }
            }
            Label {
                text: name + ":"
                font.capitalization: Font.Capitalize
            }
            ComboBox {
                id:subroutineCb
                model: uniform.subroutineValues
                onCurrentTextChanged: {
                    if(! loading ) {
                        uniform.value = currentText;
                    }
                }
                textRole: ""
            }
        }
    }

    Component {
        id: defaultFloatSlider
        MinMaxSlider {
            anchors.fill: parent
            property string name
            property string qmlTypename
            onValueChanged: {
                priv.setParameter(name, value, qmlTypename);
            }
        }
    }

    Component {
        id: defaultVec2Control
        ColumnLayout {
            id: comp
            property string name
            property bool isInt
            property string qmlTypename
            function updateUniform() {
                priv.setParameter(name, Qt.vector2d(valueSliderx.value,
                                                    valueSlidery.value), qmlTypename);
            }
            MinMaxSlider {
                id: valueSliderx
                isInt: comp.isInt
                minMaxEditable: false
                min: valueSlidery.min
                max: valueSlidery.max
                onValueChanged: updateUniform()
            }
            MinMaxSlider {
                id: valueSlidery
                isInt: comp.isInt
                onValueChanged: updateUniform()
            }
        }
    }

    Component {
        id:defaultVec3Control
        ColumnLayout {
            id: comp
            anchors.left: parent.left
            anchors.right: parent.right
            property string name
            property bool isInt
            property string qmlTypename
            function updateUniform() {
                priv.setParameter(name, Qt.vector3d(valueSliderx.value,
                                                    valueSlidery.value,
                                                    valueSliderz.value), qmlTypename);
            }
            MinMaxSlider {
                Layout.fillWidth: true
                id:valueSliderx
                isInt: comp.isInt
                minMaxEditable: false
                min: valueSliderz.min
                max: valueSliderz.max
                onValueChanged: updateUniform()
            }
            MinMaxSlider {
                id:valueSlidery
                isInt: comp.isInt
                minMaxEditable: false
                min: valueSliderz.min
                max: valueSliderz.max
                onValueChanged: updateUniform()
            }
            MinMaxSlider {
                id:valueSliderz
                isInt: comp.isInt
                onValueChanged: updateUniform()
            }
        }
    }
    Component {
        id:defaultVec4Control
        ColumnLayout {
            id: comp
            property string name
            property bool isInt
            property string qmlTypename
            function updateUniform() {
                priv.setParameter(name, Qt.vector4d(valueSliderx.value,
                                                    valueSlidery.value,
                                                    valueSliderz.value,
                                                    valueSliderw.value), qmlTypename);
            }
            MinMaxSlider {
                id:valueSliderx
                isInt: comp.isInt
                minMaxEditable: false
                min: valueSliderw.min
                max: valueSliderw.max
                onValueChanged: updateUniform()
            }
            MinMaxSlider {
                id:valueSlidery
                isInt: comp.isInt
                minMaxEditable: false
                min: valueSliderw.min
                max: valueSliderw.max
                onValueChanged: updateUniform()
            }
            MinMaxSlider {
                id:valueSliderz
                isInt: comp.isInt
                minMaxEditable: false
                min: valueSliderw.min
                max: valueSliderw.max
                onValueChanged: updateUniform()
            }
            MinMaxSlider {
                id:valueSliderw
                isInt: comp.isInt
                onValueChanged: updateUniform()
            }
        }
    }

    Component {
        id: defaultBoolComponent
        CheckBox {
            id: comp
            property string name
            property string qmlTypename
            onCheckedChanged: {
                priv.setParameter(name, checked, qmlTypename);
            }
        }
    }

    Component {
        id:notAvaliableComponent
        GroupBox {
            property var datatype
            Text {
                text: "(unsupported in Gui)"
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
            }
        }
    }
}
