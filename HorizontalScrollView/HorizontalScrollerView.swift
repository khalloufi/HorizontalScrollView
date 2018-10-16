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
    @IBOutlet weak var container: NSView!
    @IBOutlet weak var stack: NSStackView!
    @IBOutlet weak var scroll: NSScrollView!
    weak var dataSource: HorizontalScrollerViewDataSource?
    weak var delegate: HorizontalScrollerViewDelegate?
    // 1
    private enum ViewConstants {
        static let Padding: CGFloat = 10
        static let Dimensions: CGFloat = 100
        static let Offset: CGFloat = 100
    }
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
        Bundle.main.loadNibNamed("HorizontalScrollerView", owner: self, topLevelObjects: nil)
        addSubview(container)
        container.frame = self.bounds
        container.autoresizingMask = [NSView.AutoresizingMask.height, NSView.AutoresizingMask.width]

        stack.spacing = ViewConstants.Padding
        let tapRecognizer = NSClickGestureRecognizer(target: self, action: #selector(itemClicked(gesture:)))
        stack.addGestureRecognizer(tapRecognizer)
    }
    @objc func itemClicked(gesture: NSClickGestureRecognizer) {
        let location = gesture.location(in: stack)
        guard let index = stack.views.index(where: { $0.frame.contains(location)}) else { return }
        delegate?.horizontalScrollerView(self, didSelectViewAt: index)
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
        stack.views.forEach { $0.removeFromSuperview() }
        // 4 - Fetch and add the new views
        for index in (0..<dataSource.numberOfViews(in: self)){
            let view = dataSource.horizontalScrollerView(self, viewAt: index)
            stack.addArrangedSubview(view)
            stack.addConstraint(view.widthAnchor.constraint(equalToConstant: view.frame.width + ViewConstants.Padding))
        }
    }
}
extension NSClipView{
    open override var isFlipped: Bool{
        get{
           return true
        }
    }
}
