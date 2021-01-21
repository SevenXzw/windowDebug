//
//  GDDebugVisualizeManager.m
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import "GDDebugVisualizeManager.h"

@interface GDDebugVisualizeManager ()<CAAnimationDelegate>

/** save windows dictionary */
@property (nonatomic, strong) NSMutableDictionary *windowDic;

@end

@implementation GDDebugVisualizeManager

static GDDebugVisualizeManager *_instance;
+ (instancetype)shared{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
        });
    }
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}


#pragma mark - getter
- (NSMutableDictionary *)windowDic{
    if (!_windowDic) {
        _windowDic = [NSMutableDictionary dictionary];
    }
    return _windowDic;
}

#pragma mark - public methods

+ (UIWindow *)windowForKey:(NSString *)key{
    if (!key.length) {
        NSAssert(0, @"GDDebugVisualizeManager: 传入的 key 值不对");
        return nil;
    }
    
    return [[GDDebugVisualizeManager shared].windowDic objectForKey:key];
}

+ (void)saveWindow:(UIWindow *)window forKey:(NSString *)key{
    if (!key.length) {
        NSAssert(0, @"GDDebugVisualizeManager: 传入的 key 值不对");
        return;
    }
    if (!window) {
        NSAssert(0, @"GDDebugVisualizeManager: 不能传入空 window");
        return;
    }
    
    NSAssert([self windowForKey:key] == nil, @"GDDebugVisualizeManager: 已存在 key=\"%@\" 的 window", key);
    [[GDDebugVisualizeManager shared].windowDic setObject:window forKey:key];
}

+ (void)destroyWindowForKey:(NSString *)key{
    if (!key.length) {
        NSAssert(0, @"GDDebugVisualizeManager: 传入的 key 值不对");
        return;
    }

    UIWindow *window = [[GDDebugVisualizeManager shared].windowDic objectForKey:key];
    window.hidden = YES;
    if (window.rootViewController.presentedViewController) {
        [window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    window.rootViewController = nil;
    
    //出栈
    [GDDebugVisualizeManager unstackAreaController:window.rootViewController];
    
    [[GDDebugVisualizeManager shared].windowDic removeObjectForKey:key];
}

+ (void)destroyAllWindow{
    NSArray *allKeys = [GDDebugVisualizeManager shared].windowDic.allKeys.copy;
    for (NSString *key in allKeys) {
        [self destroyWindowForKey:key];
    }
}

+ (void)unstackAreaController:(UIViewController *)vc{
    
    if(vc.presentedViewController){
        [vc.presentedViewController dismissViewControllerAnimated:false completion:nil];
        [GDDebugVisualizeManager unstackAreaController:vc];
    }else if ([vc isKindOfClass:[UINavigationController class]]){
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 1){
            [svc popToRootViewControllerAnimated:false];
            [GDDebugVisualizeManager unstackAreaController:vc];
        }
    }
    
}

@end
