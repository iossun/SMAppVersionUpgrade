//
//  SMVersionManager.h
//  SMAppVersionUpgrade
//
//  Created by 孙慕 on 2017/12/20.
//  Copyright © 2017年 孙慕. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kNotificationAppShouldUpdate = @"appShouldUpdate";
static NSString *const kUpdateIgnoredVersion = @"updateIgnoredVersion";

#define VERSION (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_ID @"1318137387"

@class SMVersionModel;
@interface SMVersionManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) SMVersionModel *versionInfo;


/// 新版本是否已忽略
@property (readwrite, nonatomic) BOOL versionIgnored;
/// 是否强制用户升级
@property (readwrite, nonatomic) BOOL needsForceUpdate;
/**
 *  是否有新版本
 */
@property (readwrite, nonatomic) BOOL hasNewVersion;

- (void)configureApp;

-(NSString *)getNewestVersion;

-(NSString *)getCurrentVersion;
@end






@interface SMVersionModel : NSObject
/// 版本号
@property (strong, nonatomic) NSString *version;

/// 标识
@property (strong, nonatomic) NSString *URI;

/// 描述
@property (strong, nonatomic) NSString *releaseNote;

/// 最低版本
@property (strong, nonatomic) NSString *minimalRequiredVersion;
@end
