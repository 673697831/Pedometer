//
//  ViewController.m
//  Pedometer
//
//  Created by megil on 10/23/14.
//  Copyright (c) 2014 megil. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property(nonatomic, weak) UIButton *startButton;
@property(nonatomic, weak) UILabel *timeLabel;
@property(nonatomic, weak) UILabel *stepNumberLabel;
@property(nonatomic, assign) NSUInteger counter;
@property(nonatomic, assign) NSInteger timeInterval;

@property(nonatomic, strong) CMMotionManager *manager;
@property(nonatomic, strong) NSMutableArray *mLastValues;
@property(nonatomic, strong) NSMutableArray *mLastDirections;
@property(nonatomic, strong) NSMutableArray *mLastExtremes;
@property(nonatomic, strong) NSMutableArray *mLastDiff;
@property(nonatomic, assign) NSInteger h;
@property(nonatomic, assign) CGFloat mYOffset;
@property(nonatomic, assign) CGFloat scale1;
@property(nonatomic, assign) CGFloat mLimit;
@property(nonatomic, assign) NSInteger mLastMatch;
@property(nonatomic, assign) long long start;
@property(nonatomic, assign) long long end;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, strong) CLLocationManager *myLocationManager;// 定位管理
@property(nonatomic, assign) BOOL status;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *startButton = [UIButton new];
    [startButton addTarget:self
                    action:@selector(clickButton:)
          forControlEvents:UIControlEventTouchUpInside];
    
    startButton.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:startButton];
    self.startButton = startButton;
    [self.startButton setTitle:@"开启计步器"
                      forState:UIControlStateNormal];
    
    UILabel *timeLabel = [UILabel new];
    [self.view addSubview:timeLabel];
    timeLabel.text = @"计时 00:00:00";
    self.timeLabel = timeLabel;
    
    UILabel *stepNumberLabel = [UILabel new];
    [self.view addSubview:stepNumberLabel];
    stepNumberLabel.text = @"计步 0";
    self.stepNumberLabel = stepNumberLabel;
    
    
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(200);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(startButton.mas_top).with.offset(-50);
    }];
    
    [stepNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(startButton.mas_bottom).with.offset(50);
    }];
    
    CMMotionManager *manager = [CMMotionManager new];
    manager.accelerometerUpdateInterval = 1./60;
    [manager startAccelerometerUpdates];
    self.manager = manager;
    [NSTimer scheduledTimerWithTimeInterval:1.0/5.0
                                     target:self
                                   selector:@selector(timerAction)
                                   userInfo:nil
                                    repeats:YES];
    NSMutableArray *extreme1;
    NSMutableArray *extreme2;
    
    for (int i = 0; i < 6; i ++) {
        [self.mLastValues addObject:@(0)];
        [self.mLastDirections addObject:@(0)];
        [extreme1 addObject:@(0)];
        [extreme2 addObject:@(0)];
        [self.mLastDiff addObject:@(0)];
    }
    
    [self.mLastExtremes addObject:extreme1];
    [self.mLastExtremes addObject:extreme2];
    self.h = 480;
    self.mYOffset = self.h * 0.5f;
    self.scale1 = -(self.h * 0.5f * (1.0f / (10.0 * 2)));
    self.mLimit = 10;
    self.mLastMatch = -1;
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
        NSError *audioSessionError = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError]){
            NSLog(@"Successfully set the audio session.");
        } else {
            NSLog(@"Could not set the audio session");
        }
        
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"mySong" ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
        
        if (self.audioPlayer != nil){
            self.audioPlayer.delegate = self;
            
            [self.audioPlayer setNumberOfLoops:-1];
            if ([self.audioPlayer prepareToPlay] && [self.audioPlayer play]){
                NSLog(@"Successfully started playing...");
            } else {
                NSLog(@"Failed to play.");
            }
        } else {
            
        }
    });
    
    self.myLocationManager = [[CLLocationManager alloc] init];// 初始化
    [self.myLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];// 设置精度值
    [self.myLocationManager setDelegate:self];// 设置代理
}

- (void)dealloc
{
    if(self.myLocationManager)
    {
        [self.myLocationManager stopUpdatingLocation];
    }
}

- (void)clickButton:(id)sender
{
    self.status = !self.status;
    
    if(self.status)
    {
        [self.startButton setTitle:@"停止计步器"
                          forState:UIControlStateNormal];
        [self.myLocationManager startUpdatingLocation];
    }else
    {
        [self.startButton setTitle:@"开启计步器"
                          forState:UIControlStateNormal];
        [self.myLocationManager stopUpdatingLocation];
    }
    
}

- (void)timerAction
{
    //NSLog(@"%f %f %f", self.manager.accelerometerData.acceleration.x, self.manager.accelerometerData.acceleration.y, self.manager.accelerometerData.acceleration.z);
    CGFloat x = self.manager.accelerometerData.acceleration.x;
    CGFloat y = self.manager.accelerometerData.acceleration.y;
    CGFloat z = self.manager.accelerometerData.acceleration.z;
   // NSLog(@"%f", sqrt(x*x+y*y+z*z));
    if (self.status)
    {
        if (sqrt(x*x+y*y+z*z) >2) {
            NSLog(@"我走路拉");
            self.counter ++;
        }
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.counter];

        NSInteger timeInterval = self.timeInterval/5;
        
        NSInteger hour = timeInterval / (60*60);
        timeInterval = timeInterval - hour * 60 * 60;
        NSInteger min = timeInterval / 60;
        timeInterval = timeInterval - min *60;
        NSInteger second = timeInterval;
        
        self.timeLabel.text = [NSString stringWithFormat:@"计时 %02d:%02d:%02d", hour, min, second];
        self.stepNumberLabel.text = [NSString stringWithFormat:@"计步 %d", self.counter];
        self.timeInterval ++;

    }else
    {
        self.timeInterval = 0;
        self.counter  = 0;
    }
    
    
}

- (void)check
{
    //CGFloat scale2 = -(h * 0.5f * (1.0f / (10.0)));
    //NSArray *mScale = @[@(scale1), @(scale2)];
    CGFloat vSum = 0;
    for (int i=0 ; i<3 ; i++) {
        vSum += self.mYOffset + self.manager.accelerometerData.acceleration.x * self.scale1;
    }
    
    int k = 0;
    float v = vSum / 3;
    
    CGFloat direction = (v > [self.mLastValues[k] floatValue] ? 1 : (v < [self.mLastValues[k] floatValue] ? -1 : 0));
    NSLog(@"%f, %f %f", direction, [self.mLastDirections[k] floatValue], v);
    if (direction == - [self.mLastDirections[k] floatValue]) {
        // Direction changed
        int extType = (direction > 0 ? 0 : 1); // minumum or maximum?
        self.mLastExtremes[extType][k] = self.mLastValues[k];
        CGFloat diff = abs([self.mLastExtremes[extType][k] floatValue] - [self.mLastExtremes[1 - extType][k] floatValue]);
        NSLog(@"%f, %f", diff, self.mLimit);
        if (diff > self.mLimit) {
            
            BOOL isAlmostAsLargeAsPrevious = diff > ([self.mLastDiff[k] floatValue] * 2/3);
            BOOL isPreviousLargeEnough = [self.mLastDiff[k] floatValue] > (diff/3);
            BOOL isNotContra = (self.mLastMatch != 1 - extType);
            
            if (isAlmostAsLargeAsPrevious && isPreviousLargeEnough && isNotContra) {
                self.end = [[NSDate date] timeIntervalSince1970];
                NSLog(@"%lld, %lld", self.start, self.end);
                if (self.end > (self.start + 200) && self.end < (self.start + 2000)) {// 此时判断为走了一步
                    NSLog(@"我走了一步拉");
                    self.mLastMatch = extType;
                    
                    self.start = self.end;
                } else if(self.end > (self.start + 2000)) {
                    self.mLastMatch = extType;
                    self.start = self.end;
                }
                else if(self.end < (self.start + 200)) {
                    self.mLastMatch = extType;
                    self.start = self.end;
                }
            }
            else {
                self.mLastMatch = -1;
            }
        }
        self.mLastDiff[k] = @(diff);
    }
    self.mLastDirections[k] = @(direction);
    self.mLastValues[k] = @(v);

}

- (void)locationManager:(CLLocationManager *)manager

       didFailWithError:(NSError *)error

{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"GPS发生错误,请稍后再试" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    exit(0);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
