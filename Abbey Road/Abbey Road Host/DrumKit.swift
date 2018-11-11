//
//  DrumKit.swift
//  Abbey Road Host
//
//  Created by P L Garlaschi Sousa on 10/11/2018.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import Foundation
import AudioKit

class DrumKit {
    static let sharedInstance = DrumKit()
    let drums = AKAppleSampler()
    init() {
        
        drums.volume = 1
        AudioKit.output = drums
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        do {
            
            let bassDrumFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "grime_kick3_C1", withExtension: "wav")!)
            let clapFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "clap_D#1", withExtension: "wav")!)
            let closedHiHatFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "hiphop_closed_Hihat6_F#1", withExtension: "wav")!)
            let hiTomFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "hi_tom_D2", withExtension: "wav")!)
            let loTomFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "lo_tom_F1", withExtension: "wav")!)
            let midTomFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "mid_tom_B1", withExtension: "wav")!)
            let openHiHatFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "open_hi_hat_A#1", withExtension: "wav")!)
            let snareDrumFile = try AKAudioFile(forReading: Bundle.main.url(forResource: "hiphop_snare5_D1", withExtension: "wav")!)
            
            try drums.loadAudioFiles([bassDrumFile,
                                      clapFile,
                                      closedHiHatFile,
                                      hiTomFile,
                                      loTomFile,
                                      midTomFile,
                                      openHiHatFile,
                                      snareDrumFile])
            
            
        } catch {
            AKLog("Files Didn't Load")
        }
    }
    
//    func Bit(volume : Double, pan : Double, note : MIDINoteNumber)  {
//        drums.pan = pan;
//        drums.volume = volume;
//        try? drums.play(noteNumber: note);
//    }
    
}
