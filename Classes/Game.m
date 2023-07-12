/* ----====----====----====----====----====----====----====----====----====----
Game.m (jeweltoy)

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

#import "Game.h"
#import "Gem.h"
//
// MW...
//
#import "ScoreBubble.h"
//

@implementation Game {
    // MW...
    //
    NSMutableArray	*scoreBubbles;
    //
    Gem 	*board[8][8];
    int		sx1,sy1,sx2,sy2, hintx, hinty;
    int		score, bonusMultiplier, gemsFaded;
    // CASCADE BONUS
    int		cascade;
    //
    BOOL	muted;
}

- (id) init
{
    int i,j;
    self = [super init];
    gemsFaded = 0;
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            board[i][j] = [[Gem alloc] init];
    // MW
    scoreBubbles= [[NSMutableArray arrayWithCapacity:12] retain];
    //
    return self;
}

- (id) initWithImagesFrom:(NSArray *) imageArray
{
    int i,j;
    self = [super init];
    srand([[NSDate date] timeIntervalSince1970]);	// seed by time
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
        {
            int r = [self randomGemTypeAt:i:j];
            board[i][j] = [[Gem gemWithNumber:r andImage:[imageArray objectAtIndex:r]] retain];
            [board[i][j] setPositionOnBoard:i:j];
            [board[i][j] setPositionOnScreen:i*48:j*48];
            [board[i][j] shake];
        }
            // MW...
            scoreBubbles= [[NSMutableArray arrayWithCapacity:12] retain];
    //
    score = 0;
    gemsFaded = 0;
    bonusMultiplier = 1;
    return self;
}

- (id) initWithSpritesFrom:(NSArray *) spriteArray
{
    int i,j;
    self = [super init];
    srand([[NSDate date] timeIntervalSince1970]);	// seed by time
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
        {
            //int r = (rand() % 3)*2+((i+j)%2);
            int r = [self randomGemTypeAt:i:j];
            board[i][j] = [[Gem gemWithNumber:r andSprite:[spriteArray objectAtIndex:r]] retain];
            [board[i][j] setPositionOnBoard:i:j];
            [board[i][j] setPositionOnScreen:i*48:j*48];
            [board[i][j] shake];
        }
            // MW...
            scoreBubbles= [[NSMutableArray arrayWithCapacity:12] retain];
    //
    score = 0;
    gemsFaded = 0;
    bonusMultiplier = 1;
    return self;
}

- (void) dealloc
{
    int i,j;
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            [board[i][j] release];
    // MW...
    [scoreBubbles release];
    //
    [super dealloc];
}

- (void) setImagesFrom:(NSArray *) imageArray
{
    int i,j;
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            [board[i][j] setImage:[imageArray objectAtIndex:[board[i][j] gemType]]];
}

- (void) setSpritesFrom:(NSArray *) spriteArray
{
    int i,j;
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            [board[i][j] setSprite:[spriteArray objectAtIndex:[board[i][j] gemType]]];
}

- (int) randomGemTypeAt:(int)x :(int)y
{
    int c = (x+y) % 2;
    int r = rand() % 7;
    if (c)
        return (r & 6);	// even
    if (r == 6)
        return 1;	// catch returning 7
    return (r | 1); 	// odd
}

- (Gem *) gemAt:(int)x :(int)y
{
    return board[x][y];
}

//
// MW...
//
- (NSMutableArray *)scoreBubbles
{
    return scoreBubbles;
}
//
////

- (void) setMuted:(BOOL)value
{
    int i,j;
    muted = value;
    if (muted)
    	for (i = 0; i < 8; i++)
            for (j = 0; j < 8; j++)
                [board[i][j] setSoundsTink:NULL Sploink:NULL];
    else
    	for (i = 0; i < 8; i++)
            for (j = 0; j < 8; j++)
                [board[i][j] setSoundsTink:[NSSound soundNamed:@"tink"] Sploink:[NSSound soundNamed:@"sploink"]];
}    


- (void) swap:(int)x1 :(int)y1 and:(int)x2 :(int)y2
{
    Gem	*swap = board[x1][y1];
    board[x1][y1] = board[x2][y2];
    [board[x1][y1] setPositionOnBoard:x1:y1];
    board[x2][y2] = swap;
    [board[x2][y2] setPositionOnBoard:x2:y2];
    sx1 = x1; sx2 = x2; sy1 = y1; sy2 = y2;
}

- (void) unswap
{
    [self swap:sx1:sy1 and:sx2:sy2];
}

- (BOOL) testForThreeAt:(int) x :(int) y
{
    int	tx,ty,cx,cy;
    int bonus, linebonus, scorePerGem;
    float scorebubble_x = -1.0;
    float scorebubble_y = -1.0;
    BOOL result = NO;
    int	gemtype = [board[x][y] gemType];
    tx = x; ty = y; cx = x; cy = y;
    bonus = 0;
    if ([board[x][y] state] == GEMSTATE_FADING)		result = YES;
    while ((tx > 0)&&([board[tx-1][y] gemType]==gemtype))	tx = tx-1;
    while ((cx < 7)&&([board[cx+1][y] gemType]==gemtype))	cx = cx+1;
    if ((cx-tx) >= 2)
    {
        // horizontal line
        int i,j;
        linebonus= 0;
        scorePerGem = (cx-tx)*5;
        for (i = tx; i <= cx; i++)
        {
            linebonus+= scorePerGem;
            [board[i][y] fade];
            for (j=7; j>y; j--) {
                if ([board[i][j] state]!= GEMSTATE_FADING) {
                    [board[i][j] shiver];	//	MW prepare to fall
                }
            }
        }
        // to center scorebubble ...
        scorebubble_x = tx + (cx-tx)/2.0;
        scorebubble_y = y;
        //
        bonus += linebonus;
        result = YES;
    }
    while ((ty > 0)&&([board[x][ty-1] gemType]==gemtype))	ty = ty-1;
    while ((cy < 7)&&([board[x][cy+1] gemType]==gemtype))	cy = cy+1;
    if ((cy-ty) >= 2)
    {
        // vertical line
        int i,j;
        linebonus= 0;
        scorePerGem = (cy-ty)*5;
        for (i = ty; i <= cy; i++)
        {
            linebonus += scorePerGem;
            [board[x][i] fade];
        }
        for (j=7; j>cy; j--) {
            if ([board[x][j] state]!= GEMSTATE_FADING) {
                [board[x][j] shiver];		//	MW prepare to fall
            }
        }
        // to center scorebubble ...
        if (scorebubble_x < 0)	// only if one hasn't been placed already ! (for T and L shapes)
        {
            scorebubble_x = x;
            scorebubble_y = ty + (cy-ty)/2.0;
        }
        else			// select the original gem position
        {
            scorebubble_x = x;
            scorebubble_y = y;
        }
        //
        bonus += linebonus;
        result = YES;
    }
    // CASCADE BONUS
    if (cascade>=1)
        bonus *= cascade;
    //
    // MW's scorebubble
    //
    if (bonus>0)
        [scoreBubbles addObject:[ScoreBubble scoreWithValue:bonus*bonusMultiplier
                                                         At:NSMakePoint(scorebubble_x*48+24, scorebubble_y*48+24)
                                                   Duration:40]];
    //
    score += bonus * bonusMultiplier;
    return result;
}

- (BOOL) finalTestForThreeAt:(int) x :(int) y
{
    int	tx,ty,cx,cy;
    BOOL result = NO;
    int	gemtype = [board[x][y] gemType];
    tx = x; ty = y; cx = x; cy = y;

    if ([board[x][y] state] == GEMSTATE_FADING)	return YES;
        
    while ((tx > 0)&&([board[tx-1][y] gemType]==gemtype))	tx = tx-1;
    while ((cx < 7)&&([board[cx+1][y] gemType]==gemtype))	cx = cx+1;
    if ((cx-tx) >= 2)
    {
        // horizontal line
        int i;
        for (i = tx; i <= cx; i++)
            [board[i][y] fade];
        result = YES;
    }
    while ((ty > 0)&&([board[x][ty-1] gemType]==gemtype))	ty = ty-1;
    while ((cy < 7)&&([board[x][cy+1] gemType]==gemtype))	cy = cy+1;
    if ((cy-ty) >= 2)
    {
        // vertical line
        int i;
        for (i = ty; i <= cy; i++)
            [board[x][i] fade];
        result = YES;
    }
    return result;
}

- (BOOL) checkForThreeAt:(int) x :(int) y
{
    int	tx,ty,cx,cy;
    int	gemtype = [board[x][y] gemType];
    tx = x; ty = y; cx = x; cy = y;
    while ((tx > 0)&&([board[tx-1][y] gemType]==gemtype))	tx = tx-1;
    while ((cx < 7)&&([board[cx+1][y] gemType]==gemtype))	cx = cx+1;
    if ((cx-tx) >= 2)
    	return YES;
    while ((ty > 0)&&([board[x][ty-1] gemType]==gemtype))	ty = ty-1;
    while ((cy < 7)&&([board[x][cy+1] gemType]==gemtype))	cy = cy+1;
    if ((cy-ty) >= 2)
        return YES;
    return NO;
}

- (BOOL) checkBoardForThrees
{
    int i,j;
    BOOL result = NO;
    // CASCADE BONUS increase
    cascade++;
    //
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
        if ([board[i][j] state]!=GEMSTATE_FADING)
            result = result | [self testForThreeAt:i:j];
    // CASCADE BONUS check for reset
    if (!result) cascade = 1;
    return result;
}


- (void) showAllBoardMoves
{
    // test every possible move
    int i,j;

    // horizontal moves
    for (j = 0; j < 8; j++)
        for (i = 0; i < 7; i++)
        {
            [self swap:i:j and:i+1:j];
            [self finalTestForThreeAt:i:j];
            [self finalTestForThreeAt:i+1:j];
            [self unswap];
        }

    // vertical moves
    for (i = 0; i < 8; i++)
        for (j = 0; j < 7; j++)
        {
            [self swap:i:j and:i:j+1];
            [self finalTestForThreeAt:i:j];
            [self finalTestForThreeAt:i:j+1];
            [self unswap];
        }

    // over the entire board, set the animationtime for the marked gems higher
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
        {
            if ([board[i][j] state] == GEMSTATE_FADING)
            {
                [board[i][j] erupt];
                [board[i][j] setAnimationCounter:1];
            }
            else
                [board[i][j] erupt];
        }

    
}

- (BOOL) boardHasMoves
{
    // test every possible move
    int i,j;
    BOOL	result = NO;
    // horizontal moves
    for (j = 0; j < 8; j++)
        for (i = 0; i < 7; i++)
        {
            [self swap:i:j and:i+1:j];
            result = [self checkForThreeAt:i:j] | [self checkForThreeAt:i+1:j];
            [self unswap];
            if (result)
            {
                hintx = i;
                hinty = j;
                return result;
            }
        }

            // vertical moves
            for (i = 0; i < 8; i++)
                for (j = 0; j < 7; j++)
                {
                    [self swap:i:j and:i:j+1];
                    result = [self checkForThreeAt:i:j] | [self checkForThreeAt:i:j+1];
                    [self unswap];
                    if (result)
                    {
                        hintx = i;
                        hinty = j;
                        return result;
                    }
                }
                    return NO;
}

//- (void) removeFadedGemsAndReorganiseWithImagesFrom:(NSArray *) imageArray
//{
//    int i,j,fades, y;
//    for (i = 0; i < 8; i++)
//    {
//        Gem	*column[8];
//        fades = 0;
//        y = 0;
//        // let non-faded gems fall into place
//        for (j = 0; j < 8; j++)
//        {
//            if ([board[i][j] state] != GEMSTATE_FADING)
//            {
//                column[y] = board[i][j];
//                if ([board[i][j] positionOnScreen].y > y*48)
//                    [board[i][j] fall];
//                y++;
//            }
//            else
//                fades++;
//        }
//        // transfer faded gems to top of column
//        for (j = 0; j < 8; j++)
//        {
//            if ([board[i][j] state] == GEMSTATE_FADING)
//            {
//                // randomly reassign
//                int r = (rand() % 7);
//                [board[i][j]	setGemType:r];
//                [board[i][j]	setImage:[imageArray objectAtIndex:r]];
//
//                column[y] = board[i][j];
//                [board[i][j] setPositionOnScreen:i*48:(7+fades)*48];
//                [board[i][j] fall];
//                y++;
//                gemsFaded++;
//                fades--;
//            }
//        }
//        // OK, shuffling all done - reorganise column
//        for (j = 0; j < 8; j++)
//        {
//            board[i][j] = column[j];
//            [board[i][j] setPositionOnBoard:i:j];
//        }
//    }
//}

- (void) removeFadedGemsAndReorganiseWithSpritesFrom:(NSArray *) spriteArray
{
    int i,j,fades, y;
    for (i = 0; i < 8; i++)
    {
        Gem	*column[8];
        fades = 0;
        y = 0;
        // let non-faded gems fall into place
        for (j = 0; j < 8; j++)
        {
            if ([board[i][j] state] != GEMSTATE_FADING)
            {
                column[y] = board[i][j];
                if ([board[i][j] positionOnScreen].y > y*48)
                    [board[i][j] fall];
                y++;
            }
            else
                fades++;
        }
        // transfer faded gems to top of column
        for (j = 0; j < 8; j++)
        {
            if ([board[i][j] state] == GEMSTATE_FADING)
            {
                // randomly reassign
                int r = (rand() % 7);
                [board[i][j]	setGemType:r];
                [board[i][j]	setSprite:[spriteArray objectAtIndex:r]];

                column[y] = board[i][j];
                [board[i][j] setPositionOnScreen:i*48:(7+fades)*48];
                [board[i][j] fall];
                y++;
                gemsFaded++;
                fades--;
            }
        }
        // OK, shuffling all done - reorganise column
        for (j = 0; j < 8; j++)
        {
            board[i][j] = column[j];
            [board[i][j] setPositionOnBoard:i:j];
        }
    }
}

- (void) shake
{
    int i,j;
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            [board[i][j] shake];
}

- (void) erupt
{
    int i,j;
    if (!muted)	[[NSSound soundNamed:@"yes"] play];
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            [board[i][j] erupt];
}

- (void) explodeGameOver
{
    //int i,j;
    if (!muted)	[[NSSound soundNamed:@"explosion"] play];
    /*--
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
            [board[i][j] erupt];
    --*/
    [self showAllBoardMoves];	// does a delayed eruption
}

- (void) wholeNewGameWithImagesFrom:(NSArray *) imageArray
{
    int i,j;
    srand([[NSDate date] timeIntervalSince1970]);	// seed by time
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
        {
            //int r = (rand() % 3)*2+((i+j)%2);
            int r = [self randomGemTypeAt:i:j];
            [board[i][j] setGemType:r];
            [board[i][j] setImage:[imageArray objectAtIndex:r]];
            [board[i][j] setPositionOnBoard:i:j];
            [board[i][j] setPositionOnScreen:i*48:(15-j)*48];
            [board[i][j] fall];
        }
            score = 0;
    gemsFaded = 0;
    bonusMultiplier = 1;
}

- (void) wholeNewGameWithSpritesFrom:(NSArray *) spriteArray
{
    int i,j;
    srand([[NSDate date] timeIntervalSince1970]);	// seed by time
    for (i = 0; i < 8; i++)
        for (j = 0; j < 8; j++)
        {
            //int r = (rand() % 3)*2+((i+j)%2);
            int r = [self randomGemTypeAt:i:j];
            [board[i][j] setGemType:r];
            [board[i][j] setSprite:[spriteArray objectAtIndex:r]];
            [board[i][j] setPositionOnBoard:i:j];
            [board[i][j] setPositionOnScreen:i*48:(15-j)*48];
            [board[i][j] fall];
        }
            score = 0;
    gemsFaded = 0;
    bonusMultiplier = 1;
}

- (NSPoint)	hintPoint
{
    return NSMakePoint(hintx*48,hinty*48);
}

- (float) collectGemsFaded
{
    float result = (float)gemsFaded;
    gemsFaded = 0;
    return result;
}

- (int) score
{
    return score;
}

- (int) bonusMultiplier
{
    return bonusMultiplier;
}

- (void) increaseBonusMultiplier
{
    bonusMultiplier++;
}

@end
