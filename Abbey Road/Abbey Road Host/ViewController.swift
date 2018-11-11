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
    var pluckNode: AKOperationGenerator!
//    var boosterNode: AKBooster!
    var filter: AKMoogLadder!
    
    init() {
        pluckNode = AKOperationGenerator { parameters in
        let frequency = (AKOperation.parameters[1] + 40).midiNoteToFrequency()
        return AKOperation.pluckedString(
            trigger: AKOperation.trigger,
            frequency: frequency,
            amplitude: 0.5,
            lowestFrequency: 50)
        }
        
        let reverb = AKReverb(pluckNode)
        reverb.dryWetMix = 0.01
        
//        boosterNode = AKBooster(reverb)
        filter = AKMoogLadder(reverb)
        
        
        AudioKit.output = filter
        do {
            try AudioKit.start()
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
    var distances = [MCPeerID : Float]()
    var pointerNodes = [MCPeerID : SCNNode]()
    var hues = [MCPeerID : CGFloat]()
    
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
            if let distance = distances[peerId] {
                self.kit.drums.volume = Double(1.0 - distance)
            }
            if message.action == 0 {
                try? self.kit.drums.play(noteNumber: 36 - 12)
            } else if message.action == 1 {
                try? self.kit.drums.play(noteNumber: 38 - 12)
            } else if message.action == 2 {
                try? self.kit.drums.play(noteNumber: 46 - 12)
            }
        } else if message.instrument == .Harp {
            if let distance = distances[peerId] {
//                self.harp.boosterNode.gain = Double(1.0 - distance)
                self.harp.filter.cutoffFrequency = Double(1.0 - distance) * 2000 + 1
            }
            if message.action == 0 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(20)
                self.harp.pluckNode.trigger()
            } else if message.action == 1 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(23)
                self.harp.pluckNode.trigger()
            } else if message.action == 2 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(29)
                self.harp.pluckNode.trigger()
            } else if message.action == 3 {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(32)
                self.harp.pluckNode.trigger()
            } else {
                self.harp.pluckNode.start()
                self.harp.pluckNode.parameters[1] = Double(34)
                self.harp.pluckNode.trigger()
            }
            
        }
    }
    
    func cloneArrowIfNeeded(peerId: MCPeerID) {
        if self.pointerNodes[peerId] == nil {
            
            let referenceNode = SCNNode()
            referenceNode.name = "pointer"
            let pyramidNode = SCNNode()
            pyramidNode.name = "pyramid"
            pyramidNode.eulerAngles = SCNVector3(0, -45, 0)
            pyramidNode.scale = SCNVector3(0.05, 1, 0.05)
            referenceNode.addChildNode(pyramidNode)
            pyramidNode.geometry = SCNPyramid()
            self.pointerNodes[peerId] = referenceNode
            
            self.sceneView.scene?.rootNode.addChildNode(referenceNode)
            let randomHue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            self.hues[peerId] = randomHue
        }
    }
    
    func positionChanged(service: MusicService, peerId: MCPeerID, position: simd_float3) {
        if peerId.displayName == UIDevice.current.name {
            return
        }
        
        DispatchQueue.main.async {
            self.cloneArrowIfNeeded(peerId: peerId)
            
            guard let node = self.pointerNodes[peerId] else {
                return
            }
            
            let projectedPos = simd_float2(position.x, position.z)
            let normalized = simd_normalize(projectedPos)
            let angle = atan2(-normalized.x, -normalized.y)
            self.angles[peerId] = angle
            node.eulerAngles.z = angle
            
            var distanceToCenter = CGFloat(simd_length_squared(position)) * 0.5
            if distanceToCenter > 1.0 {
                distanceToCenter = 1.0
            }
            self.distances[peerId] = Float(distanceToCenter)
            
            if let pyramidNode = node.childNode(withName: "pyramid", recursively: false) {
                pyramidNode.geometry?.firstMaterial?.diffuse.contents = UIColor(hue: self.hues[peerId] ?? 0.5, saturation: 0.8, brightness: 1.0 - distanceToCenter, alpha: 0.7)
            }
        }
    }
    
}
