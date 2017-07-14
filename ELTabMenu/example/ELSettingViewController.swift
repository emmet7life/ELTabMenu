//
//  ELSettingViewController.swift
//  ELTabMenu
//
//  Created by 陈建立 on 7/14/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit

struct ELGlobalConfig {
    static var `default` = ELGlobalConfig()

    private var defaultOptions: ELTabMenuOptions {
        var options = ELTabMenuOptions()
        options.padding = 10
        options.margin = 20
        options.textFontSize = 14.0
        options.bold = true
        options.edgeNeedMargin = true
        options.itemWidthMode = .equal
        options.itemLayoutMode = .full
        options.scrollBarAlignPosition = .alignView
        options.scrollBarPosition = .bottom
        options.scrollBarLeadingPosition = .center
        options.scrollBarZPosition = .behind
        return options
    }

    var options = ELTabMenuOptions()

    var tabNum: Int = 2
    var hasChanged = false

    init() {
        options = defaultOptions
    }

    mutating func reset() {
        tabNum = 2
        options = defaultOptions
    }
}

func ==(lhs: ELGlobalConfig, rhs: ELGlobalConfig) -> Bool {
    guard lhs.tabNum == rhs.tabNum else { return false }
    guard lhs.options.padding == rhs.options.padding else { return false }
    guard lhs.options.margin == rhs.options.margin else { return false }
    guard lhs.options.textFontSize == rhs.options.textFontSize else { return false }
    guard lhs.options.scrollBarPositionOffset == rhs.options.scrollBarPositionOffset else { return false }
    guard lhs.options.scrollBarHeight == rhs.options.scrollBarHeight else { return false }
    guard lhs.options.scrollBarWidthPercent == rhs.options.scrollBarWidthPercent else { return false }
    guard lhs.options.bold == rhs.options.bold else { return false }
    guard lhs.options.edgeNeedMargin == rhs.options.edgeNeedMargin else { return false }
    guard lhs.options.itemWidthMode == rhs.options.itemWidthMode else { return false }
    guard lhs.options.itemLayoutMode == rhs.options.itemLayoutMode else { return false }
    guard lhs.options.scrollBarAlignPosition == rhs.options.scrollBarAlignPosition else { return false }
    guard lhs.options.scrollBarPosition == rhs.options.scrollBarPosition else { return false }
    guard lhs.options.scrollBarLeadingPosition == rhs.options.scrollBarLeadingPosition else { return false }
    guard lhs.options.scrollBarZPosition == rhs.options.scrollBarZPosition else { return false }
    return true
}

func !=(lhs: ELGlobalConfig, rhs: ELGlobalConfig) -> Bool {
    return !(lhs == rhs)
}

class ELSettingViewController: UIViewController {

    // View
    @IBOutlet weak var paddingField: UITextField!
    @IBOutlet weak var marginField: UITextField!
    @IBOutlet weak var fontSizeField: UITextField!
    @IBOutlet weak var positionOffsetField: UITextField!

    @IBOutlet weak var tabNumLabel: UILabel!
    @IBOutlet weak var paddingLabel: UILabel!
    @IBOutlet weak var marginLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var positionOffsetLabel: UILabel!
    @IBOutlet weak var scrollBarHeightLabel: UILabel!
    @IBOutlet weak var scrollBarWidthPercentLabel: UILabel!

    @IBOutlet weak var tabNumSlider: UISlider!
    @IBOutlet weak var paddingSlider: UISlider!
    @IBOutlet weak var marginSlider: UISlider!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var positionOffsetSlider: UISlider!
    @IBOutlet weak var scrollBarHeightSlider: UISlider!
    @IBOutlet weak var scrollBarWidthPercentSlider: UISlider!

    @IBOutlet weak var boldSegment: UISegmentedControl!
    @IBOutlet weak var edgeNeedMarginSegment: UISegmentedControl!
    @IBOutlet weak var itemWidthModeSegment: UISegmentedControl!
    @IBOutlet weak var itemLayoutModeSegment: UISegmentedControl!
    @IBOutlet weak var scrollBarAlignPositionSegment: UISegmentedControl!
    @IBOutlet weak var scrollBarPositionSegment: UISegmentedControl!
    @IBOutlet weak var scrollBarLeadingPositionSegment: UISegmentedControl!
    @IBOutlet weak var scrollBarZPositionSegment: UISegmentedControl!

    // Data
    var preConfig = ELGlobalConfig()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 没有将所有的可配置参数放在界面上调节，可通过代码自行配置查看效果
        updateViewValue()
    }

    private func updateViewValue(with globalConfig: ELGlobalConfig = ELGlobalConfig.default) {

        let tabNum = globalConfig.tabNum
        tabNumSlider.value = Float(tabNum)
        tabNumLabel.text = "tabNum(\(tabNum))"

        var value = globalConfig.options.padding
        paddingSlider.value = Float(value)
        paddingLabel.text = "padding(\(value))"

        value = globalConfig.options.margin
        marginSlider.value = Float(value)
        marginLabel.text = "margin(\(value))"

        value = globalConfig.options.textFontSize
        fontSizeSlider.value = Float(value)
        fontSizeLabel.text = "fontSize(\(value))"

        value = globalConfig.options.scrollBarPositionOffset
        positionOffsetSlider.value = Float(value)
        positionOffsetLabel.text = "positionOffset(\(value))"

        value = globalConfig.options.scrollBarHeight
        scrollBarHeightSlider.value = Float(value)
        scrollBarHeightLabel.text = "scrollBarHeight(\(value))"

        value = globalConfig.options.scrollBarWidthPercent
        scrollBarWidthPercentSlider.value = Float(value)
        scrollBarWidthPercentLabel.text = "scrollBarWidthPercent(\(value))"

        boldSegment.selectedSegmentIndex = globalConfig.options.bold ? 0 : 1
        edgeNeedMarginSegment.selectedSegmentIndex = globalConfig.options.edgeNeedMargin ? 0 : 1
        itemWidthModeSegment.selectedSegmentIndex = globalConfig.options.itemWidthMode == .equal ? 0 : 1
        itemLayoutModeSegment.selectedSegmentIndex = globalConfig.options.itemLayoutMode == .free ? 0 : 1
        scrollBarAlignPositionSegment.selectedSegmentIndex = globalConfig.options.scrollBarAlignPosition == .alignText ? 0 : 1

        switch globalConfig.options.scrollBarPosition {
        case .top:
            scrollBarPositionSegment.selectedSegmentIndex = 0
        case .center:
            scrollBarPositionSegment.selectedSegmentIndex = 1
        case .bottom:
            scrollBarPositionSegment.selectedSegmentIndex = 2
        }

        scrollBarLeadingPositionSegment.selectedSegmentIndex = globalConfig.options.scrollBarLeadingPosition == .left ? 0 : 1
        scrollBarZPositionSegment.selectedSegmentIndex = globalConfig.options.scrollBarZPosition == .front ? 0 : 1

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preConfig = ELGlobalConfig.default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ELGlobalConfig.default.hasChanged = preConfig != ELGlobalConfig.default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onTabNumSliderChanged(_ sender: UISlider) {
        let tabNum = Int(sender.value)
        ELGlobalConfig.default.tabNum = tabNum
        tabNumSlider.value = Float(tabNum)
        tabNumLabel.text = "tabNum(\(tabNum))"
    }

    @IBAction func onPaddingChanged(_ sender: UISlider) {
        let value = Float(String(format: "%.1f", sender.value))!
        ELGlobalConfig.default.options.padding = CGFloat(value)
        paddingSlider.value = value
        paddingLabel.text = "padding(\(value))"
    }

    @IBAction func onMarginChanged(_ sender: UISlider) {
        let value = Float(String(format: "%.1f", sender.value))!
        ELGlobalConfig.default.options.margin = CGFloat(value)
        marginSlider.value = value
        marginLabel.text = "margin(\(value))"
    }

    @IBAction func onFontSizeChanged(_ sender: UISlider) {
        let value = Float(String(format: "%.1f", sender.value))!
        ELGlobalConfig.default.options.textFontSize = CGFloat(value)
        fontSizeSlider.value = value
        fontSizeLabel.text = "fontSize(\(value))"
    }

    @IBAction func onPositionOffsetChanged(_ sender: UISlider) {
        let value = Float(String(format: "%.1f", sender.value))!
        ELGlobalConfig.default.options.scrollBarPositionOffset = CGFloat(value)
        positionOffsetSlider.value = value
        positionOffsetLabel.text = "positionOffset(\(value))"
    }

    @IBAction func onScrollBarHeightChanged(_ sender: UISlider) {
        let value = Float(String(format: "%.1f", sender.value))!
        ELGlobalConfig.default.options.scrollBarHeight = CGFloat(value)
        scrollBarHeightSlider.value = value
        scrollBarHeightLabel.text = "scrollBarHeight(\(value))"
    }

    @IBAction func onScrollBarWidthPercentChanged(_ sender: UISlider) {
        let value = Float(String(format: "%.1f", sender.value))!
        ELGlobalConfig.default.options.scrollBarWidthPercent = CGFloat(value)
        scrollBarWidthPercentSlider.value = value
        scrollBarWidthPercentLabel.text = "scrollBarWidthPercent(\(value))"
    }

    @IBAction func onBoldChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.bold = sender.selectedSegmentIndex == 0
    }

    @IBAction func onEdgeNeedMarginChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.edgeNeedMargin = sender.selectedSegmentIndex == 0
    }

    @IBAction func onItemWidthModeChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.itemWidthMode = sender.selectedSegmentIndex == 0 ? .equal : .dynamic
    }

    @IBAction func onItemLayoutModeChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.itemLayoutMode = sender.selectedSegmentIndex == 0 ? .free : .full
    }

    @IBAction func onScrollBarAlignPositionChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.scrollBarAlignPosition = sender.selectedSegmentIndex == 0 ? .alignText : .alignView
    }

    @IBAction func onScrollBarPositionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ELGlobalConfig.default.options.scrollBarPosition = .top
        case 1:
            ELGlobalConfig.default.options.scrollBarPosition = .center
        case 2:
            ELGlobalConfig.default.options.scrollBarPosition = .bottom
        default: break
        }
    }

    @IBAction func onScrollBarLeadingPositionChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.scrollBarLeadingPosition = sender.selectedSegmentIndex == 0 ? .left : .center
    }

    @IBAction func onScrollBarZPositionChanged(_ sender: UISegmentedControl) {
        ELGlobalConfig.default.options.scrollBarZPosition = sender.selectedSegmentIndex == 0 ? .front : .behind
    }

    @IBAction func onResetTapped(_ sender: UIButton) {
        ELGlobalConfig.default.reset()
        updateViewValue()
    }

}
