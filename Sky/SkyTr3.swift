import UIKit
import Tr3

class SkyTr3: NSObject {
    
    static let shared = SkyTr3()
    
    let root = Tr3("√")
    var screenFillZero˚: Tr3?
    var screenFillOne˚: Tr3?
    var touchRepeat˚: Tr3?
    var scrolling˚: Tr3?
    var skySize = CGSize(width: 1920, height: 1080)
    
    override init() {
        
        super.init()
        parseScripts()
        initScreenFill()
    }

    /// fill screen callback to clear universe
    
    func initScreenFill() {

        func fillDraw(_ value: Float?) {
            if let value = value {
                SkyDraw.shared.fillValue = value
            }
        }
        if let sky = root.findPath("sky") {
        
            screenFillZero˚ = sky.findPath("draw.screen.fillZero")
            screenFillOne˚  = sky.findPath("draw.screen.fillOne")

            screenFillZero˚?.addClosure { tr3,_ in fillDraw(tr3.FloatVal()) }
            screenFillOne˚? .addClosure { tr3,_ in fillDraw(tr3.FloatVal()) }
            
            scrolling˚ = sky.findPath("sky.shader.drawScroll.buffer.scroll")
            scrolling˚?.addClosure { tr3,_ in
                if let p = tr3.CGPointVal() {
                    let touchRepeat = abs(p.x - 0.5) > 0.001 || abs(p.y - 0.5) > 0.001
                    SkyView.shared.touchRepeat = touchRepeat
                }
            }
        }
        else {
            print("*** missing path: '√.sky'")
        }
    }
    func parseScripts() {

        let archive = MuArchive("Snapshot.zip", readOnly: true)
        var script : String!
        archive.get("Snapshot.tr3") { data in
            script = String(data: data, encoding: .utf8)
        }
        if script != nil {
            // parseFile("Snapshot")
            if script.hasPrefix("√ { \n") {
                script = String(script.dropFirst(5))
                print(script!)
            }
            let _ = Tr3Parse.shared.parseScript(root, script, whitespace: "\n\t ")
        }
        else {
            func parseFile(_ fileName:String) {
                Tr3Parse.shared.parseTr3(root,fileName)
            }

            parseFile("sky.main")
            parseFile("sky.shader")
            parseFile("panel.cell")

            parseFile("panel.cell.fader")
            parseFile("panel.cell.average")
            parseFile("panel.cell.melt")
            parseFile("panel.cell.timeTunnel")
            parseFile("panel.cell.zhabatinski")
            parseFile("panel.cell.slide")
            parseFile("panel.cell.fredkin")

            parseFile("panel.cell.brush")
            parseFile("panel.shader.colorize")
            parseFile("panel.cell.scroll")
            parseFile("panel.shader.tile")
            //!!! parseFile("panel.cell.camera")
            parseFile("panel.speed")
        }
        //let script = root.makeScript(0,pretty:false)
        //print(script)
    }

}
