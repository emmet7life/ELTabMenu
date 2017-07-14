//
//  ELTabMenu.swift
//  SwiftKit
//
//  Created by 陈建立 on 4/20/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import Foundation
import UIKit

// MARK: 辅助工具类
public class ELTabMenuUtils {

    static let share = ELTabMenuUtils()

    fileprivate var displayLinkForTransition: CADisplayLink?
    fileprivate var _fromFloat: CGFloat = 0.0
    fileprivate var _toFloat: CGFloat = 0.0
    fileprivate var _markTransitionTimeStamp: CFTimeInterval = 0.0
    fileprivate var _transitionDuration: CFTimeInterval = 0.25

    typealias ELTabMenuTransitionCallback = (Bool, CGFloat) -> Void
    fileprivate var _callback: ELTabMenuTransitionCallback?

    fileprivate func transitionFloat(_ fromFloat: CGFloat, toFloat: CGFloat, progress: CGFloat) -> CGFloat {
        let t = progress
        let f = 1 - t
        return t * toFloat + f * fromFloat
    }

    func transition(_ fromFloat: CGFloat, toFloat: CGFloat, duration: CFTimeInterval = 0.25, callback: @escaping ELTabMenuTransitionCallback) {
        _fromFloat = fromFloat
        _toFloat = toFloat
        _transitionDuration = duration
        _callback = callback

        _markTransitionTimeStamp = CACurrentMediaTime()

        if displayLinkForTransition == nil {
            displayLinkForTransition = CADisplayLink.init(target: self, selector: #selector(updateTransition(_:)))
            displayLinkForTransition?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
    }

    @objc fileprivate func updateTransition(_ link: CADisplayLink) {
        var progress = _transitionDuration > 0 ? (link.timestamp - _markTransitionTimeStamp) / _transitionDuration : 1
        progress = max(0, min(1, progress))
        let transitioningFloat = transitionFloat(_fromFloat, toFloat: _toFloat, progress: CGFloat(progress))
        _callback?(progress >= 1, transitioningFloat)

        if (progress >= 1) {
            if displayLinkForTransition != nil {
                displayLinkForTransition?.invalidate()
                displayLinkForTransition = nil
            }
        }
    }

}

// Tab Item的宽度模式
public enum ELTabMenuItemWidthMode {
    case equal         // 等宽
    case dynamic    // 动态计算自身宽度
}

// 整体Tab Item的布局模式
public enum ELTabMenuItemLayoutMode {
    case free       // 从左到右自由布局
    case full       // 当所有Item的总宽度小于屏幕宽度时也让其平铺屏幕
}

// scrollBar滚动条对齐的对象是其父视图还是UIButton中的UILabel文本组件
public enum ELTabMenuScrollBarAlignPosition {
    case alignView // it`s superwiew
    case alignText // the UIButton`s UILabel`s Edge
}

// scrollBar滚动条的垂直向布局位置
// top:     顶部
// center: 中间
// bottom: 底部
public enum ELTabMenuScrollBarPosition {
    case top
    case center
    case bottom
}

// scrollBar滚动条的水平向布局位置
public enum ELTabMenuScrollBarLeadingPosition {
    case center
    case left
}

// scrollBar滚动条的z轴布局位置，是在所有Item前还是在所有Item后放置
public enum ELTabMenuScrollBarZAnchorPosition {
    case front
    case behind
}

public func == (lhs: ELTabMenuScrollBarPosition, rhs: ELTabMenuScrollBarPosition) -> Bool {
    switch (lhs, rhs) {
    case (.top, .top): return true
    case (.center, .center): return true
    case (.bottom, .bottom): return true
    default:  return false
    }
}

public struct ELTabMenuOptions {
    // common style
    var padding: CGFloat = 8.0
    var margin: CGFloat = 20.0
    var textFontSize: CGFloat = 16.0
    var bold = false

    // 布局时头尾Item是否也加上margin
    var edgeNeedMargin: Bool = true

    var normalColor = ELTabMenu.ELTabMenuConstant.kDefaultNormalColor
    var selectedColor = ELTabMenu.ELTabMenuConstant.kDefaultFocusColor

    var maxItemWidth: CGFloat = 0.0// 最大宽度限制
    var defaultItemIndex: Int = 0// 默认选中项索引

    var itemWidthMode: ELTabMenuItemWidthMode = .dynamic
    var itemLayoutMode: ELTabMenuItemLayoutMode = .full

    // scroll bar style
    var scrollBarAlpha: CGFloat = 1.0
    var scrollBarColor = ELTabMenu.ELTabMenuConstant.kDefaultFocusColor
    var scrollBarHeight = ELTabMenu.ELTabMenuConstant.kDefaultScrollBarHeight
    var scrollBarPosition: ELTabMenuScrollBarPosition = .bottom
    var scrollBarAlignPosition: ELTabMenuScrollBarAlignPosition = .alignView
    var scrollBarPositionOffset: CGFloat = 0.0// 偏移量
    var scrollBarLeadingPosition: ELTabMenuScrollBarLeadingPosition = .center
    var scrollBarZPosition: ELTabMenuScrollBarZAnchorPosition = .behind
    var scrollBarWidthPercent: CGFloat = 1.0 { // 滚动条占据整个Item宽度的百分比，默认与Item等宽
        didSet {
            autoAdjustScrollBarWidthPercent = false
        }
    }
    var autoAdjustScrollBarWidthPercent = true// 是否自动调整scrollBarWidthPercent，默认true

    // debug mode
    var debug = false
}

public protocol ELTabMenuDelegate: class {
    // 跨越多个Tab时，需要将disable参数设置为true
    func switchToTab(_ index: Int, disable: Bool)
}

// @IBDesignable
open class ELTabMenu: UIView {

    struct ELTabMenuConstant {
        static let kDefaultNormalColor = UIColor.colorWithHexRGBA(hexValue: 0x646464)
        static let kDefaultFocusColor = UIColor.colorWithHexRGBA(hexValue: 0x0091A4)
        static let kDefaultScrollBarHeight: CGFloat = 2.0
        static let kDefaultItemWidth: CGFloat = 100.0

        static var kScreenWidth: CGFloat {
            return UIScreen.main.bounds.width
        }
        static var kScreenHeight: CGFloat {
            return UIScreen.main.bounds.height
        }
    }

    // 各个Item的容器父视图
    fileprivate lazy var _contentView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.clear
        return scrollView
    }()

    // 滚动条指示器视图
    fileprivate lazy var _scrollBar: UIView = {
        let scrollBar = UIView()
        scrollBar.backgroundColor = self.options.scrollBarColor
        return scrollBar
    }()

    // TODO 开放视图属性给外部?
    public var contentView: UIScrollView {
        return _contentView
    }

    public var scrollBar: UIView {
        return _scrollBar
    }

    fileprivate var _tabItemViewArr = [UIView]()

    // Data
    fileprivate var _cacheItemWidths = [CGFloat]()
    fileprivate var _currentTabIndex: Int = 0
    fileprivate var _currentOffset = CGPoint.zero

    weak var delegate: ELTabMenuDelegate?

    var options: ELTabMenuOptions = ELTabMenuOptions()

    fileprivate var _titles = [String]()

    var tabTitles: [String] {
        get {
            return _titles
        }

        set {

            guard newValue.count >= 2 else {
                return
            }

            _titles = newValue

            var contentSize = CGSize.zero
            contentSize.height = _height

            // 缓存文本所占宽度
            var cacheTabTextWidths = [CGFloat]()

            // 1.先将所有Item所需的宽度计算一遍，并将结果缓存起来备用
            _cacheItemWidths.removeAll()
            for title in _titles {
                // TODO 这里需要算上padding吗 ??
                let width = measureSize(title).width + options.padding * 2.0
                _cacheItemWidths.append(width)
            }
            cacheTabTextWidths.append(contentsOf: _cacheItemWidths)

            // 2.判断是否配置了最大宽度
            let _max = _cacheItemWidths.max() ?? ELTabMenuConstant.kDefaultItemWidth
            let maxMeasureItemWidth: CGFloat = options.maxItemWidth > 0 ? min(options.maxItemWidth, _max) : _max

            // 3.处理之前缓存的Item宽度
            // 3.1 等宽模式时，所有Item的宽度都将是一致的，等于maxMeasureItemWidth
            // 3.2 动态模式时，item的宽度使用Item自身测量出的宽度值但不大于maxMeasureItemWidth
            _cacheItemWidths = _cacheItemWidths.map {
                switch options.itemWidthMode {
                case .equal:
                    return maxMeasureItemWidth
                case .dynamic:
                    return min(maxMeasureItemWidth, $0)
                }
            }

            // 4.当布局模式为平铺时，需要进一步判断总宽度是否仍然小于屏幕宽度，如果小，则需要将差值部分平分给各个Item

            // 4.1 计算时，需要把margin算上
            var marginNeedNum = _titles.count - 1
            marginNeedNum += (options.edgeNeedMargin ? 2 : 0)
            let sum = _cacheItemWidths.reduce(0, +) + CGFloat(marginNeedNum) * options.margin

            if sum < _width && options.itemLayoutMode == .full {
                let dis = (_width - sum) / CGFloat(_titles.count) // 剩余多少宽度值平分给每个Item
                _cacheItemWidths = _cacheItemWidths.map {
                    return $0 + dis
                }
            }

            // 5. 当Item数目小于等于3个时，并且布局模式是平铺时，如果某Item的文字数目很少，
            // 可能会造成scrollBar进度条的宽度(默认与Item宽度一致)远比文字宽度大的情况，造成界面不美观，因此这里需要额外处理
            if options.autoAdjustScrollBarWidthPercent && _titles.count <= 3 {
                // 纯文本在各个Tab所在Button中的占比
                var tempIndex: Int = 0
                let percents = cacheTabTextWidths.map { (element) -> CGFloat in
                    let percent = element / _cacheItemWidths[tempIndex]
                    tempIndex += 1
                    return percent
                }
                // 当最大占比小于等于0.8时，使用max
                if let max = percents.max(), max <= 0.8 {
                    // TODO 目前是每个Item的宽度都将统一乘以scrollBarWidthPercent得到最终的宽度
                    // 是否需要为每个Item单独计算一个scrollBarWidthPercent?，因为每个Item的占比可能是不一样的!
                    options.scrollBarWidthPercent = max
                }
            }

            // 横竖屏切换时，不提取数据，直接使用_currentTabIndex
            if _currentTabIndex == 0 {
                let initIndex = min(max(0, options.defaultItemIndex), _titles.count - 1)
                _currentTabIndex = initIndex
            }

            // 6. 重新设置内容时重置视图
            _contentView.subviews.forEach { $0.removeFromSuperview() }
            _tabItemViewArr.forEach { $0.removeFromSuperview() }
            _tabItemViewArr.removeAll()

            // 7. 开始布局
            // add scroll bar
            _scrollBar.alpha = options.scrollBarAlpha
            _contentView.addSubview(_scrollBar)

            var scrollBarY: CGFloat = 0
            switch options.scrollBarPosition {
            case .top:
                if options.scrollBarAlignPosition == .alignView {
                    scrollBarY = 0
                } else if options.scrollBarAlignPosition == .alignText {
                    let textHeight = firstTabItemCharacterMeasureSize().height
                    scrollBarY = (_height - textHeight) * 0.5
                }
            case .center:
                scrollBarY = (_height - options.scrollBarHeight) * 0.5
            case .bottom:
                if options.scrollBarAlignPosition == .alignView {
                    scrollBarY = _height - options.scrollBarHeight
                } else if options.scrollBarAlignPosition == .alignText {
                    let textHeight = firstTabItemCharacterMeasureSize().height
                    scrollBarY = (_height + textHeight) * 0.5 - options.scrollBarHeight
                }
            }
            scrollBarY += options.scrollBarPositionOffset * UIScreen.main.scale
            _scrollBar.frame = CGRect(x: scrollBar_x(_currentTabIndex), y: scrollBarY, width: scrollBar_width(_currentTabIndex), height: options.scrollBarHeight)

            // add tab item
            let lastIndex = _titles.count - 1
            var x: CGFloat = 0.0
            if options.edgeNeedMargin {
                x += options.margin
            }
            for text in _titles.enumerated() {
                let title = text.element
                let index = text.offset
                let width = _cacheItemWidths[index]

                let button = UIButton(type: .custom)
                button.tag = index
                button.addTarget(self, action: #selector(onItemTapped(_:)), for: .touchUpInside)
                button.titleLabel?.font = options.bold ? UIFont.boldSystemFont(ofSize: options.textFontSize) : UIFont.systemFont(ofSize: options.textFontSize)
                button.setTitle(title, for: UIControlState())
                button.setTitleColor(options.normalColor, for: UIControlState())
                button.setTitleColor(options.selectedColor, for: .selected)
                button.setTitleColor(options.selectedColor, for: .highlighted)
                button.frame = CGRect(x: x, y: 0, width: width, height: _height)
                _contentView.addSubview(button)
                _tabItemViewArr.append(button)

                button.isSelected = index == _currentTabIndex

                x += width
                contentSize.width = x
                if options.edgeNeedMargin && index == lastIndex {
                    contentSize.width += options.margin
                }
                x += options.margin

                if options.debug {
                    button.layer.borderColor = UIColor.darkGray.cgColor
                    button.layer.borderWidth = 0.5
                }
            }

            _contentView.contentSize = contentSize

            if options.scrollBarZPosition == .front {
                _contentView.bringSubview(toFront: _scrollBar)
            }

            layoutIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInitialize()
    }

    fileprivate func didInitialize() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(_contentView)
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        _contentView.frame = bounds
        // 横竖屏切换时，需要重新布局
        tabTitles = _titles
    }

    fileprivate var _width: CGFloat {
        return bounds.size.width
    }

    fileprivate var _height: CGFloat {
        return bounds.size.height
    }

    fileprivate var measureLabel: UILabel {
        let label = UILabel()
        label.font = options.bold ? UIFont.boldSystemFont(ofSize: options.textFontSize) : UIFont.systemFont(ofSize: options.textFontSize)
        return label
    }

    fileprivate func measureSize(_ text: String) -> CGSize {
        let label = measureLabel
        let size = CGSize(width: CGFloat(MAXFLOAT), height: _height)
        label.text = text
        return label.sizeThatFits(size)
    }

    fileprivate func firstTabItemCharacterMeasureSize() -> CGSize {
        return measureSize("\(_titles.first?.characters.first ?? "国")")
    }

    // Item的x坐标值
    fileprivate func item_x(_ index: Int) -> CGFloat {
        var marginNeedNum = index
        if options.edgeNeedMargin {
            marginNeedNum += 1
        }
        // 数组的prefix方法表示取出数组的前index个元素
        return _cacheItemWidths.prefix(index).reduce(0, +) + CGFloat(marginNeedNum) * options.margin
    }

    // Item对应的scrollBar滚动条的宽度
    fileprivate func scrollBar_width(_ index: Int) -> CGFloat {
        return _cacheItemWidths[validIndex(index)] * options.scrollBarWidthPercent
    }

    // Item对应的scrollBar滚动条的x坐标值
    fileprivate func scrollBar_x(_ index: Int) -> CGFloat {
        let itemX = item_x(index)
        switch options.scrollBarLeadingPosition {
        case .center:
            let itemWidth = _cacheItemWidths[validIndex(index)]
            return itemX + itemWidth * (1.0 - options.scrollBarWidthPercent) * 0.5
        case .left:
            return itemX
        }
    }

    @objc fileprivate func onItemTapped(_ any: AnyObject?) {
        guard let button = any as? UIButton else {
            return
        }
        let tabIndex = button.tag
        scrollToTab(tabIndex)
    }

    func scrollToTab(_ tabIndex: Int, animted: Bool = true) {
        //        guard _currentTabIndex != tabIndex else {
        //            return
        //        }

        if _currentTabIndex != tabIndex {
            delegate?.switchToTab(tabIndex, disable: abs(_currentTabIndex - tabIndex) > 1)
        }

        let toFloat = CGFloat(tabIndex) * ELTabMenuConstant.kScreenWidth
        if animted {
            // 利用CADisplayLink来模拟PageController的contentOffset的变化
            ELTabMenuUtils.share.transition(_currentOffset.x, toFloat: toFloat) {[weak self] (finished, offsetX) in
                self?.contentOffset = CGPoint(x: offsetX, y: 0)
                if finished {
                    // 结束啦！
                    self?.scrollTabToCenter(tabIndex)
                }
            }
        } else {
            contentOffset = CGPoint(x: toFloat, y: 0)
            scrollTabToCenter(tabIndex, animted: false)
        }
    }

    func scrollTabToCenter(_ tabIndex: Int, animted: Bool = true) {
        // 1.该目标Tab的坐标
        let tabFrame = _tabItemViewArr[tabIndex].frame
        let centerX = tabFrame.origin.x + tabFrame.width * 0.5
        var offsetX = centerX - _width * 0.5
        offsetX = min(max(0, _contentView.contentSize.width - _width), max(0, offsetX))
        _contentView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animted)
    }

    fileprivate func validIndex(_ index: Int) -> Int {
        return min(_titles.count - 1, max(index, 0))
    }

    var contentOffset: CGPoint = CGPoint.zero {
        didSet {
            // TODO 目前没有对只有一个Tab时的处理

            // 请保证至少需要两个Tab，不然下面的计算会出问题
            guard _titles.count >= 2 else {
                return
            }

            _currentOffset = contentOffset

            // 假定默认情况下，与之配对的PageController是全屏的
            let allPageContentWidth = CGFloat(_titles.count) * ELTabMenuConstant.kScreenWidth
            // offset的百分比
            let diffPercent = (contentOffset.x + 0.5) / (allPageContentWidth - ELTabMenuConstant.kScreenWidth)
            let multiplied = 1.0 / CGFloat(_titles.count - 1)
            // 根据offset计算当前在哪个Page上
            let currentTabIndex = Int(diffPercent / multiplied)
            _currentTabIndex = currentTabIndex
            //            __devlog("diffPercent \(diffPercent), multiplied \(multiplied), currentTabIndex \(currentTabIndex)")

            let multipiedOffset = multiplied * CGFloat(currentTabIndex)

            let diffMultipied = diffPercent - multipiedOffset
            let _percent = diffMultipied / multiplied
            //            __devlog("diffMultipied \(diffMultipied), _percent \(_percent)")

            let _diffXOffset = scrollBar_x(currentTabIndex + 1) - scrollBar_x(validIndex(currentTabIndex))
            let _diffWidthOffset = scrollBar_width(currentTabIndex + 1) - scrollBar_width(currentTabIndex)
            //            __devlog("_diffXOffset \(_diffXOffset), _diffWidthOffset \(_diffWidthOffset)")

            let scrollBarX = scrollBar_x(currentTabIndex)
            let scrollBarWidth = scrollBar_width(currentTabIndex)
            let targetX = scrollBarX + _diffXOffset * _percent
            let targetWidth = scrollBarWidth + _diffWidthOffset * _percent

            var frame = _scrollBar.frame
            frame.origin.x = targetX
            frame.size.width = targetWidth
            _scrollBar.frame = frame

            //            print("//////////////////////////////////////////////////////////////////////////")
            //            print("//////////////////////////////////////////////////////////////////////////")

            for element in _tabItemViewArr.enumerated() {
                let itemView = element.element
                let offset = element.offset
                
                if diffPercent >= multiplied * (CGFloat(offset - 1) + 0.5) && diffPercent <= multiplied * (CGFloat(offset) + 0.5) {
                    //                    print("offset is \(offset)")
                    (itemView as? UIButton)?.isSelected = true
                } else {
                    (itemView as? UIButton)?.isSelected = false
                }
                
            }
        }
    }
    
}
