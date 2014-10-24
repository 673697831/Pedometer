//
//  ViewController.h
//  Pedometer
//
//  Created by megil on 10/23/14.
//  Copyright (c) 2014 megil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<AVAudioPlayerDelegate, CLLocationManagerDelegate>

@end
