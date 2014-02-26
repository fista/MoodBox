//
//  WSMoodViewController.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WSSongs.h"
#import "WSAppDelegate.h"

@interface WSMoodViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MPMediaPickerControllerDelegate>
{
    WSAppDelegate *delegate;
    AVQueuePlayer *queuePlayer;
    AVPlayer *player;
    NSMutableArray *playerItems;
    IBOutlet UICollectionView *mainCollectionView;
    
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *pauseButton;
    IBOutlet UILabel *songTitleLabel;
    IBOutlet UIImageView *artImageView;
    NSTimer *timer;
    
    IBOutlet UIProgressView *progressView;
    NSTimer *seekTimer;
}
@property (nonatomic, retain) NSString *moodTitle;
@property (nonatomic) int row;

@property (nonatomic) BOOL isLeftSide;

@property (strong, readonly, nonatomic) NSOperationQueue* operationQueue;
@property (nonatomic) BOOL searching;
@end
