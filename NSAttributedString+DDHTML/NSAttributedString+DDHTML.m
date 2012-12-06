//
//  NSAttributedString+HTML.m
//  HTMLToAttributedString
//
//  Created by Derek Bowen on 12/5/12.
//  Copyright (c) 2012 Deloitte Digital. All rights reserved.
//

#import "NSAttributedString+DDHTML.h"
#include <libxml/HTMLparser.h>

@implementation NSAttributedString (DDHTML)

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString boldFont:(UIFont *)boldFont
{
    xmlDoc *document = htmlReadMemory([htmlString cStringUsingEncoding:NSUTF8StringEncoding], htmlString.length, nil, NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    
    if (document == NULL)
        return nil;
    
    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] init];
    
    xmlNodePtr currentNode = document->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode boldFont:boldFont];
        [finalAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    return finalAttributedString;
}

+ (NSAttributedString *)attributedStringFromNode:(xmlNodePtr)xmlNode boldFont:(UIFont *)boldFont
{
    NSMutableAttributedString *nodeAttributedString = [[NSMutableAttributedString alloc] init];
    
    if ((xmlNode->type != XML_ENTITY_REF_NODE) && ((xmlNode->type != XML_ELEMENT_NODE) && xmlNode->content != NULL)) {
        [nodeAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithCString:(const char *)xmlNode->content encoding:NSUTF8StringEncoding]]];
    }
    
    // Handle children
    xmlNodePtr currentNode = xmlNode->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode boldFont:boldFont];
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
                NSString *attributeName = [NSString stringWithCString:(const char*)attribute->name encoding:NSUTF8StringEncoding];
                [attributeDictionary setObject:attributeValue forKey:attributeName];
                
                attribute = attribute->next;
            }
        }
        
        // Bold Tag
        if (strncmp("b", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString addAttribute:NSFontAttributeName value:boldFont range:nodeAttributedStringRange];
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
            
            if ([attributeDictionary objectForKey:@"color"]) {
                strokeColor = [self colorFromHexString:[attributeDictionary objectForKey:@"color"]];
            }
            if ([attributeDictionary objectForKey:@"width"]) {
                strokeWidth = @(fabs([[attributeDictionary objectForKey:@"width"] doubleValue]));
            }
            if (![attributeDictionary objectForKey:@"nofill"]) {
                strokeWidth = @(-fabs([strokeWidth doubleValue]));
            }
            
            [nodeAttributedString addAttribute:NSStrokeColorAttributeName value:strokeColor range:nodeAttributedStringRange];
            [nodeAttributedString addAttribute:NSStrokeWidthAttributeName value:strokeWidth range:nodeAttributedStringRange];
        }
        
        // Shadow Tag
        else if (strncmp("shadow", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowOffset = CGSizeMake(0, 0);
            shadow.shadowBlurRadius = 2.0;
            shadow.shadowColor = [UIColor purpleColor];
            
            if ([attributeDictionary objectForKey:@"offset"]) {
                shadow.shadowOffset = CGSizeFromString([attributeDictionary objectForKey:@"offset"]);
            }
            if ([attributeDictionary objectForKey:@"blurRadius"]) {
                shadow.shadowBlurRadius = [[attributeDictionary objectForKey:@"blurRadius"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"color"]) {
                shadow.shadowColor = [self colorFromHexString:[attributeDictionary objectForKey:@"color"]];
            }
            
            [nodeAttributedString addAttribute:NSShadowAttributeName value:shadow range:nodeAttributedStringRange];
        }
        
        // Font Tag
        else if (strncmp("font", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            NSString *fontName = nil;
            NSNumber *fontSize = nil;
            UIColor *foregroundColor = nil;
            UIColor *backgroundColor = nil;
            
            if ([attributeDictionary objectForKey:@"face"]) {
                fontName = [attributeDictionary objectForKey:@"face"];
            }
            if ([attributeDictionary objectForKey:@"size"]) {
                fontSize = @([[attributeDictionary objectForKey:@"size"] doubleValue]);
            }
            if ([attributeDictionary objectForKey:@"color"]) {
                foregroundColor = [self colorFromHexString:[attributeDictionary objectForKey:@"color"]];
            }
            if ([attributeDictionary objectForKey:@"backgroundColor"]) {
                backgroundColor = [self colorFromHexString:[attributeDictionary objectForKey:@"backgroundColor"]];
            }
    
            if (fontName == nil && fontSize != nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[fontSize doubleValue]] range:nodeAttributedStringRange];
            }
            else if (fontName != nil && fontSize == nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:12.0] range:nodeAttributedStringRange];
            }
            else if (fontName != nil && fontSize != nil) {
                [nodeAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:[fontSize doubleValue]] range:nodeAttributedStringRange];
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
                NSString *alignString = [attributeDictionary objectForKey:@"align"];
                
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
            if ([attributeDictionary objectForKey:@"lineBreakMode"]) {
                NSString *lineBreakModeString = [attributeDictionary objectForKey:@"lineBreakMode"];
                
                if ([lineBreakModeString isEqualToString:@"WordWrapping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                }
                else if ([lineBreakModeString isEqualToString:@"CharWrapping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
                }
                else if ([lineBreakModeString isEqualToString:@"Clipping"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
                }
                else if ([lineBreakModeString isEqualToString:@"TruncatingHead"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
                }
                else if ([lineBreakModeString isEqualToString:@"TruncatingTail"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                }
                else if ([lineBreakModeString isEqualToString:@"TruncatingMiddle"]) {
                    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
                }
            }
            
            if ([attributeDictionary objectForKey:@"firstLineHeadIndent"]) {
                paragraphStyle.firstLineHeadIndent = [[attributeDictionary objectForKey:@"firstLineHeadIndent"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"headIndent"]) {
                paragraphStyle.headIndent = [[attributeDictionary objectForKey:@"headIndent"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"hyphenationFactor"]) {
                paragraphStyle.hyphenationFactor = [[attributeDictionary objectForKey:@"hyphenationFactor"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"lineHeightMultiple"]) {
                paragraphStyle.lineHeightMultiple = [[attributeDictionary objectForKey:@"lineHeightMultiple"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"lineSpacing"]) {
                paragraphStyle.lineSpacing = [[attributeDictionary objectForKey:@"lineSpacing"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"maximumLineHeight"]) {
                paragraphStyle.maximumLineHeight = [[attributeDictionary objectForKey:@"maximumLineHeight"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"minimumLineHeight"]) {
                paragraphStyle.minimumLineHeight = [[attributeDictionary objectForKey:@"minimumLineHeight"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"paragraphSpacing"]) {
                paragraphStyle.paragraphSpacing = [[attributeDictionary objectForKey:@"paragraphSpacing"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"paragraphSpacingBefore"]) {
                paragraphStyle.paragraphSpacingBefore = [[attributeDictionary objectForKey:@"paragraphSpacingBefore"] doubleValue];
            }
            if ([attributeDictionary objectForKey:@"tailIndent"]) {
                paragraphStyle.tailIndent = [[attributeDictionary objectForKey:@"tailIndent"] doubleValue];
            }
            
            [nodeAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:nodeAttributedStringRange];
        }
    }
    
    return nodeAttributedString;
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
