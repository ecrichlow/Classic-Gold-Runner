/*******************************************************************************
* FlickView.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for the custom
*						view used to catch gestures
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	01/29/09		*	EGC	*	File creation date
*******************************************************************************/

#import "FlickView.h"
#import "Classic_Gold_RunnerAppDelegate.h"

@implementation FlickView

#pragma mark - View Lifecycle

- (id)initWithFrame:(CGRect)frame
{
	
    if (self = [super initWithFrame:frame])
		{
        // Initialization code
		self.alpha = 1.0;
		self.backgroundColor = [UIColor clearColor];
		}
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Business Logic

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchStartPosition = [[touches anyObject] locationInView:self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent*)event
{

	UITouch				*touch = [touches anyObject];
 
	if	([touch tapCount] == 2)
		{
		// Process a double-tap gesture
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:YES];
		}
	else if ([touch tapCount] == 1)
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:STOP];
		}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

	UITouch *touch = [touches anyObject];
	CGPoint touchEndPosition = [touch locationInView:self];
 
	// Got a valid flick on one axis or the other
	if (fabsf(touchStartPosition.x - touchEndPosition.x) > TOUCH_DRAG_OFFSET || fabsf(touchStartPosition.y - touchEndPosition.y) > TOUCH_DRAG_OFFSET)
		{
		// Y Axis drags take precedence
		if (fabsf(touchStartPosition.y - touchEndPosition.y) > TOUCH_DRAG_OFFSET && fabsf(touchStartPosition.y - touchEndPosition.y) > fabsf(touchStartPosition.x - touchEndPosition.x))
			{
			if (touchStartPosition.y > touchEndPosition.y)
				{
				[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:UP];
				}
			else
				{
				[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:DOWN];
				}
			}
		else if (fabsf(touchStartPosition.x - touchEndPosition.x) > TOUCH_DRAG_OFFSET && fabsf(touchStartPosition.x - touchEndPosition.x) > fabsf(touchStartPosition.y - touchEndPosition.y))
			{
			if (touchStartPosition.x > touchEndPosition.x)
				{
				[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:LEFT];
				}
			else
				{
				[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:RIGHT];
				}
			}
		}
}

@end
