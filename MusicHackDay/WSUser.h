//
//  WSUser.h
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WSSongs.h"
@interface WSUser : NSObject <CLLocationManagerDelegate>
{
    
}
-(void)getMyCurrentLocation;
-(void)getUserId:(void(^)())success faild:(void(^)())failed;
-(void)getFavList:(void(^)())success faild:(void(^)())failed;
+(WSUser *)user;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, retain) NSMutableArray *favList;

@end
