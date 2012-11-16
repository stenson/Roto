//
//  ADKViewController.m
//  Roto
//
//  Created by Robert Stenson on 11/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ADKViewController.h"

#define RADIANS_FROM_DEGREES(x) (M_PI * (x) / 180.0)
#define DEGREES_FROM_RADIANS(x) ((180.0 / M_PI) * (x))

@interface LPCircleView : UIView
@end

@implementation LPCircleView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[[UIColor redColor] colorWithAlphaComponent:0.7] set];
    CGContextFillEllipseInRect(context, rect);
    
    [[UIColor whiteColor] set];
    CGContextFillRect(context, CGRectMake(rect.size.width/2, rect.size.height/2 - 4,
                                          rect.size.width/2, 8));
    
    [[UIColor purpleColor] set];
    CGContextFillRect(context, CGRectMake(0, rect.size.height/2 - 4,
                                          rect.size.width/2, 8));
    
    [[UIColor orangeColor] set];
    CGContextTranslateCTM(context, rect.size.width/2, rect.size.height/2);
    CGContextRotateCTM(context, RADIANS_FROM_DEGREES(45));
    CGContextTranslateCTM(context, -rect.size.width/2, -rect.size.height/2);
    CGContextFillRect(context, CGRectMake(0, rect.size.height/2 - 4,
                                          rect.size.width, 8));
}
@end



@interface LPInfiniteScrollView : UIScrollView <UIScrollViewDelegate> {
    CGFloat _lastXContentOffset;
    CGFloat _lastYContentOffset;
}
@property (nonatomic, unsafe_unretained) LPCircleView *circle;
@end

@implementation LPInfiniteScrollView

@synthesize circle = _circle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lastXContentOffset = 0;
        _lastYContentOffset = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat currentYOffset = self.contentOffset.y;
    CGFloat currentXOffset = self.contentOffset.x;
    
    CGFloat diff = ((_lastYContentOffset - currentYOffset) / self.contentSize.height);
    CGFloat xDiff = ((_lastXContentOffset - currentXOffset) / self.contentSize.width);
    
    CGFloat operableDiff = fabsf(diff) > fabsf(xDiff) ? diff : xDiff;
    
    _circle.transform = CGAffineTransformRotate(_circle.transform, operableDiff*(2.*M_PI));
    
    CGFloat angle = DEGREES_FROM_RADIANS(atan2(_circle.transform.b, _circle.transform.a));
    if ((int)floorf(angle)%45 == 0) {
        NSLog(@"CLICK");
    }
    
    CGFloat contentHeight = self.contentSize.height;
    CGFloat centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0;
    CGFloat verticalDistanceFromCenter = fabs(currentYOffset - centerOffsetY);
    
    if (verticalDistanceFromCenter > (contentHeight / 3.0)) {
        self.contentOffset = CGPointMake(self.contentOffset.x, floorf(self.contentSize.height / 2.4));
        _lastYContentOffset = self.contentOffset.y;
    } else {
        _lastYContentOffset = currentYOffset;
    }
    
    CGFloat contentWidth = self.contentSize.width;
    CGFloat centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0;
    CGFloat horizontalDistanceFromCenter = fabsf(currentXOffset - centerOffsetX);
    
    if (horizontalDistanceFromCenter > (contentWidth / 3.0)) {
        self.contentOffset = CGPointMake(floorf(self.contentSize.width / 2.4), self.contentOffset.y);
        _lastXContentOffset = self.contentOffset.x;
    } else {
        _lastXContentOffset = currentXOffset;
    }
}

@end

@interface ADKViewController () <UIScrollViewDelegate> {
    LPInfiniteScrollView *_scroll;
    LPCircleView *_circle;
    ADKAudioGraph *_audio;
}

@end

@implementation ADKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect screen = [[UIScreen mainScreen] bounds];
	
    CGRect square = CGRectMake(floorf(-screen.size.height/2.2), floorf(screen.size.height/3.2), screen.size.height, screen.size.height);
    _circle = [[LPCircleView alloc] initWithFrame:CGRectInset(square, 20, 20)];
    _circle.userInteractionEnabled = NO;
    _circle.opaque = NO;
    
    _scroll = [[LPInfiniteScrollView alloc] initWithFrame:screen];
    _scroll.delegate = _scroll;
    _scroll.contentSize = CGSizeMake(1200, 2000);
    _scroll.contentOffset = CGPointMake(_scroll.contentSize.width / 2.0, _scroll.contentSize.height / 2.0);
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.circle = _circle;
    
#define PLAYHEAD_WIDTH 40
    
    CALayer *playhead = [CALayer layer];
    playhead.frame = CGRectMake(0, screen.size.height/2 - (PLAYHEAD_WIDTH/2), screen.size.width, PLAYHEAD_WIDTH);
    playhead.backgroundColor = [[UIColor whiteColor] CGColor];
    playhead.opacity = 0.4;
    
    [self.view addSubview:_scroll];
    [self.view addSubview:_circle];
    //\[self.view.layer addSublayer:playhead];
    
    _audio = [[ADKAudioGraph alloc] init];
    [_audio power];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
