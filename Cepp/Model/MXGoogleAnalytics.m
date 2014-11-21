//
//  MXGoogleAnalytics.m
//  Morbix
//
//  Created by Henrique Morbin on 26/07/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MXGoogleAnalytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation MXGoogleAnalytics

+ (void)ga_inicializeWithTrackingId:(NSString *)trackingId
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
}

#pragma mark - Application
+ (void)ga_trackApplicationLauchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *userInfoRemote = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (userInfoRemote != nil ){
        [MXGoogleAnalytics ga_trackEventWith:@"Launch" action:@"Remote"];
    }else{
        NSDictionary *userInfoLocal = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
        if (userInfoLocal != nil ){
            [MXGoogleAnalytics ga_trackEventWith:@"Launch" action:@"Local"];
        }else{
            [MXGoogleAnalytics ga_trackEventWith:@"Launch" action:@"Organic"];
        }
    }
}

#pragma mark - Screen
+ (void)ga_trackScreen:(NSString *)screen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:screen];
    
    // Previous V3 SDK versions
    //[tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Event
+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    // May return nil if a tracker has not already been initialized with a property
    // ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label          // Event label
                                                           value:value] build]];    // Event value
}

+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action label:(NSString *)label
{
    [MXGoogleAnalytics ga_trackEventWith:category action:action label:label value:nil];
}

+ (void)ga_trackEventWith:(NSString *)category action:(NSString *)action
{
    [MXGoogleAnalytics ga_trackEventWith:category action:action label:@"" value:nil];
}
@end
