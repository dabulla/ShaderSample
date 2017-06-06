import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

ColumnLayout {
    id:comp
    property bool minMaxEditable: true
    property alias min: minVal.text
    property alias max: maxVal.text
    property bool isInt
    property alias value: valueSlider.value
    Slider {
        Layout.fillWidth: true
        id: valueSlider
        minimumValue: parseFloat(minVal.text)
        maximumValue: parseFloat(maxVal.text)
        stepSize: isInt ? 1.0 : 0.0
    }
    RowLayout {
        Layout.fillWidth: true
        visible: minMaxEditable
        Label {
            text: "Min:"
        }
        TextField {
            id: minVal
            text: "0"
            validator: DoubleValidator {}
            Layout.fillWidth: true
            Layout.maximumWidth: 60
            Layout.minimumWidth: 10
        }
        Label {
            text: "Max:"
        }
        TextField {
            id: maxVal
            text: "1"
            validator: DoubleValidator {}
            Layout.fillWidth: true
            Layout.maximumWidth: 60
            Layout.minimumWidth: 10
        }
    }
}
