//
//  AppDelegate.m
//  Pedometer
//
//  Created by megil on 10/23/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    ViewController *viewControl = [ViewController new];
    self.window.rootViewController = viewControl;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    self.myLocationManager = [[CLLocationManager alloc] init];// 初始化
//    [self.myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];// 设置精度值
//    [self.myLocationManager setDelegate:self];// 设置代理
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    printf("\n applicationDidEnterBackground \n");
//    
//    //////////////////////////////////////
//    
//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//        
//        [self backgroundHandler];
//        
//    }];
//    
//    if (backgroundAccepted)
//        
//    {
//        NSLog(@"backgrounding accepted");
//    }
//    
//    [self backgroundHandler];
    
//    self.backgroundTaskIdentifier =[application beginBackgroundTaskWithExpirationHandler:^(void) {
//        
//        // 当应用程序留给后台的时间快要到结束时（应用程序留给后台执行的时间是有限的）， 这个Block块将被执行
//        // 我们需要在次Block块中执行一些清理工作。
//        // 如果清理工作失败了，那么将导致程序挂掉
//        
//        // 清理工作需要在主线程中用同步的方式来进行
//        [self endBackgroundTask];
//    }];
//    
//    // 模拟一个Long-Running Task
//    self.myTimer =[NSTimer scheduledTimerWithTimeInterval:1.0f
//                                                   target:self
//                                                 selector:@selector(timerMethod:)     userInfo:nil
//                                                  repeats:YES];
     //[NSRunLoop currentRunLoop];
    // 当程序退到后台时，进行定位的重新计算
    //self.executingInBackground = YES;
    //[self.myLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //[self.myLocationManager startUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)backgroundHandler {
    
    NSLog(@"### -->backgroundinghandler");
    
    UIApplication* app = [UIApplication sharedApplication];
    
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:self.bgTask];
        
        self.bgTask = UIBackgroundTaskInvalid;
        
    }];
    
    // Start the long-running task
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (1) {
            
            NSLog(@"counter:%d", self.counter++);
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.counter];
            sleep(1);
            
        }
        
    });
    
}

- (void)endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];// 停止定时器
            
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            // 销毁后台任务标识符
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}

// 模拟的一个 Long-Running Task 方法
- (void) timerMethod:(NSTimer *)paramSender{
    // backgroundTimeRemaining 属性包含了程序留给的我们的时间
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
    }
}

- (void)locationManager:(CLLocationManager *)manager

       didFailWithError:(NSError *)error

{
    
    NSLog(@"执行error");
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"GPS发生错误,请稍后再试" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(0);
}

@end
