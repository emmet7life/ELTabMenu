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
