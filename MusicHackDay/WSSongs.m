//
//  WSSongs.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import "WSSongs.h"

@implementation WSSongs
static WSSongs *songs = nil;
+ (WSSongs *)songs
{
    if (songs == nil) {
        songs = [[super allocWithZone:NULL] init];
    }
    return songs;
}

- (NSMutableArray *)randomizedArray:(NSMutableArray *)filename{
    
    srand([[NSDate date] timeIntervalSinceReferenceDate]);
    int i = (int)[filename count];
    while(--i) {
        int j = rand() % (i+1);
        [filename exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    return filename;
}

-(void)sendMusicWithTitle:(NSString *)title albumName:(NSString *)albumName artist:(NSString *)artist  success:(void(^)())success faild:(void(^)())failed
{
    float latitude = 0.0f;
    float longitude = 0.0f;
    if ([WSUser user].latitude == 0.0 || [WSUser user].longitude == 0.0) {
        latitude = 35.681111;
        longitude = 139.766667;
    }else{
        latitude = [WSUser user].latitude;
        longitude = [WSUser user].longitude;
    }
    
    NSMutableArray *mapList = [[NSMutableArray alloc] init];
    NSMutableArray *latitudeList = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:37.331667],[NSNumber numberWithFloat:51.487222],[NSNumber numberWithFloat:34.402814],[NSNumber numberWithFloat:35.658333],[NSNumber numberWithFloat:35.658611],[NSNumber numberWithFloat:35.670167],[NSNumber numberWithFloat:35.646667],[NSNumber numberWithFloat:35.6435],[NSNumber numberWithFloat:35.690833],[NSNumber numberWithFloat:41.3825],[NSNumber numberWithFloat:45.508889],[NSNumber numberWithFloat:40.712778],[NSNumber numberWithFloat:48.86223],[NSNumber numberWithFloat:-37.820556],[NSNumber numberWithFloat:31.166667],[NSNumber numberWithFloat:-22.908333], nil];
    NSMutableArray *longitudeList = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:-122.030833],[NSNumber numberWithFloat:-0.124444],[NSNumber numberWithFloat:132.458967],[NSNumber numberWithFloat:139.708333],[NSNumber numberWithFloat:139.701111],[NSNumber numberWithFloat:139.702694],[NSNumber numberWithFloat:139.710139],[NSNumber numberWithFloat:139.671167],[NSNumber numberWithFloat:139.700278],[NSNumber numberWithFloat:2.176944],[NSNumber numberWithFloat:-73.554167],[NSNumber numberWithFloat:-74.006111],[NSNumber numberWithFloat:2.351074],[NSNumber numberWithFloat:144.961389],[NSNumber numberWithFloat:121.483333],[NSNumber numberWithFloat:-43.196389], nil];
    for (int i = 0; i < [latitudeList count]; i++) {
        NSDictionary *mapDic = [NSDictionary dictionaryWithObjectsAndKeys:[latitudeList objectAtIndex:i], @"latitude", [longitudeList objectAtIndex:i], @"longitude", nil];
        [mapList addObject:mapDic];
    }
    
    NSMutableArray *randomizedMapList = [[NSMutableArray alloc] initWithArray:[self randomizedArray:mapList]];
    NSDictionary *finalMapList = [NSDictionary dictionaryWithDictionary:randomizedMapList.firstObject];
    
    latitude = [[finalMapList objectForKey:@"latitude"] floatValue];
    longitude = [[finalMapList objectForKey:@"longitude"] floatValue];
    
    NSString *url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/songs/search?artist=%@&album=%@&title=%@&latitude=%f&longitude=%f&user_id=%d", artist, albumName, title, latitude, longitude, [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] intValue]];
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
                                   _currentMood = [jsonData objectForKey:@"mood"];
                                   _tmpSong = [[WSSong alloc] init];
                                   _tmpSong.songId = [[jsonData objectForKey:@"id"] intValue];
                                   _tmpSong.albumArtUrl = [jsonData objectForKey:@"album_art_url"];
                                   _tmpSong.albumArtistName = [jsonData objectForKey:@"album_artist_name"];
                                   _tmpSong.albumGnid = [[jsonData objectForKey:@"album_gnid"] intValue];
                                   _tmpSong.albumTitle = [jsonData objectForKey:@"album_title"];
                                   _tmpSong.albumYear = [[jsonData objectForKey:@"album_year"] intValue];
                                   _tmpSong.artistImageUrl = [jsonData objectForKey:@"artist_image_url"];
                                   _tmpSong.mood = [jsonData objectForKey:@"mood"];
                                   _tmpSong.previewUrl = [jsonData objectForKey:@"preview_url"];
                                   _tmpSong.tempo = [jsonData objectForKey:@"tempo"];
                                   _tmpSong.trackArtistName = [jsonData objectForKey:@"track_artist_name"];
                                   _tmpSong.trackGnid = [[jsonData objectForKey:@"track_gnind"] intValue];
                                   _tmpSong.trackNumber = [[jsonData objectForKey:@"track_number"] intValue];
                                   _tmpSong.trackTitle = [jsonData objectForKey:@"track_title"];
                                   _tmpSong.createdAt = [jsonData objectForKey:@"created_at"];
                                   _tmpSong.updatedAt = [jsonData objectForKey:@"updated_at"];
                                   _tmpSong.latitude = [[jsonData objectForKey:@"latitude"] floatValue];
                                   _tmpSong.longitude = [[jsonData objectForKey:@"longitude"] floatValue];
                                   _tmpSong.isLoadedArt = NO;
                                   _tmpSong.isPlayed = NO;
                                   success();
                               }else{
                                   failed();
                               }
                           }];
}

-(void)getSongList:(NSString *)mood success:(void(^)())success faild:(void(^)())failed
{
    _latestSongId = 0;
    _songList = [[NSMutableArray alloc] init];
    NSString *url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/songs/getMood?mood=%@&id=0", mood];
    
    if (_tmpSong != nil) {
        [_songList addObject:_tmpSong];
        _tmpSong = [[WSSong alloc] init];
    }
    
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
                               
                               NSMutableArray *list = [[NSMutableArray alloc] initWithArray:jsonData];
                               for (int i = 0; i < [list count]; i++) {
                                   NSDictionary *dic = [list objectAtIndex:i];
                                   WSSong *song = [[WSSong alloc] init];
                                   song.songId = [[dic objectForKey:@"id"] intValue];
                                   song.albumArtUrl = [dic objectForKey:@"album_art_url"];
                                   song.albumArtistName = [dic objectForKey:@"album_artist_name"];
                                   song.albumGnid = [[dic objectForKey:@"album_gnid"] intValue];
                                   song.albumTitle = [dic objectForKey:@"album_title"];
                                   song.albumYear = [[dic objectForKey:@"album_year"] intValue];
                                   song.artistImageUrl = [dic objectForKey:@"artist_image_url"];
                                   song.mood = [dic objectForKey:@"mood"];
                                   song.previewUrl = [dic objectForKey:@"preview_url"];
                                   song.tempo = [dic objectForKey:@"tempo"];
                                   song.trackArtistName = [dic objectForKey:@"track_artist_name"];
                                   song.trackGnid = [[dic objectForKey:@"track_gnind"] intValue];
                                   song.trackNumber = [[dic objectForKey:@"track_number"] intValue];
                                   song.trackTitle = [dic objectForKey:@"track_title"];
                                   song.createdAt = [dic objectForKey:@"created_at"];
                                   song.updatedAt = [dic objectForKey:@"updated_at"];
                                   song.latitude = [[dic objectForKey:@"latitude"] floatValue];
                                   song.longitude = [[dic objectForKey:@"longitude"] floatValue];
                                   song.isLoadedArt = NO;
                                   song.isPlayed = NO;
                                   [_songList addObject:song];
                                   
                                   _latestSongId = [[dic objectForKey:@"id"] intValue];
                               }
                               success();
                           }];
}

-(void)getMoreSongList:(NSString *)mood success:(void(^)())success faild:(void(^)())failed
{
    NSString *url;
    url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/songs/mood?mood=%@&id=%d", mood, _latestSongId];
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
                               
                               NSMutableArray *list = [[NSMutableArray alloc] initWithArray:jsonData];
                               if ([list count] > 0) {
                                   for (int i = 0; i < [list count]; i++) {
                                       NSDictionary *dic = [list objectAtIndex:i];
                                       WSSong *song = [[WSSong alloc] init];
                                       song.songId = [[dic objectForKey:@"id"] intValue];
                                       song.albumArtUrl = [dic objectForKey:@"album_art_url"];
                                       song.albumArtistName = [dic objectForKey:@"album_artist_name"];
                                       song.albumGnid = [[dic objectForKey:@"album_gnid"] intValue];
                                       song.albumTitle = [dic objectForKey:@"album_title"];
                                       song.albumYear = [[dic objectForKey:@"album_year"] intValue];
                                       song.artistImageUrl = [dic objectForKey:@"artist_image_url"];
                                       song.mood = [dic objectForKey:@"mood"];
                                       song.previewUrl = [dic objectForKey:@"preview_url"];
                                       song.tempo = [dic objectForKey:@"tempo"];
                                       song.trackArtistName = [dic objectForKey:@"track_artist_name"];
                                       song.trackGnid = [[dic objectForKey:@"track_gnind"] intValue];
                                       song.trackNumber = [[dic objectForKey:@"track_number"] intValue];
                                       song.trackTitle = [dic objectForKey:@"track_title"];
                                       song.createdAt = [dic objectForKey:@"created_at"];
                                       song.updatedAt = [dic objectForKey:@"updated_at"];
                                       song.latitude = [[dic objectForKey:@"latitude"] floatValue];
                                       song.longitude = [[dic objectForKey:@"longitude"] floatValue];
                                       song.isLoadedArt = NO;
                                       song.isPlayed = NO;
                                       [_songList insertObject:song atIndex:1];
                                       
                                       _latestSongId = [[dic objectForKey:@"id"] intValue];
                                   }
                                   success();
                               }else{
                                   failed();
                               }

                           }];
}

-(void)favSong:(void(^)())success faild:(void(^)())failed
{

    WSSong *song  = _songList.firstObject;
    NSString *url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/favorites/add?track_id=%d&user_id=%d", (int)song.trackGnid,[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] intValue]];
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
                               
                               success();
                           }];
}


-(void)searchSong:(int)trackGnid success:(void(^)(WSSong *song))success faild:(void(^)())failed
{
    WSSong *targetSong = [[WSSong alloc] init];
    NSString *url = [NSString stringWithFormat:@"http://music-hack-day.herokuapp.com/songs/searchTrack?track_gnid=%d", trackGnid];
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
                               
                               NSMutableArray *list = [[NSMutableArray alloc] initWithArray:jsonData];
                               NSDictionary *dic = [NSDictionary dictionaryWithDictionary:list.firstObject];
                               targetSong.songId = [[dic objectForKey:@"id"] intValue];
                               targetSong.albumArtUrl = [dic objectForKey:@"album_art_url"];
                               targetSong.albumArtistName = [dic objectForKey:@"album_artist_name"];
                               targetSong.albumGnid = [[dic objectForKey:@"album_gnid"] intValue];
                               targetSong.albumTitle = [dic objectForKey:@"album_title"];
                               targetSong.albumYear = [[dic objectForKey:@"album_year"] intValue];
                               targetSong.artistImageUrl = [dic objectForKey:@"artist_image_url"];
                               targetSong.mood = [dic objectForKey:@"mood"];
                               targetSong.previewUrl = [dic objectForKey:@"preview_url"];
                               targetSong.tempo = [dic objectForKey:@"tempo"];
                               targetSong.trackArtistName = [dic objectForKey:@"track_artist_name"];
                               targetSong.trackGnid = [[dic objectForKey:@"track_gnind"] intValue];
                               targetSong.trackNumber = [[dic objectForKey:@"track_number"] intValue];
                               targetSong.trackTitle = [dic objectForKey:@"track_title"];
                               targetSong.createdAt = [dic objectForKey:@"created_at"];
                               targetSong.updatedAt = [dic objectForKey:@"updated_at"];
                               targetSong.latitude = [[dic objectForKey:@"latitude"] floatValue];
                               targetSong.longitude = [[dic objectForKey:@"longitude"] floatValue];
                               targetSong.isLoadedArt = NO;
                               targetSong.isPlayed = NO;
                               
                               success(targetSong);
                           }];
}
@end
