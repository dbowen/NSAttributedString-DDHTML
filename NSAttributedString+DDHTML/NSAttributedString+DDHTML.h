//
//  NSAttributedString+HTML.h
//  HTMLToAttributedString
//
//  Created by Derek Bowen on 12/5/12.
//  Copyright (c) 2012 Deloitte Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (DDHTML)

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString boldFont:(UIFont *)boldFont;

@end
