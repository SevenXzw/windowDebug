//
//  GDDebugVisualizeView.h
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

/*
 we need dependend on framework
 QuartzCore.framework
 SystemConfiguration.framework
 AdSupport.framework
 CoreTelephony.framework
 AVFoundation.framework
 CFNetwork.framework
 */

#import <UIKit/UIKit.h>
#import "GDDebugVisualizeManager.h"
#import "GDDebugVisualizeContainer.h"
#import "GDDebugVisualizeController.h"

NS_ASSUME_NONNULL_BEGIN

@class GDDebugVisualizeView;
@protocol GDDebugVisualizeViewDelegate <NSObject>
/** callback for click on the GDDebugVisualizeView */
- (void)suspensionViewClick:(GDDebugVisualizeView *)suspensionView;
@end

typedef NS_ENUM(NSUInteger, GDDebugVisualizeLeanType) {
    /** Can only stay in the left and right */
    GDDebugVisualizeLeanTypeHorizontal,
    /** Can stay in the upper, lower, left, right */
    GDDebugVisualizeLeanTypeEachSide
};

@interface GDDebugVisualizeView : UIView

/** delegate */
@property (nonatomic, weak)id <GDDebugVisualizeViewDelegate>delegate;
/** lean type, default is ZYSuspensionViewLeanTypeHorizontal */
@property (nonatomic, assign) GDDebugVisualizeLeanType leanType;
/** container window */
@property (nonatomic, readonly) GDDebugVisualizeContainer *containerWindow;

/**
 Create a susView

 @param frame frame
 @param color background color
 @param delegate delegate for susView
 @return obj
 */
- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<GDDebugVisualizeViewDelegate>)delegate;

/**
 *  Show
 */
- (void)show;

/**
 *  Remove and dealloc
 */
- (void)remove;

/**
 *  Record log_text
 */
- (void)showLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
