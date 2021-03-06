√ {
    sky {
        main { frame: 11494  fps:(1...60=60)  run: 0  }
        pipeline { drawScroll: "draw"  cellAverage: "compute"  colorize: "colorize"  render: "render"  }
        dock { fader average: 1  melt timetunnel zhabatinski slide fredkin brush colorize scroll tile speed camera record }
        colorize { xfade:(0...1=0)  pal0: "roygbik"  pal1: "wKZ"  }
        input { azimuth:(x y):(-0.2...0.2=0)  force:(0...0.5=0)  -> sky.draw.brush.size  accel:(x y z):(-0.3...0.3)  { on:(0...1)  } radius:(1...92=9)  tilt:(0...1=0)  }
        draw {
            screen { fillZero: 0  fillOne: 0  }
            brush { type: "dot"  size:(1...64=1)  press:(0...1=0)  index:(1...255=127)  }
            line { prev:(x y):(0...1)  next:(x y):(0...1)  } }
        shader {
            _compute { type: "compute"  file: "whatever.metal"  on:(0...1=0)  buffer { version:(0...1=0)  } }
            cellMelt { type: "compute"  file: "cell.melt.metal"  on:(0...1=0)  buffer { version:(0...1=1)  } }
            cellFredkin { type: "compute"  file: "cell.fredkin.metal"  on:(0...1=0)  buffer { version:(0...1=0.5)  } }
            cellGas { type: "compute"  file: "cell.gas.metal"  on:(0...1=0)  buffer { version:(0...1=0)  } }
            cellAverage { type: "compute"  file: "cell.average.metal"  on:(0...1=0)  buffer { version:(0...1=0.4)  } }
            cellModulo { type: "compute"  file: "cell.modulo.metal"  on:(0...1=0)  buffer { version:(0...1=0)  } }
            cellFader { type: "compute"  file: "cell.fader.metal"  on:(0...1=0)  buffer { version:(0...1=0.5)  } }
            cellSlide { type: "compute"  file: "cell.slide.metal"  on:(0...1=0)  buffer { version:(0...1=1)  } }
            cellDrift { type: "compute"  file: "cell.drift.metal"  on:(0...1=0)  buffer { version:(0...1=0)  } }
            cellTimetunnel { type: "compute"  file: "cell.timetunnel.metal"  on:(0...1=0)  buffer { version:(0...1=1)  } }
            cellZhabatinski { type: "compute"  file: "cell.zhabatinski.metal"  on:(0...1=0) buffer { version:(0...1=0.75)  bits:(2...4=3)  } repeat: 11  }
            cellRecord { type: "record"  file: "cell.record.metal"  on:(0...1=0)  buffer { version:(0...1=0)  } flip:(0...1=0)  }
            cellCamera { type: "camera"  file: "cell.camera.metal"  on:(0...1=0)  buffer { version:(0...1=0.5)  } flip:(0...1=0)  }
            drawScroll { type: "draw"  file: "drawScroll.metal"  on:(0...1=0)  buffer { scroll:(x y):(0...1=0.5)  } }
            colorize { type: "colorize"  file: "colorize.metal"  buffer { bitplane:(0...1=0.0563063)  } }
            render { type: "render"  file: "render.metal" buffer { repeat:(x y)  mirror:(x y)  } } } }
    panel {
        _cell {
            base { type: "cell"  title: "_cell"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.ring.white.png"  }
            controls {
                hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.ring.white.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  lag: 0  }
                version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=1)  user -> ruleOn.value: 1  }
                lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                    icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
        cell {
            fader {
                base { type: "cell"  title: "Fader"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.fader.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.fader.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellFader.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=0.5)  -> sky.shader.cellFader.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0.2)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            average {
                base { type: "cell"  title: "Average"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.average.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.average.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellAverage.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=0.4)  -> sky.shader.cellAverage.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0.3)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            melt {
                base { type: "cell"  title: "Melt"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.melt.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.melt.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellMelt.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=1)  -> sky.shader.cellMelt.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0.0563063)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value: 1.67772e+07  -> sky.draw.screen.fillOne  } fillZero { value: 1.67772e+07  } } }
            timetunnel {
                base { type: "cell"  title: "Time Tunnel"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.timeTunnel.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.timeTunnel.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellTimetunnel.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=1)  -> sky.shader.cellTimetunnel.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            zhabatinski {
                base { type: "cell"  title: "Zhabatinski"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.zhabatinski.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.zhabatinski.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellZhabatinski.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=0.75)  -> sky.shader.cellZhabatinski.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            slide {
                base { type: "cell"  title: "Slide Bit Planes"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.slide.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.slide.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellSlide.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=1)  -> sky.shader.cellSlide.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            fredkin {
                base { type: "cell"  title: "Fredkin"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.cell.fredkin.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.cell.fredkin.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellFredkin.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=0.5)  -> sky.shader.cellFredkin.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            brush {
                base { type: "brush"  title: "Brush"  frame:(x: 0 y: 0 w: 280 h: 170)  icon: "icon.cell.brush.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    brushPress { type: "switch"  title: "Pressure"  frame:(x: 210 y: 50 w: 60 h: 44)  icon: "icon.pen.press.png"  value:(0...1=0)  <-> sky.draw.brush.press  }
                    brushSize { type: "slider"  title: "Size"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1)  <-> sky.draw.brush.size  user -> brushPress.value: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "clear 0xFFFF"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            scroll {
                base { type: "cell"  title: "Scroll"  frame:(x: 0 y: 0 w: 218 h: 186)  icon: "icon.scroll.png"  }
                controls {
                    scrollOn { type: "panelon"  title: "Active"  frame:(x: 162 y: 6 w: 48 h: 32)  icon: "icon.scroll.png"  value:(0...1=0)
                        user -> scrollBox.value:(x: 0.5 y: 0.5)  -> brushTilt.value: 0  { x y } lag: 0  }
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    scrollBox { type: "box"  title: "Screen Scroll"  frame:(x: 10 y: 48 w: 128 h: 128)  radius: 10  tap2:(-1 -1)  lag: 0  value:(x y):(0...1=0.5)  <-> sky.input.azimuth  -> sky.shader.drawScroll.buffer.scroll  user ->(brushTilt.value: 0 accelTilt.value: 0 scrollOn.value: 1 )  }
                    brushTilt { type: "switch"  title: "Brush Tilt"  frame:(x: 148 y: 52 w: 60 h: 44)  icon: "icon.pen.tilt.png"  value:(0...1=0)  <-> sky.input.tilt  -> accelTilt.value: 0  }
                    fillZero { type: "trigger"  title: "Fill Zero"  frame:(x: 148 y: 126 w: 44 h: 44)  icon: "icon.drop.clear.png"  value:(0...1=0)  -> sky.draw.screen.fillZero  } } }
            camera {
                base { type: "camera"  title: "Camera"  frame:(x: 0 y: 0 w: 260 h: 170)  icon: "icon.camera.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    ruleOn { type: "panelon"  title: "Active"  frame:(x: 202 y: 6 w: 48 h: 32)  icon: "icon.camera.png"  value:(0...1=0)  -> panel.cell˚ruleOn.value: 0  -> panel.cell.speed.restart  -> sky.shader.cellCamera.on  lag: 0  }
                    version { type: "segment"  title: "Version"  frame:(x: 10 y: 50 w: 192 h: 44)  value:(0...1=0.5)  -> sky.shader.cellCamera.buffer.version  user -> ruleOn.value: 1  }
                    lock { type: "switch"  title: "Lock"  frame:(x: 210 y: 50 w: 44 h: 44)
                        icon: "icon.camera.flip.png"  { off: "icon.lock.closed.png"  on: "icon.lock.open.png"  } value:(0...1=0)  -> sky.shader.cellCamera.flip  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0.2)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            speed { restart:(0...1=0)  -> speedOn: 1  -> controls.speed.value: 60
                base { type: "cell"  title: "Speed"  frame:(x: 0 y: 0 w: 212 h: 104)  icon: "icon.speed.png"  }
                controls {
                    speedOn { type: "panelon"  title: "Active"  frame:(x: 154 y: 6 w: 48 h: 32)  icon: "icon.speed.png"  value:(0...1=0)  -> sky.main.run
                        user -> scrollBox.value:(x: 0.5 y: 0.5)  { x y } lag: 0  }
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    speed { type: "slider"  title: "Frames per second"  frame:(x: 10 y: 50 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(1...60=60)  <-> sky.main.fps  user -> speedOn.value: 1  } } } }
        shader {
            colorize {
                base { type: "colorize"  title: "Colorize"  frame:(x: 0 y: 0 w: 260 h: 176)  icon: "icon.pal.main.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    palFade { type: "slider"  title: "Palette Cross Fade"  frame:(x: 10 y: 50 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  <-> sky.colorize.xfade  lag: 0  }
                    bitplane { type: "slider"  title: "Bit Plane"  frame:(x: 10 y: 106 w: 192 h: 44)  icon: "icon.pearl.white.png"  value:(0...1=0)  -> sky.shader.colorize.buffer.bitplane  }
                    fillOne { type: "trigger"  title: "Fill Ones"  frame:(x: 210 y: 106 w: 44 h: 44)  icon: "icon.drop.gray.png"  value:(0...1=0)  -> sky.draw.screen.fillOne  } } }
            tile {
                base { type: "shader"  title: "Tile"  frame:(x: 0 y: 0 w: 230 h: 170)  icon: "icon.shader.tile.png"  }
                controls {
                    hide { type: "panelx"  title: "hide"  frame:(x: 0 y: 0 w: 40 h: 40)  icon: "icon.thumb.X.png"  value:(0...1=0)  }
                    tileOn { type: "panelon"  title: "Active"  frame:(x: 174 y: 6 w: 48 h: 32)  icon: "icon.shader.tile.png"  value:(0...1=0)
                        user -> repeatBox.value:(x: 0 y: 0)  { x y } lag: 0  }
                    repeatBox { type: "box"  title: "Repeat"  frame:(x: 10 y: 40 w: 120 h: 120)  radius: 10  tap2:(-1 -1)  lag: 0  user:(0...1=1)  -> tileOn.value: 1  value:(0 0):(0...1)  -> sky.shader.render.buffer.repeat  }
                    mirrorBox { type: "box"  title: "Mirror"  frame:(x: 140 y: 60 w: 80 h: 80)  radius: 10  tap2:(1 1)  lag: 0  user:(0...1=1)  value:(0 0):(0...1=0)  -> sky.shader.render.buffer.mirror  } } } } } }
