//
//  GDDebugVisualizeContainer.m
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import "GDDebugVisualizeContainer.h"

@implementation GDDebugVisualizeContainer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark Suspend
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = 1000000;
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - private api

#if DEBUG
- (BOOL)_canAffectStatusBarAppearance
{
    return self.gd_canAffectStatusBarAppearance;
}

- (bool)_canBecomeKeyWindow
{
    return self.gd_canBecomeKeyWindow;
}
#endif

@end
