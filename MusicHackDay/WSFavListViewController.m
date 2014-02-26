//
//  WSFavListViewController.m
//  MusicHackDay
//
//  Created by tatsuya fujii on 2014/02/23.
//  Copyright (c) 2014年 Wondershake. All rights reserved.
//

#import "WSFavListViewController.h"
#import "WSMoodViewController.h"
#import "UIImage+ImageEffects.h"
@interface WSFavListViewController ()

@end

@implementation WSFavListViewController

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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bg2.png"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:24];
    titleLabel.text = @"Favorites";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    mainTableView.backgroundColor = [UIColor clearColor];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.view.frame];
    bg.image = [_bgImage applyDarkEffect];
    mainTableView.backgroundView = bg;
    
    [[WSUser user] getFavList:^(void){
        [mainTableView reloadData];
    } faild:^(void){}];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[WSUser user].favList count];
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
    WSSong *song = [[WSUser user].favList objectAtIndex:indexPath.row];
    
    UIImageView *artImageView = (UIImageView *)[cell viewWithTag:1];
    [artImageView setImageWithURL:[NSURL URLWithString:song.albumArtUrl]];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.text = [NSString stringWithFormat:@"%@-%@", song.trackTitle, song.albumTitle];
    
    UILabel *artistLabel = (UILabel *)[cell viewWithTag:3];
    artistLabel.text = song.albumArtistName;
    
    return cell;
}

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
        WSSong *song = [[WSUser user].favList objectAtIndex:indexPath.row];
        controller.moodTitle = song.mood;
        [WSSongs songs].tmpSong = song;
        NSArray *moodList = @[@"Peaceful", @"Tender", @"Sentimental", @"Melancholy", @"Somber", @"Gritty", @"Cool", @"Sophisficated", @"Romantic", @"Easygoing", @"Upbeat", @"Empowering", @"Sensual", @"Yeaming", @"Serious", @"Blooding", @"Urgent", @"Fiery", @"Stiming", @"Livery", @"Excited", @"Rowdy", @"Energizing", @"Default", @"Aggressive"];
        int count = 0;
        for (int i = 0; i < [moodList count]; i++) {
            NSString *mood = [moodList objectAtIndex:i];
            if ([mood isEqualToString:song.mood]) {
                count = i;
            }
        }
        controller.row = count;
    }
}

@end
