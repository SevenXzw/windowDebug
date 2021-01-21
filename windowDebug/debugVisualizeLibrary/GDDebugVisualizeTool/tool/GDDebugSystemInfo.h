//
//  GDDebugSystemInfo.h
//  GDSdk
//
//  Created by 许振文 on 2021/1/20.
//  Copyright © 2021 许振文. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,DeviceType) {
    
    Unknown = 0,
    Simulator,
    IPhone_1G,          //基本不用
    IPhone_3G,          //基本不用
    IPhone_3GS,         //基本不用
    IPhone_4,           //基本不用
    IPhone_4s,          //基本不用
    IPhone_5,
    IPhone_5C,
    IPhone_5S,
    IPhone_SE,
    IPhone_6,
    IPhone_6P,
    IPhone_6s,
    IPhone_6s_P,
    IPhone_7,
    IPhone_7P,
    IPhone_8,
    IPhone_8P,
    IPhone_X,
};

@interface GDDebugSystemInfo : NSObject

/** bundleName (show in SpringBoard) */
+ (NSString *)gd_AppBundleName;
/** bundleID com.**.app */
+ (NSString *)gd_AppBundleID;
/** 版本号 1.1.1 */
+ (NSString *)gd_AppVersion;
/** build 号 111 */
+ (NSString *)gd_AppBuildNumber;

/** 获取IDFA */
+ (NSString *)gd_IDFA;
/** 获取IDFV */
+ (NSString *)gd_IDFV;
/** 获取UUID */
+ (NSString *)gd_UUID;
/** 系统版本 */
+ (NSString *)gd_SystemVersion;
/** 获取系统型号 用于判断 */
+ (DeviceType)deviceType;
/** 获取设备型号 用于显示 */
+ (NSString *)gd_DeviceModel;
/** 获取设备名字 */
+ (NSString *)gd_DeviceName;
/** 获取磁盘大小 */
+ (long)gd_DiskTotalSize;
/** 获取磁盘剩余空间 */
+ (long)gd_DiskFreeSize;
/** 获取电量 */
+ (float)gd_BatteryLevel;
/** 获取电池的状态 */
+ (NSString *)gd_BatteryState;
/** 屏幕亮度 */
+ (float)gd_ScreenBrightness;
/** 音量大小 */
+ (float)gd_DeviceVolume;
/** wifi名称 */
+ (NSString *)gd_WifiSSID;
/** 网络制式 */
+ (NSString *)gd_NetCarrier;
/** 获取内网ip地址 */
+ (NSString *)gd_WANIPAddress;
/** 获取外网ip地址 */
+ (NSString *)gd_InternetIPAddress;
/** 是否被破解 */
+ (BOOL)gd_Cracked;
/** 判断是否越狱 */
+ (BOOL)gd_JailBreak;
/** 判断是否插入sim卡 */
+ (BOOL)gd_SimInserted;
/** 获取系统开机时间到1970时间差值(毫秒) */
+ (NSTimeInterval)gd_BootTime;
/** 用户是否使用代理 */
+ (BOOL)gd_IsViaProxy;

/** CPU频率 */
+ (NSUInteger)gd_CPUFrequency;
/** 总线频率 */
+ (NSUInteger)gd_BusFrequency;
/** ram大小 */
+ (NSUInteger)gd_RamSize;
/** CPU型号 */
+ (NSUInteger)gd_CPUNumber;
/** 总内存 */
+ (NSUInteger)gd_TotalMemory;
/** 用户内存 */
+ (NSUInteger)gd_UserMemory;
/** 内存使用状况 */
+ (float)gd_MemoryUsage;
/** CPU使用情况(包含监控线程) 和xCode不一致 */
+ (float)gd_CPUUsage;
/** CPU使用情况(排除监控线程) 和xCode不一致 */
+ (float)gd_CPUUsage2;

@end

NS_ASSUME_NONNULL_END
