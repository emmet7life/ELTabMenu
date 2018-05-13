# ELTabMenu
An iOS tab menu that can customize with various options.(iOS平台下多样化、可定制的菜单组件)

```swift
tabMenu.options.padding = 0.0 // 菜单项文本左右的内边距大小

tabMenu.options.itemLayoutMode = .free // 菜单项的布局方式，是随自身宽度布局还是铺满全屏

tabMenu.options.scrollBarWidthPercent = 0.7 // 滚动条宽度比例，默认跟随每个菜单项的宽度

tabMenu.options.scrollBarHeight = 4.5 // 滚动条的高度

tabMenu.options.bold = true // 菜单项文本字样样式是否加粗

tabMenu.options.normalColor = UIColor.colorWithHexRGBA(hexValue: 0x999999) // 菜单项未选中时文本的颜色

tabMenu.options.selectedColor = UIColor.colorWithHexRGBA(hexValue: 0x333333) // 菜单项被选中时文本的颜色

tabMenu.options.scrollBarColor = UIColor.colorWithHexRGBA(hexValue: 0xFF707A) // 滚动条的背景色

tabMenu.options.scrollBarAlignPosition = .alignText // scrollBar滚动条对齐的对象是其父视图还是UIButton中的UILabel文本组件

tabMenu.options.scrollBarPositionOffset = -0.5 // 滚动条位置偏移量

tabMenu.options.scrollBarLeadingPosition = .left // scrollBar滚动条的水平向布局位置

// 更多配置参数可查看源码，都已详细注释
```

<p>
<img src="https://github.com/emmet7life/ELTabMenu/blob/master/screenshot/demo1.png" />
</p>

<p>
<img src="https://github.com/emmet7life/ELTabMenu/blob/master/screenshot/demo2.png" />
</p>
<p>
<img src="https://github.com/emmet7life/ELTabMenu/blob/master/screenshot/demo3.png" />
</p>
<p>
<img src="https://github.com/emmet7life/ELTabMenu/blob/master/screenshot/demo4.png" />
</p>

```swift
        // 【关注-热门】菜单项配置
        fileprivate lazy var _tabMenu: ELTabMenu = ELTabMenu(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        ...
        ...
        var options = ELTabMenuOptions()
    
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.colorWithHexRGBA(0xFF4D6A)
        backgroundView.layer.cornerRadius = _tabMenu.height * 0.5
        backgroundView.layer.masksToBounds = true
        
        let scrollBarHeight: CGFloat = _tabMenu.height - 2.0
        let scrollIndicatorView = UIView()
        scrollIndicatorView.backgroundColor = .white
        scrollIndicatorView.layer.cornerRadius = scrollBarHeight * 0.5
        scrollIndicatorView.layer.masksToBounds = true
        
        options.margin = 1
        options.padding = 5
        options.normalColor = .white
        options.backgroundView = backgroundView
        options.scrollIndicatorView = scrollIndicatorView
        options.scrollBarHeight = CGFloat(scrollBarHeight)
        options.scrollBarPositionOffset = -1.0
        options.edgeNeedMargin = true
        options.defaultItemIndex = VCLoginManager.shared.isLogined ? 0 : 1
        options.isScrollBarAutoScrollWithOffsetChanged = false
        
        _tabMenu.options = options
        _tabMenu.isExclusiveTouch = true
        _tabMenu.tabTitles = ["关注", "热门"]
        
        
        // 【追番-博主】菜单项配置
        fileprivate lazy var _tabMenu: ELTabMenu = {
            let menu = ELTabMenu()
            menu.backgroundColor = .white
            menu.options.padding = 0.0
            menu.options.scrollBarWidthPercent = 0.1
            menu.options.scrollBarHeight = 3
            menu.options.scrollBarAlignPosition = .alignText
            menu.options.scrollBarPositionOffset = 5.0
            menu.options.scrollBarPosition = .bottom
            menu.options.scrollBarLeadingPosition = .center
            menu.options.edgeNeedMargin = false
            menu.options.isShowSeperatorView = false
            menu.options.pointOffset = CGPoint(x: -4, y: 0)
            menu.options.normalColor = UIColor.colorWithHexRGBA(0x999999)
            menu.options.selectedColor = UIColor.colorWithHexRGBA(0xFF4C6A)
            menu.tabTitles = ["追番", "博主"]
            return menu
        }()
```
<p>
<img src="https://github.com/emmet7life/ELTabMenu/blob/master/screenshot/关注-热门&追番-博主，均使用本控件实现.jpg" />
</p>
