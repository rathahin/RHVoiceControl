//
//  RHWaveformView.m
//  Vegas
//
//  Created by Ratha Hin on 2/6/14.
//  Copyright (c) 2014 Golden Gekko. All rights reserved.
//

#import "RHWaveformView.h"

@interface RHWaveformView ()

@property (nonatomic, strong) UIToolbar *blurEffect;
@property (nonatomic, strong) CAShapeLayer *waveformLayer;

@end

@implementation RHWaveformView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self commonSetuponInitWithFrame:frame];
    }
    return self;
}

- (void)commonSetuponInitWithFrame:(CGRect)frame {
  [self addSubview:self.blurEffect];
  [self.layer addSublayer:self.waveformLayer];
  
}

- (CAShapeLayer *)waveformLayer {
  if (!_waveformLayer) {
    _waveformLayer = [CAShapeLayer layer];
    _waveformLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 156);
    _waveformLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - 78);
    _waveformLayer.contentsGravity = kCAGravityCenter;
    _waveformLayer.contents = (id)[UIImage imageNamed:@"dummy_waveform"].CGImage;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
      _waveformLayer.contentsScale = [[UIScreen mainScreen] scale];
    }
#endif
    return _waveformLayer;
  }
  
  return _waveformLayer;
}

- (UIToolbar *)blurEffect {
  if (!_blurEffect) {
    _blurEffect = [[UIToolbar alloc] initWithFrame:self.bounds];
    _blurEffect.barStyle = UIBarStyleBlack;
    _blurEffect.translucent = YES;
    return _blurEffect;
  }
  
  return _blurEffect;
}

- (void)updateWaveFormWithWaveInformation:(id)mockInformation {
  
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
