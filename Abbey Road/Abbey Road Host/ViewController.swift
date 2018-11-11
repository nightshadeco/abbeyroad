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

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sceneView: SCNView!
    
    let musicService = MusicService()

    let kit = DrumKit()
    
    var angles = [MCPeerID : Float]()
    var pointerNodes = [MCPeerID : SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(Handler));
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        sceneView.scene = SCNScene(named: "art.scnassets/scene.scn")!
        
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
        }
    }
    
    func positionChanged(service: MusicService, peerId: MCPeerID, position: simd_float3) {
        if peerId.displayName == UIDevice.current.name {
            return
        }
        
        DispatchQueue.main.async {
            if self.pointerNodes[peerId] == nil {
                self.pointerNodes[peerId] = self.sceneView.scene?.rootNode.childNode(withName: "pointer", recursively: true)
                self.pointerNodes[peerId]?.isHidden = false
            }
            let projectedPos = simd_float2(position.x, position.z)
            let normalized = simd_normalize(projectedPos)
            let angle = atan2(-normalized.x, -normalized.y)
            self.angles[peerId] = angle
            self.pointerNodes[peerId]?.eulerAngles.z = angle
        }
    }
    
}
