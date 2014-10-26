//
//  CurrencyManager.swift
//

import Foundation
import UIKit

class CurrencyManager: NSObject {
    let currencies = NSLocale.ISOCurrencyCodes() as [String];
    /*
    ["AED",
    "AUD",
    "BHD",
    "BND",
    "BRL",
    "CAD",
    "CHF",
    "CLP",
    "CNY",
    "CYP",
    "CZK",
    "DKK",
    "EUR",
    "GBP",
    "HKD",
    "HUF",
    "IDR",
    "ILS",
    "INR",
    "ISK",
    "JPY",
    "KRW",
    "KWD",
    "KZT",
    "LKR",
    "MTL",
    "MUR",
    "MXN",
    "MYR",
    "NOK",
    "NPR",
    "NZD",
    "OMR",
    "PKR",
    "QAR",
    "RUB",
    "SAR",
    "SEK",
    "SGD",
    "SKK",
    "THB",
    "TWD",
    "USD",
    "ZAR"]
*/
    
    private let kBaseCurrency = "BaseCurrency"
    
    private let _numberFormatter = NSNumberFormatter()
    
    class var instance: CurrencyManager {
        struct Static {
            static let instance : CurrencyManager = CurrencyManager()
        }
        return Static.instance
    }
    
    class func getInstance() -> CurrencyManager {
        return CurrencyManager.instance
    }
    
    private override init() {
        super.init()
        
        _numberFormatter.numberStyle = .CurrencyStyle
        _numberFormatter.locale = NSLocale.currentLocale()
        
        _baseCurrency = NSUserDefaults.standardUserDefaults().objectForKey(kBaseCurrency) as NSString?

        // TEST : get currency code list
        /*
        var codes = NSLocale.ISOCurrencyCodes() as [String];
        for code in codes {
            NSLog(code);
        }
        */
    }
    
    /**
     * システムデフォルトの通貨コードを返す
     */
    class func systemCurrency() -> String {
        var nf = NSNumberFormatter()
        nf.numberStyle = .CurrencyStyle
        return nf.currencyCode
    }
    
    /**
     * ベース通貨コード
     */
    var baseCurrency: String? {
        get {
            return _baseCurrency
        }
        set {
            if _baseCurrency != newValue {
                _baseCurrency = newValue
            
                if (_baseCurrency != nil){
                    _numberFormatter.currencyCode = _baseCurrency!
                } else {
                    _numberFormatter.currencyCode = CurrencyManager.systemCurrency()
                }
            
                NSUserDefaults.standardUserDefaults().setObject(_baseCurrency, forKey: kBaseCurrency)
            }
        }
    }
    
    private var _baseCurrency: NSString?
    
    class func formatCurrency(value: Double) -> String {
        return CurrencyManager.instance._formatCurrency(value)
    }
    
    private func _formatCurrency(value: Double) -> String {
        return _numberFormatter.stringFromNumber(value)!
    }
}
