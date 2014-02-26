//
//  WSFavListViewController.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/23.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSUser.h"
@interface WSFavListViewController : UIViewController
{
    IBOutlet UITableView *mainTableView;
}
@property (nonatomic, retain) UIImage *bgImage;

@end
