//
//  MXGoogleAnalytics.h
//  Morbix
//
//  Created by Henrique Morbin on 26/07/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXGoogleAnalytics : NSObject

+ (void)ga_inicializeWithTrackingId:(NSString *)trackingId;

#pragma mark - Application
+ (void)ga_trackApplicationLauchingWithOptions:(NSDictionary *)launchOptions;

#pragma mark - Screen
+ (void)ga_trackScreen:(NSString *)screen;

#pragma mark - Event
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label;
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action;
@end
