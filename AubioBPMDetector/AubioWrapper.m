//
//  AubioWrapper.m
//  AubioBPMDetector
//
//  Created by Andrew Higbee on 12/20/24.
//

#import <Foundation/Foundation.h>
#include "aubio.h"

// Create the tempo detector
void *createTempoDetector(const char *method, uint_t buf_size, uint_t hop_size, uint_t samplerate) {
    return (void *)new_aubio_tempo(method, buf_size, hop_size, samplerate);
}
//aubio_tempo_t *createTempoDetector(const char *method, uint_t buf_size, uint_t hop_size, uint_t samplerate) {
//    return new_aubio_tempo(method, buf_size, hop_size, samplerate);
//}

// Destroy the tempo detector
void destroyTempoDetector(aubio_tempo_t *tempo) {
    del_aubio_tempo(tempo);
}

// Process audio with tempo detection
void processAudioWithTempo(aubio_tempo_t *tempo, float *audioData, uint_t hop_size) {
    fvec_t *buffer = new_fvec(hop_size);    // Create input buffer
    fvec_t *tempoBuffer = new_fvec(1);     // Create output buffer

    for (uint_t i = 0; i < hop_size; i++) {
        fvec_set_sample(buffer, audioData[i], i);
    }

    aubio_tempo_do(tempo, buffer, tempoBuffer); // Process the audio data

    del_fvec(buffer);        // Clean up input buffer
    del_fvec(tempoBuffer);   // Clean up output buffer
}

// Get the BPM from the tempo detector
float getBPMFromTempo(aubio_tempo_t *tempo) {
    return aubio_tempo_get_bpm(tempo);
}
