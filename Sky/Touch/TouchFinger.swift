
//
//  SkyDraw
//  Sky
//
//  Created by warren on 2/5/19.
//  Copyright © 2019 Muse. All rights reserved.
//

import Foundation
import UIKit
import MuCubic

class TouchFinger: NSObject {

    var touchItems:[[TouchItem]] = [[TouchItem](),[TouchItem]()] // double buffer index == 0 or 1
    var lastItem: TouchItem? // allow last touch to repeat until isDone
    var quadXYR = QuadXYR()
    var touchNext = 0
    var isDone = false

    func cacheTouchItem(_ touchItem: TouchItem?) {
        if let touchItem = touchItem {
            touchItems[touchNext].append(touchItem)
        }
    }

    /// For each finger, iterate intermediate points, with closure to drawing routine
    ///
    func flushCacheBuf(_ closure: @escaping (CGPoint,CGFloat)->())  {

        touchNext = touchNext ^ 1 // switch double buffer
        let touchPrev = touchNext ^ 1 // flush what used to be nextBuffer
        let skyDraw = SkyDraw.shared

        func flushItem(_ item: TouchItem?) {
            
            if let item = item {

                let radius = skyDraw.update(item)

                let p = CGPoint(x: item.next.x, y: item.next.y)

                isDone = item.phase == .ended || item.phase == .cancelled

                quadXYR.addXYR(p, radius, isDone)
                quadXYR.iterate12(closure)
            }
        }
        // there is new movement of finger
        let count = touchItems[touchPrev].count
        if count > 0 {
            for item in touchItems[touchPrev] {
                flushItem(item)
            }
            lastItem = touchItems[touchPrev].last // last last movement for repeat
        }
        else if SkyView.shared.touchRepeat {  // finger is stationary
            flushItem(lastItem)                 // so maybe repeat last movement
        }
        touchItems[touchPrev].removeAll()
    }
}
