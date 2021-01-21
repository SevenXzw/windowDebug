//
//  GDFPSMonitor.h
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDFPSMonitor : NSObject

@property (nonatomic, copy) void (^monitorBlock)(float fps);

/** 开始监测 */
- (void)startMonitor;

/** 结束监测 */
- (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
