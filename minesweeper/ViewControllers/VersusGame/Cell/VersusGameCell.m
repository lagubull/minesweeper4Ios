//
//  VersusGameCell.m
//  minesweeper
//
//  Created by jlagunas on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGameCell.h"
#import "VersusGame.h"
#import "Tools.h"

@implementation VersusGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setVersusGames: (VersusGame *) vGame
{
    [Tools versionedScaleFactor:_lblRemainingMines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblRemainingMines alignment:NSTextAlignmentLeft];
    
    [_lblPlayer1 setText: [NSString stringWithUTF8String: [vGame.player1_username UTF8String ]]];
    [Tools versionedScaleFactor:_lblPlayer1 factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer1 alignment:NSTextAlignmentLeft];
    
    [_lblPlayer2 setText: [NSString stringWithUTF8String: [vGame.player2_username UTF8String ]]];
    [Tools versionedScaleFactor:_lblPlayer2 factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer2 alignment:NSTextAlignmentLeft];
    
    [_lblPlayer1Mines setText: [NSString stringWithFormat:@"%d",[vGame mines_player1] ] ];
    [Tools versionedScaleFactor:_lblPlayer1Mines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer1Mines alignment:NSTextAlignmentCenter];
    
    [_lblPlayer2Mines setText: [NSString stringWithFormat:@"%d",[vGame mines_player2] ] ];
    [Tools versionedScaleFactor:_lblPlayer2Mines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer2Mines alignment:NSTextAlignmentCenter];
    
    [_lblMines setText: [NSString stringWithFormat: @"%d",[vGame remainingMines]]];
    [Tools versionedScaleFactor:_lblMines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblMines alignment:NSTextAlignmentCenter];
    
    [_lblDate setText: [NSString stringWithUTF8String: [vGame.date_last_played UTF8String ]]];
    [Tools versionedScaleFactor:_lblDate factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblDate alignment:NSTextAlignmentLeft];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
