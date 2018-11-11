//
//  ViewController.swift
//  Abbey Road Host
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import UIKit
import AudioKit
import MultipeerConnectivity
import SceneKit

class Harp {
    static let sharedInstance = Harp()
    let playRate = 2.0
    var pluckNode: AKOperationGenerator!
    var performance: AKPeriodicFunction!
    
    init() {
        pluckNode = AKOperationGenerator { parameters in
        let frequency = (AKOperation.parameters[1] + 40).midiNoteToFrequency()
        return AKOperation.pluckedString(
            trigger: AKOperation.trigger,
            frequency: frequency,
            amplitude: 0.5,
            lowestFrequency: 50)
        }
        
        let delay = AKDelay(pluckNode)
        delay.time = 1.5 / playRate
        delay.dryWetMix = 0.3
        delay.feedback = 0.2
        
        let reverb = AKReverb(delay)
        
        let scale = [0, 2, 4, 5, 7, 9, 11, 12]
        
        performance = AKPeriodicFunction(frequency: playRate) {
            var note = scale.randomElement()!
            let octave = [0, 1, 2, 3].randomElement()! * 12
            if random(in: 0...10) < 1.0 { note += 1 }
            if !scale.contains(note % 12) { print("ACCIDENT!") }
        
            if random(in: 0...6) > 1.0 {
                self.pluckNode.parameters[1] = Double(note + octave)
                self.pluckNode.trigger()
            }
        }
        
        AudioKit.output = reverb
        do {
            try AudioKit.start(withPeriodicFunctions: performance)
        } catch {
            AKLog("AudioKit did not start!")
        }
        //pluckNode.start()
        //performance.start()
        //
        //import PlaygroundSupport
        //PlaygroundPage.current.needsIndefiniteExecution = true
    }
}

//let playRate = 2.0
//
//let pluckNode = AKOperationGenerator { parameters in
//    let frequency = (AKOperation.parameters[1] + 40).midiNoteToFrequency()
//    return AKOperation.pluckedString(
//        trigger: AKOperation.trigger,
//        frequency: frequency,
//        amplitude: 0.5,
//        lowestFrequency: 50)
//}
//
//var delay = AKDelay(pluckNode)
//delay.time = 1.5 / playRate
//delay.dryWetMix = 0.3
//delay.feedback = 0.2
//
//let reverb = AKReverb(delay)
//
//let scale = [0, 2, 4, 5, 7, 9, 11, 12]
//
//let performance = AKPeriodicFunction(frequency: playRate) {
//    var note = scale.randomElement()
//    let octave = [0, 1, 2, 3].randomElement() * 12
//    if random(in: 0...10) < 1.0 { note += 1 }
//    if !scale.contains(note % 12) { print("ACCIDENT!") }
//
//    if random(in: 0...6) > 1.0 {
//        pluckNode.parameters[1] = Double(note + octave)
//        pluckNode.trigger()
//    }
//}
//
//AudioKit.output = reverb
//try AudioKit.start(withPeriodicFunctions: performance)
//pluckNode.start()
//performance.start()
//
//import PlaygroundSupport
//PlaygroundPage.current.needsIndefiniteExecution = true


class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sceneView: SCNView!
    
    let musicService = MusicService()

    let kit = DrumKit()
    let harp = Harp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(Handler));
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        sceneView.scene = SCNScene(named: "host")
        
        musicService.delegate = self
    }
    
    @objc func Handler(sender: UITapGestureRecognizer? = nil) {
        
        let x : CGFloat = (sender?.location(in: view).x)!;
        let w : CGFloat = UIScreen.main.bounds.width;
        if(x < w * 0.1){
            try? self.kit.drums.play(noteNumber: 36 - 12)
        }
        else if(x < w * 0.2){
            try? self.kit.drums.play(noteNumber: 38 - 12)
        }
        else if(x < w * 0.3){
            try? self.kit.drums.play(noteNumber: 42 - 12)
        }
        else if(x < w * 0.4){
            try? self.kit.drums.play(noteNumber: 46 - 12)
        }
        else if(x < w * 0.5){
            try? self.kit.drums.play(noteNumber: 41 - 12)
        }
        else if(x < w * 0.6){
            try? self.kit.drums.play(noteNumber: 47 - 12)
        }
        else if(x < w * 0.7){
            try? self.kit.drums.play(noteNumber: 50 - 12)
        }
        else if(x < w * 0.8){
            try? self.kit.drums.play(noteNumber: 39 - 12)
        }
        else if(x < UIScreen.main.bounds.width * 0.9){
            try? self.kit.drums.play(noteNumber: 36 - 12)
        }
    }

}

extension ViewController: MusicServiceDelegate {
    
    func connectedDevicesChanged(service: MusicService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            //            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func instrumentMessage(service: MusicService, peerId: MCPeerID, message: InstrumentMessage) {
        if message.instrument == .Drum {
            if message.action == 0 {
                try? self.kit.drums.play(noteNumber: 36 - 12)
            } else if message.action == 1 {
                try? self.kit.drums.play(noteNumber: 38 - 12)
            } else if message.action == 2 {
                try? self.kit.drums.play(noteNumber: 46 - 12)
            }
        } else if(message.instrument == .Harp) {
            if message.action == 0 {
                self.harp.pluckNode.start()
                self.harp.performance.start()
            }
            
        }
    }
    
}
