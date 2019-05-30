//
//  RegularType.swift
//  TapLabel
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

/// 字符串中需要检查的类型
///
/// - topic: 话题 #话题#
/// - metion: @某人
/// - url: 网址
/// - phoneNumber: 电话号码
/// - custom: 自定义
public enum RegularType {
    case topic(PatternType)
    case metion(PatternType)
    case url(PatternType)
    case phoneNumber(PatternType)
    case custom(String)
    
    /// 正则字符串的样式
    ///
    /// - custom: 自定义的正则字符串
    /// - system: 使用系统默认(话题和@某人是自己写的默认),网址和电话号码是NSTextCheckingResult.CheckingType.link和phoneNumber
    public enum PatternType {
        case custom(String)
        case system
    }
}

// MARK: - 正则表达字符串
extension RegularType {
    
    /// 获取正则表达字符串
    public var pattern: String {
        switch self {
        case .topic(let subType):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                return RegularType.topicPattern
            }
        case .metion(let subType):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                return RegularType.mentionPattern
            }
        case .url(let subType):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                // UInt64 32
                return  String(NSTextCheckingResult.CheckingType.link.rawValue)
            }
        case .phoneNumber(let subType):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                // UInt64 2048
                return  String(NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            }
        case .custom(let pattern):
            return pattern
        }
    }
}

extension RegularType: CustomStringConvertible {
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
        }
        return description
    }
}

// MARK: - 话题和@某人是我写的默认
extension RegularType {
    
    /// 话题的正则表达字符串
    static let topicPattern = "(?:^|\\s|$)#.*#[\\p{L}0-9_]*"
    
    /// @某人的正则表达字符串
    // 你好呀 @DY *最后两边都各有一个空格*
    static let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
}
