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
        
        AudioKit.output = reverb
        do {
            try AudioKit.start(withPeriodicFunctions: performance)
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
}


class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sceneView: SCNView!
    
    let musicService = MusicService()

    let kit = DrumKit()
    let harp = Harp()
    
    var angles = [MCPeerID : Float]()
    var pointerNodes = [MCPeerID : SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(Handler));
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        sceneView.scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        musicService.delegate = self
        musicService.startHost()
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
                self.harp.pluckNode.parameters[1] = Double(36)
                self.harp.pluckNode.trigger()
            } else if message.action == 1 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(39)
                self.harp.pluckNode.trigger()
            } else if message.action == 2 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(45)
                self.harp.pluckNode.trigger()
            } else if message.action == 3 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(48)
                self.harp.pluckNode.trigger()
            } else {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(50)
                self.harp.pluckNode.trigger()
            }
            
        }
    }
    
    func cloneArrowIfNeeded() {
        if self.pointerNodes[peerId] == nil {
            let referenceNode = self.sceneView.scene?.rootNode.childNode(withName: "pointer", recursively: true)
            if let node = referenceNode?.clone() {
                node.geometry = referenceNode?.geometry?.copy() as? SCNGeometry
                let randomHue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                node.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: randomHue, saturation: 0.8, brightness: 1.0, alpha: 1.0)
                self.pointerNodes[peerId] = node
                node.isHidden = false
                self.sceneView.scene?.rootNode.addChildNode(node)
            }
        }
    }
    
    func positionChanged(service: MusicService, peerId: MCPeerID, position: simd_float3) {
        if peerId.displayName == UIDevice.current.name {
            return
        }
        
        DispatchQueue.main.async {
            cloneArrowIfNeeded()
            
            let projectedPos = simd_float2(position.x, position.z)
            let normalized = simd_normalize(projectedPos)
            let angle = atan2(-normalized.x, -normalized.y)
            self.angles[peerId] = angle
            self.pointerNodes[peerId]?.eulerAngles.z = angle
            
            var distanceToCenter = simd_length_squared(position) * 5.0
            if distanceToCenter > 1.0 {
                distanceToCenter = 1.0
            }
            
            if let color = node.geometry?.firstMaterial?.diffuse.contents as? UIColor {
//                color.hu
            }
        }
    }
    
}
