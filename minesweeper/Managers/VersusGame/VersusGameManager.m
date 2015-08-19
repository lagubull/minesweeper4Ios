//
//  VersusGameManager.m
//  minesweeper
//
//  Created by jlagunas on 12/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGameManager.h"

#import "Tools.h"
#import "DBManager.h"
#import "VersusGame.h"
#import "VersusViewController.h"

@implementation VersusGameManager

#pragma mark - Getters

- (VersusGame *)versusGame
{
    if (!_versusGame)
    {
        _versusGame = [[VersusGame alloc] initWithNumMines:60
                                                numColumns:11
                                                   numRows:14];
    }
    
    return _versusGame;
}


#pragma mark - SetUpGame

- (void)setupGame
{
    [self.versusViewController loadBoard];
    
    if (self.versusGame.gameInternalId == -1)
    {
        //initialise the board
        self.versusGame.player = JMSPlayer1;
        
        [self.versusGame setupGame];
    }
    else
    {
        [self restoreGameController];
    }
    
    [self.versusViewController passTurn:self.versusGame.player];
}

#pragma mark - ClickCell

- (void)clickCell:(NSInteger)row
           column:(NSInteger)column
{
    //if cell had not been clicked before
    if (self.versusGame.visible[row][column] == 0)
    {
        if (self.versusGame.board[row][column] != 9)
        {
            //reveal cell's content
            self.versusGame.visible[row][column] = self.versusGame.player;
            
            NSString *value = [NSString stringWithFormat:@"%@", @(self.versusGame.board[row][column])];
            
            [self.versusViewController paintCell:(row * kJMSRow + column + kJMSRow)
                                           title:value];
            
            //if not near mines
            if (self.versusGame.board[row][column] == 0)
            {
                //loop through the nearby cells and click them aswell
                for (NSInteger row2 = MAX (0, (row - 1)); row2 < MIN (self.versusGame.rowsNumber, (row + 2)); row2++)
                {
                    for (NSInteger column2 = MAX (0, (column - 1)); column2 < MIN(self.versusGame.columnsNumber, (column + 2)); column2++)
                    {
                        [self clickCell:row2
                                 column:column2];
                    }
                }
            }
        }
    }
}

#pragma mark - CellSelected

- (void)cellSelected:(NSInteger)cellID
{
    if (self.versusGame.lastCellPlayer1 == -1)
    {
        [self.versusGame persist];
    }
    
    NSInteger *row;
    NSInteger *column;
    row = malloc(4);
    column = malloc(4);
    
    [self.versusGame findCoordinatesWithPosition:cellID
                                             row:row
                                          column:column];
    
    if (self.versusGame.visible[*row][*column] == 0)
    {
        if (self.versusGame.board[*row][*column] == 9)
        {
            self.versusGame.visible[*row][*column] = self.versusGame.player;
            
            [self.versusViewController paintMine:(*row * kJMSRow + *column + kJMSRow)
                                          player:self.versusGame.player
                                       animation:YES ];
            
            //mine
            [self checkVictory];
        }
        else
        {
            //empty cell
            [self clickCell:*row
                     column:*column];
            
            [self passTurn:self.versusGame.player];
        }
        
        [self.versusGame update];
    }
}

#pragma mark - PassTurn

-(void)passTurn:(NSInteger)cellId
{
    switch (self.versusGame.player)
    {
        case JMSPlayer1:
        {
            self.versusGame.player = JMSPlayer2;
            self.versusGame.lastCellPlayer1 = cellId;
            
            break;
        }
        case JMSPlayer2:
        {
            self.versusGame.player = JMSPlayer1;
            self.versusGame.lastCellPlayer2 = cellId;
            
            break;
        }
    }
    
    [self.versusViewController passTurn:self.versusGame.player];
}

#pragma mark - UpdateMinesCount

- (void)updateMinesCount
{
    self.versusGame.remainingMines--;
    
    switch (self.versusGame.player)
    {
        case JMSPlayer1:
        {
            self.versusGame.minesPlayer1++;
            
            break;
        }
        case JMSPlayer2:
        {
            self.versusGame.minesPlayer2++;
            
            break;
        }
    }
    
    [self.versusViewController updateMinesCounters];
}

#pragma mark CheckVictory

- (void)checkVictory
{
    [self updateMinesCount];
    
    if (self.versusGame.minesPlayer1  >= (self.versusGame.minesNumber / 2))
    {
        //Player 1 Victory
        
        [Tools showSingleButtonAlert:NSLocalizedString(@"WINNER",@"Winner title")
                             message:NSLocalizedString(@"YOU_WIN",@"Winner message")
                          buttonText:NSLocalizedString(@"PLAY_AGAIN",@"Play again button")
                            delegate:self];
    }
    else
    {
        if (self.versusGame.minesPlayer2  >= (self.versusGame.minesNumber / 2))
        {
            //Player 2 Victory
            [Tools showSingleButtonAlert:NSLocalizedString(@"WINNER",@"Winner title")
                                 message:NSLocalizedString(@"YOU_WIN",@"Winner message")
                              buttonText:NSLocalizedString(@"PLAY_AGAIN",@"Play again button")
                                delegate:self];
        }
    }
}

#pragma mark - RestoreGameController

-(void)restoreGameController
{
    for (NSInteger row = 0; row < self.versusGame.rowsNumber; row++)
    {
        for (NSInteger column = 0; column < self.versusGame.columnsNumber; column++)
        {
            if (self.versusGame.visible[row][column] != 0)
            {
                if (self.versusGame.board[row][column] != 9)
                {
                    NSString *value = [NSString stringWithFormat:@"%@", @(self.versusGame.board[row][column])];
                    
                    [self.versusViewController paintCell:(row * kJMSRow + column + kJMSRow)
                                                   title:value];
                }
                else
                {
                    [self.versusViewController paintMine:(row * kJMSRow + column + kJMSRow)
                                                  player:self.versusGame.visible[row][column]
                                               animation:NO];
                }
            }
        }
    }
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self setupGame];
}

@end
