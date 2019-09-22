import MetalKit
import MuMetal
import Tr3

/// metal draw/scroll + CA Rule + colorize + render pipleline
public class SkyPipeline: NSObject, MTKViewDelegate {

    static let shared = SkyPipeline()

    var mtkView     : MTKView?              // MetalKit render view
    var mtlDevice   : MTLDevice?            // GPU to render
    var mtlCommand  : MTLCommandQueue?      // queue w/ command buffers
    var firstNode   : MetaNode?             // 1st node in renderer chain
    var cellNode    : MetaNode?             // 1st cellular automata node
    var nodes       = [String : MetaNode]() // find node by name
    var drawSize    = CGSize.zero           // size of render surface
    var settingup   = true                  // ignore swapping in new shaders
    var skyColor    : SkyColor!             // instance of subtree of sky.colorize
    var skyMainRun˚ : Tr3?                  // run the cellulary automata rules
    var skyMainRun  = true

    override init() {
        super.init()
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        skyColor = SkyColor(SkyTr3.shared.root)
        drawSize = CGSize(width: size.width * scale, height: size.height * scale)
        nodes = [:]

        skyMainRun˚ = SkyTr3.shared.root.findPath("sky.main.run")
        skyMainRun˚?.addClosure { tr3,_ in
            self.skyMainRun = tr3.BoolVal()
            self.cellNode?.isOn = self.skyMainRun
        }
    }

    func setMetalKitView(_ mtkView_: MTKView) {

        mtkView = mtkView_
        mtlDevice = mtkView?.device
        mtlCommand = mtlDevice?.makeCommandQueue()
    }

    func setupSkyPipeline() {
        let tr3Root = SkyTr3.shared.root
        if  let pipeline = tr3Root.findPath("sky.pipeline"),
            let firstChild = pipeline.children.first {

            var lastNode: MetaNode?
            let type = firstChild.StringVal() ?? "draw"
            let name = firstChild.name
            firstNode = addNodeName(name, after: nil, type: type)
            lastNode = firstNode

            for i in 1..<pipeline.children.count {
                let next = pipeline.children[i]
                let type = next.StringVal() ?? "compute"
                let name = next.name
                if let nextNode = addNodeName(name, after: lastNode, type: type) {
                    lastNode = nextNode
                    if type == "compute" {
                        cellNode = nextNode
                    }
                }
            }
            firstNode?.inNode = cellNode // feedback loop
            firstNode?.inTex = cellNode?.outTex
        }
        else {
            setupDefaultPipeline()
        }
    }
    /// Create linked list of MetaNode to render scene
    func setupDefaultPipeline() {

        // make first pipeline af draw, compute, colorize, render
        firstNode    = addNodeName("drawScroll", after: nil,       type: "draw")
        cellNode     = addNodeName("cellFader",  after: firstNode, type: "compute")
        let colorize = addNodeName("colorize",   after: cellNode,  type: "colorize")
        let _        = addNodeName("render",     after: colorize,  type: "render")
        firstNode?.inNode = cellNode // feedback loop
        firstNode?.inTex = cellNode?.outTex

        // firstNode?.printMetaNodes()
    }

    func addNodeName(_ name: String, after: MetaNode?, type: String) -> MetaNode? {

        if let node = nodes[name] {
            if let after = after {
                node.inNode = after
                node.inNode?.outNode = node
                node.type = type
            }
            return node
        }
        
        var node: MetaNode?
        switch type {
        case "draw":     node = MetaKernelDraw    (name, mtlDevice, drawSize, type, after, SkyDraw.shared.drawTouch)
        case "colorize": node = MetaKernelColorize(name, mtlDevice, drawSize, type, after, skyColor.getMix)
        case "render":   node = MetaKernelRender  (name, mtlDevice, drawSize, type, after, mtkView)
        default:         node = MetaKernelCompute (name, mtlDevice, drawSize, type, after)
        }
        if let node = node {
            nodes[name] = node
        }
        return node
    }

    func swap(inNode node: MetaNode) {
        if settingup { return }
        if let oldCellNode = cellNode {
            cellNode = oldCellNode.replace(with: node)
        }
    }

    /// Called whenever view changes orientation or is resized
    static var mtkViewIsFirstTime = true

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

        if size.width == 0 {
            return
        }

        drawSize = size // view.frame.size

        if SkyPipeline.mtkViewIsFirstTime {
            SkyPipeline.mtkViewIsFirstTime = false
            setupSkyPipeline()
        } else {
            //TODO: setup resize for all active MetaNodes
        }
    }

    // delegates--------------------------------------

    /// Called whenever the view needs to render a frame
    public func draw(in inView: MTKView) {

        // PrintMetalRenderer("-");

        if nodes.isEmpty { return } // nothing to draw yet

        settingup = false // done setting up

        if inView.currentRenderPassDescriptor == nil {
            print("*** SkyPipeline currentRenderPassDescriptor == nil ")
            return
        }

        if let command = mtlCommand?.makeCommandBuffer(),
            let firstNode = firstNode {
                command.label = "command"
                firstNode.goCommand(command)
        }
        else {
            print("*** SkyPipeline could not get either mtlCommand, makeCommandBuffer, or firstNode")
        }
    }

}
