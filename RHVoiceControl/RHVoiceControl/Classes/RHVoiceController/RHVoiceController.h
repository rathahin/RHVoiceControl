//
// Created by Ratha Hin on 2/4/14.
// Copyright (c) 2014 Golden Gekko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>


@interface RHVoiceController : NSObject

@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

- (void)attachToMainWindows:(UIWindow *)windows;

@end