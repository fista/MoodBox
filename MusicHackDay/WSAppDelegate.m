//
//  WSAppDelegate.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import "WSAppDelegate.h"

@implementation WSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[self getUUID] forKey:@"UUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
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

- (NSString*) getUUID { //UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

-(void)showLoadingView
{
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height)];
    loadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.center = self.window.rootViewController.view.center;
    [loadingView addSubview:indicator];
    [indicator startAnimating];
    
    [self.window addSubview:loadingView];
}

-(void)hideLoadingView
{
    [loadingView removeFromSuperview];
}

@end

//NSNull Crash対策
@implementation NSNull(IgnoreMessages)

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig=[[NSNull class] instanceMethodSignatureForSelector:aSelector];
    // Just return some meaningless signature
    if (sig == nil) {
        sig = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
    }
    
    return sig;
}
@end
