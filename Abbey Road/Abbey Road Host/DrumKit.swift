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
        
        drums.volume = 2;
        AudioKit.output = drums
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        do {
            
            let bassDrumFile    = try AKAudioFile(readFileName: "Drums/bass_drum_C1.wav")
            let clapFile        = try AKAudioFile(readFileName: "Drums/clap_D#1.wav")
            let closedHiHatFile = try AKAudioFile(readFileName: "Drums/closed_hi_hat_F#1.wav")
            let hiTomFile       = try AKAudioFile(readFileName: "Drums/hi_tom_D2.wav")
            let loTomFile       = try AKAudioFile(readFileName: "Drums/lo_tom_F1.wav")
            let midTomFile      = try AKAudioFile(readFileName: "Drums/mid_tom_B1.wav")
            let openHiHatFile   = try AKAudioFile(readFileName: "Drums/open_hi_hat_A#1.wav")
            let snareDrumFile   = try AKAudioFile(readFileName: "Drums/snare_D1.wav")
            
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
    
    func Bit(volume : Double , pan : Double  , note : MIDINoteNumber  )  {
        drums.pan = pan;
        drums.volume = volume;
        try? drums.play(noteNumber: note);
    }
    
}
