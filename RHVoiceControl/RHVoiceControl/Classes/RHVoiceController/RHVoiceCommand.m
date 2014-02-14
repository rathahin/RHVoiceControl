//
// Created by Ratha Hin on 2/4/14.
// Copyright (c) 2014 Golden Gekko. All rights reserved.
//

#import "RHVoiceCommand.h"
#import <AVFoundation/AVFoundation.h>


@implementation RHVoiceCommand {

}

+ (void)speak:(NSString *)speakText {
  AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
  AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakText];
  [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-AU"]];
  utterance.rate = AVSpeechUtteranceMaximumSpeechRate / 4; // Tell it to me slowly
  [synthesizer speakUtterance:utterance];
}

@end