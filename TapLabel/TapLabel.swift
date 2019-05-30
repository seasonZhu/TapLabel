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
    
    /// 代理
    public weak var delegate: TapLabelDelegate?
    
    /// 回调
    public var tapCallback: ((MatchResultType) -> Void)?
    
    
}
