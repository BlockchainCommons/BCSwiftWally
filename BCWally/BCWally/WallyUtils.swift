//
//  WallyUtils.swift
//  BCWally
//
//  Created by Wolf McNally on 8/25/21.
//

import Foundation

public typealias WallyTx = UnsafeMutablePointer<wally_tx>
public typealias WallyTxInput = UnsafeMutablePointer<wally_tx_input>
public typealias WallyTxOutput = UnsafeMutablePointer<wally_tx_output>
public typealias WallyExtKey = ext_key
public typealias WallyPSBT = UnsafeMutablePointer<wally_psbt>
public typealias WallyPSBTInput = wally_psbt_input
public typealias WallyPSBTOutput = wally_psbt_output

public enum Wally {
    private static var _initialized: Bool = {
        wally_init(0)
        return true
    }()
    
    public static func initialize() {
        _ = _initialized
    }
}
