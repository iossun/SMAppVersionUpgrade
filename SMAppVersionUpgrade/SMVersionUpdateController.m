//
//  SMVersionUpdateController.m
//  manniu
//
//  Created by 孙慕 on 2017/12/20.
//  Copyright © 2017年 蛮牛科技. All rights reserved.
//

#import "SMVersionUpdateController.h"

@interface SMVersionUpdateController ()

@end

@implementation SMVersionUpdateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageV.image = [UIImage imageNamed:@"launch.jpeg"];
    [self.view addSubview:imageV];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popUpAlert)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self popUpAlert];
}

- (void)popUpAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"发现需要升级的版本，现在去更新?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlStr]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlStr]];
            }
        });
    }];

    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Screen Orientation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
