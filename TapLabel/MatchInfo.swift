//
//  MatchInfo.swift
//  TapLabel
//
//  Created by season on 2020/6/11.
//  Copyright © 2020 season. All rights reserved.
//

import Foundation

// public typealias MatchInfo = (rangeString: String, nsRange: NSRange, attributes: Attributes, checkingResult: NSTextCheckingResult?) 最初版本用的是元组,我就没明白,结构体不香吗?
public struct MatchInfo {
    
    /// range所在的字符串
    public let rangeString: String
    
    /// NSRange区间
    public let nsRange: NSRange
    
    /// 富文本的特性
    public let attributes: Attributes
    
    /// checkingResult
    public let checkingResult: NSTextCheckingResult?
}

public typealias NotMatchInfo = MatchInfo
