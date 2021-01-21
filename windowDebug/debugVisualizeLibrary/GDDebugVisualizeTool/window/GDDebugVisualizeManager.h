//
//  GDDebugVisualizeManager.h
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDDebugVisualizeManager : NSObject

+ (instancetype)shared;

/**
 *  Get UIWindow based on key value
 *
 *  @param key key
 *
 *  @return window
 */
+ (UIWindow *)windowForKey:(NSString *)key;

/**
 *  Save a window and set the key
 *
 *  @param window window
 *  @param key    key
 */
+ (void)saveWindow:(UIWindow *)window forKey:(NSString *)key;

/**
 *  Destroy a window according to key
 *
 *  @param key       key
 */
+ (void)destroyWindowForKey:(NSString *)key;

/**
 *  Destroy all window
 */
+ (void)destroyAllWindow;

@end

NS_ASSUME_NONNULL_END
