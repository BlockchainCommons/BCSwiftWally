//
//  WallyExtKey.swift
//  BCWally
//
//  Created by Wolf McNally on 11/30/21.
//

import Foundation
@_implementationOnly import WolfBase

extension Wally {
    public static func key(from parentKey: WallyExtKey, childNum: UInt32, isPrivate: Bool) -> WallyExtKey? {
        withUnsafePointer(to: parentKey) { parentPointer in
            let flags = UInt32(isPrivate ? BIP32_FLAG_KEY_PRIVATE : BIP32_FLAG_KEY_PUBLIC)
            var derivedKey = WallyExtKey()
            guard bip32_key_from_parent(parentPointer, childNum, flags, &derivedKey) == WALLY_OK else {
                return nil
            }
            return derivedKey
        }
    }

    public static func fingerprintData(for key: WallyExtKey) -> Data {
        // This doesn't work with a non-derivable key, because LibWally thinks it's invalid.
        //var bytes = [UInt8](repeating: 0, count: Int(BIP32_KEY_FINGERPRINT_LEN))
        //precondition(bip32_key_get_fingerprint(&hdkey, &bytes, bytes.count) == WALLY_OK)
        //return Data(bytes)

        hash160(key.pub_key).prefix(Int(BIP32_KEY_FINGERPRINT_LEN))
    }

    public static func fingerprint(for key: WallyExtKey) -> UInt32 {
        deserialize(UInt32.self, fingerprintData(for: key))!
    }

    public static func updateHash160(in key: inout WallyExtKey) {
        let hash160Size = MemoryLayout.size(ofValue: key.hash160)
        withUnsafeByteBuffer(of: key.pub_key) { pub_key in
            withUnsafeMutableByteBuffer(of: &key.hash160) { hash160 in
                precondition(wally_hash160(
                    pub_key.baseAddress!, Int(EC_PUBLIC_KEY_LEN),
                    hash160.baseAddress!, hash160Size
                ) == WALLY_OK)
            }
        }
    }

    public static func updatePublicKey(in key: inout WallyExtKey) {
        withUnsafeByteBuffer(of: key.priv_key) { priv_key in
            withUnsafeMutableByteBuffer(of: &key.pub_key) { pub_key in
                precondition(wally_ec_public_key_from_private_key(
                    priv_key.baseAddress! + 1, Int(EC_PRIVATE_KEY_LEN),
                    pub_key.baseAddress!, Int(EC_PUBLIC_KEY_LEN)
                ) == WALLY_OK)
            }
        }
    }
}

extension Wally {
    public static func hdKey(bip39Seed: Data, network: Network) -> WallyExtKey? {
        let flags = network.wallyBIP32Version(isPrivate: true)
        var key = WallyExtKey()
        let result = bip39Seed.withUnsafeByteBuffer { buf in
            bip32_key_from_seed(buf.baseAddress, buf.count, flags, 0, &key)
        }
        guard result == WALLY_OK else {
            return nil
        }
        return key
    }
    
    public static func hdKey(fromBase58 base58: String) -> WallyExtKey? {
        var result = WallyExtKey()
        guard bip32_key_from_base58(base58, &result) == WALLY_OK else {
            return nil
        }
        return result
    }
}

extension WallyExtKey: CustomStringConvertible {
    public var description: String {
        let chain_code = Data(of: self.chain_code).hex
        let parent160 = Data(of: self.parent160).hex
        let depth = self.depth
        let priv_key = Data(of: self.priv_key).hex
        let child_num = self.child_num
        let hash160 = Data(of: self.hash160).hex
        let version = self.version
        let pub_key = Data(of: self.pub_key).hex

        return "WallyExtKey(chain_code: \(chain_code), parent160: \(parent160), depth: \(depth), priv_key: \(priv_key), child_num: \(child_num), hash160: \(hash160), version: \(version), pub_key: \(pub_key))"
    }

    public var isPrivate: Bool {
        priv_key.0 == BIP32_FLAG_KEY_PRIVATE
    }

    public var isMaster: Bool {
        depth == 0
    }

    public static func version_is_valid(ver: UInt32, flags: UInt32) -> Bool
    {
        if ver == BIP32_VER_MAIN_PRIVATE || ver == BIP32_VER_TEST_PRIVATE {
            return true
        }

        return flags == BIP32_FLAG_KEY_PUBLIC &&
               (ver == BIP32_VER_MAIN_PUBLIC || ver == BIP32_VER_TEST_PUBLIC)
    }

    public func checkValid() {
        let ver_flags = isPrivate ? UInt32(BIP32_FLAG_KEY_PRIVATE) : UInt32(BIP32_FLAG_KEY_PUBLIC)
        precondition(Self.version_is_valid(ver: version, flags: ver_flags))
        //precondition(!Data(of: chain_code).isAllZero)
        precondition(pub_key.0 == 0x2 || pub_key.0 == 0x3)
        precondition(!Data(of: pub_key).dropFirst().isAllZero)
        precondition(priv_key.0 == BIP32_FLAG_KEY_PUBLIC || priv_key.0 == BIP32_FLAG_KEY_PRIVATE)
        precondition(!isPrivate || !Data(of: priv_key).dropFirst().isAllZero)
        precondition(!isMaster || Data(of: parent160).isAllZero)
    }

    public var network: Network? {
        switch version {
        case UInt32(BIP32_VER_MAIN_PRIVATE), UInt32(BIP32_VER_MAIN_PUBLIC):
            return .mainnet
        case UInt32(BIP32_VER_TEST_PRIVATE), UInt32(BIP32_VER_TEST_PUBLIC):
            return .testnet
        default:
            return nil
        }
    }
}
