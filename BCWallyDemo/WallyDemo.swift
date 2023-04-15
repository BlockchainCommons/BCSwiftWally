import Foundation
import BCWally

var wallyDemo: String {
    Wally.initialize()
    let data = Data(hex: "1673a0b7da12c9a7252f5c93a1376a8f")!
    let bip39 = Wally.bip39Encode(data: data)
    let expected = "biology other combine reflect clutch squeeze net twist neck answer survey butter"
    precondition(bip39 == expected)
    return bip39
}
