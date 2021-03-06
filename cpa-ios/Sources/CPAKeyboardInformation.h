//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CPANullability.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class makes keyboard properties accessible at any time in a convenient way. Just access the +keyboardInformation 
 * method. If the returned object is not nil, then the keyboard is docked and visible (or soon will) and you can check its 
 * properties. The object is nil if the keyboard is floating (iPad) or invisible.
 *
 * You should avoid accessing CPAKeyboardInformation from within keyboard notification callbacks (since keyboard notifications
 * are used to fill CPAKeyboardInformation, the information might be unreliable depending on the order in which notifications
 * callbacks are called)
 *
 * Not meant to be instantiated directly. Simply use the +keyboardInformation class method.
 */
@interface CPAKeyboardInformation : NSObject

/**
 * Return the keyboard information if docked and displayed (or about to be displayed), nil if the keyboard is not visible,
 * about to be hidden, or floating
 *
 * Remark: On iOS 8 and 8.1, the undocked keyboard has serious bugs. When dragging the keyboard, docking / undocking
 *         is not correctly detected. As a result, the +keyboardInformation method might return a value which does
 *         not match the keyboard visual status (but is consistent with the buggy keyboard status maintained by the
 *         system)
 */
+ (nullable instancetype)keyboardInformation;

/**
 * Start frame of the keyboard before it is displayed (in the window coordinate system). Refer to the 
 * UIKeyboardFrameBeginUserInfoKey documentation for how to translate this frame into a meaningful coordinate system
 */
@property (nonatomic, readonly) CGRect beginFrame;

/**
 * Start frame of the keyboard after it is displayed (in the window coordinate system). This is the most interesting 
 * keyboard property since it lets you find which screen area the keyboard covers when displayed. Refer to the 
 * UIKeyboardFrameEndUserInfoKey documentation for how to translate this frame into a meaningful coordinate system
 */
@property (nonatomic, readonly) CGRect endFrame;

/**
 * Duration of the animation showing the keyboard
 */
@property (nonatomic, readonly) NSTimeInterval animationDuration;

/**
 * Curve of the animation showing the keyboard
 */
@property (nonatomic, readonly) UIViewAnimationCurve animationCurve;

@end

@interface CPAKeyboardInformation (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
