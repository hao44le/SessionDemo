//
//  AppDelegate.h
//  SessionDemo
//
//  Created by Gelei Chen on 19/3/2017.
//  Copyright © 2017 AISense Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEVViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) void(^backgroundSessionCompletionHandler)();
@property (strong,nonatomic) NEVViewController * downloadVC;

@end

