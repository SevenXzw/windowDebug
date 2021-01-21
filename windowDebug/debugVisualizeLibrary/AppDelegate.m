//
//  AppDelegate.m
//  debugVisualizeLibrary
//
//  Created by 许振文 on 2021/1/21.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "GDDebugVisualizeView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate{
    GDDebugVisualizeView *_debugVisualizeView;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    UIColor *color = [UIColor colorWithRed:0.97 green:0.30 blue:0.30 alpha:1.00];
    CGFloat m_y = 60;
    _debugVisualizeView = [[GDDebugVisualizeView alloc] initWithFrame:CGRectMake(0, m_y, 40, 40)
                                                               color:color
                                                            delegate:nil];
    _debugVisualizeView.leanType = GDDebugVisualizeLeanTypeEachSide;
    [_debugVisualizeView show];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [_debugVisualizeView showLog:@"活跃！！！！！"];
}

@end
