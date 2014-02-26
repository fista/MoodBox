//
//  WSHomeViewController.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "WSSongs.h"
#import "WSUser.h"
#import "FadeAnimationController.h"
#import "WSAppDelegate.h"
@interface WSHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, MPMediaPickerControllerDelegate>
{
    WSAppDelegate *delegate;
    MPMusicPlayerController *musicPlayer;
    BOOL updateFlg;
    AVQueuePlayer *queuePlayer;
    
    NSTimer *tm;
    
    IBOutlet UILabel *songTitleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UIImageView *artworkImageView;
    
    IBOutlet UITableView *mainTableView;
    NSArray *moodList;
    
}
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

@end
