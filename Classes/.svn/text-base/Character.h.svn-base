/*******************************************************************************
* Character.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for the
*						characters
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/30/08		*	EGC	*	File creation date
*******************************************************************************/

#import <Foundation/Foundation.h>

@interface Character : NSObject
{

	short			xpos;			/* Current Pixel Position on Board - X Axis */
	short			ypos;			/* Current Pixel Position on Board - Y Axis */
	short			dir;			/* Current Direction */
	short			move;			/* Boolean Value for Character Moved */
	short			fall;			/* Boolean Value for Character Falling */
	short			platform;		/* Boolean Value for Character on Platform */
	short			sprite;			/* Current Sprite Displaying */
	short			xblk;			/* Current Block Position on Board - X Axis */
	short			yblk;			/* Current Block Position on Board - Y Axis */
	short			gold;			/* Amount of Gold in Possession */
	short			time;			/* Time Guard Stuck in Hole */
	short			last_x_dir;		/* Last X Axis Direction Player Moved In */
	short			last_y_dir;		/* Last Y Axis Direction Player Moved In */
	// Additions to the original variables
	BOOL			runner;			// Flag for whether this character is the runner
}
- (void)Character_Placement;
- (BOOL)Check_Path:(short)mode inDirection:(short)direction;
- (void)Chase_Pattern;
- (short)xpos;
- (short)ypos;
- (short)time;
- (short)sprite;
- (short)xblk;
- (short)yblk;
- (short)last_x_dir;
- (short)last_y_dir;
- (short)dir;
- (short)gold;
- (void)setXPos:(short)newPos;
- (void)setYPos:(short)newPos;
- (void)setXBlk:(short)newPos;
- (void)setYBlk:(short)newPos;
- (void)setSprite:(short)newSprite;
- (void)setTime:(short)newTime;
- (void)setFall:(short)newFall;
- (void)setMove:(BOOL)newMove;
- (void)setDir:(short)newDir;
- (void)setAsRunner;
- (void)incrementGold;
- (void)decrementGold;
@end
