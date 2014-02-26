//
//  WSUser.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import "WSUser.h"
@implementation WSUser
static WSUser *user = nil;
+ (WSUser *)user
{
    if (user == nil) {
        user = [[super allocWithZone:NULL] init];
    }
    return user;
}

-(void)getUserId:(void(^)())success faild:(void(^)())failed
{
    NSString *url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/users/add?uuid=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]];
    NSString *encodedString = [url stringByAddingPercentEscapesUsingEncoding:
                               NSUTF8StringEncoding];
    NSLog(@"%@", encodedString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               if (error) {
                                   NSLog(@"%@", [error description]);
                                   return;
                               }
                               id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:&error];
                               
                               NSLog(@"%@", jsonData);
                               
                               if (jsonData != nil) {
                                   int userId = [[jsonData objectForKey:@"id"] intValue];
                                   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   success();
                               }else{
                                   failed();
                               }
                           }];

}

-(void)getMyCurrentLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        NSLog(@"Start updating location.");
        
    } else {
        NSLog(@"The location services is disabled.");
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    _latitude = newLocation.coordinate.latitude;
    _longitude = newLocation.coordinate.longitude;
    NSLog(@"%f %f", _latitude, _longitude);
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

-(void)getFavList:(void (^)())success faild:(void (^)())failed
{
    _favList = [[NSMutableArray alloc] init];
    NSString *url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/favorites/list?user_id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]];
    NSString *encodedString = [url stringByAddingPercentEscapesUsingEncoding:
                               NSUTF8StringEncoding];
    NSLog(@"%@", encodedString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               if (error) {
                                   NSLog(@"%@", [error description]);
                                   return;
                               }
                               id jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:&error];
                               
                               NSLog(@"%@", jsonData);
                               
                               if (jsonData != nil){
                                   NSMutableArray *list = [[NSMutableArray alloc] initWithArray:jsonData];
                                   for (int i = 0; i < list.count; i++) {
                                       NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[list objectAtIndex:i]];
                                       [[WSSongs songs] searchSong:[[dic objectForKey:@"song_id"] intValue] success:^(WSSong *song){
                                           [_favList addObject:song];
                                           success();
                                       } faild:^(void){}];
                                   }
                                   
                               }else{
                                   failed();
                               }
                           }];
}
@end
