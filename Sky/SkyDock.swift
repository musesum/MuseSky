//
//  SkyDock.swift
//  Tr3Sky
//
//  Created by warren on 9/9/19.
//  Copyright © 2019 Muse. All rights reserved.
//

import Foundation
import Tr3
import Tr3Thumb

class SkyDock {

    var thumbDock : ThumbDock!
    var tr3Root: Tr3!

    init(_ thumbDock_ : ThumbDock, _ tr3Root_ :Tr3) {

        thumbDock = thumbDock_
        tr3Root = tr3Root_

        if let panel = tr3Root.findPath("panel") {
            for child in panel.children {
                if child.name == "cell" || child.name == "shader" {
                    child.children.forEach { thumbDock.addTr3Child($0) }
                }
                else {
                    thumbDock.addTr3Child(child)
                }
            }
        }
        if let shader = tr3Root.findPath("sky.shader") {
            for child in shader.children {
                SkyMetal.shared.makeShader(for: child)
            }
        }

        // get dock dot order from script
        var reorderNames = [String]()
        var selectName = ""
        var selectIndex = 0
        var currentIndex = 0

        if let skyDot = tr3Root.findPath("sky.dock") {
            for child in skyDot.children {
                reorderNames.append(child.name)
                if child.CGFloatVal() ?? 0 > 0 {
                    selectIndex = currentIndex
                    selectName = child.name
                }
                currentIndex += 1
            }
            thumbDock.reorderDots(reorderNames)
            thumbDock.dotNow = thumbDock.dots[selectIndex]
        }
        else {
            reorderNames = ["fader", "average", "melt", "timetunnel", "zhabatinski", "slide", "fredkin", "brush", "colorize", "scroll", "tile", "speed"]
            thumbDock.reorderDots(reorderNames)
            thumbDock.dotNow = thumbDock.dots.first
        }

        //dock.printDotNames()
        thumbDock.reorderDots(reorderNames)
        thumbDock.arrangeDots()
        thumbDock.updatePanels()
        thumbDock.splashWithCompletion { }

        let panelName = "panel.cell.\(selectName).controls"
        let controls = tr3Root.findPath(panelName)
        controls?.findPath("ruleOn.value")?.setVal(1, [.activate])
        controls?.findPath("bitplane.value")?.setVal(0.30, [.activate])

    }
}
