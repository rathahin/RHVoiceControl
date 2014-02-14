//
// Created by Ratha Hin on 2/4/14.
// Copyright (c) 2014 Golden Gekko. All rights reserved.
//

#import "RHVoiceController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "RHVoiceCommandable.h"
#import <OpenEars/LanguageModelGenerator.h>
#import "RHWaveformView.h"

@interface RHVoiceController () <OpenEarsEventsObserverDelegate>

@property (nonatomic, strong) UIWindow * windows;
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) CAShapeLayer *touchIndicatorLayer;
@property (nonatomic, strong) CABasicAnimation *basicClockwise;
@property (nonatomic, strong) UIView *overlay;
@property SystemSoundID answerSoundID;
@property SystemSoundID questionSoundID;
@property (nonatomic, strong) NSString *lmPath;
@property (nonatomic, strong) NSString *dicPath;
@property (nonatomic, strong) RHWaveformView *wavefromView;

@end

@implementation RHVoiceController {
  
  
}

@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;

- (id)init {
  self = [super init];
  
  if (self) {
    [self commonSetupOnInit];
  }
  
  return self;
}

- (void)commonSetupOnInit {
  _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(longPressAction:)];
  _touchIndicatorLayer = [CAShapeLayer layer];
  self.touchIndicatorLayer.frame = CGRectMake(0, 0, 120, 120);
  self.touchIndicatorLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.touchIndicatorLayer.bounds
                                                             cornerRadius:CGRectGetMidX(self.touchIndicatorLayer.bounds)].CGPath;
  self.touchIndicatorLayer.fillColor = [UIColor clearColor].CGColor;
  self.touchIndicatorLayer.strokeColor = [UIColor greenColor].CGColor;
  self.touchIndicatorLayer.lineWidth = 5;
  self.touchIndicatorLayer.strokeEnd = 0;
  
  self.basicClockwise = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  self.basicClockwise.toValue = [NSNumber numberWithFloat:1.0f];
  self.basicClockwise.duration = 0.5f;
  self.basicClockwise.removedOnCompletion = NO;
  
  self.overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
  
  [self setupSound];
  
  self.wavefromView = [[RHWaveformView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
}

- (void)setupSound {
  NSString *siriAnswerSoundPath = [[NSBundle mainBundle] pathForResource:@"answer" ofType:@"wav"];
	NSURL *siriAnswerSoundURL = [NSURL fileURLWithPath:siriAnswerSoundPath];
	AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain(siriAnswerSoundURL), &_answerSoundID);
  
  NSString *siriQuestionSoundPath = [[NSBundle mainBundle] pathForResource:@"question" ofType:@"wav"];
  NSURL *siriQuestionSoundURL = [NSURL fileURLWithPath:siriQuestionSoundPath];
  AudioServicesCreateSystemSoundID((CFURLRef) CFBridgingRetain(siriQuestionSoundURL), &_questionSoundID);
}

- (UIWindow *)overlayWindow {
  if(!_overlayWindow) {
    _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _overlayWindow.backgroundColor = [UIColor clearColor];
    _overlayWindow.userInteractionEnabled = YES;
    _overlayWindow.windowLevel = UIWindowLevelNormal;
  }
  return _overlayWindow;
}

- (void)attachToMainWindows:(UIWindow *)windows {
  [windows addGestureRecognizer:self.longPressGesture];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGesture {
  if (longPressGesture.state == UIGestureRecognizerStateBegan) {
    NSLog(@"Begin");
    [self.overlay.layer addSublayer:self.touchIndicatorLayer];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.touchIndicatorLayer.position = [longPressGesture locationInView:self.windows];
    [CATransaction commit];
    [self.overlayWindow addSubview:self.overlay];
    [self.overlayWindow setHidden:NO];
    [self.touchIndicatorLayer addAnimation:self.basicClockwise forKey:@"strokeEndAnimation"];
    
  } else if(longPressGesture.state == UIGestureRecognizerStateEnded) {
    NSLog(@"End");
    [self.touchIndicatorLayer removeAnimationForKey:@"strokeEndAnimation"];
    [self.touchIndicatorLayer removeFromSuperlayer];
    self.touchIndicatorLayer.strokeEnd = 0;
    [self.overlay removeFromSuperview];
    self.overlayWindow = nil;
    
    [self triggerSpeaking];
  }
}

- (void)triggerSpeaking {
  UIViewController *viewController = [self topMostViewController];
  
  if (viewController && [viewController conformsToProtocol:@protocol(RHVoiceCommandable)]) {
    [self setupOpenEarWithWords:[(id<RHVoiceCommandable>)viewController availableCommandAsStrings]];
    [self performSelector:@selector(listenEar) withObject:nil afterDelay:0.5];
  } else {
    [self speak:@"Command is not available"];
  }
}

- (void)setupOpenEarWithWords:(NSArray *)words {
  LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
  
  NSString *name = @"NameIWantForMyLanguageModelFiles";
  NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
  
  
  NSDictionary *languageGeneratorResults = nil;
  
  NSString *lmPath = nil;
  NSString *dicPath = nil;
	
  if([err code] == noErr) {
    
    languageGeneratorResults = [err userInfo];
		
    self.lmPath = lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
    self.dicPath = dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
  } else {
    NSLog(@"Error: %@",[err localizedDescription]);
  }
  
  [self.openEarsEventsObserver setDelegate:self];
}

- (void)speak:(NSString *)speakText {
  AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
  AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakText];
  [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-AU"]];
  utterance.rate = AVSpeechUtteranceMaximumSpeechRate / 4; // Tell it to me slowly
  [synthesizer speakUtterance:utterance];
}

- (UIViewController *)topMostViewController {
  UIWindow *window = [[UIApplication sharedApplication] keyWindow];
  id topViewController = window.rootViewController;
  if ([topViewController isKindOfClass:[UINavigationController class]]) {
    return [(UINavigationController *)topViewController topViewController];
  } else {
    return topViewController;
  }
}

#pragma mark - open ear
- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (void)listenEar {
  AudioServicesPlaySystemSound(self.questionSoundID);

  [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:self.dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
}


- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
  [self handlingRespondToHypothesis:hypothesis];
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
  
  [self.overlayWindow addSubview:self.wavefromView];
  [self.overlayWindow setHidden:NO];
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
  AudioServicesPlaySystemSound(self.answerSoundID);
  [self.wavefromView removeFromSuperview];
  self.overlayWindow = nil;
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (void)handlingRespondToHypothesis:(NSString *)hyp {
    
    UIViewController *viewController = [self topMostViewController];
    
    if (viewController && [viewController conformsToProtocol:@protocol(RHVoiceCommandable)]) {
      [(id<RHVoiceCommandable>)viewController responseToCommandString:hyp];
    } else {
      [self speak:@"Command is not available"];
    }
    
    // stop listening
    [self.pocketsphinxController stopListening];
}
@end