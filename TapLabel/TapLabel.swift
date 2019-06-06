//
//  TapLabel.swift
//  TapLabel
//
//  Created by season on 2019/5/30.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit

/// TapLabel的点击的回调
public protocol TapLabelDelegate: class {
    func didTap(_ label: TapLabel, matchResult: MatchResultType)
}

/// 文字根据正则可点击的Label
public class TapLabel: UILabel {
    
    //MARK:- 对外属性
    
    /// 代理
    public weak var delegate: TapLabelDelegate?
    
    /// 配置规则
    public var regularTypes = [RegularType]()
    
    /// 未匹配文字的富文本特性
    public var notMatchAttributes: Attributes?
    
    /// 段落间距
    @IBInspectable public var lineSpacing: CGFloat = 0 {
        didSet { updateTextStorage(parseText: false) }
    }
    
    /// 最小行高
    @IBInspectable public var minimumLineHeight: CGFloat = 0 {
        didSet { updateTextStorage(parseText: false) }
    }
    
    // MARK: - 重新UILabel的属性
    
    open override var text: String? {
        didSet { updateTextStorage() }
    }
    
    open override var attributedText: NSAttributedString? {
        didSet { updateTextStorage() }
    }
    
    open override var font: UIFont! {
        didSet { updateTextStorage(parseText: false) }
    }
    
    open override var textColor: UIColor! {
        didSet { updateTextStorage(parseText: false) }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet { updateTextStorage(parseText: false)}
    }
    
    open override var numberOfLines: Int {
        didSet { textContainer.maximumNumberOfLines = numberOfLines }
    }
    
    open override var lineBreakMode: NSLineBreakMode {
        didSet { textContainer.lineBreakMode = lineBreakMode }
    }
    
    public override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        textContainer.size = CGSize(width: superSize.width, height: CGFloat.greatestFiniteMagnitude)
        let size = layoutManager.usedRect(for: textContainer)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    /// 匹配结果集
    public var matchResults = [MatchResultType]()
    
    /// 被选择的结果
    private var selectedMatchResult: MatchResultType?
    
    /// 回调
    private var tapCallback: ((MatchResultType) -> Void)?
    
    /// 过滤规则
    private var filterPredicate: ((String) -> Bool)? {
        didSet { updateTextStorage() }
    }
    
    /// 过滤白名单
    private var filterList = [String]() {
        didSet { updateTextStorage() }
    }
    
    /// 高度修正
    private var heightCorrection: CGFloat = 0
    
    /// NSTextStorage
    private lazy var textStorage = NSTextStorage()
    
    /// NSLayoutManager
    private lazy var layoutManager = NSLayoutManager()
    
    /// NSTextContainer
    private lazy var textContainer = NSTextContainer()
    
    /// 是否正在配置
    private var _customizing: Bool = true
    
    //MARK:- 对外方法
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _customizing = false
        setUpLabel()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _customizing = false
        setUpLabel()
    }
}

// MARK: - 私有方法
extension TapLabel {
    
    /// 文本起始位置
    ///
    /// - Parameter rect: CGrect
    /// - Returns: CGPoint
    private func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRect(for: textContainer)
        heightCorrection = (rect.height - usedRect.height)/2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }
    
    /// 配置Label
    private func setUpLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        isUserInteractionEnabled = true
    }
    
    /// 更新TextStorag
    ///
    /// - Parameter parseText: 是否配置文字
    private func updateTextStorage(parseText: Bool = true) {
        if _customizing { return }
        // clean up previous active elements
        guard let attributedText = attributedText, attributedText.length > 0 else {
            clearActiveElements()
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }
        
        if parseText {
            clearActiveElements()
        }
        
        let all = RegexManager.widgets(regularTypes: regularTypes, string: self.text, filterList: filterList, filterPredicate: filterPredicate)
        matchResults = RegexManager.regexMatches(regularTypes: regularTypes, string: self.text, filterList: filterList, filterPredicate: filterPredicate)
        var mutAttrString = notMatchAttributes == nil ? all.attributedString : all.addNotMatchAttributes(notMatchAttributes!)
        mutAttrString = addLineBreak(mutAttrString)
        textStorage.setAttributedString(mutAttrString)
        
        _customizing = true
        text = mutAttrString.string
        _customizing = false
        setNeedsDisplay()
    }
    
    /// 富文本添加行距
    ///
    /// - Parameter attrString: 富文本
    /// - Returns: 新的富文本
    private func addLineBreak(_ attrString: NSAttributedString) -> NSMutableAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: attrString)
        
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)
        
        let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.minimumLineHeight = minimumLineHeight > 0 ? minimumLineHeight: self.font.pointSize * 1.14
        
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        
        mutAttrString.setAttributes(attributes, range: range)
        return mutAttrString
    }
    
    /// 清除被选中的元素
    private func clearActiveElements() {
        selectedMatchResult = nil
    }
    
    /// 是否被点击
    ///
    /// - Parameter touch: UITouch
    /// - Returns: Bool
    private func onTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        var avoidSuperCall = false
        
        switch touch.phase {
        case .began, .moved:
            if let element = element(at: location) {
                if element.nsRange.location != selectedMatchResult?.nsRange.location || element.nsRange.length != selectedMatchResult?.nsRange.length {
                    selectedMatchResult = element
                }
                avoidSuperCall = true
            } else {
                selectedMatchResult = nil
            }
        case .ended:
            guard let selectedElement = selectedMatchResult else { return avoidSuperCall }
            tapCallback?(selectedElement)
            delegate?.didTap(self, matchResult: selectedElement)
            avoidSuperCall = true
        case .cancelled:
            selectedMatchResult = nil
        case .stationary:
            break
        @unknown default:
            break
        }
        
        return avoidSuperCall
    }
    
    /// 点击的位置是否有元素
    ///
    /// - Parameter location: 位置
    /// - Returns: 元素
    private func element(at location: CGPoint) -> MatchResultType? {
        guard textStorage.length > 0 else {
            return nil
        }
        
        var correctLocation = location
        correctLocation.y -= heightCorrection
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }
        
        let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)
        
        for element in matchResults {
            if index >= element.nsRange.location && index <= element.nsRange.location + element.nsRange.length {
                return element
            }
        }
        
        return nil
    }
}

// MARK: - 共有的配置方法
extension TapLabel {
    
    /// 设置回调方法
    ///
    /// - Parameter tapCallback: 回调方法
    /// - Returns: 对象自己
    @discardableResult
    public func setTapCallback(_ tapCallback: ((MatchResultType) -> Void)?) -> Self {
        self.tapCallback = tapCallback
        return self
    }
    
    /// 设置过滤规则
    ///
    /// - Parameter filterPredicate: 过滤规则
    /// - Returns: 对象自己
    @discardableResult
    public func setFilterPredicate(_ filterPredicate: ((String) -> Bool)?) -> Self {
        self.filterPredicate = filterPredicate
        return self
    }
    
    /// 设置过滤白名单
    ///
    /// - Parameter filterPredicate: 过滤规则
    /// - Returns: 对象自己
    @discardableResult
    public func setFilterList(_ filterList: [String]) -> Self {
        self.filterList = filterList
        return self
    }
    
    /// 配置化方法
    ///
    /// - Parameter block: 配置函数
    /// - Returns: 对象自己
    @discardableResult
    open func customize(_ block: (TapLabel) -> ()) -> TapLabel {
        _customizing = true
        block(self)
        _customizing = false
        updateTextStorage()
        return self
    }
}

// MARK: - UILabel中的方法重写
extension TapLabel {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        updateTextStorage()
    }
    
    open override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)
        
        layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        _ = onTouch(touch)
        super.touchesCancelled(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesEnded(touches, with: event)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TapLabel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

