//
//  GDDebugVisualizeContainer.h
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDDebugVisualizeContainer : UIWindow

@property (nonatomic, weak) UIWindow *lastKeyWindow;

@property (nonatomic, assign) BOOL gd_canAffectStatusBarAppearance;
@property (nonatomic, assign) BOOL gd_canBecomeKeyWindow;

@end

NS_ASSUME_NONNULL_END
