//
//  WSAppDelegate.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIView *loadingView;
}

@property (strong, nonatomic) UIWindow *window;
-(void)showLoadingView;
-(void)hideLoadingView;

@end
