
import QuartzCore
import UIKit
import Tr3
import MuUtilities

class SkyDraw: NSObject {

    static var shared = SkyDraw()

    var go˚: Tr3?
    var brushTilt˚: Tr3?
    var brushPress˚: Tr3?
    var brushSize˚: Tr3?

    var linePrev˚: Tr3?            // beginning of line
    var lineNext˚: Tr3?            // end of line
    var inForce˚: Tr3?             // pressure
    var inRadius˚: Tr3?            // finger radius
    var inAzimuth˚: Tr3?           // apple pencil

    var brushTilt = false          // via brushTilt˚
    var brushPress = true          // via brushPress˚
    var brushSize = CGFloat(1)     // via brushSize˚

    var linePrev = CGPoint.zero    // via linePrev˚
    var lineNext = CGPoint.zero    // via lineNext˚
    var inForce = CGFloat(0)       // via inForce˚
    var inRadius = CGFloat(0)      // via inRadius˚
    var inAzimuth = CGPoint.zero   // var inAzimuth˚

    var margin = CGSize.zero
    var fillValue = Float(0)

    override init() {
        super.init()
        // margin = ShaderView.shared.vertex.margin
    }

    func bindTr3(_ root: Tr3) {

        if  let sky = root.findPath("sky") ,
            let input = sky.findPath("input"),
            let brush = sky.findPath("draw.brush"),
            let line = sky.findPath("draw.line") {

            brushTilt˚ = input.findPath("tilt"); brushTilt˚?.addClosure { t,_ in self.brushTilt = t.BoolVal() }
            brushPress˚ = brush.findPath("press"); brushPress˚?.addClosure { t,_ in self.brushPress = t.BoolVal() }
            brushSize˚ = brush.findPath("size"); brushSize˚?.addClosure { t,_ in self.brushSize = t.CGFloatVal() ?? 1 }
            linePrev˚ = line.findPath("prev"); linePrev˚?.addClosure { t,_ in self.linePrev = t.CGPointVal() ?? .zero }
            lineNext˚ = line.findPath("next"); lineNext˚?.addClosure { t,_ in self.lineNext = t.CGPointVal() ?? .zero }

            inForce˚ = input.findPath("force"); inForce˚?.addClosure { t,_ in self.inForce = t.CGFloatVal() ?? 1 }
            inRadius˚ = input.findPath("radius"); inRadius˚?.addClosure { t,_ in self.inRadius = t.CGFloatVal() ?? 1 }
            inAzimuth˚ = input.findPath("azimuth"); inAzimuth˚?.addClosure { t,_ in self.inAzimuth = t.CGPointVal() ?? .zero }
        }
        else {
            print("*** could not find either sky, input, draw.brush, shape.line")
        }
    }

    public func update(_ item: TouchItem) -> CGFloat {

        // if using Apple Pencil and brush tilt is turned on
        if item.force > 0, brushTilt {
            let azi = CGPoint(x: -item.azimuth.dy, y: -item.azimuth.dx)
            inAzimuth˚?.setVal(azi, [.activate]) // will update local azimuth via Tr3Graph
        }
        
        // if brush press is turned on
        var radiusNow = CGFloat(1)
        if brushPress  {
            if inForce > 0 || item.azimuth.dx != 0.0 {
                inForce˚?.setVal(item.force, [.activate]) // will update local azimuth via Tr3Graph
                radiusNow = brushSize
            } else {
                inRadius˚?.setVal(item.radius,[.activate])
                radiusNow = inRadius
            }
        }
        else {
            radiusNow = brushSize
        }
        return radiusNow //PrintGesture("azimuth dXY(%.2f,%.2f)", item.azimuth.dx, item.azimuth.dy)
    }

    func drawPoint(_ point_: CGPoint,_ radius_: CGFloat) {

        let point = point_
        let norm = normalizedPoint(point)

        if brushPress {

            inRadius˚?.setVal(radius_,[.activate])
            brushSize˚?.setVal(radius_,[.activate])
        }
        linePrev˚?.setVal(norm, [.activate])
        lineNext˚?.setVal(norm, [.activate])
        go˚?.activate()
    }

    func drawPoint(_ point_: CGPoint,_ radius_: CGFloat,_ value: UInt32,_  buf: UnsafeMutablePointer<UInt32>,_ size: CGSize) {
        if point_ == .zero { return }

        let scale = UIScreen.main.scale
        let p = point_ * scale
        var radius = radius_ 

        if brushPress {

            inRadius˚?.setVal(radius,[])
            brushSize˚?.setVal(radius,[.activate]) // will update brushSize via closure
            radius = brushSize
        }

        let r = radius * 2.0 - 1
        let r2 = Int(r * r / 4.0)
        let xs = Int(size.width)
        let ys = Int(size.height)
        let px = Int(p.x)
        let py = Int(p.y)

        var x0 = Int(p.x - radius - 0.5)
        var y0 = Int(p.y - radius - 0.5)
        var x1 = Int(p.x + radius + 0.5)
        var y1 = Int(p.y + radius + 0.5)

        if x0 < 0 { x0 += xs }
        if y0 < 0 { y0 += ys }
        while x1 < x0 { x1 += xs }
        while y1 < y0 { y1 += ys }

        //??? print(String(format:"(%i,%i)-(%i,%i):%.f",x0,y0,x1,y1,radius))

        if radius == 1 {
            buf[y0 * xs + x0] = value
            return
        }
        
        for y in y0 ..< y1 {

            for x in x0 ..< x1  {

                let xd = (x - px) * (x - px)
                let yd = (y - py) * (y - py)

                if xd + yd < r2 {

                    let yy = (y+ys)%ys      // wrapped pixel y index
                    let xx = (x+xs)%xs      // wrapped pixel x index
                    let ii = yy * xs + xx   // final pixel x,y index into buffer

                    buf[ii] = value         // set the buffer to value
                }
            }
        }
    }

    func normalizedPoint(_ p: CGPoint) -> CGPoint {

        let bounds = UIScreen.main.bounds
        let size = bounds.size
        let h = size.height
        let w = size.width
        let XFactor = (1 - margin.width * 2)
        let YFactor = (1 - margin.height * 2)

        let delta = CGPoint(x:   p.y - h/2,
                            y: -(p.x - w/2))

        let n = CGPoint(x: 0.5 + delta.x / h * YFactor,
                        y: 0.5 + delta.y / w * XFactor)
        return n
    }


    /// either fill or draw inside texture
    ///
    /// - return: true if filled, false if drawn
    /// 
    func drawTouch(_ bytes: UnsafeMutablePointer<UInt32>, size: CGSize) -> Bool {

        let w = Int(size.width)
        let h = Int(size.height)

        if fillValue > 255 {
            let val = UInt32(fillValue)
            fillValue = -1
            for i in 0 ..< (w*h) {
                bytes[i] = val
            }
            return true
        }
        else if fillValue >= 0 {

            let v8 = UInt32(fillValue * 255)
            let val = v8 << 24 + v8 << 16 + v8 << 8 + v8
            fillValue = -1
            for i in 0 ..< (w*h) {
                bytes[i] = val
            }
            return true
        }
        else {

            SkyView.shared.flushFingersBuf { point,radius in
                self.drawPoint(point, radius, 127, bytes, size)
            }

            // copy boundaries for toroid

            // . corners are copyied twice
            // t0: T top edge replaced by b
            // t1: t top content copied to B
            // b0: B bottom edge replace by t
            // b1: b bottom content copied to T
            // l0: L left edge replaced by r
            // l1: l left content replaces R
            // r0: R right edge replaced by l
            // r1: r right content replaces L
            // --  c content remains unchanged
            //
            // .TTTTTTTTTTTTT.
            // LltttttttttttrR
            // LlcccccccccccrR
            // LlcccccccccccrR
            // LbbbbbbbbbbbbbR
            // .BBBBBBBBBBBBB.

            for y in 0 ..< h {

                let l0 = y * w          // left edge
                let l1 = l0+1           // left content to copy to right edge
                let r0 = l0 + w - 1     // right edge
                let r1 = r0 - 1         // right content to copy to left edg3

                bytes[l0] = bytes[r1]   // copy right content to left edge
                bytes[r0] = bytes[l1]   // copy left content to right edge
            }
            for x in 0 ..< w {
                
                let t0 = x              // top edge
                let t1 = t0 + w         // top content to copy to bottom edge
                let b0 = x + (h-1) * w  // bottom edge
                let b1 = b0 - w         // bottom content to copy to top edge

                bytes[t0] = bytes[b1]   // copy bottom content to top edge
                bytes[b0] = bytes[t1]   // copy top content to bottom edge
            }
        }
        return false // didn't fill
    }

}
