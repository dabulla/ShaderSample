import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import Qt3D.Render 2.0
import QtQml 2.2
import fhac 1.0
Item {
    id: root
    property alias autoSelectComponent: autoSelectComponent
    readonly property var parameters: []
    property var target
    property string parametersProperty: "parameters"

    signal parametersChanging()
    signal parametersChangedFinished()
    Item {
        id: priv
        Instantiator {
            id: parameterInstantiator
            property int numberOfEditableParameters: 0
            Parameter {
                property bool initialized: false
            }
            onObjectAdded: root.parameters.push(object)
            onObjectRemoved: {
                var index = array.indexOf(object)
                if( index === -1 )
                    console.log("Removed non existent object, must never happen")
                root.parameters.splice(index, 1)
            }
        }

        function setParameter(name, value) {
            if( isNaN(value)) return
            if( value === undefined) return
            var listChanged = false
            var found = false
            for (var i in root.parameters) {
                if ( root.parameters[i].initialized
                     && root.parameters[i].name === name ) {
                    root.parameters[i].value = value
                    console.log("DBG: set " + name + " " + value)
                    found = true
                    break;
                }
            }
            if (!found) {
                listChanged = true
                parameterInstantiator.numberOfEditableParameters++;
                found = false
                for (var i in root.parameters) {
                    if ( !root.parameters[i].initialized ) {
                        root.parameters[i].name = name
                        root.parameters[i].value = value
                        console.log("DBG: added and set " + name + " " + value)
                        root.parameters[i].initialized = true
                        console.log("DBG: added #" + parameterInstantiator.numberOfEditableParameters)
                        found = true
                        break;
                    }
                }
                if(!found) {
                    console.log("Error, could not add param")
                }
            }
            if(listChanged) {
                console.log("DBG: before");
                root.parametersChanging();
            }
            root.target[root.parametersProperty] = [];
            console.log("DBG: 1");
            root.target[root.parametersProperty] = root.parameters;
            if(listChanged) {
                console.log("DBG: 2");
                root.parametersChangedFinished();
            }
        }
    }

    Component {
        id: autoSelectComponent
        Item {
            id: item
            Component.onCompleted: {
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
        id:subroutineChooser
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
                text: uniform.name + ":"
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
        id:defaultFloatSlider
        ColumnLayout {
            id:comp
            property bool isInt
            property string name
            Label {
                text: name + ":"
                font.capitalization: Font.Capitalize
            }
            Slider {
                id:valueSlider
                minimumValue: parseFloat(minVal.text)
                maximumValue: parseFloat(maxVal.text)
                stepSize: isInt ? 1.0 : 0.0
                onValueChanged: {
                    priv.setParameter(name, value);
                }
            }
            RowLayout {
                Label {
                    text: "Min:"
                }
                TextField {
                    id: minVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                }
                Label {
                    text: "Max:"
                }
                TextField {
                    id: maxVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                }
            }
        }
    }

    Component {
        id:defaultVec2Control
        ColumnLayout {
            id:comp
            property var uniform
            property bool loading
            Component.onCompleted: {
                comp.loading = true;
                if(uniform.initialized) {
                    minVal.text = uniform.min;
                    maxVal.text = uniform.max;
                    valueSliderx.value = uniform.value.x;
                    valueSlidery.value = uniform.value.y;
                } else {
                    minVal.text = 0.0;
                    maxVal.text = 1.0;
                    valueSliderx.value = 0.2;
                    valueSlidery.value = 0.8;
                    updateUniform();
                    uniform.initialized = true;
                }
                comp.loading = false;
            }
            function updateUniform() {
                uniform.value = Qt.vector2d(valueSliderx.value,
                                            valueSlidery.value);
            }
            Label {
                text: uniform.name + ":"
                font.capitalization: Font.Capitalize
            }
            Slider {
                id:valueSliderx
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            Slider {
                id:valueSlidery
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            RowLayout {
                Label {
                    text: "Min:"
                }
                TextField {
                    id:minVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                    Binding {
                        when: comp.loading === false;
                        target: uniform
                        property: "min"
                        value: minVal.text
                    }
                }
                Label {
                    text: "Max:"
                }
                TextField {
                    id:maxVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                    Binding {
                        when: comp.loading === false;
                        target: uniform
                        property: "max"
                        value: maxVal.text
                    }
                }
            }
        }
    }

    Component {
        id:defaultVec3Control
        ColumnLayout {
            id:comp
            property var uniform
            property bool loading
            Component.onCompleted: {
                comp.loading = true;
                if(uniform.initialized) {
                    minVal.text = uniform.min;
                    maxVal.text = uniform.max;
                    valueSliderx.value = uniform.value.x;
                    valueSlidery.value = uniform.value.y;
                    valueSliderz.value = uniform.value.z;
                } else {
                    minVal.text = 0.0;
                    maxVal.text = 1.0;
                    valueSliderx.value = 0.0;
                    valueSlidery.value = 0.5;
                    valueSliderz.value = 1.0;
                    updateUniform();
                    uniform.initialized = true;
                }
                comp.loading = false;
            }
            function updateUniform() {
                uniform.value = Qt.vector3d(valueSliderx.value,
                                            valueSlidery.value,
                                            valueSliderz.value);
            }
            Label {
                text: uniform.name + ":"
                font.capitalization: Font.Capitalize
            }
            Slider {
                id:valueSliderx
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            Slider {
                id:valueSlidery
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            Slider {
                id:valueSliderz
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            RowLayout {
                Label {
                    text: "Min:"
                }
                TextField {
                    id:minVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                    Binding {
                        when: comp.loading === false;
                        target: uniform
                        property: "min"
                        value: minVal.text
                    }
                }
                Label {
                    text: "Max:"
                }
                TextField {
                    id:maxVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                    Binding {
                        when: comp.loading === false;
                        target: uniform
                        property: "max"
                        value: maxVal.text
                    }
                }
            }
        }
    }
    Component {
        id:defaultVec4Control
        ColumnLayout {
            id:comp
            property var uniform
            property bool loading
            Component.onCompleted: {
                comp.loading = true;
                if(uniform.initialized) {
                    minVal.text = uniform.min;
                    maxVal.text = uniform.max;
                    valueSliderx.value = uniform.value.x;
                    valueSlidery.value = uniform.value.y;
                    valueSliderz.value = uniform.value.z;
                    valueSliderw.value = uniform.value.w;
                } else {
                    minVal.text = 0.0;
                    maxVal.text = 1.0;
                    valueSliderx.value = 0.9;
                    valueSlidery.value = 0.8;
                    valueSliderz.value = 0.8;
                    valueSliderw.value = 1.0;
                    updateUniform();
                    uniform.initialized = true;
                }
                comp.loading = false;
            }
            function updateUniform() {
                uniform.value = Qt.vector4d(valueSliderx.value,
                                            valueSlidery.value,
                                            valueSliderz.value,
                                            valueSliderw.value);
            }
            Label {
                text: uniform.name + ":"
                font.capitalization: Font.Capitalize
            }
            Slider {
                id:valueSliderx
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            Slider {
                id:valueSlidery
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            Slider {
                id:valueSliderz
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            Slider {
                id:valueSliderw
                minimumValue: uniform.min
                maximumValue: uniform.max
                onValueChanged: if(!comp.loading) updateUniform();
            }
            RowLayout {
                Label {
                    text: "Min:"
                }
                TextField {
                    id:minVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                    Binding {
                        when: comp.loading === false;
                        target: uniform
                        property: "min"
                        value: minVal.text
                    }
                }
                Label {
                    text: "Max:"
                }
                TextField {
                    id:maxVal
                    validator: DoubleValidator {}
                    Layout.maximumWidth: 60
                    Binding {
                        when: comp.loading === false;
                        target: uniform
                        property: "max"
                        value: maxVal.text
                    }
                }
            }
        }
    }

    Component {
        id:defaultBoolComponent
        CheckBox {
            id:comp
            property var uniform
            property bool loading;
            Component.onCompleted: {
                if(uniform.initialized) {
                    comp.loading = true;
                    checked = uniform.value;
                    comp.loading = false;
                } else {
                    checked = false;
                    uniform.value = false;
                    uniform.initialized = true;
                }
            }
            onCheckedChanged: {
                uniform.value = checked;
            }
        }
    }

    Component {
        id:notAvaliableComponent
        GroupBox {
            property var datatype
            Text {
                text: "(unsupported in Gui<br>Type: (<b>" + datatype.toString() + "</b>)\n"
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
            }
        }
    }
}
