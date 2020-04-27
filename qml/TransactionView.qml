import Blockstream.Green 0.1
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.12

Page {
    property Transaction transaction
    property int confirmations: transactionConfirmations(transaction)

    function tx_direction(type) {
        switch (type) {
            case 'incoming':
                return qsTrId('id_incoming')
            case 'outgoing':
                return qsTrId('id_outgoing')
            case 'redeposit':
                return qsTrId('id_redeposited')

        }
    }

    Component {
        id: liquid_amount_delegate
        RowLayout {
            property TransactionAmount amount: modelData

            spacing: 16


            AssetIcon {
                asset: amount.asset
            }

            ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: amount.asset.name
                    font.pixelSize: 14
                    elide: Label.ElideRight
                }

                Label {
                    visible: 'entity' in amount.asset.data
                    Layout.fillWidth: true
                    opacity: 0.5
                    text: amount.asset.data.entity ? amount.asset.data.entity.domain : ''
                    elide: Label.ElideRight
                }
            }

            Label {
                text: amount.formatAmount(wallet.settings.unit)
            }
        }
    }

    Component {
        id: bitcoin_amount_delegate
        RowLayout {
            property TransactionAmount amount: modelData

            spacing: 16

            Label {
                text: amount.formatAmount(wallet.settings.unit)
            }
        }
    }

    background: Item {}

    header: RowLayout {
        ToolButton {
            id: back_arrow_button
            icon.source: '/svg/arrow_left.svg'
            icon.height: 16
            icon.width: 16
            onClicked: stack_view.pop()
        }

        Label {
            text: qsTrId('id_transaction_details') + ' - ' + tx_direction(transaction.data.type)
            font.pixelSize: 14
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
        }

        Button {
            Layout.rightMargin: 16
            flat: true
            text: qsTrId('id_view_in_explorer')
            onClicked: transaction.openInExplorer()
        }
    }

    ScrollView {
        id: scroll_view
        anchors.fill: parent
        anchors.leftMargin: 16
        clip: true

        ColumnLayout {
            width: scroll_view.width - 16
            spacing: 16

            Column {
                spacing: 8

                Label {
                    text: qsTrId('id_received_on')
                    color: 'gray'
                }

                Label {
                    text: formatDateTime(transaction.data.created_at)
                }
            }

            Column {
                spacing: 8

                Label {
                    text: qsTrId('id_transaction_status')
                    color: 'gray'
                }

                Label {
                    text: transactionStatus(confirmations)
                }
            }

            ColumnLayout {
                spacing: 8

                Label {
                    text: qsTrId('id_amount')
                    color: 'gray'
                }

                Repeater {
                    model: transaction.amounts
                    delegate: wallet.network.liquid ? liquid_amount_delegate : bitcoin_amount_delegate
                }
            }

            Column {
                visible: transaction.data.type === 'outgoing'
                spacing: 8

                Label {
                    text: qsTrId('id_fee')
                    color: 'gray'
                }

                Label {
                    text: `${transaction.data.fee / 100000000} BTC (${Math.round(transaction.data.fee_rate / 1000)} sat/vB)`
                }
            }

            Column {
                spacing: 8

                Label {
                    text: qsTrId('id_my_notes')
                    color: 'gray'
                }

                TextArea {
                    id: memo_edit
                    placeholderText: qsTrId('id_add_a_note_only_you_can_see_it')
                    width: scroll_view.width - 16
                    text: transaction.data.memo
                    selectByMouse: true
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        if (text.length > 1024) {
                            memo_edit.text = text.slice(0, 1024);
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    Button {
                        flat: true
                        text: qsTrId('id_cancel')
                        enabled: memo_edit.text !== transaction.data.memo
                        onClicked: memo_edit.text = transaction.data.memo
                    }
                    Button {
                        flat: true
                        text: qsTrId('id_save')
                        enabled: memo_edit.text !== transaction.data.memo
                        onClicked: transaction.updateMemo(memo_edit.text)
                    }
                }
            }

            Page {
                header: Label {
                    text: qsTrId('id_transaction_id')
                    color: 'gray'
                }
                background: MouseArea {
                    onClicked: {
                        transaction.copyTxhashToClipboard()
                        ToolTip.show(qsTrId('id_copied_to_clipboard'), 1000)
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Label {
                            text: transaction.data.txhash
                        }
                        Image {
                            source: '/svg/copy.svg'
                        }
                    }
                }
            }
        }
    }
}