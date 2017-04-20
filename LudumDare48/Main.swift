//
//  MyFile.swift
//  LudumDare48
//
//  Created by Ryan Gibson on 19/04/2017.
//  Copyright © 2017 Fat Grin Software Ltd. All rights reserved.
//

import Foundation

let singleFrame = 1.0 / 60
var totalFrames: UInt16 = 0
var totalTime: TimeInterval = 0

func textureAtlasPath() -> String {
    return Bundle.main.pathForImageResource("textureAtlas")!
    
}

func time(block: () -> Void) {
    totalFrames += 1
    let now = Date.timeIntervalSinceReferenceDate
    block()
    let duration = Date.timeIntervalSinceReferenceDate - now
    totalTime += duration
    if duration > singleFrame {
        print("Drop: \(duration)")
    }
    if totalFrames % 120 == 0 {
        let avgFrame = totalTime / Double(totalFrames)
        print("Avg frame: \(avgFrame) (\(singleFrame / avgFrame) draws per frame)")
    }
}

func run() {
    let textureAtlasSurface = Images.load(file: textureAtlasPath())!
    
    
    sdl.start()
    defer { sdl.quit() }

    let window = Window(title: "ld48", width: 800, height: 600, flags: [ .OPENGL ]) // .ALLOW_HIGHDPI, .FULLSCREEN_DESKTOP

    
    

    let gl = sdl.gl.createContext(window: window)!
    defer { sdl.gl.delete(context: gl) }
    let pxf = window.pixelFormat
    
    
    
    
    let txAtlas = window.renderer.createTextureFromSurface(surface: textureAtlasSurface)
    

    var x: Int32 = 0
    let frameTicks = 1_000_000 / 60
    
    func update(ticks: UInt64) {
        x += 10
        if x > 800 {
            x = 0
        }
    }
    
    
    
    func display() {
        time {
            window.renderer.setDrawColor(r: 255, g: 0, b: 0)
            window.renderer.clear()
    //        window.renderer.setDrawColor(r: 255, g: 255, b: 0)
            let size: Int32 = 64
            let s = Rect(x: size, y: size, w: size, h: size)
            let r = Rect(x: x, y: 10, w: size, h: size)
    //        window.renderer.fillRect(rect: &r)
            window.renderer.copyTexture(texture: txAtlas, sourceRect: s, destinationRect: r)
            window.renderer.present()
        }
    }
    
    update(ticks: 0)
    display()
    

//    var lastFrame: UInt64 = 0
    
    
    var displayLink: CVDisplayLink?
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
    
    var lastFrame: UInt64 = 0
    CVDisplayLinkSetOutputHandler(displayLink!) { (link, ts, ts2, opts, flags) -> CVReturn in

//        print("\(t1.hostTime - lastFrame)")
        let ticks = ts2.pointee.hostTime - lastFrame
        lastFrame = ts2.pointee.hostTime
        
        update(ticks: ticks)
        display()
        return kCVReturnSuccess
    }
    CVDisplayLinkStart(displayLink!)
    //let displayLink = CADisplayLink(target: eng, selector: #selector(display))
    //displayLink.ad

    var evt = Event()
    while true {
        Events.wait(evt: &evt)
        if evt.isQuit {
            exit(0)
        } else if evt.isKeyDown {
            let k = evt.key
            switch k.keysym.sym.littleEndian {
            case 119: // W
                break
            case 115: // S
                break
            case 97:  // A
                break
            case 100: // D
                break
            case 32:  // SPACE
                break
            default:
                break;
            }
        }
    }
    
}
