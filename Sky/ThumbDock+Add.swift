
import Tr3
import Tr3Metal
import UIKit

extension ThumbDock {

    func addTr3Child(_ tr3: Tr3) {
        if tr3.name.first == "_" { return }

        let panel = ThumbPanel(SkyView, tr3:tr3)
        
        // already added child
        if let _ = dotNames[tr3.name] { return }

        if  let base = tr3.findPath("base"),
            let type = base.findPath("type")?.StringVal(),
            let icon = base.findPath("icon")?.StringVal() {

            let dot = ThumbDot(self,tr3.name, type, icon, panel, nil)

            dots.append(dot)
            superview?.addSubview(dot)
            dotNames[tr3.name] = dot
            panel.thumbDot = dot
        }
        else {
            print("*** \(tr3.scriptLineage(3)) could not find either `base`, `type`, or `icon`")
        }
    }

    func addSkyRoot(_ skyRoot:Tr3) {

        if let panel = skyRoot.findPath("panel") {
            for child in panel.children {
                if child.name == "cell" || child.name == "shader" {
                    child.children.forEach { addTr3Child($0) }
                }
                else {
                    addTr3Child(child)
                }
            }
        }
        if let shader = skyRoot.findPath("sky.shader") {
            for child in shader.children {
                MetalTr3.shared.makeShader(for: child)
            }
        }
        dotNow = dots.first
    }

    func splashWithCompletion(completion: (()->())?) {

        OrienteDevice.shared.orientationChanged(nil)
        if let cursor = cursor {

            let cursorSize = cursor.frame.size
            let screenSize = UIScreen.main.bounds.size
            let deltaCenter = (screenSize - cursorSize) / 2

            let startFrame = CGRect(x: deltaCenter.width,
                                    y: deltaCenter.height,
                                    width: cursorSize.width,
                                    height: cursorSize.height)

            superview?.bringSubviewToFront(self)

            cursor.frame = startFrame
        }
        dots.forEach { $0.alpha = 0 }
        dotRing.alpha = 0

        func recenterDots() {
            if let cursor = cursor {
                dots.forEach { $0.center = cursor.center }
                dotRing.center = cursor.center
                
                UIView.animate(withDuration: AnimDuration, delay: 0, options: AnimUser, animations:
                { self.dots.forEach { $0.alpha = 1 } }) { _ in completion?() }
            }
        }
        
        UIView.animate(withDuration: AnimDuration, delay: 0, options:AnimUser,
                       animations: { self.cursor?.center = self.cursorCenter }) { _ in recenterDots() }
    }

}
