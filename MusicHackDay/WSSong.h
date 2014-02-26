//
//  WSSong.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSong : NSObject
{
}
@property (nonatomic) int songId;
@property (nonatomic, retain) NSString *albumArtUrl;
@property (nonatomic, retain) NSString *albumArtistName;
@property (nonatomic) int albumGnid;
@property (nonatomic, retain) NSString *albumTitle;
@property (nonatomic) int albumYear;
@property (nonatomic, retain) NSString *artistImageUrl;
@property (nonatomic, retain) NSString *mood;
@property (nonatomic, retain) NSString *previewUrl;
@property (nonatomic, retain) NSString *tempo;
@property (nonatomic, retain) NSString *trackArtistName;
@property (nonatomic) int trackGnid;
@property (nonatomic) int trackNumber;
@property (nonatomic, retain) NSString *trackTitle;
@property (nonatomic, retain) NSString *updatedAt;
@property (nonatomic, retain) NSString *createdAt;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) BOOL isLoadedArt;
@property (nonatomic) BOOL isPlayed;
@end
