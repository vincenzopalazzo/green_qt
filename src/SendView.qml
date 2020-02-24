import Blockstream.Green 0.1
import QtMultimedia 5.13
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import './views'

StackView {
    id: stack_view
    property alias address: address_field.text
    property Asset asset: asset_field_loader.item ? asset_field_loader.item.asset : null
    property alias amount: amount_field.text
    property alias sendAll: send_all_button.checked

    property var actions: currentItem.actions

    property Item scanner_view: ScannerView {
        source: camera
        onCancel: {
            stack_view.pop();
            camera.stop();
        }
        onCodeScanned: {
            camera.stop();
            address_field.text = WalletManager.parseUrl(code).address;
            stack_view.pop();
        }
    }

    property Camera camera: Camera {
        cameraState: Camera.LoadedState
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointAuto
        }
    }

    initialItem: ColumnLayout {

        property list<Action> actions: [Action{
               text: qsTr('id_send')
               enabled: controller.valid && !controller.transaction.error
               onTriggered: controller.send()
           }]

        spacing: 8

        Label {
            text: qsTrId(controller.transaction.error || '')
            color: 'red'
        }

        Loader {
            id: asset_field_loader
            active: wallet.network.liquid
            Layout.fillWidth: true
            sourceComponent: ComboBox {
                property Balance balance: controller.account.balances[asset_field.currentIndex]
                property Asset asset: balance.asset
                id: asset_field
                flat: true
                model: controller.account.balances
                delegate: AssetDelegate {
                    highlighted: index === asset_field.currentIndex
                    balance: modelData
                    showIndicator: false
                    width: parent.width
                }

                leftPadding: 8
                topPadding: 12
                bottomPadding: 12

                contentItem: BalanceItem {
                    balance: controller.account.balances[asset_field.currentIndex]
                }
            }
        }

        RowLayout {
            TextField {
                id: address_field
                Layout.fillWidth: true
                horizontalAlignment: TextField.AlignHCenter
                placeholderText: qsTr('id_enter_an_address')
            }

            Button {
                highlighted: false
                flat: true
                icon.source: './assets/svg/qr.svg'
                onClicked: {
                    camera.start()
                    stack_view.push(scanner_view)
                }
            }
        }
        TextField {
            id: amount_field
            Layout.fillWidth: true
            enabled: !send_all_button.checked
            horizontalAlignment: TextField.AlignHCenter
            placeholderText: qsTr('id_add_amount')

            Binding on text {
                when: send_all_button.checked && wallet.network.liquid
                value: asset_field_loader.item ? asset_field_loader.item.balance.inputAmount : 0
            }

            Binding on text {
                when: send_all_button.checked && !wallet.network.liquid
                value: wallet.formatAmount(controller.account.balance, false, wallet.settings.unit)
            }
        }

        Switch {
            id: send_all_button
            checkable: true
            text: qsTr('id_send_all_funds')
        }

        Label {
            text: qsTr('id_network_fee')
        }

        FeeComboBox {
            Layout.fillWidth: true
            property var indexes: [3, 12, 24]

            Component.onCompleted: {
                currentIndex = indexes.indexOf(controller.account.wallet.settings.required_num_blocks)
                controller.feeRate = controller.account.wallet.events.fees[blocks]
            }

            onBlocksChanged: {
                controller.feeRate = controller.account.wallet.events.fees[blocks]
            }
        }
    }
}
