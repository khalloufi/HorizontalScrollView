//
//  ViewController.swift
//  HorizontalScrollView
//
//  Created by issam on 15/10/2018.
//  Copyright © 2018 ZetaLearning Inc. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var horizontalScrollerView: HorizontalScrollerView!
    private var currentAlbumIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalScrollerView.dataSource = self
        horizontalScrollerView.delegate = self
        horizontalScrollerView.reload()
        // Do any additional setup after loading the view.
    }
}
extension ViewController: HorizontalScrollerViewDataSource {
    func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
        return 10
    }
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 10 * (index + 1), height: 20))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.random.cgColor
        return view
    }
}
extension ViewController: HorizontalScrollerViewDelegate{
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int) {
        print("didSelectViewAt = \(index)")
    }
}
let colors: [NSColor] = [.blue, .red, .orange, .yellow, .brown, .black, .green, .purple, .gray, .cyan]

private extension NSColor {
    class var random: NSColor { return colors[Int(arc4random_uniform(UInt32(colors.count)))] }
}
