//
//  VersusGameTableViewController.m
//  minesweeper
//
//  Created by admin on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGameTableViewController.h"
#import "VersusGame.h"
#import "VersusGameCell.h"
#import "VersusViewController.h"

@implementation VersusGameTableViewController


NSMutableArray *games;
NSMutableArray *gamesRestored;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    UIImageView *iv = [[UIImageView alloc] initWithImage: [UIImage imageNamed:NSLocalizedString(@"IMG_background", @"Background Image")]];
    
    [iv setFrame: self.view.frame];
    [iv setAlpha: 1];
    
    [self.tableView setBackgroundView: iv ];
    [self.tableView setDelegate: self];
    [self.tableView setDataSource: self];
   
}

-(void) goBack: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [games removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
  	[self.navigationItem setTitle: NSLocalizedString(@"title_VGame_list", @"Title for the Versus Game List")];
	[super viewWillAppear:animated];
    gamesRestored = [[NSMutableArray alloc] init];
    VersusGame * vg = [[VersusGame alloc] init];
    games = [vg getRestorableGames];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    VersusViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VersusViewController"];
    [vvc setVGame: [games objectAtIndex: indexPath.row ] ];
    
    [self.navigationController pushViewController:vvc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [games count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GameCell";
    
    
    VersusGameCell *cell = (VersusGameCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        UINib *quoteCellNib = [UINib nibWithNibName:@"GameCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.gameCell;
        self.gameCell = nil;
    }
    VersusGame * game = [games objectAtIndex: indexPath.row ];
    if ( ![gamesRestored containsObject:indexPath])
    {
        [game restore];
        [gamesRestored addObject:indexPath];
    }
        
    
    [cell setVersusGames: game];
    return cell;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBannerViewFrame:nil];
    [super viewDidUnload];
}



@end
