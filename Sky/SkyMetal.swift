
import UIKit
import Tr3
import MuMetal

class SkyMetal {
    
    static let shared = SkyMetal()

    var pipeline = SkyPipeline.shared


    /// translate Tr3 script into shader with uniforms
    ///
    ///     shader {
    ///         cellMelt {
    ///             type : "compute"
    ///             file : "cell.melt.metal"
    ///             on   : (0...1=0)
    ///             buffer {
    ///                 version:(0...1=0)  } }
    ///
    /// - Note: in the above example
    /// cellMelt refers to metal function `kernel void cellMelt(...)`
    /// declared inside the file `cell.melt.metal`.
    /// Currently, the metal file is statically linked. So, the filename is ignored.
    /// Later, will be able to compile the file at runtime, or possibly
    /// later, an option of embedding the script inside a .tr3 file
    /// 
    func makeShader(for tr3: Tr3) {

        func updateBuffer(_ node: MetaNode, tr3: Tr3) {

            switch tr3.val {
            case is Tr3ValTuple: tr3.addClosure { tr3,_ in
                node.updateBuffer(named: tr3.name, point: tr3.CGPointVal() ?? .zero)
            };  node.updateBuffer(named: tr3.name, point: tr3.CGPointVal() ?? .zero)

            case is Tr3ValScalar: tr3.addClosure { tr3,_ in
                node.updateBuffer(named: tr3.name, float: tr3.FloatVal() ?? .zero)
            };  node.updateBuffer(named: tr3.name, float: tr3.FloatVal() ?? .zero)

            default: break
            }
        }

        // begin ---------------------------------------------------------------

        if tr3.name.first == "_" { return } // ignore "_compute" base class
        if  let type = tr3.findPath("type")?.StringVal(),
            let node = pipeline.addNodeName(tr3.name, after: nil, type:type) {

            func addOn(_ child:Tr3) {
                node.isOn = child.BoolVal()
                child.addClosure { tr3,_ in
                    let nodes = self.pipeline.nodes
                    guard let parent = tr3.parent       else { return print("*** no parent" ) }
                    guard let node = nodes[parent.name] else { return print("*** no node for parent:\(parent.scriptLineage(2))" ) }
                    let isOn = tr3.BoolVal()
                    node.isOn = isOn

                    if isOn {
                        self.pipeline.swap(inNode: node)
                        self.pipeline.cellNode?.isOn = isOn
                    }
                    //print("*** tr3:\(tr3.scriptLineage(3)) isOn:\(isOn)")
                }
            }

            for child in tr3.children {
                switch child.name {
                case "buffer" : child.children.forEach { updateBuffer(node,tr3:$0) }
                case "file"   : node.filename = child.StringVal() ?? ""
                case "repeat" : node.repeats = child.IntVal() ?? 1
                case "on"     : addOn(child)
                case "type"   : break // already found, see above
                default: print("*** unknown shader:\(tr3.name) parameter: \(child.name)")
                }
            }
        }
    }
}
