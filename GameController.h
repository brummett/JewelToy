/* ----====----====----====----====----====----====----====----====----====----
GameController.h (jeweltoy)

JewelToy is a simple game played against the clock.
Copyright (C) 2001  Giles Williams

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
----====----====----====----====----====----====----====----====----====---- */

#import <Cocoa/Cocoa.h>

#define	GAMESTATE_GAMEOVER		1
#define	GAMESTATE_AWAITINGFIRSTCLICK	2
#define	GAMESTATE_AWAITINGSECONDCLICK	3
#define	GAMESTATE_FRACULATING		4
#define	GAMESTATE_SWAPPING		5
#define	GAMESTATE_FADING		6
#define	GAMESTATE_FALLING		7
#define	GAMESTATE_UNSWAPPING		8
#define	GAMESTATE_EXPLODING		9
#define	GAMESTATE_FINISHEDFRACULATING	10

#define GEM_GRAPHIC_SIZE	48
#define GEM_MOVE_SPEED		6

#define	GEMS_FOR_BONUS	100.0
#define	SPEED_LIMIT	5000

#define TIMER_INTERVAL	0.04

@class Game, GameView, MyTimerView;

@interface GameController : NSObject
{
    IBOutlet NSPanel		*aboutPanel, *prefsPanel;
    IBOutlet GameView		*gameView;
    IBOutlet NSButton		*prefsStandardGraphicsButton, *prefsAlternateGraphicsButton;
    IBOutlet NSImageView	*prefsAlternateGraphicsImageView;
    IBOutlet NSButton		*prefsCustomBackgroundCheckbox, *prefsSelectFolderButton;
    IBOutlet NSTextField	*prefsCustomBackgroundFolderTextField;
    IBOutlet NSImageView	*iv1, *iv2, *iv3, *iv4, *iv5, *iv6, *iv7;
    IBOutlet NSButton		*easyGameButton, *hardGameButton, *toughGameButton;
    IBOutlet NSMenuItem		*easyGameMenuItem, *hardGameMenuItem, *toughGameMenuItem;
    IBOutlet NSButton		*abortGameButton, *pauseGameButton, *muteButton;
    IBOutlet NSMenuItem		*abortGameMenuItem, *pauseGameMenuItem, *muteMenuItem;
    IBOutlet NSMenuItem		*freePlayMenuItem, *showHighScoresMenuItem, *resetHighScoresMenuItem;
    IBOutlet NSTextField	*scoreTextField, *bonusTextField;
    IBOutlet MyTimerView	*timerView;
    IBOutlet NSWindow		*gameWindow;
    IBOutlet NSPanel		*hiScorePanel;
    IBOutlet NSTextField	*hiScorePanelScoreTextField, *hiScorePanelNameTextField;
    
    NSLock		*animationTimerLock;
    
    NSArray		*hiScores;
    NSMutableArray	*gameScores, *gameNames;

    int			*hintTimeSeconds;
    
    NSString		*noMoreMovesString, *jeweltoyStartString, *gameOverString;
    NSImage		*titleImage;
    
    BOOL		abortGame;
    NSTimer		*timer;
    Game		*game;
    int			gameLevel;
    float		gameSpeed;
    float		gameTime;
    int			gemMoveSpeed, gemMoveSteps, gemMoveSize;
    
    BOOL		useAlternateGraphics, useImportedGraphics, useCustomBackgrounds;
    BOOL		paused, freePlay, muted, animationStatus;

    NSString		*customBackgroundFolderPath;
    
    int			gameState, gemsSoFar, chx1, chy1, chx2, chy2;
    SEL			whatNext;
}

- (id) init;
- (void) dealloc;

- (void)awakeFromNib;

- (void)windowWillClose:(NSNotification *)aNotification;
- (IBAction)prefsGraphicDropAction:(id)sender;
- (IBAction)prefsCustomBackgroundCheckboxAction:(id)sender;
- (IBAction)prefsSelectFolderButtonAction:(id)sender;

- (BOOL) validateMenuItem: (NSMenuItem*) aMenuItem;

- (IBAction)startNewGame:(id)sender;
- (IBAction)abortGame:(id)sender;
- (IBAction)receiveHiScoreName:(id)sender;
- (IBAction)togglePauseMode:(id)sender;
- (IBAction)toggleMute:(id)sender;
- (IBAction)orderFrontAboutPanel:(id)sender;
- (IBAction)orderFrontPreferencesPanel:(id)sender;
- (IBAction)showHighScores:(id)sender;
- (IBAction)resetHighScores:(id)sender;

- (NSArray *)makeBlankHiScoresWith:(NSArray *)oldScores;

- (void)runOutOfTime;
- (void)checkHiScores;
- (void)bonusAwarded;

- (void)startAnimation:(SEL)andThenSelector;
- (void)animationEnded;

- (void)waitForNewGame;
- (void)newBoard1;
- (void)newBoard2;
- (void)waitForFirstClick;
- (void)receiveClickAt:(int)x:(int)y;
- (void)updateBonusTextFieldWithValue:(int)val;
- (void)tryMoveSwapping:(int)x1:(int)y1 and:(int)x2:(int)y2;
    // test for threes
- (void)testForThrees;    
    // if there are threes:

    //// repeat:	remove threes
- (void)removeThreesAndReplaceGems;
    //// 		replace gems
- (void)testForThreesAgain;
    //// 		test for threes
    //// until there are no threes
- (void)unSwap;    
    // else swap them back

- (int) gameState;
- (BOOL) gameIsPaused;
- (BOOL) useCustomBackgrounds;
- (NSPoint) crossHair1Position;
- (NSPoint) crossHair2Position;
@end
