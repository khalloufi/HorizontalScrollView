//
//  HorizontalScrollerView.swift
//  HorizontalScrollView
//
//  Created by issam on 15/10/2018.
//  Copyright © 2018 ZetaLearning Inc. All rights reserved.
//

import Cocoa
protocol HorizontalScrollerViewDataSource: class {
    // Ask the data source how many views it wants to present inside the horizontal scroller
    func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
    // Ask the data source to return the view that should appear at <index>
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> NSView
}

protocol HorizontalScrollerViewDelegate: class {
    // inform the delegate that the view at <index> has been selected
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int)
}
extension NSView{
    var center:CGPoint{
        get{
            let x = (self.frame.origin.x + self.frame.width) / 2.0
            let y = (self.frame.origin.y + self.frame.height) / 2.0
            return CGPoint(x: x, y: y)
        }
    }
}
class HorizontalScrollerView: NSView {
    weak var dataSource: HorizontalScrollerViewDataSource?
    weak var delegate: HorizontalScrollerViewDelegate?
    
    // 1
    private enum ViewConstants {
        static let Padding: CGFloat = 10
        static let Dimensions: CGFloat = 100
        static let Offset: CGFloat = 100
    }
    // 2
    private lazy var scroller:NSScrollView = {
        let view =  NSScrollView()
        view.hasHorizontalScroller = true
        return view
    }()
    
    // 3
    private lazy var contentViews:NSStackView = {
        let stack = NSStackView()
        stack.orientation = NSUserInterfaceLayoutOrientation.horizontal
        stack.alignment = NSLayoutConstraint.Attribute.centerY
        stack.spacing = ViewConstants.Padding
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScrollView()
    }
    
    func initializeScrollView() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollViewDidEnd(notification:)),
                                               name: NSScrollView.didEndLiveMagnifyNotification,
                                               object: nil)
        //1
        addSubview(scroller)
        //2
        scroller.translatesAutoresizingMaskIntoConstraints = false
        //3
        NSLayoutConstraint.activate([
            scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scroller.topAnchor.constraint(equalTo: self.topAnchor),
            scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        scroller.documentView = contentViews
        //2
        contentViews.translatesAutoresizingMaskIntoConstraints = false
        //3
        NSLayoutConstraint.activate([
            contentViews.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentViews.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentViews.topAnchor.constraint(equalTo: self.topAnchor),
            contentViews.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        //4
        let tapRecognizer = NSClickGestureRecognizer(target: self, action: #selector(scrollerClicked(gesture:)))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    func scrollToView(at index: Int, animated: Bool = true) {
        let centralView = contentViews.views[index]
        let targetCenter = centralView.center
        let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
        scroller.documentView?.scroll(CGPoint(x: targetOffsetX, y: 0))
        //scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
    }
    @objc func scrollerClicked(gesture: NSClickGestureRecognizer) {
        let location = gesture.location(in: scroller)
        guard let index = contentViews.views.index(where: { $0.frame.contains(location)}) else { return }
        delegate?.horizontalScrollerView(self, didSelectViewAt: index)
        scrollToView(at: index)
    }
    
    func view(at index :Int) -> NSView {
        return contentViews.views[index]
    }
    
    func reload() {
        // 1 - Check if there is a data source, if not there is nothing to load.
        guard let dataSource = dataSource else {
            return
        }
        
        //2 - Remove the old content views
        contentViews.views.forEach { $0.removeFromSuperview() }
        // 4 - Fetch and add the new views
        for index in (0..<dataSource.numberOfViews(in: self)){
            let view = dataSource.horizontalScrollerView(self, viewAt: index)
            contentViews.addArrangedSubview(view)
            contentViews.addConstraint(view.widthAnchor.constraint(equalToConstant: view.frame.width + ViewConstants.Padding))
        }
        // 7
        //scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
        //scroller.documentView?.setFrameSize(CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height))
        print("==>>>>==\(scroller.frame)")
    }
    
    private func centerCurrentView() {
        let centerRect = CGRect(
            origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
            size: CGSize(width: ViewConstants.Padding, height: bounds.height)
        )
        
        guard let selectedIndex = contentViews.subviews.index(where: { $0.frame.intersects(centerRect) })
            else { return }
        let centralView = contentViews.subviews[selectedIndex]
        let targetCenter = centralView.center
        let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
        scroller.documentView?.scroll(CGPoint(x: targetOffsetX, y: 0))
        //scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        delegate?.horizontalScrollerView(self, didSelectViewAt: selectedIndex)
    }
}
extension HorizontalScrollerView {
    @objc func scrollViewDidEnd(notification:Notification){
        print(notification)
        centerCurrentView()
    }
    /*func scrollViewDidEndDragging(_ scrollView: NSScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: NSScrollView) {
        centerCurrentView()
    }*/
}
