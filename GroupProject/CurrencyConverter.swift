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
        
        localCurrencyCode = "USD"
        localCurrencySign = "$"
        localCurrencyName = "United States Dollar"
        localCurrencyImage = "USD"
        localToNativeFactor = 1.0
        localCurrencyAmount = 1.0

        nativeCurrencyCode = "JPY"
        nativeCurrencySign = "¥"
        nativeCurrencyName = "Japanese Yen"
        nativeCurrencyImage = "JPY"
        nativeToLocalFactor = 1.0
        nativeCurrencyAmount = 1.0

        conversionMode = ConversionMode.localToNative
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
