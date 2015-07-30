//
//  VersusGame.m
//  minesweeper
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGame.h"

@implementation VersusGame

@synthesize player2_username;
@synthesize last_cell_player2;
@synthesize mines_player1;
@synthesize mines_player2;
@synthesize player;

#pragma mark - Init

- (instancetype)initWithNumMines:(int)numMines
                      numColumns:(int)numColumns
                         numRows:(int)numRows
{
    self = [super initWithNumMines:numMines numColumns:numColumns numRows:numRows];
    
    if (self)
    {
        self.last_cell_player2 = -1;
        self.player = 1;
        self.player2_username = @"Player 2";
        self.mines_player1 = 0;
        self.mines_player2 = 0;
    }
    
    return self;
}

#pragma mark - Getters

- (NSMutableArray *)getRestorableGames
{
    return  [self.manager getRestorableVersusGame];
}

#pragma mark - Restore

- (void)restore
{
    [self restoreBoard];
    
    int *r;
    int *c;
    r = malloc(4);
    c = malloc(4);
    
    for (int i = 0; i < self.num_mines; i++)
    {
        [self findCoordinates:self.mines[i] row:r column:c];
        
        if (self.visible [*r][*c] == 1)
        {
            mines_player1++;
        }
        else if (self.visible [*r][*c] == 2)
        {
            mines_player2++;
        }
    }
    
}

#pragma mark - Persist

- (void)persist
{
    [self.manager createVersusGame:self];
    self.gameInternalId = [self.manager getLatestVersusGame];
}

#pragma mark - Update

- (void)update
{
    [self.manager updateVersusGame: self];
}

@end
