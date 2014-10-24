//
//  AppDelegate.h
//  Pedometer
//
//  Created by megil on 10/23/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, assign) NSUInteger counter;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;
//@property (nonatomic, strong) CLLocationManager *myLocationManager;// 定位管理
@property (nonatomic, unsafe_unretained, getter=isExecutingInBackground) BOOL executingInBackground;// 判断程序是否在后台

@end
