//
//  WallyPSBT.swift
//  BCWally
//
//  Created by Wolf McNally on 11/30/21.
//

import Foundation

extension Wally {
    public static func psbt(from data: Data) -> WallyPSBT? {
        data.withUnsafeByteBuffer { bytes in
            var p: WallyPSBT? = nil
            guard wally_psbt_from_bytes(bytes.baseAddress!, data.count, &p) == WALLY_OK else {
                return nil
            }
            return p!
        }
    }
    
    public static func free(psbt: WallyPSBT) {
        wally_psbt_free(psbt)
    }
    
    public static func clone(psbt: WallyPSBT) -> WallyPSBT {
        var new_psbt: WallyPSBT!
        precondition(wally_psbt_clone_alloc(psbt, 0, &new_psbt) == WALLY_OK)
        return new_psbt
    }
    
    public static func isFinalized(psbt: WallyPSBT) -> Bool {
        var result = 0
        precondition(wally_psbt_is_finalized(psbt, &result) == WALLY_OK)
        return result != 0
    }
    
    public static func finalized(psbt: WallyPSBT) -> WallyPSBT? {
        let final = copy(psbt: psbt)
        guard wally_psbt_finalize(final) == WALLY_OK else {
            return nil
        }
        return final
    }

    public static func finalizedPSBT(psbt: WallyPSBT) -> WallyTx? {
        var output: WallyTx!
        guard wally_psbt_extract(psbt, &output) == WALLY_OK else {
            return nil
        }
        return output
    }
    
    public static func getLength(psbt: WallyPSBT) -> Int {
        var len = 0
        precondition(wally_psbt_get_length(psbt, 0, &len) == WALLY_OK)
        return len
    }
    
    public static func serialized(psbt: WallyPSBT) -> Data {
        let len = getLength(psbt: psbt)
        var result = Data(count: len)
        result.withUnsafeMutableBytes {
            var written = 0
            precondition(wally_psbt_to_bytes(psbt, 0, $0.bindMemory(to: UInt8.self).baseAddress!, len, &written) == WALLY_OK)
            precondition(written == len)
        }
        return result
    }
    
    private static func copy(psbt: WallyPSBT) -> WallyPSBT {
        let data = serialized(psbt: psbt)
        return Self.psbt(from: data)!
    }
    
    public static func signed(psbt: WallyPSBT, ecPrivateKey: Data) -> WallyPSBT? {
        ecPrivateKey.withUnsafeByteBuffer { keyBytes in
            let signedPSBT = copy(psbt: psbt)
            let ret = wally_psbt_sign(signedPSBT, keyBytes.baseAddress, keyBytes.count, 0)
            guard ret == WALLY_OK else {
                return nil
            }
            return signedPSBT
        }
    }
}
