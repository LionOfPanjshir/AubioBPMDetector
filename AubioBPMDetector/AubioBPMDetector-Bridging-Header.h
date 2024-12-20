//
//  AubioBPMDetector-Bridging-Header.h
//  AubioBPMDetector
//
//  Created by Andrew Higbee on 12/20/24.
//

#ifndef AubioBPMDetector_Bridging_Header_h
#define AubioBPMDetector_Bridging_Header_h
#include "aubio.h"
//#include <aubio/aubio.h>
#endif /* AubioBPMDetector_Bridging_Header_h */

typedef struct _aubio_tempo_t aubio_tempo_t;
aubio_tempo_t *createTempoDetector(const char *method, uint_t buf_size, uint_t hop_size, uint_t samplerate);
void destroyTempoDetector(aubio_tempo_t *tempo);
void processAudioWithTempo(aubio_tempo_t *tempo, float *audioData, uint_t hop_size);
float getBPMFromTempo(aubio_tempo_t *tempo);
