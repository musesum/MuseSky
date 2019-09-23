
/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of our cross-platform view controller
*/

import MetalKit
import UIKit
import Par
import Tr3
import Tr3Thumb

class SkyVC: UIViewController {

    static var shared: SkyVC!

    private var pipeline: SkyPipeline!
    var device: MTLDevice!
    var mtkView: MTKView!

    override func viewDidLoad() {

        super.viewDidLoad()
        SkyVC.shared = self
        // Set the view to use the default device
        mtkView = MTKView()
        if mtkView == nil { print("*** MetalKit view is unavailable") ; return }

        mtkView.device = MTLCreateSystemDefaultDevice()
        if mtkView.device == nil  {  print("*** Metal is not supported on this device") ; return }

        mtkView.frame = view.frame
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        mtkView.framebufferOnly = false
        view = mtkView
        
        pipeline = SkyPipeline.shared
        pipeline.setMetalKitView(mtkView)
        pipeline.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = pipeline
        setNeedsUpdateOfHomeIndicatorAutoHidden()

        // add dock
        let skyView = SkyView.shared
        let thumbDock = ThumbDock(skyView)
        let tr3Root = SkyTr3.shared.root
        let _ = SkyDock(thumbDock, tr3Root)
        view.addSubview(skyView)
        SkyDraw.shared.initTr3(tr3Root)
        let _ = SkyMain.shared
    }


    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return UIInterfaceOrientationMask.portrait
            }
            else {
                return UIInterfaceOrientationMask.landscape
            }
        }
    }
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        get {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return UIInterfaceOrientation.portrait
            }
            else {
                return UIInterfaceOrientation.landscapeRight
            }
        }
    }
    override var shouldAutorotate: Bool { false }
    override var prefersHomeIndicatorAutoHidden: Bool { return true }
    override var prefersStatusBarHidden: Bool { return true }
}
