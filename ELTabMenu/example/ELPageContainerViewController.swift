//
//  ELPageContainerViewController.swift
//  VCComicCollector
//
//  Created by 陈建立 on 16/12/14.
//  Copyright © 2016年 VComic. All rights reserved.
//

import UIKit

@objc protocol ELPageContainerDelegate {
    func onPageContainerCurrentPageChanged(_ pageIndex: Int) -> Void
    func onPageContainerViewDidScroll(_ scrollView: UIScrollView) -> Void
    func onPageContainerViewEndScroll(_ scrollView: UIScrollView) -> Void
}

class ELPageContainerViewController: UIViewController {

    weak var delegate: ELPageContainerDelegate?

    fileprivate var _isStartScrollingAnimation = false
//    private var _isOffsetByAnimating = false
    var disableOffsetNotifyWhenIndexChanged = false// 改变selectedPageIndex时禁用掉offset的通知回调

    fileprivate var _selectedPageIndex: Int = 0
    var selectedPageIndex: Int {
        set {
            if _selectedPageIndex != newValue {
                setSelectedPageIndex(newValue)
            }
        }

        get {
            return _selectedPageIndex
        }
    }
    fileprivate var _prevSelectedPageIndex = 0

    fileprivate(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
//        view.scrollEnabled = false
        view.bounces = false
        view.alwaysBounceHorizontal = false
        view.alwaysBounceVertical = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    var viewControllers: [UIViewController] = [] {

        didSet {
            // 移除旧的
            for controller in oldValue {
                controller.willMove(toParentViewController: nil)
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
            }

            // 添加新的
            for controller in viewControllers {
                self.addChildViewController(controller)
                controller.willMove(toParentViewController: self)
                controller.view.frame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight)
                scrollView.addSubview(controller.view)
                controller.didMove(toParentViewController: self)
            }

            _selectedPageIndex = 0
            layoutSubviews()
        }
    }

    // 当前视图
    var visibleViewController: UIViewController? {
        if _selectedPageIndex < viewControllers.count {
            return viewControllers[_selectedPageIndex]
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        scrollView.delegate = self
//        scrollView.pagingEnabled = true
//        scrollView.showsHorizontalScrollIndicator = false

        view.addSubview(scrollView)
    }



    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }

    fileprivate var scrollViewWidth: CGFloat {
        return scrollView.bounds.width
    }

    fileprivate var scrollViewHeight: CGFloat {
        return scrollView.bounds.height
    }

    @objc fileprivate func layoutSubviews(_ animated: Bool = false) {
        var x: CGFloat = 0.0
        let frameWidth = scrollViewWidth
        let frameHeight = scrollViewHeight
        for controller in viewControllers {
            controller.view.frame = CGRect(x: x, y: 0, width: frameWidth, height: frameHeight)
            x += frameWidth
        }
        scrollView.contentSize = CGSize(width: x, height: frameHeight)
        scrollView.setContentOffset(CGPoint(x: CGFloat(selectedPageIndex) * scrollViewWidth, y: 0), animated: animated)
        scrollView.isUserInteractionEnabled = true
    }

    func setSelectedPageIndex(_ selectedIndex: Int, animated: Bool = true, disable: Bool = false) {
        guard selectedPageIndex != selectedIndex else {
            return
        }
        _isStartScrollingAnimation = animated
        _prevSelectedPageIndex = selectedPageIndex
        // TODO: fix 走A会造成VCNavBarSwitchView的ScrollBar滚动条的跳闪，暂时关闭
        disableOffsetNotifyWhenIndexChanged = disable
        if !disableOffsetNotifyWhenIndexChanged {// 禁用时，走A方案
            _selectedPageIndex = selectedIndex
        }
        if abs(selectedPageIndex - selectedIndex) <= 1 {
            // A
            _selectedPageIndex = selectedIndex
            scrollView.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * scrollViewWidth, y: 0), animated: animated)
        } else {
            // B
            scrollView.isUserInteractionEnabled = false
            let scrollToRight = selectedIndex > selectedPageIndex
            let leftController = viewControllers[max(0, min(selectedPageIndex, selectedIndex))]
            let rightController = viewControllers[max(0, max(selectedPageIndex, selectedIndex))]
            leftController.view.frame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            rightController.view.frame = CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollView.contentSize = CGSize(width: 2.0 * scrollViewWidth, height: scrollViewHeight)

            _selectedPageIndex = selectedIndex
            if scrollToRight {
                scrollView.contentOffset = CGPoint.zero
                scrollView.setContentOffset(CGPoint(x: scrollViewWidth, y: 0), animated: animated)
            } else {
                scrollView.contentOffset = CGPoint(x: scrollViewWidth, y: 0)
                scrollView.setContentOffset(CGPoint.zero, animated: animated)
            }
        }
    }

}

extension ELPageContainerViewController: UIScrollViewDelegate {


    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let selectedPageIndex = Int(scrollView.contentOffset.x / scrollViewWidth)
        if selectedPageIndex != _selectedPageIndex {
            // 如果需要界面统计功能，可以在这里调用对应的方法
//            viewControllers[_selectedPageIndex].trackPageEnd()
//            viewControllers[selectedPageIndex].trackPageBegin()
            _selectedPageIndex = selectedPageIndex
        }

        delegate?.onPageContainerViewEndScroll(scrollView)
        delegate?.onPageContainerCurrentPageChanged(selectedPageIndex)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if _isStartScrollingAnimation {
            layoutSubviews(false)
            _isStartScrollingAnimation = false
        }

        if disableOffsetNotifyWhenIndexChanged {
            disableOffsetNotifyWhenIndexChanged = false
        }

        if _prevSelectedPageIndex != selectedPageIndex {
            // 如果需要界面统计功能，可以在这里调用对应的方法
//            viewControllers[_prevSelectedPageIndex].trackPageEnd()
//            viewControllers[selectedPageIndex].trackPageBegin()
        }

        delegate?.onPageContainerViewEndScroll(scrollView)
        delegate?.onPageContainerCurrentPageChanged(_selectedPageIndex)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _isStartScrollingAnimation && disableOffsetNotifyWhenIndexChanged {
            // Ignore...
        } else {
            delegate?.onPageContainerViewDidScroll(scrollView)
        }
    }

}
