//
//  Transaction.swift
//  StellarKit
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

struct MemoType {
    static let MEMO_NONE: Int32 = 0
    static let MEMO_TEXT: Int32 = 1
    static let MEMO_ID: Int32 = 2
    static let MEMO_HASH: Int32 = 3
    static let MEMO_RETURN: Int32 = 4
}

enum Memo: XDRCodable {
    case MEMO_NONE
    case MEMO_TEXT (String)
    case MEMO_ID (UInt64)
    case MEMO_HASH (FixedLengthDataWrapper)
    case MEMO_RETURN (FixedLengthDataWrapper)

    init(xdrData: inout Data, count: Int32 = 0) {
        let discriminant = Int32(xdrData: &xdrData)

        switch discriminant {
        case MemoType.MEMO_NONE:
            self = .MEMO_NONE
        // Insert other cases as support is required.
        default:
            self = .MEMO_NONE
        }
    }

    private func discriminant() -> Int32 {
        switch self {
        case .MEMO_NONE: return MemoType.MEMO_NONE
        case .MEMO_TEXT: return MemoType.MEMO_TEXT
        case .MEMO_ID: return MemoType.MEMO_ID
        case .MEMO_HASH: return MemoType.MEMO_HASH
        case .MEMO_RETURN: return MemoType.MEMO_RETURN
        }
    }

    func toXDR(count: Int32 = 0) -> Data {
        var xdr = discriminant().toXDR()

        switch self {
        case .MEMO_NONE: break
        case .MEMO_TEXT (let text): xdr.append(text.toXDR())
        case .MEMO_ID (let id): xdr.append(id.toXDR())
        case .MEMO_HASH (let hash): xdr.append(hash.toXDR())
        case .MEMO_RETURN (let hash): xdr.append(hash.toXDR())
        }

        return xdr
    }
}

struct TimeBounds: XDREncodableStruct {
    let minTime: UInt64
    let maxTime: UInt64
}

public struct Transaction: XDREncodableStruct, XDRDecodable {
    let sourceAccount: PublicKey
    let fee: UInt32
    let seqNum: UInt64
    let timeBounds: TimeBounds?
    let memo: Memo
    let operations: [Operation]
    let reserved: Int32 = 0

    init(sourceAccount: PublicKey,
         seqNum: UInt64,
         timeBounds: TimeBounds?,
         memo: Memo,
         operations: [Operation]) {
        self.sourceAccount = sourceAccount
        self.seqNum = seqNum
        self.timeBounds = timeBounds
        self.memo = memo
        self.operations = operations

        self.fee = UInt32(100 * operations.count)
    }

    public init(xdrData: inout Data, count: Int32 = 0) {
        sourceAccount = PublicKey(xdrData: &xdrData)
        fee = UInt32(xdrData: &xdrData)
        seqNum = UInt64(xdrData: &xdrData)

        _ = Int32(xdrData: &xdrData)
        timeBounds = nil

        memo = Memo(xdrData: &xdrData)
        operations = Array<Operation>(xdrData: &xdrData)

        _ = Int32(xdrData: &xdrData)
    }
}

struct EnvelopeType {
    static let ENVELOPE_TYPE_SCP: Int32 = 1
    static let ENVELOPE_TYPE_TX: Int32 = 2
    static let ENVELOPE_TYPE_AUTH: Int32 = 3
}

struct TransactionSignaturePayload: XDREncodableStruct {
    let networkId: FixedLengthDataWrapper
    let taggedTransaction: TaggedTransaction

    enum TaggedTransaction: XDREncodable {
        case ENVELOPE_TYPE_TX (Transaction)

        private func discriminant() -> Int32 {
            switch self {
            case .ENVELOPE_TYPE_TX: return EnvelopeType.ENVELOPE_TYPE_TX
            }
        }

        func toXDR(count: Int32 = 0) -> Data {
            var xdr = discriminant().toXDR()

            switch self {
            case .ENVELOPE_TYPE_TX (let tx): xdr.append(tx.toXDR())
            }

            return xdr
        }
    }
}

struct DecoratedSignature: XDREncodableStruct, XDRDecodable {
    let hint: FixedLengthDataWrapper;
    let signature: Data

    init(hint: FixedLengthDataWrapper, signature: Data) {
        self.hint = hint
        self.signature = signature
    }

    init(xdrData: inout Data, count: Int32 = 0) {
        hint = FixedLengthDataWrapper(Data(xdrData: &xdrData, count: 4))
        signature = Data(xdrData: &xdrData)
    }
}

public struct TransactionEnvelope: XDREncodableStruct, XDRDecodable {
    let tx: Transaction
    let signatures: [DecoratedSignature]

    init(tx: Transaction, signatures: [DecoratedSignature]) {
        self.tx = tx
        self.signatures = signatures
    }

    public init(xdrData: inout Data, count: Int32 = 0) {
        tx = Transaction(xdrData: &xdrData)
        signatures = Array<DecoratedSignature>(xdrData: &xdrData)
    }
}
