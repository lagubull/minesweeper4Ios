//
//  DBManager.h
//  DBTest
//
//  Created by jlagunas on 24/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

extern const NSInteger kJMSRestorableGames;

@class VersusGame;

@interface DBManager : NSObject

/**
 Creates the DB
 */
- (void)createDB;

/**
 Upgrades the DB from one version to another
 
 @param oldVersion original version of the user's DB
 @param newVersion most recent version of the DB
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
 
 @return NSMutableArray with versus games
 */
- (NSMutableArray *)getRestorableVersusGame;

/**
 Get Latest Versus Game
 
 @return id of the latest versusGame
 */
- (NSInteger)getLatestVersusGame;

/**
 Writes to DB an updated status of the game
 
 @param game to be updated
 */
- (void)updateVersusGame:(VersusGame *)game;

@end
