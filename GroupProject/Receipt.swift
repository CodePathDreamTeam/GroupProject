//
//  Receipt.swift
//  GroupProject
//
//  Created by Nana on 5/4/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation

enum ReceiptCategory: String {
    case Food
    case Logistics
    case Entertainment
    case Misc

    static var categoryNames: [String] {
        return ["Dining","Travel","Entertainment","Misc"]
    }

    static var count: Int {
        return categoryNames.count
    }
}

struct Receipt {

    var title: String
    var sourceCurrency: String
    var targetCurrency: String
    var sourceAmount: Double
    var targetAmount: Double
    var category: ReceiptCategory

    // Default initializer
    init(title: String, sourceCurrency: String, targetCurrency: String, sourceAmount: Double, targetAmount: Double, category: ReceiptCategory) {

        self.title = title
        self.sourceCurrency = sourceCurrency
        self.targetCurrency = targetCurrency
        self.sourceAmount = sourceAmount
        self.targetAmount = targetAmount
        self.category = category
    }

    // Convenience initializer
    init?(dictionary: Dictionary<String, Any>) {

        guard let title = dictionary["title"] as? String,
                let sourceCurrency = dictionary["sourceCurrency"] as? String,
                let targetCurrency = dictionary["targetCurrency"] as? String,
                let categoryStr = dictionary["category"] as? String,
                let category = ReceiptCategory(rawValue: categoryStr) else {
            return nil
        }

        self.title = title
        self.sourceCurrency = sourceCurrency
        self.targetCurrency = targetCurrency
        self.sourceAmount = dictionary["sourceAmount"] as? Double ?? 0.0
        self.targetAmount = dictionary["targetAmount"] as? Double ?? 0.0
        self.category = category
    }

    // Convenience static method to create array of receipt models
    static func receipts(dictionaries: Array<Dictionary<String, Any>>) -> Array<Receipt> {

        var receipts = Array<Receipt>()

        for aDictionary in dictionaries {
            if let receipt = Receipt(dictionary: aDictionary) {
                receipts.append(receipt)
            }
        }

        return receipts
    }

    // Translates Receipt struct to Dictionary for persistence
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        dictionary.updateValue(title, forKey: "title")
        dictionary.updateValue(sourceCurrency, forKey: "sourceCurrency")
        dictionary.updateValue(targetCurrency, forKey: "targetCurrency")
        dictionary.updateValue(sourceAmount, forKey: "sourceAmount")
        dictionary.updateValue(targetAmount, forKey: "targetAmount")
        dictionary.updateValue(category.rawValue, forKey: "category")

        return dictionary
    }
}
