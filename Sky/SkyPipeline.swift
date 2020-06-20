import MetalKit
import MuMetal
import Tr3

import Compression
import ZIPFoundation

/// metal draw/scroll + CA Rule + colorize + render pipleline
public class SkyPipeline: NSObject, MTKViewDelegate {

    static let shared = SkyPipeline()

    var mtkView: MTKView?             // MetalKit render view
    var mtlDevice: MTLDevice?         // GPU to render
    var mtlCommand: MTLCommandQueue?  // queue w/ command buffers

    var firstNode: MetaNode?    // 1st node in renderer chain
    var drawNode: MetaNode?     // drawing node, optional 1st node
    var cellNode: MetaNode?     // 1st CA node, after drawNode / cameraNode
    var colorNode: MetaNode?    // colorized palette
    var recordNode: MetaNode?   // record text to m4v
    var renderNode: MetaNode?   // record to screen
    var cameraNode: MetaNode?   // camera input node - always first firstNode
    var camixNode: MetaNode?    // camera mix node is before renderNode

    var nodeNamed = [String: MetaNode]() // find node by name
    var drawSize = CGSize.zero  // size of render surface
    var settingup = true        // ignore swapping in new shaders
    var skyColor: SkyColor!     // instance of subtree of sky.colorize
    var skyMainRun˚ : Tr3?      // run the cellulary automata rules
    var skyMainRun = true

    override init() {
        super.init()
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        skyColor = SkyColor(SkyTr3.shared.root)
        drawSize = CGSize(width: size.width * scale, height: size.height * scale)
        nodeNamed = [:]

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

    func scriptPipeline() -> String {
        var str = ""
        var del = "["

        var node = firstNode
        while node != nil {
            str += del + node!.name + ":" + node!.type
            del = ", "
            node = node!.outNode
        }
        str += "]"
        return str
    }

    func removeNode(_ node: MetaNode) {
        node.inNode?.outNode = node.outNode
        node.outNode?.inNode = node.inNode
    }

    /// create pipeline from script or snapshot
    func setupSkyPipeline() {

        camixNode = nil

        func fixupNodes() {
            if  let camixNode = camixNode,
                let renderNode = renderNode {

                removeNode(camixNode)
                renderNode.insertNode(camixNode, .above)
            }
            firstNode?.inNode = cellNode // feedback loop
            firstNode?.inTex = cellNode?.outTex
        }

        let tr3Root = SkyTr3.shared.root
        if  let pipeline = tr3Root.findPath("sky.pipeline"),
            let firstChild = pipeline.children.first {

            var lastNode: MetaNode?
            let type = firstChild.StringVal() ?? "draw"
            let name = firstChild.name
            firstNode = addNodeName(name, after: nil, type: type)
            guard let firstNode = firstNode else { return }
            lastNode = firstNode

            for i in 1 ..< pipeline.children.count {

                let next = pipeline.children[i]
                let type = next.StringVal() ?? "compute"
                let name = next.name
                if let nextNode = addNodeName(name, after: lastNode, type: type) {
                    lastNode = nextNode
                    switch type {
                        case "compute": cellNode = nextNode
                        case "record": recordNode = nextNode
                        case "render": renderNode = nextNode
                        case "camera": cameraNode = nextNode
                        case "camix": camixNode = nextNode
                        default: break
                    }
                }
            }
            fixupNodes()
            print("*** pipeline: " + scriptPipeline())
        }
        else {
            setupDefaultPipeline()
        }
    }

    // snapshot on framebuffer, drawTexture and skyGraph
    func saveSnapshot(_ name: String, _ completion:@escaping (()->())) {

        let time = trunc(Date().timeIntervalSince1970)
        let archive = MuArchive(name + ".\(time).zip")

        func renderSnapshot() {
            if let renderNode = nodeNamed["render"] as? MetaKernelRender,
                let renderTex = renderNode.renderedTex,
                let image = renderTex.toImage() {
                let uiImage = UIImage(cgImage: image).rotatedIcon(128)
                if let data = uiImage?.pngData() {
                    archive.add(name + ".png", data: data)
                }
            }
        }

        func drawSnapshot() {
            if  let drawNode = nodeNamed["drawScroll"] as? MetaKernelDraw,
                let drawTex = drawNode.outTex {

                let (bytes,_,totalSize) = drawTex.bytes()
                let data = Data.init(bytes: bytes, count: totalSize)
                archive.add(name + ".tex", data: data)
            }
        }

        func tr3Snapshot() {
            let script = SkyTr3.shared.root.makeScript(0, pretty: false)
            let data = Data(script.utf8)
            archive.add(name + ".tr3", data: data)
        }

        // save state on frameBufferOnly
        let frameBufferOnlyPrior = mtkView?.framebufferOnly ?? true
        mtkView?.framebufferOnly = false

        renderSnapshot()  // take an image snapshot of framebuffer
        drawSnapshot()    // take a texture snapshot of drawKernel

        // restore state for frameBufferOnly
        mtkView?.framebufferOnly = frameBufferOnlyPrior

        // snapshot of Sky Graph
        tr3Snapshot()
        completion()
    }


    /// Create linked list of MetaNode to render scene
    func setupDefaultPipeline() {

        // make first pipeline af draw, compute, colorize, render
        drawNode = addNodeName("drawScroll", after: nil,         type: "draw")
        cellNode = addNodeName("cellFader",  after: drawNode,    type: "compute")
        colorNode = addNodeName("colorize",  after: cellNode,    type: "colorize")
        recordNode = addNodeName("record",   after: colorNode,   type: "record" )
        renderNode = addNodeName("render",   after: recordNode,  type: "render")

        firstNode = drawNode
        firstNode?.inNode = cellNode // feedback cell back into firstNode
        firstNode?.inTex = cellNode?.outTex

        // firstNode?.printMetaNodes()
    }

    /// setup new node during shader startup or via pipeline
    func initNodeName(_ name: String,
                      _ type: String)  -> MetaNode? {

        var node = nodeNamed[name]
        if node == nil {
            switch type {
                case "camera":   node = MetaKernelCamera(name, mtlDevice, drawSize, type)
                case "draw":     node = MetaKernelDraw(name, mtlDevice, drawSize, type, SkyDraw.shared.drawTouch)
                case "compute":  node = MetaKernelCompute(name, mtlDevice, drawSize, type)
                case "colorize": node = MetaKernelColorize(name, mtlDevice, drawSize, type, skyColor.getMix)
                case "camix":    node = MetaKernelCamix(name, mtlDevice, drawSize, type)
                case "render":   node = MetaKernelRender (name, mtlDevice, drawSize, type, mtkView)
                case "record":   node = MetaKernelRecord(name, mtlDevice, drawSize, type)
                default:         node = MetaKernelCompute(name, mtlDevice, drawSize, type)
            }
            nodeNamed[name] = node
        }
        node?.type = type
        return node
    }


    /// setup new node during shader startup or via pipeline
    func addNodeName(_ name: String,
                     after: MetaNode?,
                     type: String)  -> MetaNode? {

        func addCameraToPipeline(_ node: MetaNode) {
            // !! cameraNode?.removeFromPipeline()
            cameraNode = node
            if let cameraNode = cameraNode,
                firstNode == drawNode {
                cameraNode.insert(before: drawNode)
                firstNode = cameraNode
            }
        }
        func addDrawToPipeline(_ node: MetaNode) {
            // !! drawNode?.removeFromPipeline()
            drawNode = node
            firstNode = firstNode ?? drawNode
        }
        func addComputeToPipeline(_ node: MetaNode) {
            // !! cellNode?.removeFromPipeline()
            cellNode = node
            if let drawNode = drawNode {
                cellNode?.insert(after: after)
                // CA double universe feedback loop
                drawNode.inNode = node
                drawNode.inTex = node.outTex
            }
        }

        // begin -------------------------

        if let node = nodeNamed[name] ?? initNodeName(name, type) {
            
            //if after != nil {

                switch type {
                    case "camera":   addCameraToPipeline(node)
                    case "draw":     addDrawToPipeline(node)
                    case "compute":  addComputeToPipeline(node)
                    case "colorize": colorNode = node.insert(after: after)
                    case "camix":    camixNode = node.insert(after: after)
                    case "render":   renderNode = node.insert(after: after)
                    case "record":   recordNode = node.insert(after: after)
                    default:         node.insert(after: after)
                }
            //}
            return node
        }
        return nil
    }

    /// called from SkyMetal:: makeShader.updateBuffer.addOn
    func swap(inNode node: MetaNode) {
        
        if settingup { return } // don't swap while setting up pipeline

        switch node.type {
            case "camera": cameraNode = drawNode?.insertNode(node, .above)
            case "camix":  camixNode = renderNode?.insertNode(node, .above)
            default:       cellNode = cellNode?.replace(with: node)
        }
        print("*** pipeline: " + scriptPipeline())
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

        if nodeNamed.isEmpty { return } // nothing to draw yet

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
