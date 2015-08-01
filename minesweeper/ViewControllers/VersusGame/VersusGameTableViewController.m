//
//  VersusGameTableViewController.m
//  minesweeper
//
//  Created by jlagunas on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGameTableViewController.h"
#import "VersusGame.h"
#import "VersusGameCell.h"
#import "VersusViewController.h"

@interface VersusGameTableViewController ()

@property (nonatomic, strong) NSMutableArray *games;

@property (nonatomic, strong) NSMutableArray *gamesRestored;

@property (nonatomic, strong) UIImageView *backgoundImageView;

@end

@implementation VersusGameTableViewController

#pragma mark - ViewLifeCyle

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.tableView setBackgroundView:self.backgoundImageView];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:NO];
    
    [self.navigationItem setTitle: NSLocalizedString(@"title_VGame_list", @"Title for the Versus Game List")];
    
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.games removeAllObjects];
    
    self.games = nil;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setBannerViewFrame:nil];
    
    [super viewDidUnload];
}

#pragma mark - Subviews

- (UIImageView *)backgoundImageView
{
    if (!_backgoundImageView)
    {
        _backgoundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:NSLocalizedString(@"IMG_background", @"Background Image")]];
        
        _backgoundImageView.frame = self.tableView.frame;
        _backgoundImageView.alpha = 1.0f;
    }
    
    return _backgoundImageView;
}

#pragma mark - Getters

- (NSMutableArray *)games
{
    if (!_games)
    {
        VersusGame *vg = [[VersusGame alloc] init];
        _games = [vg getRestorableGames];
    }
    
    return _games;
}

- (NSMutableArray *)gamesRestored
{
    if (!_gamesRestored)
    {
        _gamesRestored = [[NSMutableArray alloc] init];
    }
    
    return _gamesRestored;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    VersusViewController *versusViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VersusViewController"];
    versusViewController.versusGame = self.games[indexPath.row];
    
    [self.navigationController pushViewController:versusViewController
                                         animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GameCell";
    
    VersusGameCell *cell = (VersusGameCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        UINib *quoteCellNib = [UINib nibWithNibName:@"GameCell"
                                             bundle:nil];
        
        [quoteCellNib instantiateWithOwner:self
                                   options:nil];
        
        cell = self.gameCell;
        self.gameCell = nil;
    }
    
    VersusGame *game = [self.games objectAtIndex: indexPath.row];
    
    if (![self.gamesRestored containsObject:indexPath])
    {
        [game restore];
        [self.gamesRestored addObject:indexPath];
    }
    
    [cell setVersusGames:game];
    
    return cell;
}

@end
