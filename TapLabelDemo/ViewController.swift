//
//  ViewController.swift
//  TapLabelDemo
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit
import TapLabel

class ViewController: UIViewController {
    
    let string = """
    我正在尝试使用系统的正则系统,我的手机号是13437156081,我另外一个手机号 @DY 是19927101229,今天的话题是 #好冷啊#,我经常去的网站是www.hao123.com,以及lostsakura.com我的住址是武汉市硚口区云鹤小区13345678910,
    """
    override func viewDidLoad() {
        super.viewDidLoad()
        tapLabelBegin()
    }
}

extension ViewController {
    func tapLabelBegin() {
        
        /// 匹配手机号 并且过滤掉13437156081这个号码
        let phoneResults = RegexManager.regexMatches(regularType: .phoneNumber(.system, .nothing), string: string) { matche in matche == "13437156081" }
        /// 匹配网址
        let urlResults = RegexManager.regexMatches(regularType: .url(.system, .nothing), string: string)
        /// 匹配@某人
        let atResults = RegexManager.regexMatches(regularType: .metion(.system, .nothing), string: string)
        /// 匹配话题
        let topicResults = RegexManager.regexMatches(regularType: .topic(.system, .nothing), string: string)
        /// 自定义匹配
        let customResults = RegexManager.regexMatches(regularType: .custom("云鹤", .nothing), string: string)
        /// 所有匹配的到的集合
        let matches = phoneResults + urlResults + atResults + topicResults + customResults
        /// 非匹配的集合
        let notMatches = RegexManager.regexNotMatches(matches: matches, string: string)
        /// 通过NSRange的location按字符串表述的顺序 排列组件
        let widgets = RegexManager.widgets(matches: matches, notMatches: notMatches)
        
        /// 打印
        for widget in widgets {
            print(widget, widget.info.rangeString, widget.info.nsRange)
        }
        
        /// 一口气进行组件化并打印
        let newWidget = RegexManager.widgets(regularTypes: [.phoneNumber(.system, .nothing), .url(.system, .nothing), .metion(.system, .nothing), .topic(.system, .nothing), .custom("云鹤", .nothing)], string: string)
        print("一口气进行组件化并打印")
        for widget in newWidget {
            print(widget, widget.info.rangeString, widget.info.nsRange)
        }
    }
}

extension ViewController {
    func think() {
        /// 使用系统的detector可以找到手机号码
        let detector = try! NSDataDetector(types: NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue + NSTextCheckingResult.CheckingType.phoneNumber.rawValue))
        
        print(NSTextCheckingResult.CheckingType.link.rawValue)
        print(NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        
        let results = detector.matches(in: string, options: [], range: NSMakeRange(0, string.count))
        let checkTuple = results.map { (result) -> (NSRange, String) in
            return (result.range, (string as NSString).substring(with: result.range))
        }
        print(checkTuple)
        var newString = string
        for (nsRange, checkString) in checkTuple {
            newString = newString.replacingOccurrences(of: checkString, with: "`")
        }
        print(newString)
        let strings = newString.split(separator: "`").map { return String($0) }
        print(strings)
        
        let unCheckTuple = strings.map { (unCheckString) -> (NSRange, String) in
            let range = string.range(of: unCheckString)!
            let nsRange = string.nsRange(from: range)
            return (nsRange, unCheckString)
        }
        
        print(unCheckTuple)
        
        let widgets = (checkTuple + unCheckTuple).sorted { (value1, value2) -> Bool in
            return value1.0.location < value2.0.location
        }
        
        print(widgets)
        
        
        
        let label = ActiveLabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        label.customize { label in
            label.text = string
            label.numberOfLines = 0
            label.lineSpacing = 4
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
            
            //label.handleMentionTap { print($0); SwiftProgressHUD.showOnlyText($0)}
            //label.handleHashtagTap { print($0); SwiftProgressHUD.showOnlyText($0)}
            //label.handleURLTap { print($0.absoluteString); SwiftProgressHUD.showOnlyText($0.absoluteString) }
            
        }
        label.textColor = UIColor.black
        label.center = view.center
        label.checkTuples = checkTuple
        view.addSubview(label)
    }
}

// MARK: - 这个和String分类中的很像 可以说基本一致 这里是为了配合上面的NSRegularExpression使用
private extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view) ?? self.startIndex
        let to = range.upperBound.samePosition(in: utf16view) ?? self.endIndex
        return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from),
                           utf16view.distance(from: from, to: to))
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
