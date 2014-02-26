//
//  WSSongs.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSong.h"
#import "WSUser.h"
@interface WSSongs : NSObject
{
    
}
@property (nonatomic, retain) NSMutableArray *songList;
@property (nonatomic, retain) NSString *currentMood;
@property (nonatomic) int latestSongId;
@property (nonatomic, retain) WSSong *tmpSong;
+(WSSongs *)songs;
-(void)sendMusicWithTitle:(NSString *)title albumName:(NSString *)albumName artist:(NSString *)artist  success:(void(^)())success faild:(void(^)())failed;
-(void)getSongList:(NSString *)mood success:(void(^)())success faild:(void(^)())failed;
-(void)getMoreSongList:(NSString *)mood success:(void(^)())success faild:(void(^)())failed;
-(void)favSong:(void(^)())success faild:(void(^)())failed;
-(void)searchSong:(int)trackGnid success:(void(^)(WSSong *song))success faild:(void(^)())failed;
@end
