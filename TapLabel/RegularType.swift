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
/// - mention: @某人
/// - url: 网址 其实如果需要对网址进行最大长度的限制 其实思路也很简单 就是优先正则网址 然后找到网址,保存原有的url然后切割,对整体字符串进行替换,然后重新进行整体正则,只是我的写的时候整体结果是字符串进行零件化,所以不太适合这样了
/// - phoneNumber: 电话号码
/// - custom: 自定义
public enum RegularType {
    case topic(PatternType, Attributes)
    case mention(PatternType, Attributes)
    case url(PatternType, Attributes)
    case phoneNumber(PatternType, Attributes)
    case custom(String, Attributes)
    
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
        case .topic(let subType, _):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                return RegularType.topicPattern
            }
        case .mention(let subType, _):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                return RegularType.mentionPattern
            }
        case .url(let subType, _):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                // UInt64 32
                return  String(NSTextCheckingResult.CheckingType.link.rawValue)
            }
        case .phoneNumber(let subType, _):
            switch subType {
            case .custom(let pattern):
                return pattern
            case .system:
                // UInt64 2048
                return  String(NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            }
        case .custom(let pattern, _):
            return pattern
        }
    }
    
    /// 获取富文本的特性
    public var attributes: Attributes {
        let atts: Attributes
        switch self {
        case .topic(_, let attributes):
            atts = attributes
        case .mention(_, let attributes):
            atts = attributes
        case .url(_, let attributes):
            atts = attributes
        case .phoneNumber(_, let attributes):
            atts = attributes
        case .custom(_, let attributes):
            atts = attributes
        }
        return atts
    }
}

extension RegularType: CustomStringConvertible {
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

/// 富文本特性简写
public typealias Attributes = [NSAttributedString.Key: Any]

extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    
    /// 空的富文本特性集合
    public static var nothing: Attributes {
        return [:]
    }
}
