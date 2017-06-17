//
//  AppDelegate.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 17.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "DZUser.h"

NSTimeInterval const kRefreshTime = 120;

@interface AppDelegate ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) DZUser *user;
@end

@implementation AppDelegate

- (DZUser *)user
{
    if (_user == nil)
    {
        _user = [DZUser user];
        [_user refreshData];
    }
    return _user;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    ViewController *vc = (ViewController *)self.window.rootViewController;
    if ([vc isKindOfClass:[ViewController class]])
    {
        vc.user = self.user;
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.timer invalidate];
    self.timer = nil;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSParameterAssert(self.timer == nil);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTime repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.user refreshData];
    }];
}

@end
