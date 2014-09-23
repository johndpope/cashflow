//
//  SwiftUtils.swift
//  CashFlow
//
//  Created by 村上 卓弥 on 2014/09/23.
//
//

import Foundation
import UIKit

func isIpad() -> Bool {
    return UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

func _L(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}