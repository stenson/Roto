//
//  ADKAudioGraph.h
//  Roto
//
//  Created by Robert Stenson on 11/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ADKAudioGraph : NSObject

- (BOOL)power;
- (void)updateDronePitchWithPercentage:(Float32)percentage;

@end
