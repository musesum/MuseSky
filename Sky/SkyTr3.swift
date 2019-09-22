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
        
        func parseFile(_ fileName:String) {
            Tr3Parse.shared.parseTr3(root,fileName)
        }
        if true {
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
            parseFile("panel.speed")
        }
        else {
             parseFile("Snapshot")
        }
        
        print(root.makeScript(0,pretty:false))
        // print(root.dumpScript(0,session:true))
    }

    func saveSnapshot() {
        //let bundle = 
    }
}
