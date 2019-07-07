//
//  ViewController.m
//  HTMLToAttributedString
//
//  Created by Derek Bowen (Work) on 12/5/12.
//  Copyright (c) 2012 Deloitte Digital. All rights reserved.
//

#import "ViewController.h"
#import "NSAttributedString+DDHTML.h"

@interface ViewController ()

@property(weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAttributedString *attrString =
            [NSAttributedString
                    attributedStringFromHTML:NSLocalizedString(@"SampleHtml", @"Sample HTML code")
                                  normalFont:[UIFont systemFontOfSize:12]
                                    boldFont:[UIFont boldSystemFontOfSize:12]
                                  italicFont:[UIFont italicSystemFontOfSize:12.0]];

    self.label.attributedText = attrString;
}

@end
