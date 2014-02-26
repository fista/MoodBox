//
//  WSHomeViewController.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/22.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WSHomeViewController.h"
#import "WSMoodViewController.h"
#import "WSFavListViewController.h"

@interface WSHomeViewController ()

@end

@implementation WSHomeViewController

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
    
    
    
    //[self updateMusic];
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkCurrentPlayTime) userInfo:nil repeats:YES];
    moodList = @[@"Peaceful", @"Tender", @"Sentimental", @"Melancholy", @"Somber", @"Gritty", @"Cool", @"Sophisficated", @"Romantic", @"Easygoing", @"Upbeat", @"Empowering", @"Sensual", @"Yeaming", @"Serious", @"Blooding", @"Urgent", @"Fiery", @"Stiming", @"Livery", @"Excited", @"Rowdy", @"Energizing", @"Default", @"Aggressive"];
    [mainTableView reloadData];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, 44, 44);
    [addButton setImage:[UIImage imageNamed:@"btn_music.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
    titleLabel.text = @"How does it feel now?";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favButton.frame = CGRectMake(0, 0, 44, 44);
    [favButton setImage:[UIImage imageNamed:@"top_btn_fab.png"] forState:UIControlStateNormal];
    [favButton addTarget:self action:@selector(showFavView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 214)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    UIImageView *tableHeaderBgImageView = [[UIImageView alloc] initWithFrame:tableHeaderView.frame];
    tableHeaderBgImageView.image = [UIImage imageNamed:@"top.png"];
    [tableHeaderView addSubview:tableHeaderBgImageView];
    mainTableView.tableHeaderView = tableHeaderView;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 186)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    UIImageView *tableFooterBgImageView = [[UIImageView alloc] initWithFrame:tableHeaderView.frame];
    tableFooterBgImageView.image = [UIImage imageNamed:@"bottom.png"];
    [tableFooterView addSubview:tableFooterBgImageView];
    mainTableView.tableFooterView = tableFooterView;
    
    [[WSUser user] getMyCurrentLocation];
    
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (updateMusic)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      musicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (updateMusic)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      musicPlayer];
    
    [musicPlayer beginGeneratingPlaybackNotifications];
    
    /*
    NSMutableArray *playerItems = [[NSMutableArray alloc] init];
    [[WSSongs songs] getSongList:@"Empowering" success:^(void){
        NSLog(@"%d", (int)[[WSSongs songs].songList count]);
        for (int i = 0; i < [[WSSongs songs].songList count]; i++) {
            WSSong *song = [[WSSongs songs].songList objectAtIndex:i];
            NSURL *url = [NSURL URLWithString:song.previewUrl];
            if (url) {
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                [playerItems addObject:playerItem];
            }
        }
        queuePlayer = [AVQueuePlayer queuePlayerWithItems:playerItems];
        
    } faild:^(void){
    
    }];
     */
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bg2.png"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    
    _selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    mainTableView.alpha = 1.0;
    [mainTableView reloadData];
}

-(IBAction)play
{
    [queuePlayer play];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateMusic
{
    MPMediaItem *playingItem = [musicPlayer nowPlayingItem];
    if (playingItem) {
        NSInteger mediaType = [[playingItem valueForProperty:MPMediaItemPropertyMediaType] integerValue];
        if (mediaType == MPMediaTypeMusic) {
            NSString *songTitle = [playingItem valueForProperty:MPMediaItemPropertyTitle];
            NSString *albumTitle = [playingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString *artist = [playingItem valueForProperty:MPMediaItemPropertyArtist];
            NSLog(@"%@ %@ %@", artist, albumTitle, songTitle);
            
            songTitleLabel.text = [NSString stringWithFormat:@" %@ - %@", songTitle, albumTitle];
            artistLabel.text = artist;
            
            MPMediaItemArtwork *artwork = [playingItem valueForProperty:MPMediaItemPropertyArtwork];
            UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(artwork.bounds.size.width, artwork.bounds.size.height)];
            artworkImageView.image = artworkImage;
            if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying && !updateFlg) {
                updateFlg = YES;
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]) {
                    [self sendSong:songTitle albumTitle:albumTitle artist:artist];
                }else{
                    [[WSUser user] getUserId:^(void){
                        [self sendSong:songTitle albumTitle:albumTitle artist:artist];
                    } faild:^(void){
                        updateFlg = NO;
                    }];
                }
            }
        }
    }
}

-(void)sendSong:(NSString *)songTitle albumTitle:(NSString *)albumTitle artist:(NSString *)artist
{
    [[WSSongs songs] sendMusicWithTitle:songTitle albumName:albumTitle artist:artist success:^(void){
        updateFlg = NO;
        //[self playNextItem];
    } faild:^(void){
        updateFlg = NO;
        //[self playNextItem];
    }];
}

-(IBAction)playNextItem
{
    [musicPlayer skipToNextItem];
}


#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndexPath.row && indexPath.section == _selectedIndexPath.section) {
        return self.view.frame.size.height/2;
    }else{
        return 50;
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [moodList count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.text = [moodList objectAtIndex:indexPath.row];
    
    UIImageView *bgImageView = (UIImageView *)[cell viewWithTag:100];
    bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_bg%d.png", (int)indexPath.row + 1]];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showMoodView" sender:indexPath];
    /*
    _selectedIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
    
    [mainTableView beginUpdates];
    
    [mainTableView endUpdates];
    [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^(void){
        [mainTableView scrollToRowAtIndexPath:_selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        mainTableView.alpha = 0.25;
    } completion:^(BOOL finished){
        UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WSMoodViewController *controller = [myStoryboard instantiateViewControllerWithIdentifier:@"MoodViewController"];
        controller.moodTitle = [moodList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:controller animated:NO];
    }];
     
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"showMoodView"]){
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        WSMoodViewController *controller = [segue destinationViewController];
        controller.moodTitle = [moodList objectAtIndex:indexPath.row];
        controller.row = indexPath.row;
        [[segue destinationViewController] setTransitioningDelegate:self];
    }else if([[segue identifier] isEqualToString:@"showFavListView"]){
        WSFavListViewController *controller = [segue destinationViewController];
        controller.bgImage = [self screenCaptureWithView:mainTableView rect:mainTableView.frame];
    }
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[FadeAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:
(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    return [[FadeAnimationController alloc] init];
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
            [self performSegueWithIdentifier:@"showMoodView" sender:indexPath];
        } faild:^(void){
            [delegate hideLoadingView];
        }];
    }else{
        [[WSUser user] getUserId:^(void){
            [delegate hideLoadingView];
            int row = 0;
            for (int i = 0; i < [moodList count]; i++) {
                NSString *mood = [moodList objectAtIndex:i];
                if ([mood isEqualToString:[WSSongs songs].currentMood]) {
                    row = i;
                }
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
            [self performSegueWithIdentifier:@"showMoodView" sender:indexPath];
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

-(void)showFavView
{
    [self performSegueWithIdentifier:@"showFavListView" sender:self];
}


- (UIImage *)screenCapture:(UIView *)view {
    UIImage *capture;
    UIGraphicsBeginImageContextWithOptions(view.frame.size , NO , 1.0 );
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    capture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capture;
}

- (UIImage *)screenCaptureWithView:(UIView *)view rect:(CGRect)rect{
    UIImage *capture;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CALayer *layer = view.layer;
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    capture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capture;
}
@end