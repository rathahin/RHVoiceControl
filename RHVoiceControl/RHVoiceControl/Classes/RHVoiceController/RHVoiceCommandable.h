//
//  RHVoiceCommandable.h
//  Vegas
//
//  Created by Ratha Hin on 2/5/14.
//  Copyright (c) 2014 Golden Gekko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RHVoiceCommandable <NSObject>

- (NSArray *)availableCommandAsStrings;
- (BOOL)responseToCommandString:(NSString *)commandString;

@end
