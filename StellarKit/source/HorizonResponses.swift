//
//  HorizonResponses.swift
//  StellarKit
//
//  Created by Kin Foundation.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

struct HorizonError: Decodable {
    let type: URL
    let title: String
    let status: Int
    let detail: String
    let instance: String?
    let extras: Extras?

    struct Extras: Decodable {
        let resultXDR: String

        enum CodingKeys: String, CodingKey {
            case resultXDR = "result_xdr"
        }
    }
}

public struct AccountDetails: Decodable {
    public let id: String
    public let accountId: String
    public let sequence: String
    public let balances: [Balance]

    public var seqNum: UInt64 {
        return UInt64(sequence) ?? 0
    }

    public struct Balance: Decodable {
        public let balance: String
        public let assetType: String
        public let assetCode: String?
        public let assetIssuer: String?

        public var balanceNum: Decimal {
            return Decimal(string: balance) ?? Decimal()
        }

        enum CodingKeys: String, CodingKey {
            case balance
            case assetType = "asset_type"
            case assetCode = "asset_code"
            case assetIssuer = "asset_issuer"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case sequence
        case balances
    }
}

struct TransactionResponse: Decodable {
    let hash: String
    let resultXDR: String

    enum CodingKeys: String, CodingKey {
        case hash
        case resultXDR = "result_xdr"
    }
}

