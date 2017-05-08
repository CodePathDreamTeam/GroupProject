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

class CurrencyConverter {

    var localCurrencyCode: String
    var localCurrencySign: String
    var localCurrencyName: String
    var localCurrencyImage: String?
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
    var nativeCurrencyName: String
    var nativeCurrencyImage: String?
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

    init(localCurrencyCd: String, nativeCurrencyCd: String) {
        
        self.localCurrencyCode = "USD"
        self.localCurrencySign = "$"
        self.localCurrencyName = "United States Dollar"
        self.localCurrencyImage = "USD"
        self.localToNativeFactor = 1.0
        self.localCurrencyAmount = 1.0

        self.nativeCurrencyCode = "JPY"
        self.nativeCurrencySign = "¥"
        self.nativeCurrencyName = "Japanese Yen"
        self.nativeCurrencyImage = "JPY"
        self.nativeToLocalFactor = 1.0
        self.nativeCurrencyAmount = 1.0

        self.conversionMode = ConversionMode.localToNative
    }

    convenience init(localCurrencyCd: String, nativeCurrencyCd: String, localCurrencyAmount: Double) {

        self.init(localCurrencyCd: localCurrencyCd, nativeCurrencyCd: nativeCurrencyCd)
        self.localCurrencyAmount = localCurrencyAmount
    }

    convenience init(localCurrencyCd: String, nativeCurrencyCd: String, localCurrencyAmount: Double, nativeCurrencyAmount: Double) {

        self.init(localCurrencyCd: localCurrencyCd, nativeCurrencyCd: nativeCurrencyCd)
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
