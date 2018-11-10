//
//  ViewController.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let musicService = MusicService()
    
    var cubeNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        musicService.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        configuration.detectionImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        print("Marker detected")
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        node.pivot = SCNMatrix4MakeTranslation(0, -0.05, 0)
        node.transform = SCNMatrix4MakeTranslation(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        cubeNode = node
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - MCSessionDelegate
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [unowned self] in
                // do something with the image
            }
        }
    }
    
    // MARK: - MCBrowserViewControllerDelegate
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
//
//    func sendImage(img: UIImage) {
//        if mcSession.connectedPeers.count > 0 {
//            if let imageData = img.pngData() {
//                do {
//                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
//                } catch let error as NSError {
//                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "OK", style: .default))
//                    present(ac, animated: true)
//                }
//            }
//        }
//    }
//
//    func startHosting() {
//        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: mcSession)
//        mcAdvertiserAssistant.start()
//    }
//
//    func joinSession() {
//        let mcBrowser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
//        mcBrowser.delegate = self
//        present(mcBrowser, animated: true)
//    }
    
    func change(color: UIColor) {
        if let node = cubeNode {
            node.geometry?.firstMaterial?.diffuse.contents = color
        }
    }
    
    @IBAction func redTapped() {
        change(color: .red)
        musicService.send(colorName: "red")
    }
    
    @IBAction func greenTapped() {
        change(color: .green)
        musicService.send(colorName: "green")
    }
    
}

extension ViewController: MusicServiceDelegate {
    
    func connectedDevicesChanged(service: MusicService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
//            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(service: MusicService, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "green":
                self.change(color: .green)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
}
