
import UIKit

class TouchItem: NSObject {

    var prev    = CGPoint.zero
    var next    = CGPoint.zero
    var time    = TimeInterval(0)
    var radius  = CGFloat(0)
    var force   = CGFloat(0)
    var azimuth = CGVector.zero
    var phase: UITouch.Phase!

    init(_ prev_: CGPoint,
         _ next_: CGPoint,
         _ time_: TimeInterval,
         _ radius_: CGFloat,
         _ force_: CGFloat,
         _ azimuth_: CGVector,
         _ phase_: UITouch.Phase) {

        super.init()

        //??? print(String(format:"prev:(%.f,%.f) next:(%.f,%.f) radius:%.1f force:%.3f", prev_.x,prev_.y, next_.x,next_.y,  radius_, force_))

        prev = prev_
        next = next_
        time = time_
        radius = radius_
        force = force_
        azimuth = azimuth_
        phase = phase_
    }
}
