import QtQuick 2.13
import QtQuick.Controls 2.5

DialogButtonBox {
    property StackView stackView
    Repeater {
        model: stackView.currentItem ? stackView.currentItem.actions : []
        Button {
            flat: true
            action: modelData
        }
    }
}
