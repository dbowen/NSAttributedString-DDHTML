//
//  NSAttributedString+HTML.m
//
//  Created by Derek Bowen <dbowen@demiurgic.co>
//  Copyright (c) 2012-2015, Deloitte Digital
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//  * Neither the name of the <organization> nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSAttributedString+DDHTML.h"
#include <libxml/HTMLparser.h>

@implementation NSAttributedString (DDHTML)

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString
{
    UIFont *preferredBodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    return [self attributedStringFromHTML:htmlString
                               normalFont:preferredBodyFont
                                 boldFont:[UIFont boldSystemFontOfSize:preferredBodyFont.pointSize]
                               italicFont:[UIFont italicSystemFontOfSize:preferredBodyFont.pointSize]];
}

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString boldFont:(UIFont *)boldFont italicFont:(UIFont *)italicFont
{
    return [self attributedStringFromHTML:htmlString
                               normalFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                 boldFont:boldFont
                               italicFont:italicFont];
}
+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString normalFont:(UIFont *)normalFont boldFont:(UIFont *)boldFont italicFont:(UIFont *)italicFont
{
    return [self attributedStringFromHTML:htmlString
                               normalFont:normalFont
                                 boldFont:boldFont
                               italicFont:italicFont
                                 imageMap:@{}];
}

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString normalFont:(UIFont *)normalFont boldFont:(UIFont *)boldFont italicFont:(UIFont *)italicFont imageMap:(NSDictionary<NSString *, UIImage *> *)imageMap
{
    // Parse HTML string as XML document using UTF-8 encoding
    NSData *documentData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    xmlDoc *document = htmlReadMemory(documentData.bytes, (int)documentData.length, nil, "UTF-8", HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    
    if (document == NULL) {
        return [[NSAttributedString alloc] initWithString:htmlString attributes:nil];
    }
    
    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] init];
    
    xmlNodePtr currentNode = document->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode normalFont:normalFont boldFont:boldFont italicFont:italicFont imageMap:imageMap];
        [finalAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    xmlFreeDoc(document);
    
    return finalAttributedString;
}

+ (NSAttributedString *)attributedStringFromNode:(xmlNodePtr)xmlNode normalFont:(UIFont *)normalFont boldFont:(UIFont *)boldFont italicFont:(UIFont *)italicFont imageMap:(NSDictionary<NSString *, UIImage *> *)imageMap
{
    NSMutableAttributedString *nodeAttributedString = [[NSMutableAttributedString alloc] init];
    
    if ((xmlNode->type != XML_ENTITY_REF_NODE) && ((xmlNode->type != XML_ELEMENT_NODE) && xmlNode->content != NULL)) {
        NSAttributedString *normalAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithCString:(const char *)xmlNode->content encoding:NSUTF8StringEncoding] attributes:@{NSFontAttributeName : normalFont}];
        [nodeAttributedString appendAttributedString:normalAttributedString];
    }
    
    // Handle children
    xmlNodePtr currentNode = xmlNode->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode normalFont:normalFont boldFont:boldFont italicFont:italicFont imageMap:imageMap];
        [nodeAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    if (xmlNode->type == XML_ELEMENT_NODE) {
        
        NSRange nodeAttributedStringRange = NSMakeRange(0, nodeAttributedString.length);
        
        // Build dictionary to store attributes
        NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
        if (xmlNode->properties != NULL) {
            xmlAttrPtr attribute = xmlNode->properties;
            
            while (attribute != NULL) {
                NSString *attributeValue = @"";
                
                if (attribute->children != NULL) {
                    attributeValue = [NSString stringWithCString:(const char *)attribute->children->content encoding:NSUTF8StringEncoding];
                }
                NSString *attributeName = [[NSString stringWithCString:(const char*)attribute->name encoding:NSUTF8StringEncoding] lowercaseString];
                [attributeDictionary setObject:attributeValue forKey:attributeName];
                
                attribute = attribute->next;
            }
        }
        
        // Bold Tag
        if (strncmp("b", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0 ||
            strncmp("strong", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            if (boldFont) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:boldFont range:nodeAttributedStringRange];
            }
        }
        
        // Italic Tag
        else if (strncmp("i", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            if (italicFont) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:italicFont range:nodeAttributedStringRange];
            }
        }
        
        // Underline Tag
        else if (strncmp("u", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:nodeAttributedStringRange];
        }
        
        // Stike Tag
        else if (strncmp("strike", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString addAttribute:NSStrikethroughStyleAttributeName value:@(YES) range:nodeAttributedStringRange];
        }
        
        // Stoke Tag
        else if (strncmp("stroke", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            UIColor *strokeColor = [UIColor purpleColor];
            NSNumber *strokeWidth = @(1.0);
            
            if (attributeDictionary[@"color"]) {
                strokeColor = [self colorFromHexString:attributeDictionary[@"color"]];
            }
            if (attributeDictionary[@"width"]) {
                strokeWidth = @(fabs([attributeDictionary[@"width"] doubleValue]));
            }
            if (!attributeDictionary[@"nofill"]) {
                strokeWidth = @(-fabs([strokeWidth doubleValue]));
            }
            
            [nodeAttributedString addAttribute:NSStrokeColorAttributeName value:strokeColor range:nodeAttributedStringRange];
            [nodeAttributedString addAttribute:NSStrokeWidthAttributeName value:strokeWidth range:nodeAttributedStringRange];
        }
        
        // Shadow Tag
        else if (strncmp("shadow", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            #if __has_include(<UIKit/NSShadow.h>)
                NSShadow *shadow = [[NSShadow alloc] init];
                shadow.shadowOffset = CGSizeMake(0, 0);
                shadow.shadowBlurRadius = 2.0;
                shadow.shadowColor = [UIColor blackColor];
                
                if (attributeDictionary[@"offset"]) {
                    shadow.shadowOffset = CGSizeFromString(attributeDictionary[@"offset"]);
                }
                if (attributeDictionary[@"blurradius"]) {
                    shadow.shadowBlurRadius = [attributeDictionary[@"blurradius"] doubleValue];
                }
                if (attributeDictionary[@"color"]) {
                    shadow.shadowColor = [self colorFromHexString:attributeDictionary[@"color"]];
                }
            
                [nodeAttributedString addAttribute:NSShadowAttributeName value:shadow range:nodeAttributedStringRange];
            #endif
        }
        
        // Font Tag
        else if (strncmp("font", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSString *fontName = nil;
            NSNumber *fontSize = nil;
            UIColor *foregroundColor = nil;
            UIColor *backgroundColor = nil;
            
            if (attributeDictionary[@"face"]) {
                fontName = attributeDictionary[@"face"];
            }
            if (attributeDictionary[@"size"]) {
                fontSize = @([attributeDictionary[@"size"] doubleValue]);
            }
            if (attributeDictionary[@"color"]) {
                foregroundColor = [self colorFromHexString:attributeDictionary[@"color"]];
            }
            if (attributeDictionary[@"backgroundcolor"]) {
                backgroundColor = [self colorFromHexString:attributeDictionary[@"backgroundcolor"]];
            }
    
            if (fontName == nil && fontSize != nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[fontSize doubleValue]] range:nodeAttributedStringRange];
            }
            else if (fontName != nil && fontSize == nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[self fontOrSystemFontForName:fontName size:12.0] range:nodeAttributedStringRange];
            }
            else if (fontName != nil && fontSize != nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[self fontOrSystemFontForName:fontName size:fontSize.floatValue] range:nodeAttributedStringRange];
            }
    
            if (foregroundColor) {
                [nodeAttributedString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:nodeAttributedStringRange];
            }
            if (backgroundColor) {
                [nodeAttributedString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:nodeAttributedStringRange];
            }
        }
        
        // Paragraph Tag
        else if (strncmp("p", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            
            if ([attributeDictionary objectForKey:@"align"]) {
                NSString *alignString = [attributeDictionary[@"align"] lowercaseString];
                
                if ([alignString isEqualToString:@"left"]) {
                    paragraphStyle.alignment = NSTextAlignmentLeft;
                }
                else if ([alignString isEqualToString:@"center"]) {
                    paragraphStyle.alignment = NSTextAlignmentCenter;
                }
                else if ([alignString isEqualToString:@"right"]) {
                    paragraphStyle.alignment = NSTextAlignmentRight;
                }
                else if ([alignString isEqualToString:@"justify"]) {
                    paragraphStyle.alignment = NSTextAlignmentJustified;
                }
            }
            if ([attributeDictionary objectForKey:@"linebreakmode"]) {
                NSString *lineBreakModeString = [attributeDictionary[@"linebreakmode"] lowercaseString];
                
                if ([lineBreakModeString isEqualToString:@"wordwrapping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                }
                else if ([lineBreakModeString isEqualToString:@"charwrapping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
                }
                else if ([lineBreakModeString isEqualToString:@"clipping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
                }
                else if ([lineBreakModeString isEqualToString:@"truncatinghead"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
                }
                else if ([lineBreakModeString isEqualToString:@"truncatingtail"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                }
                else if ([lineBreakModeString isEqualToString:@"truncatingmiddle"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
                }
            }
            
            if ([attributeDictionary objectForKey:@"firstlineheadindent"]) {
                paragraphStyle.firstLineHeadIndent = [attributeDictionary[@"firstlineheadindent"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"headindent"]) {
                paragraphStyle.headIndent = [attributeDictionary[@"headindent"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"hyphenationfactor"]) {
                paragraphStyle.hyphenationFactor = [attributeDictionary[@"hyphenationfactor"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"lineheightmultiple"]) {
                paragraphStyle.lineHeightMultiple = [attributeDictionary[@"lineheightmultiple"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"linespacing"]) {
                paragraphStyle.lineSpacing = [attributeDictionary[@"linespacing"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"maximumlineheight"]) {
                paragraphStyle.maximumLineHeight = [attributeDictionary[@"maximumlineheight"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"minimumlineheight"]) {
                paragraphStyle.minimumLineHeight = [attributeDictionary[@"minimumlineheight"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"paragraphspacing"]) {
                paragraphStyle.paragraphSpacing = [attributeDictionary[@"paragraphspacing"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"paragraphspacingbefore"]) {
                paragraphStyle.paragraphSpacingBefore = [attributeDictionary[@"paragraphspacingbefore"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"tailindent"]) {
                paragraphStyle.tailIndent = [attributeDictionary[@"tailindent"] doubleValue];
            }
            
            [nodeAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:nodeAttributedStringRange];
        }
        
        // Links
        else if (strncmp("a href", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            
            xmlChar *value = xmlNodeListGetString(xmlNode->doc, xmlNode->xmlChildrenNode, 1);
            if (value)
            {
                NSString *title = [NSString stringWithCString:(const char *)value encoding:NSUTF8StringEncoding];
                NSString *link = attributeDictionary[@"href"];
                [nodeAttributedString addAttribute:NSLinkAttributeName value:link range:NSMakeRange(0, title.length)];
            }
        }
        
        // New Lines
        else if (strncmp("br", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        
        // Images
        else if (strncmp("img", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            #if __has_include(<UIKit/NSTextAttachment.h>)
                NSString *src = attributeDictionary[@"src"];
                NSString *width = attributeDictionary[@"width"];
                NSString *height = attributeDictionary[@"height"];
        
                if (src != nil) {
                    UIImage *image = imageMap[src];
                    if (image == nil) {
                        image = [UIImage imageNamed:src];
                    }
                    
                    if (image != nil) {
                        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
                        imageAttachment.image = image;
                        if (width != nil && height != nil) {
                            imageAttachment.bounds = CGRectMake(0, 0, [width integerValue] / 2, [height integerValue] / 2);
                        }
                        NSAttributedString *imageAttributeString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                        [nodeAttributedString appendAttributedString:imageAttributeString];
                    }
                }
            #endif
        }
    }
    
    return nodeAttributedString;
}

+ (UIFont *)fontOrSystemFontForName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont * font = [UIFont fontWithName:fontName size:fontSize];
    if(font) {
        return font;
    }
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    if (hexString == nil)
        return nil;
    
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    char *p;
    NSUInteger hexValue = strtoul([hexString cStringUsingEncoding:NSUTF8StringEncoding], &p, 16);

    return [UIColor colorWithRed:((hexValue & 0xff0000) >> 16) / 255.0 green:((hexValue & 0xff00) >> 8) / 255.0 blue:(hexValue & 0xff) / 255.0 alpha:1.0];
}

@end
