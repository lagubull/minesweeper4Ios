//
//  Tools.m
//
//  Created by admin on 04/03/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "Tools.h"

@implementation Tools


+(void) versionedScaleFactor: (UILabel *) label factor: (CGFloat) factor size: (CGFloat) size
{
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 6)
    {
       [label setMinimumFontSize: size];
       [label setAdjustsFontSizeToFitWidth:YES];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
       //[label setFont: [UIFont systemFontOfSize:size]];
        
    }else
    {
        [label setMinimumScaleFactor: factor];
    }
}

+(void) versionedTextAlignment: (UILabel *) label alignment:(int) alignment
{
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 6)
    {
        switch (alignment)
        {
            case NSTextAlignmentCenter:
                [label setTextAlignment: UITextAlignmentCenter];
                break;
            case NSTextAlignmentJustified:
            case NSTextAlignmentLeft:
            case NSTextAlignmentNatural:
                [label setTextAlignment: UITextAlignmentLeft];
                break;
            case NSTextAlignmentRight:
                [label setTextAlignment: UITextAlignmentRight];
                break;
        }
        
    }
    else
    {
        [label setTextAlignment: alignment];
    }
}



+(void) showSingleButtonAlert: (NSString *) title  message: (NSString *) message buttonText: (NSString *) button delegate: (NSObject *) parentVC
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: message delegate:parentVC cancelButtonTitle: button otherButtonTitles: nil ];
    
    [alert show];
}

+(NSString *) date2String: (NSDate*) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yy HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

@end
