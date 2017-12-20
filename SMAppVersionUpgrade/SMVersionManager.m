//
//  SMVersionManager.m
//  SMAppVersionUpgrade
//
//  Created by 孙慕 on 2017/12/20.
//  Copyright © 2017年 孙慕. All rights reserved.
//

#import "SMVersionManager.h"
#import <UIKit/UIKit.h>
@interface SMVersionManager ()

@end

@implementation SMVersionManager


+ (instancetype)sharedInstance {
    static SMVersionManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
/**
 *  初始化信息配置
 */
- (void)configureApp{
    /**
     *  一大堆配置信息 初始化网络 设置基本颜色啥的
     */
    
    
    [self getWhiteVerdionList];
    
}

/**
 *  懒加载
 */
- (SMVersionModel *)versionInfo{
    if (!_versionInfo) {
        _versionInfo = [SMVersionModel new];
    }
    return _versionInfo;
}
/**
 *  请求白名单信息
 */
- (void)getWhiteVerdionList {
   
    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"version" ofType:@"json"];
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:jsonPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:nil];
    NSArray *dataArr = dic[@"data"];
    NSDictionary *iosDic = dataArr[0];
    NSArray *whiteList = iosDic[@"ios"];
     [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppShouldUpdate object:@{@"URI":@"11111"}];
    
    
    BOOL needUpdate = YES;
    for (NSString *version in whiteList) {
        NSString *verStr;
        if (version.length > 4) {
            verStr = [version substringToIndex:5];
        } else {
            verStr = version;
        }
        if ([verStr isEqualToString:VERSION]) {
            needUpdate = NO;
        }
    }
    if (needUpdate) {
        [SMVersionManager sharedInstance].needsForceUpdate = YES;
        
    }
    
    [[SMVersionManager sharedInstance]checkAppVersionIsInitiative];
    
}

- (void)checkAppVersionIsInitiative{
    /**
     *  APP_ID 请替换成自己的APPID
     */
    NSString *URLString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APP_ID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10.0f];
    __weak __typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && data.length > 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSArray *infoArray = [dict objectForKey:@"results"];
            if (infoArray && infoArray.count > 0) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                //描述
                weakSelf.versionInfo.releaseNote = releaseInfo[@"releaseNotes"];
                weakSelf.versionInfo.version = releaseInfo[@"version"];
                weakSelf.versionInfo.URI = releaseInfo[@"trackViewUrl"];
                
                if (weakSelf.needsForceUpdate) {
                    //强制更新 发送通知   通知接受对象可以更加自己项目情况来定
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppShouldUpdate object:@{@"URI":weakSelf.versionInfo.URI}];
                    return;
                }
                //是否忽略这个版本
                weakSelf.versionIgnored = ([weakSelf.versionInfo.version isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUpdateIgnoredVersion]]);
                //要判断这里忽略过的版本是不是更新了 和本地版本号已经一样了
                if ([VERSION isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUpdateIgnoredVersion]]) {
                    weakSelf.versionIgnored = NO;
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kUpdateIgnoredVersion];
                }
                weakSelf.hasNewVersion = ([VERSION compare:weakSelf.versionInfo.version options:NSNumericSearch] == NSOrderedAscending);
                
                if (weakSelf.versionIgnored) {
                    NSLog(@"忽略的版本");
                    return;
                }
                if (weakSelf.hasNewVersion) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版本%@",weakSelf.versionInfo.version] message:[NSString stringWithFormat:@"%@",weakSelf.versionInfo.releaseNote] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"立即更新",@"忽略此版本", nil];
                        alert.tag = 10000;
                        [alert show];
                    });
                }
            } else {
                NSLog(@"获取itunes版本失败");
            }
        }
        else {
            NSLog(@"获取itunes版本失败");
        }
        
        
    }];
    
    [task resume];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            //            NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=%@&mt=8", APP_ID];
            NSURL *url = [NSURL URLWithString:self.versionInfo.URI];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }else if(buttonIndex ==2){
            //忽略此版本
            [self ignoreCurrentVersion];
        }
    }
}

- (void)ignoreCurrentVersion {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.versionInfo.version forKey:kUpdateIgnoredVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(NSString *)getNewestVersion{
    return self.versionInfo.version;
}

-(NSString *)getCurrentVersion{
    return VERSION;
}

@end



@implementation SMVersionModel

@end
