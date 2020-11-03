import Blockstream.Green 0.1
import QtQuick 2.13

Image {
    required property Device device
    smooth: true
    mipmap: true
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignHCenter
    source: {
        switch (device.type) {
        case Device.LedgerNanoS: return 'qrc:/svg/ledger_nano_s.svg'
        case Device.LedgerNanoX: return 'qrc:/svg/ledger_nano_x.svg'
        }
    }
}
