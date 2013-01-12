/*******************************************************************************
* Character.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for the
*						characters
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/30/08		*	EGC	*	File creation date
*******************************************************************************/

#import "Character.h"
#import "Classic_Gold_RunnerAppDelegate.h"

extern struct place_block block_move[MAX_MOVE_BLOCKS];
extern struct object objs[MAX_OBJECTS];

@implementation Character

#pragma mark - Object Lifecycle

- (id)init
{
	[super init];
	xpos = 0;
	ypos = 0;
	dir = STOP;
	runner = NO;
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark - Business Logic

- (void)Character_Placement
{

   short move_x, move_y;
   short direction, player_xpos, player_ypos;
   BOOL dig = NO;
   BOOL upPressed = NO;
   BOOL downPressed = NO;
   BOOL leftPressed = NO;
   BOOL rightPressed = NO;

      if (!runner)
         {
         move_x = GUARD_MOVE_X;
         move_y = GUARD_MOVE_Y;
         direction = dir;
         }
      else
         {
         move_x = RUNNER_MOVE_X;
         move_y = RUNNER_MOVE_Y;
		if (([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controlStyle] != CONTROL_STYLE_PRECISE || [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] screenOrientation] == SCREEN_ORIENTATION_HORIZONTAL) && fall)
			{
            direction = STOP;
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:STOP];
			}
         else
		if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controlStyle] == CONTROL_STYLE_PRECISE && [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] screenOrientation] != SCREEN_ORIENTATION_HORIZONTAL)
			{
			upPressed = [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] upButtonPressed];
			downPressed = [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] downButtonPressed];
			leftPressed = [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] leftButtonPressed];
			rightPressed = [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] rightButtonPressed];
			// If we don't find a direction to set, default to the direction currently traveled
			if (upPressed)
				direction = UP;
			else if (downPressed)
				direction = DOWN;
			else if (leftPressed)
				direction = LEFT;
			else if (rightPressed)
				direction = RIGHT;
			else
				direction = STOP;
			}
		else
			{
            direction = [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controller_dir];
			}
		if (dir == UP && (downPressed || leftPressed || rightPressed))
			{
			if (downPressed)
				direction = DOWN;
			else if (leftPressed)
				direction = LEFT;
			else if (rightPressed)
				direction = RIGHT;
			}
		else if (dir == DOWN && (upPressed || leftPressed || rightPressed))
			{
			if (upPressed)
				direction = UP;
			else if (leftPressed)
				direction = LEFT;
			else if (rightPressed)
				direction = RIGHT;
			}
		else if (dir == LEFT && (upPressed || downPressed || rightPressed))
			{
			if (upPressed)
				direction = UP;
			else if (downPressed)
				direction = DOWN;
			else if (rightPressed)
				direction = RIGHT;
			}
		else if (dir == RIGHT && (upPressed || downPressed || leftPressed))
			{
			if (upPressed)
				direction = UP;
			else if (downPressed)
				direction = DOWN;
			else if (leftPressed)
				direction = LEFT;
			}
         }
      player_xpos = xpos;
      player_ypos = ypos;
      if (runner && [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner_dig] && !(!(xpos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth]) && !(ypos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight]) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_FALLTHROUGH)))
         {
		 [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:NO];
         if ((dig = [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] Dig_Hole]) == TRUE)
            {
            if (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_AIR))
               time = TRUE;
            }
         }
      if (!fall && !(runner && dig) && !(runner && time))
         {
         switch (direction)
            {
            case LEFT:
               if ([self Check_Path:1 inDirection:LEFT])
                  {
                  xpos -= move_x;
                  last_x_dir = LEFT;
                  }
               break;
            case RIGHT:
               if ([self Check_Path:1 inDirection:RIGHT])
                  {
                  xpos += move_x;
                  last_x_dir = RIGHT;
                  }
               break;
            case UP:
               if ([self Check_Path:1 inDirection:UP])
                  {
                  ypos -= move_y;
                  last_y_dir = UP;
                  }
               break;
            case DOWN:
               if ([self Check_Path:1 inDirection:DOWN])
                  {
                  ypos += move_y;
                  last_y_dir = DOWN;
                  }
               break;
            case STOP:
               if (runner && !(xpos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth]) && !(ypos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight]) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_NONSTICK) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_FALLTHROUGH))
                  {
                  if ([self Check_Path:1 inDirection:DOWN])
                     {
                     ypos += move_y;
                     last_y_dir = DOWN;
                     }
                  }
               else
                  [self Check_Path:1 inDirection:STOP];
               break;
            default:
               break;
            }
         }
      else if (!(runner && dig) && !(runner && time))
         {
         if ([self Check_Path:1 inDirection:DOWN])
            ypos += move_y;
         else if (!time && [self Check_Path:1 inDirection:direction])
            {
            switch (direction)
               {
               case LEFT:
                  xpos -= move_x;
                  last_x_dir = LEFT;
                  break;
               case RIGHT:
                  xpos += move_x;
                  last_x_dir = RIGHT;
                  break;
               default:
                  break;
               }
            }
         }
      xblk = xpos / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth];
      yblk = ypos / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight];

      if (runner && ypos == 0 && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_LADDER))
          [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] Win_Board];

      if (player_xpos != xpos || player_ypos != ypos)
         move = TRUE;
      else
         move = FALSE;
}

// Function pulled from the Gold Runner Engine and made a method of this class
- (BOOL)Check_Path:(short)mode inDirection:(short)direction
{

	short blk_x_lt, blk_x_rt, blk_y_top, blk_y_bot;
	short lt_pos_x, rt_pos_x, top_pos_y, bot_pos_y;
	short char_width, char_height, step_x, step_y;
	short blk_offx, blk_offy;
	short l_strt, r_strt, c_strt, s_strt, f_strt;
	short l_end, r_end, c_end, s_end, f_end;
	short x, y = 0;
	BOOL clear_path = NO;

	if (!runner)
	  {
	  char_width = GUARD_WIDTH;
	  char_height = GUARD_HEIGHT;
	  step_x = GUARD_MOVE_X;
	  step_y = GUARD_MOVE_Y;
	  if (mode)
		 {
		 l_strt = GUARD_LEFT_START;
		 r_strt = GUARD_RIGHT_START;
		 c_strt = GUARD_CLIMB_START;
		 s_strt = GUARD_SHIMMY_START;
		 f_strt = GUARD_FALL_START;
		 l_end = GUARD_LEFT_END;
		 r_end = GUARD_RIGHT_END;
		 c_end = GUARD_CLIMB_END;
		 s_end = GUARD_SHIMMY_END;
		 f_end = GUARD_FALL_END;
		 }
	  }
	else
	  {
	  char_width = RUNNER_WIDTH;
	  char_height = RUNNER_HEIGHT;
	  step_x = RUNNER_MOVE_X;
	  step_y = RUNNER_MOVE_Y;
	  l_strt = RUNNER_LEFT_START;
	  r_strt = RUNNER_RIGHT_START;
	  c_strt = RUNNER_CLIMB_START;
	  s_strt = RUNNER_SHIMMY_START;
	  f_strt = RUNNER_FALL_START;
	  l_end = RUNNER_LEFT_END;
	  r_end = RUNNER_RIGHT_END;
	  c_end = RUNNER_CLIMB_END;
	  s_end = RUNNER_SHIMMY_END;
	  f_end = RUNNER_FALL_END;
	  }
	if (!(xpos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth]) && !(ypos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight]) && !time && yblk < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardHeight] - 1) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_NONSTICK) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_FALLTHROUGH))
	  {
	  dir = DOWN;
	  fall = TRUE;
	  }
	switch (direction)
	  {
	  case LEFT:
		 lt_pos_x = xpos - step_x;
		 rt_pos_x = xpos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] - 1 - step_x;
		 top_pos_y = ypos;
		 bot_pos_y = ypos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] - 1;
		 if (lt_pos_x < 0)
			return (FALSE);
		 break;
	  case RIGHT:
		 lt_pos_x = xpos + step_x;
		 rt_pos_x = xpos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] - 1 + step_x;
		 top_pos_y = ypos;
		 bot_pos_y = ypos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] - 1;
		 if (rt_pos_x >= [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardWidth] * [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth])
			return (FALSE);
		 break;
	  case UP:
		 lt_pos_x = xpos;
		 rt_pos_x = xpos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] - 1;
		 top_pos_y = ypos - step_y;
		 bot_pos_y = ypos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] - 1 - step_y;
		 if (top_pos_y < 0 && !time)
			return (FALSE);
		 break;
	  case DOWN:
		 lt_pos_x = xpos;
		 rt_pos_x = xpos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] - 1;
		 top_pos_y = ypos + step_y;
		 bot_pos_y = ypos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] - 1 + step_y;
		 break;
	  case STOP:
		 lt_pos_x = xpos;
		 rt_pos_x = xpos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] - 1;
		 top_pos_y = ypos;
		 bot_pos_y = ypos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] - 1;
		 break;
	  default:
		 break;
	  }
	blk_y_top = top_pos_y / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight];
	blk_y_bot = bot_pos_y / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight];
	blk_x_lt = lt_pos_x / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth];
	blk_x_rt = rt_pos_x / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth];
	blk_offx = xpos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth];
	blk_offy = ypos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight];
	if (!blk_offy)
	  {
	  switch (direction)
		 {
		 case LEFT:
			if (runner && (blk_offx - step_x == 0) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y_bot + 1) column:blk_x_lt] & TILE_FALLTHROUGH))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  fall = 1;
				  dir = DOWN;
				  if (sprite >= l_strt && sprite < l_end)
					 sprite++;
				  else
					 sprite = l_strt;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] time] && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] >= r_strt && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] <= r_end) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] >= c_strt && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] <= c_end && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] last_y_dir] == UP)) && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] yblk] == yblk && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xblk] == (xblk + 1))
					 {
					 [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] setTime:0];
					 [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:NO];
					 }
				  }
			   }
			else if ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_NONSOLID) && !(([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_DUG) && !runner)) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileForRow:yblk column:xblk] == BRICK_TILE && !runner))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = LEFT;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE)
					 {
					 if (sprite >= s_strt && sprite < s_end)
						sprite++;
					 else
						sprite = s_strt;
					 }
				  else
					 {
					 if (sprite >= l_strt && sprite < l_end)
						sprite++;
					 else
						sprite = l_strt;
					 }
				  }
			   }
			else if (runner && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_DUG))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = LEFT;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE)
					 {
					 if (sprite >= s_strt && sprite < s_end)
						sprite++;
					 else
						sprite = s_strt;
					 }
				  else
					 {
					 if (sprite >= l_strt && sprite < l_end)
						sprite++;
					 else
						sprite = l_strt;
					 }
				  }
			   }
			break;
		 case RIGHT:
			if (runner && (blk_offx + step_x == [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth]) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_ROPE) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_LADDER) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y_top + 1) column:blk_x_rt] & TILE_FALLTHROUGH))
			   {
			   clear_path = 1;  
			   if (mode)
				  {
				  fall = 1;
				  dir = DOWN;
				  if (sprite >= r_strt && sprite < r_end)
					 sprite++;
				  else
					 sprite = r_strt;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] time] && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] >= l_strt && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] <= l_end) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] >= c_strt && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] sprite] <= c_end && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] last_y_dir] == DOWN)) && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] yblk] == yblk && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xblk] == (xblk - 2))
					 {
					 [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] setTime:0];
					 [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:NO];
					 }
				  }
			   }
			else if ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_NONSOLID) && !(([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_DUG) && !runner)) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileForRow:yblk column:xblk] == BRICK_TILE && !runner))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = RIGHT;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE)
					 {
					 if (sprite >= s_strt && sprite < s_end)
						sprite++;
					 else
						sprite = s_strt;
					 }
				  else
					 {
					 if (sprite >= r_strt && sprite < r_end)
						sprite++;
					 else
						sprite = r_strt;
					 }
				  }
			   }
			else if (runner && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_DUG))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = RIGHT;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE)
					 {
					 if (sprite >= s_strt && sprite < s_end)
						sprite++;
					 else
						sprite = s_strt;
					 }
				  else
					 {
					 if (sprite >= r_strt && sprite < r_end)
						sprite++;
					 else
						sprite = r_strt;
					 }
				  }
			   }
			break;
		 case UP:
			if ((!blk_offx && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_NONSOLID))) || (time && !runner && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:blk_x_lt] & TILE_DUG)
			   || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_AIR) && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk - 1)] & TILE_BRICK) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk - 1)] & TILE_STONE))
			   && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_BRICK) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk - 1)] & TILE_STONE))
			   && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk + 1)] & TILE_BRICK) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk + 1)] & TILE_STONE))))))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if (blk_offx && runner && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] last_x_dir] == LEFT && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:blk_x_lt] & TILE_LADDER))
			   {
			   if (!mode)
				  clear_path = TRUE;
			   else
				  {
				  [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] setXPos:([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] - step_x)];
				  if (sprite >= l_strt && sprite < l_end)
					 sprite++;
				  else if (sprite == l_end)
					 sprite = l_strt;
				  else if (sprite >= s_strt && sprite < s_end)
					 sprite++;
				  else if (sprite == s_end)
					 sprite = s_strt;
				  }
			   }
			else if (blk_offx && runner && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] last_x_dir] == RIGHT && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:blk_x_rt] & TILE_LADDER))
			   {
			   if (!mode)
				  clear_path = TRUE;
			   else
				  {
				  [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] setXPos:([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] + step_x)];
				  if (sprite >= r_strt && sprite < r_end)
					 sprite++;
				  else if (sprite == r_end)
					 sprite = r_strt;
				  else if (sprite >= s_strt && sprite < s_end)
					 sprite++;
				  else if (sprite == s_end)
					 sprite = s_strt;
				  }
			   }
			break;
		 case DOWN:
			if (!(runner && [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controller_dir] == DOWN) && fall && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_ROPE)))
			   {
			   if (mode)
				  {
				  fall = 0;
				  if (sprite >= s_strt && sprite < s_end)
					 sprite++;
				  else
					 sprite = s_strt;
				  }
			   }
			else if (!blk_offx)
			   {
			   if (!fall && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_NONSOLID))))
				  {
				  clear_path = 1;
				  if (mode)
					 {
					 dir = DOWN;
					 if (sprite >= c_strt && sprite < c_end)
						sprite++;
					 else
						sprite = c_strt;
					 }
				  }
			   else if (!fall && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_FALLTHROUGH))
				  {
				  clear_path = 1;
				  if (mode)
					 {
					 fall = 1;
					 dir = DOWN;
					 if (sprite >= f_strt && sprite < f_end)
						sprite++;
					 else
						sprite = f_strt;
					 }
				  }
			   else if (fall && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_FALLTHROUGH) && yblk < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardHeight] - 1))
				  {
				  clear_path = 1;
				  if (mode)
					 {
					 dir = DOWN;
					 if (sprite >= f_strt && sprite < f_end)
						sprite++;
					 else
						sprite = f_strt;
					 }
				  }
			   else if (!runner && fall && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER))
				  {
				  clear_path = 1;
				  fall = FALSE;
				  if (mode)
					 {
					 dir = DOWN;
					 if (sprite >= f_strt && sprite < f_end)
						sprite++;
					 else
						sprite = f_strt;
					 }
				  }
			   else
				  if (mode)
					 fall = 0;
			   }
			else
			   {
			   if (runner && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] last_x_dir] == LEFT && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y_top + 1) column:blk_x_lt] & TILE_LADDER)))
				  {
				  if (!mode)
					 clear_path = TRUE;
				  else
					 {
					 [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] setXPos:([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] - step_x)];
					 if (sprite >= l_strt && sprite < l_end)
						sprite++;
					 else if (sprite == l_end)
						sprite = l_strt;
					 else if (sprite >= s_strt && sprite < s_end)
						sprite++;
					 else if (sprite == s_end)
						sprite = s_strt;
					 }
				  }
			   else if (runner && [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] last_x_dir] == RIGHT && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y_top + 1) column:blk_x_rt] & TILE_LADDER)))
				  {
				  if (!mode)
					 clear_path = TRUE;
				  else
					 {
				  [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] setXPos:([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] + step_x)];
					 if (sprite >= r_strt && sprite < r_end)
						sprite++;
					 else if (sprite == r_end)
						sprite = r_strt;
					 else if (sprite >= s_strt && sprite < s_end)
						sprite++;
					 else if (sprite == s_end)
						sprite = s_strt;
					 }
				  }
			   else if (fall && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_FALLTHROUGH) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_rt] & TILE_FALLTHROUGH))
				  {
				  clear_path = 1;
				  if (mode)
					 {
					 dir = DOWN;
					 if (sprite >= f_strt && sprite < f_end)
						sprite++;
					 else
						sprite = f_strt;
					 }
				  }
			   else if (!fall && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_ROPE) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_ROPE)))
				  {
				  if (!mode)
					 clear_path = TRUE;
				  else
					 {
					 if (last_x_dir == LEFT)
						{
						xpos -= step_x;
						if (sprite >= l_strt && sprite < l_end)
						   sprite++;
						else if (sprite == l_end)
						   sprite = l_strt;
						else if (sprite >= s_strt && sprite < s_end)
						   sprite++;
						else if (sprite == s_end)
						   sprite = s_strt;
						}
					 else if (last_x_dir == RIGHT)
						{
						xpos += step_x;
						if (sprite >= r_strt && sprite < r_end)
						   sprite++;
						else if (sprite == r_end)
						   sprite = r_strt;
						else if (sprite >= s_strt && sprite < s_end)
						   sprite++;
						else if (sprite == s_end)
						   sprite = s_strt;
						}
					 }
				  }
			   else
				  if (mode)
					 fall = 0;
			   }
		 default:
			break;
		 }
	  }
	else
	  {
	  switch (direction)
		 {
		 case LEFT:
			if (!blk_offx && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_rt] & TILE_LADDER)))
			   {
			   if (!mode)
				  clear_path = TRUE;
			   else
				  {
				  if (last_y_dir == UP)
					 ypos -= step_y;
				  else
					 ypos += step_y;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_rt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER))
			   && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_NONSOLID) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_NONSOLID))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = LEFT;
				  if (sprite >= l_strt && sprite < l_end)
					 sprite++;
				  else
					 sprite = l_strt;
				  }
			   }
			break;
		 case RIGHT:
			if (!blk_offx && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER)))
			   {
			   if (!mode)
				  clear_path = TRUE;
			   else
				  {
				  if (last_y_dir == UP)
					 ypos -= step_y;
				  else
					 ypos += step_y;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_rt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_LADDER))
				&& ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_NONSOLID) && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_rt] & TILE_NONSOLID))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = RIGHT;
				  if (sprite >= r_strt && sprite < r_end)
					 sprite++;
				  else
					 sprite = r_strt;
				  }
			   }
			break;
		 case UP:
			if ((!blk_offx && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_LADDER) || [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_LADDER)) || time)
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = UP;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if (runner && blk_offx - step_x == 0 && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_lt] & TILE_LADDER))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = UP;
				  xpos -= step_x;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if (runner && blk_offx + step_x == [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_top column:blk_x_rt] & TILE_LADDER))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = UP;
				  xpos += step_x;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			break;
		 case DOWN:
			if (fall)
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = DOWN;
				  if (sprite >= f_strt && sprite < f_end)
					 sprite++;
				  else
					 sprite = f_strt;
				  }
			   }
			else if (!fall && !blk_offx && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_LADDER)))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = DOWN;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if (runner && !fall && blk_offx - step_x == 0 && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_lt] & TILE_LADDER))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = DOWN;
				  xpos -= step_x;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			else if (runner && !fall && blk_offx + step_x == [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y_bot column:blk_x_rt] & TILE_LADDER))
			   {
			   clear_path = 1;
			   if (mode)
				  {
				  dir = DOWN;
				  xpos += step_x;
				  if (sprite >= c_strt && sprite < c_end)
					 sprite++;
				  else
					 sprite = c_strt;
				  }
			   }
			break;
		 default:
			break;
		 }
	  }
	if (mode && !runner && !blk_offx && !blk_offy && dir != UP)
	  {
	  for (x=0;x<MAX_OBJECTS;x++)
		 {
		 if (objs[x].active == YES && objs[x].type == OBJECT_TYPE_HOLE && objs[x].xblk == xblk && objs[x].yblk == yblk)
			{
			if (time == TIME_STUCK)
			   {
			   dir = UP;
			   return (FALSE);
			   }
			else if (!time)
			   {
			   for (Character *character in [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] guards])
				  {
				  if (character != self && xblk == [character xblk] && yblk == [character yblk] && [character time])
					 {
					 dir = STOP;
					 time = TIME_STUCK;
					 fall = FALSE;
					 return (FALSE);
					 }
				  }
				[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] setCharacteristic:(unsigned char)(TILE_STONE | TILE_DUG) forRow:yblk column:xblk];
			   [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] incrementScore:50];
			   time = 1;
			   dir = STOP;
			   fall = FALSE;
			   if (gold)
				  {
				  gold = 0;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileForRow:(yblk - 1) column:xblk] == GROUND_TILE)
					[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] setAttachment:(unsigned char)GOLD_TILE_GRND forRow:(yblk - 1) column:xblk];
				  else
					[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] setAttachment:(unsigned char)GOLD_TILE_SKY forRow:(yblk - 1) column:xblk];
				  y = 0;
				  block_move[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] max_block_move]].active = YES;
				  block_move[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] max_block_move]].mode = 1;
				  block_move[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] max_block_move]].xblk = xblk;
				  block_move[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] max_block_move]].yblk = yblk - 1;
				  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileForRow:(yblk - 1) column:xblk] == SKY_TILE)
					{
					 block_move[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] max_block_move]].tile = GOLD_TILE_SKY;
					 [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] incrementMaxBlockMove];
					}
				  else if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileForRow:(yblk - 1) column:xblk] == GROUND_TILE)
					{
					 block_move[[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] max_block_move]].tile = GOLD_TILE_GRND;
					 [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] incrementMaxBlockMove];
					}
				  }
			   return (FALSE);
			   }
			else
			   {
			   time++;
			   return (FALSE);
			   }
			}
		 }
	  }
	if (mode && !clear_path && dir == UP && time == TIME_STUCK)
	  {
	  time = 0;
	  if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] < xpos)
		 dir = LEFT;
	  else if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] > xpos)
		 dir = RIGHT;
	  else if (xblk < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardWidth] / 2))
		 dir = RIGHT;
	  else
		 dir = LEFT;
	  for (x=0;x<MAX_OBJECTS;x++)
		 {
		 if (objs[x].active && objs[x].type == OBJECT_TYPE_HOLE && objs[x].xblk == xblk && objs[x].yblk == (yblk + 1))
			{
			for (Character *character in [(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] guards])
				{
			   if (character != self && [character xblk] == objs[x].xblk && [character yblk] == objs[x].yblk)
				  return (clear_path);
				}
			objs[x].state = 7;
			objs[x].time = DISINTEGRATION_RATE;
			}
		 }
	  }
	if (mode && !clear_path && direction == DOWN)
	  {
	  fall = 0;
	  if (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:xblk] & TILE_DUG))
		{
		BOOL leftBoundary = NO;
		BOOL rightBoundary = NO;
		BOOL lowerBoundary = NO;
		if (xblk > 0)
			{
			if (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk - 1)] & TILE_BRICK) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk - 1)] & TILE_STONE))
				leftBoundary = YES;
			}
		else
			leftBoundary = YES;
		if (yblk < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardHeight] - 1))
			{
			if (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_BRICK) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_STONE))
				lowerBoundary = YES;
			}
		else
			lowerBoundary = YES;
		if (xblk < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardWidth] - 1))
			{
			if (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk + 1)] & TILE_BRICK) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk + 1)] & TILE_STONE))
				rightBoundary = YES;
			}
		else
			rightBoundary = YES;
		if (leftBoundary && lowerBoundary && rightBoundary)
			{
			dir = UP;
			time = TIME_STUCK;
			}
		}
	  }
	return (clear_path);   
}

/* From: Classic Gold Runner Source File 2 - Guard Chase Patterns */
- (void)Chase_Pattern
{

	short blk_x, blk_y;
	short blk_x_off, blk_y_off, situation;
	short up, down, left, right, edge;
	short runr_up, runr_dn, runr_lt, runr_rt;
	int rnd_num;

	rnd_num = random() % MOD_RND_BY;
	runr_up = FALSE;
	runr_dn = FALSE;
	runr_lt = FALSE;
	runr_rt = FALSE;
	edge = 0;
	situation = 0;
	blk_x_off = xpos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth];
	blk_y_off = ypos % [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight];
	if (!blk_x_off && !blk_y_off && !time)
		{
		up = [self Check_Path:0 inDirection:UP];
		down = [self Check_Path:0 inDirection:DOWN];
		left = [self Check_Path:0 inDirection:LEFT];
		right = [self Check_Path:0 inDirection:RIGHT];
		if ((dir == DOWN && !down) || (dir == LEFT && xpos == 0) || (dir == RIGHT && (xpos + [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth]) == ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardWidth] * [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth])) || (dir == UP && ypos == 0)
			|| (dir == UP && !up && !left && !right) || (dir == DOWN && !down && !left && !right)
			|| (dir == LEFT && !left && !up && !down) || (dir == RIGHT && !right && !up && !down))
			edge = TRUE;
		blk_x = xpos / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth];
		blk_y = ypos / [[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight];
		if (edge || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:blk_x] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:blk_x] & TILE_LADDER) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:blk_x] & TILE_ROPE))
			{
			if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] ypos] < ypos)
			   runr_up = 1;
			else if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] ypos] > ypos)
			   runr_dn = 1;
			if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] < xpos)
			   runr_lt = 1;
			else if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] runner] xpos] > xpos)
			   runr_rt = 1;
			if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:blk_x] & TILE_LADDER)
			   situation = 1;
			else if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:blk_x] & TILE_LADDER)
			   situation = 2;
			else if ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:blk_x] & TILE_ROPE)
			   situation = 3;
			else if (edge)
			   situation = 4;
			switch (situation)
			   {
			   case 1:
				  switch (rnd_num)
					 {
					 case 0:
					 case 1:
					 case 3:
					 case 4:
					 case 5:
					 case 7:
					 case 8:
						if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (up)
									dir = UP;
								 else if (left && runr_lt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && runr_rt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (!down && up && (!left || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_AIR)) && (!right || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_AIR)))
									dir = UP;
								 else if (left && runr_lt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && runr_rt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (up)
									dir = UP;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (up)
									dir = UP;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && runr_lt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) && !up)))
									dir = LEFT;
								 else if (right && runr_rt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER)&&!up)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) && !up)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) && !up)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (!down && up && (!left || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_AIR) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk - 1)] & TILE_ROPE))) && (!right || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_AIR) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:yblk column:(xblk + 1)] & TILE_ROPE))))
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else if (left && runr_lt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && runr_rt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) && !up)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) && !up)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (!down && up && (!left || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_AIR)) && (!right || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_AIR)))
									dir = UP;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (runr_lt && left && xblk == ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] boardWidth] - 1))
									dir = LEFT;
								 else if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) && !up)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) || (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) && !up)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (!down && up && (!left || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_AIR)) && (!right || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_AIR)))
									dir = UP;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (runr_rt && right && xblk == 0)
									dir = RIGHT;
								 else if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 case 2:
					 case 6:
						if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right && runr_rt && ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) && !up) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && runr_lt && ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) && !up) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) && !up) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && ((([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) && !up) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)) && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)) && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (left && runr_lt && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up & runr_rt)
									dir = UP;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right && runr_rt && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up && runr_lt)
									dir = UP;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (up)
									dir = UP;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)) && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left&&(blk_x<([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth]>>1))&&(([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH)||([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)||([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (right && runr_rt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && runr_lt && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (DOWN)
									dir = DOWN;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (left && runr_lt && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (down & runr_rt)
									dir = DOWN;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right && runr_rt && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down && runr_lt)
									dir = DOWN;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (up)
									dir = UP;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (up)
									dir = UP;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) && !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (up && (blk_y < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = UP;
								 else if (down && (blk_y > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileHeight] >> 1)))
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 case 9:
						if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up && runr_up)
									dir = UP;
								 else if (down && runr_dn)
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (up && runr_up)
									dir = UP;
								 else if (down && runr_dn)
									dir = DOWN;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (up && runr_up)
									dir = UP;
								 else if (down && runr_dn)
									dir = DOWN;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up && runr_up)
									dir = UP;
								 else if (down && runr_dn)
									dir = DOWN;
								 else if (up)
									dir = UP;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (up)
									dir = UP;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (up)
									dir = UP;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (up)
									dir = UP;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (up)
									dir = UP;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (right && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (left && (([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_LADDER) || !([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else
									dir = UP;
								 break;
							  case LEFT:
								 if (up)
									dir = UP;
								 else if (left && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x - 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x - 1)] & TILE_ROPE)))
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (up)
									dir = UP;
								 else if (right && (!([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(blk_y + 1) column:(blk_x + 1)] & TILE_FALLTHROUGH) || ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:blk_y column:(blk_x + 1)] & TILE_ROPE)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 default:
						break;
					 }
				  break;
			   case 2:
				  switch (rnd_num)
					 {
					 case 0:
					 case 1:
					 case 3:
					 case 4:
					 case 5:
					 case 7:
					 case 8:
						if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right)
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 case 2:
					 case 6:
						if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 case 9:
						if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right)
									dir = RIGHT;
								 else
									 dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right)
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 default:
						break;
					 }
				  break;
			   case 3:
				  switch (rnd_num)
					 {
					 case 0:
					 case 1:
					 case 3:
					 case 4:
					 case 5:
					 case 7:
					 case 8:
						if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case LEFT:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (down && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_FALLTHROUGH))
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right && runr_rt)
									dir = RIGHT;
								 else if (down && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_FALLTHROUGH))
									dir = DOWN;
								 else if (right)
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 case 2:
					 case 6:
						if (runr_up)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									 dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_dn)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left && runr_lt)
									dir = LEFT;
								 else if (right && runr_rt)
									dir = RIGHT;
								 else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = LEFT;
								 else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case LEFT:
								 if (left)
									dir = LEFT;
								 else if (down)
									dir = DOWN;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (right)
									dir = RIGHT;
								 else if (down)
									dir = DOWN;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_lt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (right)
									dir = RIGHT;
								 else if (left)
									dir = LEFT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right)
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						else if (runr_rt)
						   {
						   switch (dir)
							  {
							  case UP:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case DOWN:
								 if (left)
									dir = LEFT;
								 else if (right)
									dir = RIGHT;
								 else
									dir = DOWN;
								 break;
							  case LEFT:
								 if (down)
									dir = DOWN;
								 else if (left)
									dir = LEFT;
								 else
									dir = RIGHT;
								 break;
							  case RIGHT:
								 if (down)
									dir = DOWN;
								 else if (right)
									dir = RIGHT;
								 else
									dir = LEFT;
								 break;
							  default:
								 break;
							  }
						   }
						break;
					 case 9:
						if (down && ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] characteristicForRow:(yblk + 1) column:xblk] & TILE_FALLTHROUGH))
						   dir = DOWN;
						else if (right && dir == RIGHT)
						   dir = RIGHT;
						else if (left && dir == LEFT)
						   dir = LEFT;
						else if (right)
						   dir = RIGHT;
						else
						   dir = LEFT;
						break;
					 default:
						break;
					 }
				  break;
			   case 4:
				  switch (rnd_num)
					 {
					 case 0:
					 case 1:
					 case 3:
					 case 4:
					 case 5:
					 case 7:
					 case 8:
						if (left && runr_lt)
						   dir = LEFT;
						else if (right && runr_rt)
						   dir = RIGHT;
						else if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
						   dir = LEFT;
						else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
						   dir = RIGHT;
						else if (left)
						  dir = LEFT;
						else if (right)
						   dir = RIGHT;
						else if (up)
						   dir = UP;
						else if (down)
						   dir = DOWN;
						break;
					 case 2:
					 case 6:
						if (left && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
						   dir = LEFT;
						else if (right && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
						   dir = RIGHT;
						else if (right)
						  dir = RIGHT;
						else if (left)
						   dir = LEFT;
						else if (up)
						   dir = UP;
						else if (down)
						   dir = DOWN;
						break;
					 case 9:
						if (left && runr_rt)
						   dir = LEFT;
						else if (right && runr_lt)
							dir = RIGHT;
						else if (right && (blk_x < ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
						   dir = RIGHT;
						else if (left && (blk_x > ([[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] currentBoard] tileWidth] >> 1)))
						   dir = LEFT;
						else if (right)
						   dir = RIGHT;
						else if (left)
						   dir = LEFT;
						else if (up)
						   dir = UP;
						else if (down)
						   dir = DOWN;
						break;
					 default:
						break;
					 }
				  break;
			   default:
				  break;
				}
			}
		}
	return;
}

- (short)xpos
{
	return xpos;
}

- (short)ypos
{
	return ypos;
}

- (short)time
{
	return time;
}

- (short)sprite
{
	return sprite;
}

- (short)xblk
{
	return xblk;
}

- (short)yblk
{
	return yblk;
}

- (short)last_x_dir
{
	return last_x_dir;
}

- (short)last_y_dir
{
	return last_y_dir;
}

- (short)dir
{
	return dir;
}

- (short)gold
{
	return gold;
}

- (void)setXPos:(short)newPos
{
	xpos = newPos;
}

- (void)setYPos:(short)newPos
{
	ypos = newPos;
}

- (void)setXBlk:(short)newPos
{
	xblk = newPos;
}

- (void)setYBlk:(short)newPos
{
	yblk = newPos;
}

- (void)setSprite:(short)newSprite;
{
	sprite = newSprite;
}

- (void)setTime:(short)newTime
{
	time = newTime;
}

- (void)setFall:(short)newFall
{
	fall = newFall;
}

- (void)setMove:(BOOL)newMove
{
	move = newMove;
}

- (void)setDir:(short)newDir
{
	dir = newDir;
}

- (void)setAsRunner
{
	runner = YES;
}

- (void)incrementGold
{
	gold++;
}

- (void)decrementGold
{
	gold = 0;
}

@end
