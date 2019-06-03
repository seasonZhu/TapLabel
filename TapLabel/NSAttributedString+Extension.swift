//
//  NSAttributedString+Extension.swift
//  TapLabel
//
//  Created by season on 2019/6/3.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

// MARK: - 分类方法没有公有化,避免冲突富文本的运算符
extension NSAttributedString {
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }
}
