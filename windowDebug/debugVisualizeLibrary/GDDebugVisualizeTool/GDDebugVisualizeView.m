//
//  GDDebugVisualizeView.m
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GDFPSMonitor.h"
#import "GDDebugSystemInfo.h"
#import "GDDebugVisualizeView.h"

/** 停顿时，窗口缺口部分内容大小 */
#define kLeanProportion (1/100.0)//(8/55.0)
/** 偏移值 */
#define kVerticalMargin 15.0

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

static inline NSInteger maxCount() { return 100;}

@interface GDDebugVisualizeView ()<CAAnimationDelegate>

/** 初始尺寸 */
@property (nonatomic, assign) CGRect        recordInitialFrame;
/** 拓展尺寸 */
@property (nonatomic, assign) CGRect        recordExpandFrame;
/** 临时尺寸 */
@property (nonatomic, assign) CGRect        recordTempFrame;
/** 控制是否显示拓展样式 */
@property (nonatomic, assign) BOOL          isExpand;
/** 显示FPS */
@property (nonatomic, strong) UILabel       *fpsLb;
/** 显示CPU使用情况 */
@property (nonatomic, strong) UILabel       *cpuLb;
/** 显示内存使用情况 */
@property (nonatomic, strong) UILabel       *memoryLb;
/** 显示日志textView */
@property (nonatomic, strong) UITextView    *logTV;
/** FPS探测器 */
@property (nonatomic, strong) GDFPSMonitor  *monitor;
/** 日志数组 */
@property (nonatomic, strong) NSMutableArray *logArr;

@end

@implementation GDDebugVisualizeView

#pragma mark Suspend

- (void)dealloc
{
    NSLog(@"GDDebugVisualizeView -> dealloc");
//    fprintf(stderr,"[%s ● %s ● %d] Func ★ <%s: %p> ◉ %s\n", __TIME__, ([NSString stringWithFormat:@"%s", __FILE__].lastPathComponent).UTF8String, __LINE__, NSStringFromClass(self.class).UTF8String, self,  NSStringFromSelector(_cmd).UTF8String );
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark lazy
- (UILabel *)fpsLb {
    if (!_fpsLb) {
        _fpsLb = [self label3Index:0];
        _fpsLb.frame = CGRectMake(0, 0, self.recordInitialFrame.size.width, _fpsLb.frame.size.height);
    }
    return _fpsLb;
}

- (UILabel *)cpuLb {
    if (!_cpuLb) {
        _cpuLb = [self label3Index:1];
    }
    return _cpuLb;
}

- (UILabel *)memoryLb {
    if (!_memoryLb) {
        _memoryLb = [self label3Index:2];
    }
    return _memoryLb;
}

- (UITextView *)logTV {
    if (!_logTV) {
        CGFloat m_y = CGRectGetMaxY(_fpsLb.frame);
        _logTV = [[UITextView alloc] initWithFrame:CGRectMake(0, m_y, self.recordExpandFrame.size.width, self.recordExpandFrame.size.width-m_y)];
        [_logTV setShowsVerticalScrollIndicator:NO];
        [_logTV setShowsHorizontalScrollIndicator:NO];
        [_logTV setBounces:NO];
        [_logTV setEditable:NO];
        [_logTV setFont:[UIFont fontWithName:@"Courier" size:12]];
        [_logTV setTextColor:[UIColor greenColor]];
        [_logTV setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2]];
        [_logTV.layoutManager setAllowsNonContiguousLayout:NO];
    }
    return _logTV;
}

- (GDFPSMonitor *)monitor {
    if (!_monitor) {
        _monitor = [[GDFPSMonitor alloc] init];
    }
    return _monitor;
}

- (NSMutableArray *)logArr {
    if (!_logArr) {
        _logArr = [NSMutableArray arrayWithCapacity:maxCount()];
    }
    return _logArr;
}

#pragma mark public
- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<GDDebugVisualizeViewDelegate>)delegate{
    if(self = [super initWithFrame:frame])
    {
        //保持沾边
        BOOL canChangeFrame = false;
        CGFloat m_x = frame.origin.x;
        CGFloat m_y = frame.origin.y;
        if(m_y<=0){
            m_y = -frame.size.height * kLeanProportion;
            canChangeFrame = true;
        }
        if(m_x<=0){
            if(canChangeFrame){
                m_y = 0;
            }
            m_x = -frame.size.width * kLeanProportion;
            canChangeFrame = true;
        }
        if(canChangeFrame){
            self.frame = (CGRect){m_x,m_y,frame.size};
        }
        self.recordInitialFrame = self.frame;
        CGFloat m_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat s_h = 320;
//        CGFloat diameter = sqrt(m_w*m_w + s_h*s_h);
//        (CGRect){(m_w-diameter)/2., (s_h-diameter)/2., diameter, diameter};
        self.recordExpandFrame = (CGRect){CGPointZero,m_w,s_h};
        self.isExpand = false;
        
        self.delegate = delegate;
        self.userInteractionEnabled = true;
        self.backgroundColor = color;
        self.alpha = .7;
//        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        [self addSubview:self.fpsLb];
        [self addSubview:self.cpuLb];
        [self addSubview:self.memoryLb];
        [self addSubview:self.logTV];
        self.clipsToBounds = true;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)show{
    if ([GDDebugVisualizeManager windowForKey:self.windowKey]) return;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.layer.cornerRadius = self.frame.size.width <= self.frame.size.height ? self.frame.size.width * .5f : self.frame.size.height * .5f;
    
    self.fpsLb.alpha = 1;
    self.cpuLb.alpha = 0;
    self.memoryLb.alpha = 0;
    self.logTV.alpha = 0;
    
    GDDebugVisualizeContainer *backWindow = [[GDDebugVisualizeContainer alloc] initWithFrame:self.recordInitialFrame];
    backWindow.rootViewController = [[GDDebugVisualizeController alloc] init];
    [backWindow.rootViewController.view addSubview:self];
    [backWindow setHidden:NO];
    [GDDebugVisualizeManager saveWindow:backWindow forKey:self.windowKey];
    
    __weak __typeof (self)weakSelf = self;
    [self.monitor setMonitorBlock:^(float fps) {
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        [strongSelf handleFPS:fps];
        [strongSelf handleCPU:[GDDebugSystemInfo gd_CPUUsage]];
        [strongSelf handleMemory:[GDDebugSystemInfo gd_MemoryUsage]];
    }];
    [self.monitor startMonitor];
    
    [self showLog:@"[GDDebugVisualizeView show]"];
    [self collectInfo];
}

- (void)remove{
    [self.monitor stopMonitor];
    [self showLog:@"[GDDebugVisualizeView remove]"];
    [GDDebugVisualizeManager destroyWindowForKey:self.windowKey];
}

- (void)showLog:(NSString *)log {
    if (log && log.length) {
        if (self.logArr.count > (maxCount()-1)) {
            [self.logArr removeObjectAtIndex:0];
        }
        NSLog(@"%@", log);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"HH:mm:ss:SSS"];
        NSString *timeString = [dateFormatter stringFromDate:[NSDate date]];
        
        [self.logArr addObject:[NSString stringWithFormat:@"%@ %@ %drow %@\n", timeString, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, log]];
    }
    NSString *showLog = [NSString string];
    for (NSString *tempLog in self.logArr) {
        showLog = [showLog stringByAppendingString:tempLog];
    }
    if (showLog && showLog.length) {
        [self.logTV setText:showLog];
        [self.logTV scrollRangeToVisible:NSMakeRange(showLog.length - 1, 1)];
    }
}

#pragma mark private
- (void)handleFPS:(float)fps {
    NSString *string = [NSString stringWithFormat:@"%@%.2f", @"FPS:", fps];
    NSRange range1 = NSMakeRange(0, string.length);
    NSRange range2 = [string rangeOfString:@"FPS:" options:NSBackwardsSearch];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range1];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:range1];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range2];
    self.fpsLb.attributedText = attributedStr;
}

- (void)handleCPU:(float)cpu {
    NSString *string = [NSString stringWithFormat:@"%@%.2f%%", @"CPU:", cpu];
    NSRange range1 = NSMakeRange(0, string.length);
    NSRange range2 = [string rangeOfString:@"CPU:" options:NSBackwardsSearch];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range1];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:range1];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range2];
    self.cpuLb.attributedText = attributedStr;
}

- (void)handleMemory:(float)memory {
    NSString *string = [NSString stringWithFormat:@"%@%.2fM", @"Memory:", memory];
    NSRange range1 = NSMakeRange(0, string.length);
    NSRange range2 = [string rangeOfString:@"Memory:" options:NSBackwardsSearch];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range1];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:range1];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range2];
    self.memoryLb.attributedText = attributedStr;
}

- (UILabel *)label3Index:(NSInteger)index {
    CGFloat m_w = self.recordExpandFrame.size.width/3.0;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(index * m_w, 0, m_w, self.recordInitialFrame.size.height)];
    [label setFont:[UIFont systemFontOfSize:15]];
    [label setTextColor:[UIColor greenColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:1];
    label.adjustsFontSizeToFitWidth = true;
    return label;
}

- (UIBezierPath *)smallPath {
    return [UIBezierPath bezierPathWithOvalInRect:(CGRect){self.frame.origin,self.recordInitialFrame.size}];
}

- (UIBezierPath *)bigPath {
    return [UIBezierPath bezierPathWithOvalInRect:(CGRect){self.frame.origin,self.recordExpandFrame.size}];
}

- (void)mathExpandFrame:(BOOL)expand{
    
    CGFloat m_x = self.containerWindow.frame.origin.x;
    CGFloat m_y = self.containerWindow.frame.origin.y;
    CGFloat s_w = [UIScreen mainScreen].bounds.size.width;
    CGFloat s_h = [UIScreen mainScreen].bounds.size.height;
    if (expand) {
        self.recordTempFrame = self.containerWindow.frame;
        CGFloat l_x = fabs(m_x - self.recordExpandFrame.size.width);
        if(l_x>=s_w){
            m_x = 0;
        }else{
            if(self.recordExpandFrame.size.width>=s_w){
                m_x = 0;
            }else if((m_x+self.recordExpandFrame.size.width)>s_w){
                m_x = s_w-self.recordExpandFrame.size.width;//(s_w-l_x)*0.5;
            }
               
        }
        CGFloat l_y = fabs(m_y - self.recordExpandFrame.size.height);
        if(l_y>=s_h){
            m_y = 0;
        }else{
            if(self.recordExpandFrame.size.height>=s_h){
                m_y = 0;
            }else if((m_y+self.recordExpandFrame.size.height)>s_h){
                m_y = s_h-self.recordExpandFrame.size.height;//(s_h-l_y)*0.5;
            }
                
        }
        
        self.containerWindow.frame = (CGRect){m_x,m_y,self.recordExpandFrame.size};
        self.frame = self.recordExpandFrame;
        self.fpsLb.frame = CGRectMake(0, 0, self.recordExpandFrame.size.width/3.0, self.fpsLb.frame.size.height);
        self.cpuLb.alpha = 1;
        self.memoryLb.alpha = 1;
        self.logTV.alpha = 1;
        
    } else {
        self.containerWindow.frame = self.recordTempFrame;
        self.frame = (CGRect){CGPointZero,self.recordInitialFrame.size};
        self.fpsLb.frame = CGRectMake(0, 0, self.recordInitialFrame.size.width, self.fpsLb.frame.size.height);
        self.cpuLb.alpha = 0;
        self.memoryLb.alpha = 0;
        self.logTV.alpha = 0;
    }
}

- (void)collectInfo{
    [self showLog:[NSString stringWithFormat:@"内网ip：%@",[GDDebugSystemInfo gd_WANIPAddress]]];
    [self showLog:[NSString stringWithFormat:@"当前外网ip：%@",[GDDebugSystemInfo gd_InternetIPAddress]]];
    [self showLog:[NSString stringWithFormat:@"当前wifi名称：%@",[GDDebugSystemInfo gd_WifiSSID]]];
    
    [self showLog:[NSString stringWithFormat:@"当前网络访问是否使用代理：%d",[GDDebugSystemInfo gd_IsViaProxy]]];
    [self showLog:[NSString stringWithFormat:@"系统开机时间：%f",[GDDebugSystemInfo gd_BootTime]]];
    [self showLog:[NSString stringWithFormat:@"是否破解：%d",[GDDebugSystemInfo gd_Cracked]]];
    [self showLog:[NSString stringWithFormat:@"是否越狱：%d",[GDDebugSystemInfo gd_JailBreak]]];
    [self showLog:[NSString stringWithFormat:@"是否插入SIM卡：%d",[GDDebugSystemInfo gd_SimInserted]]];
    [self showLog:[NSString stringWithFormat:@"CPU型号：%lu",(unsigned long)[GDDebugSystemInfo gd_CPUNumber]]];
    [self showLog:[NSString stringWithFormat:@"当前电量：%f",[GDDebugSystemInfo gd_BatteryLevel]]];
    [self showLog:[NSString stringWithFormat:@"电池状态：%@",[GDDebugSystemInfo gd_BatteryState]]];
    [self showLog:[NSString stringWithFormat:@"屏幕亮度：%f",[GDDebugSystemInfo gd_ScreenBrightness]]];
    [self showLog:[NSString stringWithFormat:@"音量大小：%f",[GDDebugSystemInfo gd_DeviceVolume]]];
    
    
    [self showLog:[NSString stringWithFormat:@"磁盘大小：%ld",[GDDebugSystemInfo gd_DiskTotalSize]]];
    [self showLog:[NSString stringWithFormat:@"剩余磁盘大小：%ld",[GDDebugSystemInfo gd_DiskFreeSize]]];
}

#pragma mark getter
- (NSString *)windowKey{
    return @"gd_debug_visualize_window_key";
}

- (GDDebugVisualizeContainer *)containerWindow{
    return (GDDebugVisualizeContainer *)[GDDebugVisualizeManager windowForKey:self.windowKey];
}

#pragma mark - event response
- (void)handlePanGesture:(UIPanGestureRecognizer*)p{
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        self.containerWindow.center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        self.alpha = .7;
        
        CGFloat ballWidth = self.frame.size.width;
        CGFloat ballHeight = self.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;

        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(screenWidth - left);
        CGFloat top = fabs(panPoint.y);
        CGFloat bottom = fabs(screenHeight - top);
        
        CGFloat minSpace = 0;
        if (self.leanType == GDDebugVisualizeLeanTypeHorizontal) {
            minSpace = MIN(left, right);
        }else{
            minSpace = MIN(MIN(MIN(top, left), bottom), right);
        }
        CGPoint newCenter = CGPointZero;
        CGFloat targetY = 0;
        
        CGFloat pc_h = kVerticalMargin;
        if(self.containerWindow.frame.size.width>=screenWidth){
            pc_h = 0;
        }
        //Correcting Y
        if (panPoint.y < pc_h + ballHeight / 2.0) {
            targetY = pc_h + ballHeight / 2.0;
        }else if (panPoint.y > (screenHeight - ballHeight / 2.0 - pc_h)) {
            targetY = screenHeight - ballHeight / 2.0 - pc_h;
        }else{
            targetY = panPoint.y;
        }
        
        CGFloat centerXSpace = (0.5 - kLeanProportion) * ballWidth;
        CGFloat centerYSpace = (0.5 - kLeanProportion) * ballHeight;

        CGFloat compare_y = ballHeight*0.5;
        CGFloat iponex_h = 60;
        if (minSpace == left) {
            CGFloat m_x = centerXSpace;
            if(ballWidth>=screenWidth){
                m_x = screenWidth * .5;
            }
            if(iPhoneX){
                if(targetY<compare_y+iponex_h){//up
                    targetY = compare_y+iponex_h;
                }else {//down
                    CGFloat m_c_y = screenHeight - targetY;
                    if(m_c_y<compare_y+iponex_h){
                        targetY = screenHeight-compare_y-iponex_h;
                    }
                }
            }
            newCenter = CGPointMake(m_x, targetY);
        }else if (minSpace == right) {
            CGFloat m_x = screenWidth - centerXSpace;
            if(ballWidth>=screenWidth){
                m_x = screenWidth * .5;
            }
            if(iPhoneX){
                if(targetY<compare_y+iponex_h){//up
                    targetY = compare_y+iponex_h;
                }else {//down
                    CGFloat m_c_y = screenHeight - targetY;
                    if(m_c_y<compare_y+iponex_h){
                        targetY = screenHeight-compare_y-iponex_h;
                    }
                }
            }
            newCenter = CGPointMake(m_x, targetY);
        }else if (minSpace == top) {
            CGFloat m_x = panPoint.x;
            if(ballWidth>=screenWidth){
                m_x = screenWidth * .5;
            }
            if(iPhoneX){
                if(centerYSpace<compare_y){
                    centerYSpace = compare_y+iponex_h;
                }
            }
            newCenter = CGPointMake(m_x, centerYSpace);
        }else {
            CGFloat m_x = panPoint.x;
            if(ballWidth>=screenWidth){
                m_x = screenWidth * .5;
            }
            CGFloat m_c_y = screenHeight - centerYSpace;
            if(iPhoneX){
                if(screenHeight-m_c_y<(compare_y+iponex_h)){
                    m_c_y = screenHeight-compare_y-iponex_h;
                }
            }
            newCenter = CGPointMake(m_x, m_c_y);
        }
        
        __weak __typeof (self)weakSelf = self;
        [UIView animateWithDuration:.25 animations:^{
            weakSelf.containerWindow.center = newCenter;
        }];
    }else{
        NSLog(@"pan state : %zd", p.state);
    }
}

- (void)click{
    if([self.delegate respondsToSelector:@selector(suspensionViewClick:)]){
        [self.delegate suspensionViewClick:self];
    }
    
    self.isExpand = !self.isExpand;
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id) (self.isExpand ? [self smallPath].CGPath : [self bigPath].CGPath);
    maskLayerAnimation.toValue = (__bridge id) (self.isExpand ? [self bigPath].CGPath : [self smallPath].CGPath);
    maskLayerAnimation.duration = 0.3;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    maskLayerAnimation.delegate = self;
    maskLayerAnimation.removedOnCompletion = NO; // 动画结束后不移除
    maskLayerAnimation.fillMode = kCAFillModeForwards;//这两句的效果是让动画结束后不会回到原处，必须加
    [self.layer addAnimation:maskLayerAnimation forKey:@"path"];
    
    __weak __typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf mathExpandFrame:weakSelf.isExpand];
    
    }];
//    [self layoutSubviews];
}

#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

}

@end
