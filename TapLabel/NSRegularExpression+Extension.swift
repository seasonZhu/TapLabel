//
//  NSRegularExpression+Extension.swift
//  TapLabel
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

public extension NSRegularExpression {
    func enumerateMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Swift.Void) {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)
        
        self.enumerateMatches(in: string, options: options, range: nsRange, using: block)
    }
    
    func matches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> [NSTextCheckingResult] {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)
        
        return self.matches(in: string, options: options, range: nsRange)
    }
    
    func numberOfMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> Int {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)
        
        return self.numberOfMatches(in: string, options: options, range: nsRange)
    }
    
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> NSTextCheckingResult? {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)
        
        return self.firstMatch(in: string, options: options, range: nsRange)
    }
    
    func rangeOfFirstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> Range<String.Index>? {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)
        
        let match = self.rangeOfFirstMatch(in: string, options: options, range: nsRange)
        
        return string.range(from: match)
    }
    
    func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate templ: String) -> String {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)
        
        return self.stringByReplacingMatches(in: string, options: options, range: nsRange, withTemplate: templ)
    }
}
