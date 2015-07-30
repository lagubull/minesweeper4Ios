//
//  DBManager.h
//  DBTest
//
//  Created by jlagunas on 24/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

extern const NSUInteger kJMSRestorableGames;

@class VersusGame;

@interface DBManager : NSObject

/**
 */
- (void)createDB;

/**
 */
- (void)upgrade:(NSNumber *)oldVersion
     newVersion:(NSNumber *)newVersion;

/**
 Inserts new Versus_game.
 
 @param VersusGame
 */
- (void)createVersusGame:(VersusGame *)versusGame;

/**
 Get Restorable Versus Games
 
 @return NSMutableArray
 */
- (NSMutableArray *)getRestorableVersusGame;

/**
 Get Latest Versus Game
 
 @return int
 */
- (NSNumber *)getLatestVersusGame;

/**
 */
- (void)updateVersusGame:(VersusGame *)game;

@end
