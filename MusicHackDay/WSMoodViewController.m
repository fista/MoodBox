//
//  WSMoodViewController.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import "WSMoodViewController.h"
#import "FRGWaterfallCollectionViewCell.h"
#import "FRGWaterfallCollectionViewLayout.h"
#import "FRGWaterfallHeaderReusableView.h"
#import "UIImage+ImageEffects.h"
@interface WSMoodViewController ()<FRGWaterfallCollectionViewDelegate>

@end

@implementation WSMoodViewController
@synthesize operationQueue = _operationQueue;
@synthesize searching = _searching;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    delegate = (WSAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bg2.png"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.navigationController.view.frame];
    bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", _row + 1]];
    [mainCollectionView setBackgroundView:bgImageView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:24];
    titleLabel.text = _moodTitle;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, 44, 44);
    [addButton setImage:[UIImage imageNamed:@"btn_music.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    FRGWaterfallCollectionViewLayout *cvLayout = [[FRGWaterfallCollectionViewLayout alloc] init];
    cvLayout.delegate = self;
    cvLayout.itemWidth = 150.0f;
    cvLayout.topInset = 0.0f;
    cvLayout.bottomInset = 100.0f;
    cvLayout.stickyHeader = NO;
    
    [mainCollectionView setCollectionViewLayout:cvLayout];
    [mainCollectionView reloadData];

    
    
    artImageView.image = [UIImage imageNamed:@"noimage.png"];
    songTitleLabel.text = @"";
    
    playButton.enabled = NO;
    playerItems = [[NSMutableArray alloc] init];
    [[WSSongs songs] getSongList:_moodTitle success:^(void){
        if ([[WSSongs songs].songList count] > 0) {
            playButton.enabled = YES;
            [self play];
        }
        [mainCollectionView reloadData];
    } faild:^(void){
        
    }];
}


-(void)seek
{
    double time = CMTimeGetSeconds([player currentTime]);
    double duration = CMTimeGetSeconds(player.currentItem.duration);
    progressView.progress = time / duration;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(reload) userInfo:nil repeats:YES];
    
    seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(seek) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    [seekTimer invalidate];
    [player pause];
}

-(void)reload
{
    [[WSSongs songs] getMoreSongList:_moodTitle success:^(void){
        [mainCollectionView reloadData];
    } faild:^(void){
        [timer invalidate];
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // セクション数をカウント
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    // セクション内のアイテム数をカウント
    return [[WSSongs songs].songList count] + 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 75;
    }else if(indexPath.row == [[WSSongs songs].songList count] + 1){
        return 75;
    }else{
        return 150;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:1];
    UIImageView *blurImageView = (UIImageView *)[cell viewWithTag:100];
    imgView.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height);
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    blurImageView.frame = imgView.frame;
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *artistLabel = (UILabel *)[cell viewWithTag:3];
    UIImageView *gradationImageView = (UIImageView *)[cell viewWithTag:10];
    UIButton *songPlayButton = (UIButton *)[cell viewWithTag:30];
    [songPlayButton setTitle:[NSString stringWithFormat:@"%d", (int)indexPath.row] forState:UIControlStateNormal];
    [songPlayButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == 0 || indexPath.row == [[WSSongs songs].songList count] + 1) {
        imgView.image = nil;
        titleLabel.text = @"";
        artistLabel.text = @"";
        gradationImageView.alpha = 0.00;
        songPlayButton.enabled = NO;
    }else{
        WSSong *song = [[WSSongs songs].songList objectAtIndex:indexPath.row - 1];
        if (song.albumArtUrl != nil) {
            [imgView setImageWithURL:[NSURL URLWithString:song.albumArtUrl] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
            
            if (!song.isLoadedArt) {
                song.isLoadedArt = YES;
                imgView.alpha = 0.00;
                gradationImageView.alpha = 0.00;
                titleLabel.alpha = 0.00;
                artistLabel.alpha = 0.00;
                [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void){
                    imgView.alpha = 1.00;
                    gradationImageView.alpha = 1.00;
                    titleLabel.alpha = 1.00;
                    artistLabel.alpha = 1.00;
                } completion:^(BOOL finished){}];
                
                [[WSSongs songs].songList replaceObjectAtIndex:indexPath.row - 1 withObject:song];
            }else if(song.isPlayed){
                song.isPlayed = NO;
                imgView.alpha = 1.00;
                gradationImageView.alpha = 1.00;
                titleLabel.alpha = 1.00;
                artistLabel.alpha = 1.00;
                [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void){
                    imgView.alpha = 0.00;
                    gradationImageView.alpha = 0.00;
                    titleLabel.alpha = 0.00;
                    artistLabel.alpha = 0.00;
                } completion:^(BOOL finished){}];
                
                [[WSSongs songs].songList replaceObjectAtIndex:indexPath.row - 1 withObject:song];
            }else{
                imgView.alpha = 1.00;
                gradationImageView.alpha = 1.00;
                titleLabel.alpha = 1.00;
                artistLabel.alpha = 1.00;
            }
            
            titleLabel.text = [NSString stringWithFormat:@"%@ - %@", song.trackTitle, song.albumTitle];
            artistLabel.text = [NSString stringWithFormat:@"%@", song.albumArtistName];
            
            songPlayButton.enabled = YES;
            
            /*
            if (imgView.image != nil) {
                blurImageView.image = [imgView.image applyExtraLightEffect];
            }
            if (!song.isLoadedArt) {
                song.isLoadedArt = YES;
                blurImageView.alpha = 0.00;
                blurImageView.frame = CGRectMake(0, 0, 0, 0);
                imgView.frame = blurImageView.frame;
                blurImageView.center = cell.center;
                imgView.center = CGPointMake(75, 75);
                imgView.alpha = 0.00;
                [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void){
                    blurImageView.alpha = 0.00;
                    imgView.alpha = 1.00;
                    imgView.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height);
                    blurImageView.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height);
                } completion:^(BOOL finished){}];

                [[WSSongs songs].songList replaceObjectAtIndex:indexPath.row - 1 withObject:song];
            }else{
                blurImageView.alpha = 0.00;
                imgView.alpha = 1.00;
            }
            */
            
        }
    }
    return cell;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)add
{
    // initWithMediaTypes の引数は下記を参照に利用したいメディアを設定しましょう。
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    // デリゲートを自分クラスに設定
    [picker setDelegate: self];
    
	// 複数のメディアを選択可能に設定
    [picker setAllowsPickingMultipleItems:NO];
    
	// プロンプトに表示する文言を設定
    picker.prompt = NSLocalizedString (@"Add songs to play","Prompt in media item picker");
    
	// ViewController へピッカーを設定
    [self presentViewController:picker animated:YES completion:^(void){}];
}

// デリゲートの設定 Done 押下時に呼ばれます。
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection
{
    NSArray *moodList = @[@"Peaceful", @"Tender", @"Sentimental", @"Melancholy", @"Somber", @"Gritty", @"Cool", @"Sophisficated", @"Romantic", @"Easygoing", @"Upbeat", @"Empowering", @"Sensual", @"Yeaming", @"Serious", @"Blooding", @"Urgent", @"Fiery", @"Stiming", @"Livery", @"Excited", @"Rowdy", @"Energizing", @"Default", @"Aggressive"];
    NSString *songTitle;
    NSString *albumTitle;
    NSString *artist;
    // 選択されたメディアは 配列で格納されている。
    for (MPMediaItem *item in collection.items) {
        
        // 選択されたメディアの属性を取得してログへ表示する。その他の属性に関しては下記に一覧があります。
    	NSLog(@"Title is %@", [item valueForProperty:MPMediaItemPropertyTitle]);
        songTitle = [item valueForProperty:MPMediaItemPropertyTitle];
        NSLog(@"Artist is %@", [item valueForProperty:MPMediaItemPropertyArtist]);
        albumTitle =[item valueForProperty:MPMediaItemPropertyArtist];
        NSLog(@"AlbumTitle is %@", [item valueForProperty:MPMediaItemPropertyAlbumTitle]);
        artist = [item valueForProperty:MPMediaItemPropertyArtist];
    }
    [delegate showLoadingView];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]) {
        [[WSSongs songs] sendMusicWithTitle:songTitle albumName:albumTitle artist:artist success:^(void){
            [delegate hideLoadingView];
            int row = 0;
            for (int i = 0; i < [moodList count]; i++) {
                NSString *mood = [moodList objectAtIndex:i];
                if ([mood isEqualToString:[WSSongs songs].currentMood]) {
                    row = i;
                }
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
            UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            WSMoodViewController *controller = [myStoryboard instantiateViewControllerWithIdentifier:@"MoodViewController"];
            controller.moodTitle = [moodList objectAtIndex:indexPath.row];
            controller.row = row;
            [self.navigationController pushViewController:controller animated:YES];
        } faild:^(void){
            [delegate hideLoadingView];
        }];
    }else{
        [[WSUser user] getUserId:^(void){
            [[WSSongs songs] sendMusicWithTitle:songTitle albumName:albumTitle artist:artist success:^(void){
                [delegate hideLoadingView];
                int row = 0;
                for (int i = 0; i < [moodList count]; i++) {
                    NSString *mood = [moodList objectAtIndex:i];
                    if ([mood isEqualToString:[WSSongs songs].currentMood]) {
                        row = i;
                    }
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
                UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                WSMoodViewController *controller = [myStoryboard instantiateViewControllerWithIdentifier:@"MoodViewController"];
                controller.moodTitle = [moodList objectAtIndex:indexPath.row];
                controller.row = row;
                [self.navigationController pushViewController:controller animated:YES];
            } faild:^(void){
                [delegate hideLoadingView];
            }];
        } faild:^(void){
            [delegate hideLoadingView];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(IBAction)play
{
    WSSong *currentSong = [WSSongs songs].songList.firstObject;
    NSURL *url = [NSURL URLWithString:currentSong.previewUrl];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    [player play];
    
    songTitleLabel.text = [NSString stringWithFormat:@"%@ - %@ by %@", currentSong.trackTitle,currentSong.albumTitle, currentSong.albumArtistName];
    [artImageView setImageWithURL:[NSURL URLWithString:currentSong.artistImageUrl] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    playButton.hidden = YES;
    pauseButton.hidden = NO;
}

-(void)playMusic:(UIButton *)button
{
    [player pause];
    //WSSong *previousSong = [WSSongs songs].songList.firstObject;
    //previousSong.isPlayed = YES;
    //[[WSSongs songs].songList replaceObjectAtIndex:0 withObject:previousSong];
    //[mainCollectionView reloadData];
    //[self performSelector:@selector(move) withObject:previousSong afterDelay:1.1];
    //[self performSelector:@selector(nextTargetSong:) withObject:previousSong afterDelay:1.1];
    
    NSLog(@"nextTargetSong %@", button.titleLabel.text);
    WSSong *currentSong = [[WSSongs songs].songList objectAtIndex:[button.titleLabel.text intValue] - 1];
    NSURL *url = [NSURL URLWithString:currentSong.previewUrl];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    [player play];
    
    songTitleLabel.text = [NSString stringWithFormat:@"%@ - %@ by %@", currentSong.trackTitle,currentSong.albumTitle, currentSong.albumArtistName];
    [artImageView setImageWithURL:[NSURL URLWithString:currentSong.artistImageUrl] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    
    for (int i = 0; i < [[WSSongs songs].songList count]; i++) {
        WSSong *song = [[WSSongs songs].songList objectAtIndex:0];
        if ([button.titleLabel.text intValue] - 1 > i) {
            [[WSSongs songs].songList addObject:song];
            [[WSSongs songs].songList removeObjectAtIndex:0];
        }
    }
    [mainCollectionView reloadData];
    [mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(void)nextTargetSong:(UIButton *)button
{
    NSLog(@"nextTargetSong %@", button.titleLabel.text);
    WSSong *currentSong = [[WSSongs songs].songList objectAtIndex:[button.titleLabel.text intValue] - 1];
    NSURL *url = [NSURL URLWithString:currentSong.previewUrl];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    [player play];
    
    songTitleLabel.text = [NSString stringWithFormat:@"%@ - %@ by %@", currentSong.trackTitle,currentSong.albumTitle, currentSong.albumArtistName];
    [artImageView setImageWithURL:[NSURL URLWithString:currentSong.artistImageUrl] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    
    for (int i = 0; i < [[WSSongs songs].songList count]; i++) {
        WSSong *song = [[WSSongs songs].songList objectAtIndex:0];
        if ([button.titleLabel.text intValue] - 1 > i) {
            [[WSSongs songs].songList addObject:song];
            [[WSSongs songs].songList removeObjectAtIndex:0];
        }
    }
    [mainCollectionView reloadData];
    [mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self nextItem];
}

-(IBAction)pause
{
    [player pause];
    
    playButton.hidden = NO;
    pauseButton.hidden = YES;
}

-(IBAction)nextItem
{
    NSLog(@"nextItem");
    [player pause];
    WSSong *previousSong = [WSSongs songs].songList.firstObject;
    previousSong.isPlayed = YES;
    [[WSSongs songs].songList replaceObjectAtIndex:0 withObject:previousSong];
    [mainCollectionView reloadData];
    //[self performSelector:@selector(move) withObject:previousSong afterDelay:1.1];
    [self performSelector:@selector(next) withObject:previousSong afterDelay:0.6];
}

-(void)move
{
    [mainCollectionView scrollRectToVisible:CGRectMake(0, 75, mainCollectionView.frame.size.width, mainCollectionView.frame.size.height) animated:YES];
}

-(void)next
{
    NSLog(@"next");
    WSSong *previousSong = [WSSongs songs].songList.firstObject;
    [[WSSongs songs].songList removeObjectAtIndex:0];
    [[WSSongs songs].songList addObject:previousSong];
    
    WSSong *currentSong = [WSSongs songs].songList.firstObject;
    NSURL *url = [NSURL URLWithString:currentSong.previewUrl];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    [player play];
    
    songTitleLabel.text = [NSString stringWithFormat:@"%@ - %@ by %@", currentSong.trackTitle,currentSong.albumTitle, currentSong.trackArtistName];
    [artImageView setImageWithURL:[NSURL URLWithString:currentSong.artistImageUrl] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    [mainCollectionView reloadData];
    
    //[mainCollectionView scrollRectToVisible:CGRectMake(0, 0, mainCollectionView.frame.size.width, mainCollectionView.frame.size.height) animated:NO];
}

-(IBAction)favThisSong:(UIButton *)button
{
    [[WSSongs songs] favSong:^(void){
        [button setImage:[UIImage imageNamed:@"btn_fab_on.png"] forState:UIControlStateNormal];
    } faild:^(void){}];
}

-(NSOperationQueue*)operationQueue
{
    if(_operationQueue == nil) {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}
// change searching state, and modify button and wait indicator (if you wish)
- (void)setSearching:(BOOL)searching
{
    // this changes the view of the search button to a wait indicator while the search is     perfomed
    // In this case
    _searching = searching;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(searching) {
//            self.searchButton.enabled = NO;
//            [self.searchButton setTitle:@"" forState:UIControlStateNormal];
//            [self.activityIndicator startAnimating];
        } else {
//            self.searchButton.enabled = YES;
//            [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
//            [self.activityIndicator stopAnimating];
        }
    });
}
// based on info from the iTunes affiliates docs
// http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
// this assume a search button to start the search.
-(IBAction)openItunesMusicStore {
    WSSong *currentSong = [WSSongs songs].songList.firstObject;
    
    NSString* artistTerm = currentSong.albumArtistName;  //the artist text.
    NSString* songTerm = currentSong.trackTitle;      //the song text
    // they both need to be non-zero for this to work right.
    if(artistTerm.length > 0 && songTerm.length > 0) {
        
        // this creates the base of the Link Maker url call.
        
        NSString* baseURLString = @"https://itunes.apple.com/search";
        NSString* searchTerm = [NSString stringWithFormat:@"%@ %@", artistTerm, songTerm];
        NSString* searchUrlString = [NSString stringWithFormat:@"%@?media=music&entity=song&term=%@&artistTerm=%@&songTerm=%@", baseURLString, searchTerm, artistTerm, songTerm];
        
        // must change spaces to +
        searchUrlString = [searchUrlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        //make it a URL
        searchUrlString = [searchUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* searchUrl = [NSURL URLWithString:searchUrlString];
        NSLog(@"searchUrl: %@", searchUrl);
        
        // start the Link Maker search
        NSURLRequest* request = [NSURLRequest requestWithURL:searchUrl];
        self.searching = YES;
        [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
            
            // we got an answer, now find the data.
            self.searching = NO;
            if(error != nil) {
                NSLog(@"Error: %@", error);
            } else {
                NSError* jsonError = nil;
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if(jsonError != nil) {
                    // do something with the error here
                    NSLog(@"JSON Error: %@", jsonError);
                } else {
                    NSArray* resultsArray = dict[@"results"];
                    
                    // it is possible to get no results. Handle that here
                    if(resultsArray.count == 0) {
                        NSLog(@"No results returned.");
                    } else {
                        
                        // extract the needed info to pass to the iTunes store search
                        NSDictionary* trackDict = resultsArray[0];
                        NSString* trackViewUrlString = trackDict[@"trackViewUrl"];
                        if(trackViewUrlString.length == 0) {
                            NSLog(@"No trackViewUrl");
                        } else {
                            NSURL* trackViewUrl = [NSURL URLWithString:trackViewUrlString];
                            NSLog(@"trackViewURL:%@", trackViewUrl);
                            
                            // dispatch the call to switch to the iTunes store with the proper search url
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] openURL:trackViewUrl];
                            });
                        }
                    }
                }
            }
        }];
    }
}
@end
