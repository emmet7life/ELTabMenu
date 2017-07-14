//
//  ViewController.swift
//  ELTabMenu
//
//  Created by 陈建立 on 7/14/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit

class ELTabMenuExampleViewController: UIViewController {

    @IBOutlet weak var tabMenu: ELTabMenu!
    @IBOutlet weak var contentView: UIView!

    fileprivate let pageController = ELPageContainerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 注意: TabMenu的配置参数options应该在设置tabTitles之前设置
//        tabMenu.options.debug = true
        let titles = ["综合", "动画", "漫画", "小说", "用户", "资讯"]
//        let titles = ["收藏", "历史"]

        // 1.手动配置示例
//        tabMenu.options.padding = 0.0
//        tabMenu.options.itemLayoutMode = .free
//        tabMenu.options.itemWidthMode = .dynamic
//        tabMenu.options.scrollBarWidthPercent = 0.7
//        tabMenu.options.scrollBarHeight = 4.5
//        tabMenu.options.bold = true
//        tabMenu.options.normalColor = UIColor.colorWithHexRGBA(hexValue: 0x999999)
//        tabMenu.options.selectedColor = UIColor.colorWithHexRGBA(hexValue: 0x333333)
//        tabMenu.options.scrollBarColor = UIColor.colorWithHexRGBA(hexValue: 0xFF707A)
//        tabMenu.options.scrollBarAlignPosition = .alignText
//        tabMenu.options.scrollBarPositionOffset = -0.5
//        tabMenu.options.scrollBarLeadingPosition = .left
//        tabMenu.options.scrollBarZPosition = .behind

        // 2.通过Setting Controller配置
//        tabMenu.options = ELGlobalConfig.default.options
        tabMenu.tabTitles = titles
        tabMenu.delegate = self

        // 添加Page
        addChildViewController(pageController)
        pageController.willMove(toParentViewController: self)
        contentView.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.delegate = self

        let leading = NSLayoutConstraint(item: pageController.view, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0)
        let trailing = NSLayoutConstraint(item: pageController.view, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: pageController.view, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: pageController.view, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0)
        contentView.addConstraints([leading, trailing, top, bottom])

        createPageControllerContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ELGlobalConfig.default.hasChanged {
            ELGlobalConfig.default.hasChanged = false
            let tabNum = ELGlobalConfig.default.tabNum
            let titles = ["综合频道", "动画", "漫画集", "小说", "用户群", "资讯·搞事情", "看图·美图天天看", "日常", "插画", "直播小🌶"].prefix(tabNum).map { $0 }
            tabMenu.options = ELGlobalConfig.default.options
            tabMenu.tabTitles = titles
            createPageControllerContent()
            tabMenu.contentView.setContentOffset(CGPoint.zero, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func createPageControllerContent() {
        var viewControllers = [UIViewController]()
        let colors = [UIColor.yellow, UIColor.purple, UIColor.green, UIColor.darkGray, UIColor.white]

        var preColorIndex: Int = 0

        for title in tabMenu.tabTitles {

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 30.0)
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.text = title

            // 保证随机出来的颜色与上一个Controller使用的颜色不一样
            var randomColorIndex = Int(arc4random_uniform(UInt32(colors.count)))
            while randomColorIndex == preColorIndex {
                randomColorIndex = Int(arc4random_uniform(UInt32(colors.count)))
            }

            let controller1 = UIViewController()
            controller1.view.backgroundColor = colors[randomColorIndex]
            controller1.view.addSubview(label)
            label.center = controller1.view.center
            viewControllers.append(controller1)

            preColorIndex = randomColorIndex

        }
        
        pageController.viewControllers = viewControllers
    }

}

extension ELTabMenuExampleViewController: ELPageContainerDelegate {

    func onPageContainerCurrentPageChanged(_ pageIndex: Int) {

    }

    func onPageContainerViewEndScroll(_ scrollView: UIScrollView) {
        tabMenu.scrollTabToCenter(pageController.selectedPageIndex)
    }

    func onPageContainerViewDidScroll(_ scrollView: UIScrollView) {
        tabMenu.contentOffset = scrollView.contentOffset
    }
    
}

extension ELTabMenuExampleViewController: ELTabMenuDelegate {
    func switchToTab(_ index: Int, disable: Bool) {
        pageController.setSelectedPageIndex(index, animated: true, disable: disable)
    }
}


