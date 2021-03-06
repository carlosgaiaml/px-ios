//
//  PXCustomOptionSearchItem.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
/// :nodoc:
open class PXCustomOptionSearchItem: NSObject, Codable {
    open var id: String!
    open var _description: String?
    open var paymentMethodId: String?
    open var paymentTypeId: String?
    open var discountInfo: String?
    open var defaultAmountConfiguration: String?
    open var selectedPayerCostConfiguration: PXAmountConfiguration?
    open var amountConfigurations: [String: PXAmountConfiguration]?
    open var comment: String?


    public init(id: String, description: String?, paymentMethodId: String?, paymentTypeId: String?, discountInfo: String?, defaultAmountConfiguration: String?, amountConfigurations: [String: PXAmountConfiguration]?, comment: String?) {
        self.id = id
        self._description = description
        self.paymentMethodId = paymentMethodId
        self.paymentTypeId = paymentTypeId
        self.discountInfo = discountInfo
        self.defaultAmountConfiguration = defaultAmountConfiguration
        self.amountConfigurations = amountConfigurations
        self.comment = comment

        if let defaultAmountConfiguration = defaultAmountConfiguration, let selectedPayerCostConfiguration = amountConfigurations?[defaultAmountConfiguration] {
            self.selectedPayerCostConfiguration = selectedPayerCostConfiguration
        }
    }

    public enum PXCustomOptionSearchItemKeys: String, CodingKey {
        case id
        case description
        case paymentMethodId = "payment_method_id"
        case paymentTypeId = "payment_type_id"
        case discountInfo = "discount_info"
        case defaultAmountConfiguration = "default_amount_configuration"
        case amountConfigurations = "amount_configurations"
        case comment = "comment"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCustomOptionSearchItemKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let description: String? = try container.decodeIfPresent(String.self, forKey: .description)
        let paymentMethodId: String? = try container.decodeIfPresent(String.self, forKey: .paymentMethodId)
        let paymentTypeId: String? = try container.decodeIfPresent(String.self, forKey: .paymentTypeId)
        let comment: String? = try container.decodeIfPresent(String.self, forKey: .comment)
        let discountInfo: String? = try container.decodeIfPresent(String.self, forKey: .discountInfo)
        let defaultAmountConfiguration: String? = try container.decodeIfPresent(String.self, forKey: .defaultAmountConfiguration)
        let amountConfigurations: [String: PXAmountConfiguration]? = try container.decodeIfPresent([String: PXAmountConfiguration].self, forKey: .amountConfigurations)

        self.init(id: id, description: description, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId, discountInfo: discountInfo, defaultAmountConfiguration: defaultAmountConfiguration, amountConfigurations: amountConfigurations, comment: comment)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCustomOptionSearchItemKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self._description, forKey: .description)
        try container.encodeIfPresent(self.paymentMethodId, forKey: .paymentMethodId)
        try container.encodeIfPresent(self.paymentTypeId, forKey: .paymentTypeId)
        try container.encodeIfPresent(self.discountInfo, forKey: .discountInfo)
        try container.encodeIfPresent(self.defaultAmountConfiguration, forKey: .defaultAmountConfiguration)
        try container.encodeIfPresent(self.amountConfigurations, forKey: .amountConfigurations)
        try container.encodeIfPresent(self.comment, forKey: .comment)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSONToPXCustomOptionSearchItem(data: Data) throws -> PXCustomOptionSearchItem {
        return try JSONDecoder().decode(PXCustomOptionSearchItem.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXCustomOptionSearchItem] {
        return try JSONDecoder().decode([PXCustomOptionSearchItem].self, from: data)
    }
}
