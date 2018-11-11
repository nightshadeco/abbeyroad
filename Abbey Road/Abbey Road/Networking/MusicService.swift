//
//  MusicService.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import MultipeerConnectivity
import simd

@objc protocol MusicServiceDelegate: AnyObject {
    func connectedDevicesChanged(service: MusicService, connectedDevices: [String])
    @objc optional func colorChanged(service: MusicService, peerId: MCPeerID, colorString: String)
    @objc optional func positionChanged(service: MusicService, peerId: MCPeerID, position: simd_float3)
    @objc optional func instrumentMessage(service: MusicService, peerId: MCPeerID, message: InstrumentMessage)
}

class MusicService: NSObject {
    private let MusicServiceType = "abbeyroad-music"
    
    private let peerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : MusicServiceDelegate?
    
    lazy var session: MCSession = {
        let session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    override init() {
        print("PeerID name: \(UIDevice.current.name)")
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: MusicServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: MusicServiceType)
        super.init()
        
        serviceAdvertiser.delegate = self
        
        serviceBrowser.delegate = self
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func startHost() {
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func startPeer() {
        serviceBrowser.startBrowsingForPeers()
    }
    
    func send(colorName: String) {
        NSLog("%@", "sendColor: \(colorName) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                let colorString = "C" + colorName
                try self.session.send(colorString.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
    func send(position: simd_float3) {
        NSLog("%@", "position: \(position.debugDescription) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                let positionString = "\(position.x),\(position.y),\(position.z)"
                let str = "P" + positionString
                try self.session.send(str.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
    func send(instrumentMessage: InstrumentMessage) {
        if session.connectedPeers.count > 0 {
            let message = "I" + instrumentMessage.instrument.rawValue + "\(instrumentMessage.action)"
            do {
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
}

extension MusicService: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension MusicService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MusicService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(service: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerId: MCPeerID) {
        let str = String(data: data, encoding: .utf8)!
        let index = str.index(after: str.startIndex)
        let payloadString = String(str[index...])
        if str.starts(with: "C") {
            self.delegate?.colorChanged?(service: self, peerId: peerId, colorString: payloadString)
        } else if str.starts(with: "P") {
            let positionSplits = payloadString.split(separator: ",")
            let x = Float(positionSplits[0])!
            let y = Float(positionSplits[1])!
            let z = Float(positionSplits[2])!
            let position = simd_float3(x, y, z)
            self.delegate?.positionChanged?(service: self, peerId: peerId, position: position)
        } else if str.starts(with: "I") {
            NSLog("%@", "instrument message: \(payloadString)")
            
            let instrumentString = String(payloadString.prefix(1))
            let actionString = String(payloadString[payloadString.index(payloadString.startIndex, offsetBy: 1)])
            let action = Int(actionString)!
            
            let instrumentMessage = InstrumentMessage()
            instrumentMessage.instrument = InstrumentMessage.Instrument(rawValue: instrumentString)!
            instrumentMessage.action = action
            self.delegate?.instrumentMessage?(service: self, peerId: peerId, message: instrumentMessage)
        } else {
            fatalError("Invalid protocol \(str)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}
