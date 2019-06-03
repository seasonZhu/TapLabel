//
//  RegexManager.swift
//  TapLabel
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

/// 正则管理器
public class RegexManager {
    
    /// 正则缓存池
    public static var regularExpresionPool = [String: NSRegularExpression]()
    
    /// 替换符 这里使用Ω 只是这个字符使用的比较少 不代表不会被占用
    public static var replace = "Ω" {
        didSet {
            if oldValue != replace {
                separator = Character.init(replace)
            }
        }
    }
    
    /// 分割符 随着替换符同步更换
    static var separator = Character.init("Ω")
    
    /// 空字符串
    public static var spaceCharacterSet: CharacterSet = {
        let characterSet = NSMutableCharacterSet(charactersIn: "\u{00a0}")
        characterSet.formUnion(with: CharacterSet.whitespacesAndNewlines)
        return characterSet as CharacterSet
    }()
    
    /// 清除regularExpresionPool
    public static func clearRegularExpresionPool() {
        regularExpresionPool.removeAll()
    }
    
    /// 创建NSRegularExpression
    ///
    /// - Parameter pattern: 正则字符串
    /// - Returns: NSRegularExpression
    /// - Throws: RegexError
    public static func regexWithPattern(_ pattern: String, options: NSRegularExpression.Options = []) -> NSRegularExpression? {
        if let regex = regularExpresionPool[pattern] {
            return regex
        } else {
            do {
                let regularExpression: NSRegularExpression
                regularExpression =  try NSRegularExpression(pattern: pattern, options: options)
                regularExpresionPool[pattern] = regularExpression
                return regularExpression
            } catch {
                return nil
            }
        }
    }
    
    /// 通过检查类型获取正则对象
    ///
    /// - Parameter regularType: 检查类型
    /// - Returns: 正则对象NSRegularExpression
    public static func regexWithRegularType(_ regularType: RegularType) -> NSRegularExpression? {
        let pattern = regularType.pattern
        if case RegularType.phoneNumber(.system, _) = regularType {
            return try? NSDataDetector(types: NSTextCheckingTypes(NSTextCheckingResult.CheckingType.phoneNumber.rawValue))
        }
        
        if case RegularType.url(.system, _) = regularType {
            return try? NSDataDetector(types: NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
        }
        
        return regexWithPattern(pattern)
    }
    
    /// 获取匹配结果集
    ///
    /// - Parameters:
    ///   - regularType: 检查类型
    ///   - string: 需要被匹配的字符串
    ///   - filterPredicate: 过滤条件
    ///   - filterList: 过滤列表
    /// - Returns: [MatchResultType]
    /// - Throws: 抛出异常
    public static func regexMatches(regularType: RegularType, string: String?, filterList: [String] = [], filterPredicate: ((String) throws -> Bool)? = nil) rethrows -> [MatchResultType] {
        guard let internalString = string, let regex = regexWithRegularType(regularType) else {
            return []
        }
        
        let matches = regex.matches(in: internalString)
        var resultTypes = [MatchResultType]()
        for result in matches {
            let nsRange = result.range
            let checkString = internalString.subString(with: nsRange)
            // 过滤条件
            if try filterPredicate?(checkString) == true {
                continue
            }
            // 过滤名单
            if filterList.contains(checkString) {
                continue
            }
            let resultType = MatchResultType(regularType: regularType, rangeString: checkString, nsRange: nsRange, checkingResult: result)
            resultTypes.append(resultType)
        }
        
        /*
        // 由于添加了一个过滤规则,所以这里不能使用map函数了 map函数中无法使用break和continue等函数
        let resultTypes = matches.map { (result) -> MatchResultType in
            let nsRange = result.range
            let checkString = internalString.subString(with: nsRange)
            let resultType = MatchResultType(regularType: regularType, rangeString: checkString, nsRange: nsRange, checkingResult: result)
            return resultType
        }
        */
        return resultTypes
    }
    
    /// 获取匹配所有的结果集
    ///
    /// - Parameters:
    ///   - regularType: 检查类型集合
    ///   - string: 需要被匹配的字符串
    ///   - filterPredicate: 过滤条件
    ///   - filterList: 过滤列表
    /// - Returns: [MatchResultType]
    /// - Throws: 抛出异常
    public static func regexMatches(regularTypes: [RegularType], string: String?, filterList: [String] = [], filterPredicate: ((String) throws -> Bool)? = nil) rethrows -> [MatchResultType] {
        var allMatches = [MatchResultType]()
        for regularType in regularTypes {
            let matches = try regexMatches(regularType: regularType, string: string, filterList: filterList, filterPredicate: filterPredicate)
            allMatches = allMatches + matches
        }
        return allMatches
    }
    
    /// 获取非匹配所有的结果集
    ///
    /// - Parameters:
    ///   - regularTypes: 检查类型集合
    ///   - string: 需要被匹配的字符串
    /// - Returns: [MatchResultType]
    public static func regexNotMatches(regularTypes: [RegularType], string: String?) -> [MatchResultType] {
        let allMatches = regexMatches(regularTypes: regularTypes, string: string)
        return regexNotMatches(matches: allMatches, string: string)
    }
    
    /// 获取非匹配的结果集
    /// 注意里面用于替换和分割的字符Ω可以会与文本重复
    /// - Parameters:
    ///   - matches: 匹配的结果集
    ///   - string: 需要被匹配的字符串
    /// - Returns: [MatchResultType]
    public static func regexNotMatches(matches: [MatchResultType], string: String?) -> [MatchResultType] {
        guard let noChangeString = string else {
            return []
        }
        var changeString = noChangeString
        
        for match in matches {
            let stringInfo = match.info
            changeString = changeString.replacingOccurrences(of: stringInfo.rangeString, with: replace)
        }
        
        let notMatchStrings = changeString.split(separator: separator).map { return String($0) }
        let others = notMatchStrings.map { (notMatchString) -> MatchResultType in
            let range = noChangeString.range(of: notMatchString)!
            let nsRange = noChangeString.nsRange(from: range)
            let notMatchResult = MatchResultType(rangeString: notMatchString, nsRange: nsRange, checkingResult: nil)
            return notMatchResult
        }
        return others
    }
    
    /// 根据匹配与非匹配的结果集按按照NSRange的location顺序排列结果数组
    ///
    /// - Parameters:
    ///   - regularTypes: 检查类型集合
    ///   - string: 需要被匹配的字符串
    ///   - filterPredicate: 过滤条件
    ///   - filterList: 过滤列表
    /// - Returns: 顺序排列结果集
    /// - Throws: 抛出异常
    public static func widgets(regularTypes: [RegularType], string: String?, filterList: [String] = [], filterPredicate: ((String) throws -> Bool)? = nil) rethrows -> [MatchResultType] {
        let allMatches = try regexMatches(regularTypes: regularTypes, string: string, filterList: filterList, filterPredicate: filterPredicate)
        let notMatches = regexNotMatches(matches: allMatches, string: string)
        return widgets(matches: allMatches, notMatches: notMatches)
    }
    
    /// 根据匹配与非匹配的结果集按按照NSRange的location顺序排列结果数组
    ///
    /// - Parameters:
    ///   - matches: 匹配结果集
    ///   - others: 非匹配结果集
    /// - Returns: 顺序排列结果集
    public static func widgets(matches: [MatchResultType], notMatches: [MatchResultType]) -> [MatchResultType] {
        let widgets = (matches + notMatches).sortByNSRangeLocation
        return widgets
    }
}
