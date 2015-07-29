//
//  Tools.h

//
//  Created by jlagunas on 04/03/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+(void) versionedScaleFactor: (UILabel *) label factor: (CGFloat) factor size: (CGFloat) size;
+(void) versionedTextAlignment: (UILabel *) label alignment:(int) alignment;
/*+(void) TextViewVersionedTextAlignment: (UITextView *) textV alignment:(int) alignment;
+(UIInterfaceOrientation) deviceInterfaceOrientation: (UIDeviceOrientation) orientation;
*/+(void) showSingleButtonAlert: (NSString *) title  message: (NSString *) message buttonText: (NSString *) button delegate: (NSObject *) parentVC;
+(NSString *) date2String: (NSDate*) date;

@end
