/*******************************************************************************
* FlickView.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for the custom
*						view used to catch gestures
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	01/29/09		*	EGC	*	File creation date
*******************************************************************************/

#import <UIKit/UIKit.h>

#define TOUCH_DRAG_OFFSET_PHONE_X_AXIS				4		// Number of points a touch has to move before we consider it a flick
#define TOUCH_DRAG_OFFSET_PHONE_Y_AXIS				6		// Number of points a touch has to move before we consider it a flick

@interface FlickView : UIView
{
	CGPoint									touchStartPosition;			// Position at the beginning of a touch event
}

@end
