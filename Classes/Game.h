/* ----====----====----====----====----====----====----====----====----====----
Game.h (jeweltoy)

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

@class Gem;

@interface Game : NSObject

- (id) init;
- (id) initWithImagesFrom:(NSArray *) imageArray;
- (id) initWithSpritesFrom:(NSArray *) spriteArray;
- (void) dealloc;

- (void) setImagesFrom:(NSArray *) imageArray;
- (void) setSpritesFrom:(NSArray *) spriteArray;

- (int) randomGemTypeAt:(int)x :(int)y;
- (Gem *) gemAt:(int)x :(int)y;
- (NSMutableArray *)scoreBubbles;

- (void) setMuted:(BOOL)value;

- (void) swap:(int)x1 :(int)y1 and:(int)x2 :(int)y2;
- (void) unswap;

- (BOOL) testForThreeAt:(int) x :(int) y;
- (BOOL) checkForThreeAt:(int) x :(int) y;
- (BOOL) finalTestForThreeAt:(int) x :(int) y;
- (BOOL) checkBoardForThrees;
- (BOOL) boardHasMoves;
- (void) showAllBoardMoves;

// - (void) removeFadedGemsAndReorganiseWithImagesFrom:(NSArray *) imageArray;
- (void) removeFadedGemsAndReorganiseWithSpritesFrom:(NSArray *) spriteArray;
- (void) shake;
- (void) erupt;
- (void) explodeGameOver;
- (void) wholeNewGameWithImagesFrom:(NSArray *) imageArray;
- (void) wholeNewGameWithSpritesFrom:(NSArray *) spriteArray;

- (NSPoint)	hintPoint;
- (int) score;
- (float) collectGemsFaded;
- (int) bonusMultiplier;
- (void) increaseBonusMultiplier;

@end
