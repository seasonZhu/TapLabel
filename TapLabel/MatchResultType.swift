//
//  MatchResultType.swift
//  TapLabel
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation


/// 匹配结果和非匹配的结果 range所在的字符串 NSRange区间 后面如果需要将String转为富文本 富文本的特性 NSTextCheckingResult
public typealias MatchInfo = (rangeString: String, nsRange: NSRange, attributes: Attributes, checkingResult: NSTextCheckingResult?)
public typealias NotMatchInfo = MatchInfo

/// 匹配结果
///
/// - topic: 话题
/// - mention: @某人
/// - url: 网址
/// - phoneNumber: 手机号
/// - custom: 自定义
/// - notMatch: 非匹配结果
public enum MatchResultType {
    case topic(MatchInfo)
    case mention(MatchInfo)
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
    public init(regularType: RegularType? = nil, rangeString: String, nsRange: NSRange, attributes: Attributes = .nothing,  checkingResult: NSTextCheckingResult?) {
        guard let type = regularType else {
            self = .notMatch((rangeString, nsRange, attributes, checkingResult))
            return
        }
        
        switch type {
        case .topic:
            self = .topic((rangeString, nsRange, type.attributes, checkingResult))
        case .mention:
            self = .mention((rangeString, nsRange, type.attributes, checkingResult))
        case .url:
            self = .url((rangeString, nsRange, type.attributes, checkingResult))
        case .phoneNumber:
            self = .phoneNumber((rangeString, nsRange, type.attributes, checkingResult))
        case .custom:
            self = .custom((rangeString, nsRange, type.attributes, checkingResult))
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
        case .mention(let info):
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
    
    /// 获取结果信息的字符串
    public var rangeString: String {
        return info.rangeString
    }
    
    /// 获取结果信息的nsRange
    public var nsRange: NSRange {
        return info.nsRange
    }
    
    /// 获取结果的富文本特性结果集
    public var attributes: Attributes {
        return info.attributes
    }
    
    /// 获取匹配结果
    public var checkingResult: NSTextCheckingResult? {
        return info.checkingResult
    }
    
    /// 获取富文本
    public var attributedString: NSAttributedString {
        return NSAttributedString(string: rangeString, attributes: attributes)
    }
    
    /// 获取富文本并且为没有匹配到的文字添加新的富文本特性
    ///
    /// - Parameter attributes: 富文本特性
    /// - Returns: 富文本
    public func addNotMatchAttributes(_ attributes: Attributes) -> NSAttributedString {
        if case .notMatch = self {
            return NSAttributedString(string: rangeString, attributes: attributes)
        }else {
            return attributedString
        }
    }
}

extension MatchResultType: CustomStringConvertible {
    public var description: String {
        let description: String
        switch self {
        case .topic:
            description = "话题"
        case .mention:
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

// MARK: - 数组元素为MatchResultType的扩展
extension Array where Element == MatchResultType {
    
    /// 通过NSRange.location属性从小到大排列
    public var sortByNSRangeLocation: [MatchResultType] {
        return sorted { return $0.info.nsRange.location < $1.info.nsRange.location }
    }
    
    /// MatchResultType数组进行字符串化
    public var attributedString: NSAttributedString {
        let strings = self.map { $0.attributedString }
        let attributedString = strings.reduce(NSAttributedString()) { (initAttributedString, string) -> NSAttributedString in
            return initAttributedString + string
        }
        return attributedString
    }
    
    /// MatchResultType数组获取富文本并且为没有匹配到的文字添加新的富文本特性
    ///
    /// - Parameter attributes: 富文本特性
    /// - Returns: 富文本
    public func addNotMatchAttributes(_ attributes: Attributes) -> NSAttributedString {
        let strings = self.map { (result) -> NSAttributedString in
            if case .notMatch = result {
                return NSAttributedString(string: result.rangeString, attributes: attributes)
            }else {
                return result.attributedString
            }
        }
        
        let attributedString = strings.reduce(NSAttributedString()) { (initAttributedString, string) -> NSAttributedString in
            return initAttributedString + string
        }
        return attributedString
    }
}
