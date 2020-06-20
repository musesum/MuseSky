
import UIKit

class TouchItem: NSObject {

    var prev = CGPoint.zero
    var next = CGPoint.zero
    var time = TimeInterval(0)
    var radius = CGFloat(0)
    var force = CGFloat(0)
    var azimuth = CGVector.zero
    var phase: UITouch.Phase!

    init(_ prev: CGPoint,
         _ next: CGPoint,
         _ time: TimeInterval,
         _ radius: CGFloat,
         _ force: CGFloat,
         _ azimuth: CGVector,
         _ phase: UITouch.Phase) {

        super.init()

        //??? print(String(format:"prev:(%.f,%.f) next:(%.f,%.f) radius:%.1f force:%.3f", prev_.x,prev_.y, next_.x,next_.y,  radius_, force_))

        self.prev = prev
        self.next = next
        self.time = time
        self.radius = radius
        self.force = force
        self.azimuth = azimuth
        self.phase = phase
    }
}
