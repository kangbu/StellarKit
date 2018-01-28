//
//  PublicKey.swift
//  StellarKit
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

struct CryptoKeyType {
    static let KEY_TYPE_ED25519: Int32 = 0
    static let KEY_TYPE_PRE_AUTH_TX: Int32 = 1
    static let KEY_TYPE_HASH_X: Int32 = 2
}

struct PublicKeyType {
    static let PUBLIC_KEY_TYPE_ED25519 = CryptoKeyType.KEY_TYPE_ED25519
}

enum PublicKey: XDRCodable, Equatable {
    case PUBLIC_KEY_TYPE_ED25519 (FixedLengthDataWrapper)

    var publicKey: String? {
        if case .PUBLIC_KEY_TYPE_ED25519(let wrapper) = self {
            return KeyUtils.base32(publicKey: wrapper.wrapped)
        }

        return nil
    }

    init(xdrData: inout Data, count: Int32 = 0) {
        _ = Int32(xdrData: &xdrData)

        self = .PUBLIC_KEY_TYPE_ED25519(FixedLengthDataWrapper(Data(xdrData: &xdrData, count: 32)))
    }
    
    private func discriminant() -> Int32 {
        switch self {
        case .PUBLIC_KEY_TYPE_ED25519: return PublicKeyType.PUBLIC_KEY_TYPE_ED25519
        }
    }

    func toXDR(count: Int32 = 0) -> Data {
        var xdr = discriminant().toXDR()

        switch self {
        case .PUBLIC_KEY_TYPE_ED25519 (let key):
            xdr.append(key.toXDR())
        }

        return xdr
    }

    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        switch (lhs, rhs) {
        case let (.PUBLIC_KEY_TYPE_ED25519(k1), .PUBLIC_KEY_TYPE_ED25519(k2)):
            return k1 == k2
        }
    }
}
