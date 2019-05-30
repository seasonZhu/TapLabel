//
//  MatchResultType.swift
//  TapLabel
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation


/// 匹配结果和非匹配的结果 range所在的字符串 NSRange区间 NSTextCheckingResult
public typealias MatchInfo = (rangeString: String, nsRange: NSRange, checkingResult: NSTextCheckingResult?)
public typealias NotMatchInfo = MatchInfo

/// 匹配结果
///
/// - topic: 话题
/// - metion: @某人
/// - url: 网址
/// - phoneNumber: 手机号
/// - custom: 自定义
/// - notMatch: 非匹配结果
public enum MatchResultType {
    case topic(MatchInfo)
    case metion(MatchInfo)
    case url(MatchInfo)
    case phoneNumber(MatchInfo)
    case custom(MatchInfo)
    case notMatch(NotMatchInfo)
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - regularType: 匹配类型
    ///   - rangeString: range所在的字符串
    ///   - nsRange: NSRange
    ///   - checkingResult: NSTextCheckingResult
    public init(regularType: RegularType? = nil, rangeString: String, nsRange: NSRange, checkingResult: NSTextCheckingResult?) {
        guard let type = regularType else {
            self = .notMatch((rangeString, nsRange, checkingResult))
            return
        }
        
        switch type {
        case .topic:
            self = .topic((rangeString, nsRange, checkingResult))
        case .metion:
            self = .metion((rangeString, nsRange, checkingResult))
        case .url:
            self = .url((rangeString, nsRange, checkingResult))
        case .phoneNumber:
            self = .phoneNumber((rangeString, nsRange, checkingResult))
        case .custom:
            self = .custom((rangeString, nsRange, checkingResult))
        }
    }
}

extension MatchResultType {
    
    /// 获取结果信息
    public var info: MatchInfo {
        let matchInfo: MatchInfo
        switch self {
        case .topic(let info):
            matchInfo = info
        case .metion(let info):
            matchInfo = info
        case .url(let info):
            matchInfo = info
        case .phoneNumber(let info):
            matchInfo = info
        case .custom(let info):
            matchInfo = info
        case .notMatch(let info):
            matchInfo = info
        }
        return matchInfo
    }
}

extension MatchResultType: CustomStringConvertible {
    public var description: String {
        let description: String
        switch self {
        case .topic:
            description = "话题"
        case .metion:
            description = "提到"
        case .url:
            description = "网址"
        case .phoneNumber:
            description = "手机号"
        case .custom:
            description = "自定义"
        case .notMatch:
            description = "非正则"
        }
        return description
    }
}
