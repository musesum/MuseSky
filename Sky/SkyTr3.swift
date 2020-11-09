import UIKit
import Tr3
import MuMetal

class SkyTr3: NSObject {
    
    static let shared = SkyTr3()
    
    let root = Tr3("√")
    var screenFillZero˚: Tr3?
    var screenFillOne˚: Tr3?
    var touchRepeat˚: Tr3?
    var scrolling˚: Tr3?
    var cameraFlip˚: Tr3?

    var skySize = CGSize(width: 1920, height: 1080)
    var archive: MuArchive?
    var fromSnapshot = true
    
    override init() {

        super.init()
        // parse Sky Snapshot Or scripts
         if let snapshot = MuArchive.readArchive("Snapshot.zip") {
            archive = snapshot
            archive?.get("Snapshot.tr3",1000000) { data in
                if  let data = data,
                    let script = self.dropRoot(String(data: data, encoding: .utf8)) {
                    print(script)
                    let _ = Tr3Parse.shared.parseScript(self.root, script, whitespace: "\n\t ")
                }
                else {
                    self.parseScriptFiles()
                }
                self.initScreenFill()
                self.initCameraFlip()
            }
        }
        else {
            parseScriptFiles()
            initScreenFill()
            initCameraFlip()
        }

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

    func initCameraFlip() {
        let cellCamera = root.findPath("sky.shader.cellCamera")
        cameraFlip˚ = cellCamera?.findPath("flip") ?? nil
        if let cameraFlip˚ = cameraFlip˚ {
            cameraFlip˚.addClosure  { tr3,_ in
                CameraSession.shared.flipCamera()
            }
        }
    }

    /// remove ove leading "√ { \n" from script file if it exists
    func dropRoot(_ script: String?) -> String? {
        if let script = script {
            var hasRoot = false
            var index = 0
            scan: for char in script {
                switch char {
                    case "√": hasRoot = true; index += 1
                    case " ", "\n", "\t": index += 1
                    case "{": if hasRoot { index += 1 }
                    default: break scan
                }
            }
            if hasRoot {
                let start = String.Index(utf16Offset: index, in: script)
                let end   = String.Index(utf16Offset: script.count, in: script)
                let sub = script[start ..< end]
                return String(sub)
            }
        }
        return script
    }

    func parseArchive(_ archive: MuArchive) {
        // get script and parse
        archive.get("Snapshot.tr3",1000000) { data in
            if  let data = data,
                let script = self.dropRoot(String(data: data, encoding: .utf8)) {

                print(script)
                let _ = Tr3Parse.shared.parseScript(self.root, script, whitespace: "\n\t ")
            } 
        }
    }
    func parseScriptFiles() {
        func parseFile(_ fileName: String) {
            Tr3Parse.shared.parseTr3(root,fileName)
        }

        parseFile("sky.main")
        parseFile("sky.shader")
        parseFile("sky.midi")
        parseFile("panel.cell")
        parseFile("panel.camera")

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
        parseFile("panel.cell.camera")
        parseFile("panel.cell.record") //?? 
        parseFile("panel.speed")

        //let script = root.makeScript(0,pretty: false)
        //print(script)
    }
}
