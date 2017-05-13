//
//  CurrencyConverter.swift
//  GroupProject
//
//  Created by Nana on 5/6/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import Foundation

enum ConversionMode {
    case localToNative
    case nativeToLocal

    mutating func toggle() {
        switch self {
        case .localToNative:
            self = .nativeToLocal
        case .nativeToLocal:
            self = .localToNative
        }
    }
}

let currencySign : [String:String] = ["AUD":"$", "BGN":"лв", "BRL":"R$", "CAD":"$", "CHF":"chf", "CNY":"¥", "CZK":"Kč", "DKK":"kr", "EUR":"€", "GBP":"£", "HKD":"$", "HRK":"kn", "HUF":"Ft", "IDR":"Rp", "ILS":"₪", "INR":"₹", "JPY":"¥", "KRW":"₩", "MXN":"$", "MYR":"RM", "NOK":"kr", "NZD":"$", "PHP":"₱", "PLN":"zł", "RON":"lei", "RUB":"₽", "SEK":"kr", "SGD":"$", "THB":"฿", "TRY":"₤", "USD":"$", "ZAR":"R"]

class CurrencyConverter {

    var localCurrencyCode: String
    var localCurrencySign: String
    var localCountry: String
    var localCurrencyAmount: Double {
        didSet {
            if conversionMode == .localToNative {
                nativeCurrencyAmount = localCurrencyAmount * localToNativeFactor
            }
        }
    }
    var localToNativeFactor: Double {
        didSet {
            if conversionMode == .localToNative {
                if localToNativeFactor > 0 {
                    nativeToLocalFactor = 1 / localToNativeFactor
                }
                nativeCurrencyAmount = localCurrencyAmount * localToNativeFactor
            }
        }
    }

    var nativeCurrencyCode: String
    var nativeCurrencySign: String
    var nativeCountry: String
    var nativeCurrencyAmount: Double {
        didSet {
            if conversionMode == .nativeToLocal {
                localCurrencyAmount = nativeCurrencyAmount * nativeToLocalFactor
            }
        }
    }
    var nativeToLocalFactor: Double {
        didSet {
            if conversionMode == .nativeToLocal {
                if nativeToLocalFactor > 0 {
                    localToNativeFactor = 1 / nativeToLocalFactor
                }
                localCurrencyAmount = nativeCurrencyAmount * nativeToLocalFactor
            }
        }
    }

    var conversionMode: ConversionMode

    init(localCurrencyCd: String, localCountry: String, nativeCurrencyCd: String, nativeCountry: String) {
        
        self.localCurrencyCode = localCurrencyCd
        self.localCurrencySign = currencySign[localCurrencyCd] ?? "$"
        self.localCountry = localCountry
        self.localToNativeFactor = 1.0
        self.localCurrencyAmount = 1.0

        self.nativeCurrencyCode = nativeCurrencyCd
        self.nativeCurrencySign = currencySign[nativeCurrencyCd] ?? "$"
        self.nativeCountry = nativeCountry
        self.nativeToLocalFactor = 1.0
        self.nativeCurrencyAmount = 1.0

        self.conversionMode = ConversionMode.localToNative
    }

    convenience init(localCurrencyCd: String, localCountry: String, nativeCurrencyCd: String, nativeCountry: String, localCurrencyAmount: Double) {

        self.init(localCurrencyCd: localCurrencyCd, localCountry: localCountry, nativeCurrencyCd: nativeCurrencyCd, nativeCountry: nativeCountry)
        self.localCurrencyAmount = localCurrencyAmount
    }

    convenience init(localCurrencyCd: String, localCountry: String, nativeCurrencyCd: String, nativeCountry: String, localCurrencyAmount: Double, nativeCurrencyAmount: Double) {

        self.init(localCurrencyCd: localCurrencyCd, localCountry: localCountry, nativeCurrencyCd: nativeCurrencyCd, nativeCountry: nativeCountry)
        self.localCurrencyAmount = localCurrencyAmount
        self.nativeCurrencyAmount = nativeCurrencyAmount
    }

    func updateCurrencyConversionFactors(completion: @escaping (Result<Double>) -> ()) {

        let baseCurrency: String
        let targetCurrency: String
        let currentConversionMode = conversionMode

        switch currentConversionMode {
        case .localToNative:
            baseCurrency = localCurrencyCode
            targetCurrency = nativeCurrencyCode
        case .nativeToLocal:
            baseCurrency = nativeCurrencyCode
            targetCurrency = localCurrencyCode
        }

        FixerClient.shared.getCurrencyRate(for: targetCurrency, relativeTo: baseCurrency) {[weak self] (result) in
            if result.isSuccess && result.value != nil {
                switch currentConversionMode {
                case .localToNative:
                    self?.localToNativeFactor = result.value!
                case .nativeToLocal:
                    self?.nativeToLocalFactor = result.value!
                }
            }

            completion(result)
        }
    }
}
