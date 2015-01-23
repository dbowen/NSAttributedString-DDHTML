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

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    UIFont *defaultFont = [UIFont systemFontOfSize:12.0];
    UIFontDescriptor *defaultFontDescriptor = [defaultFont.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
    UIFont *defaultFontItalic = [UIFont fontWithDescriptor:defaultFontDescriptor size:0];
    
    NSAttributedString *attrString = [NSAttributedString attributedStringFromHTML:@"<font face=\"Avenir-Heavy\" color=\"#FF0000\">This</font> <shadow>is</shadow> <b>Happy bold, <u>underlined</u>, <stroke width=\"2.0\" color=\"#00FF00\">awesomeness </stroke><a href=\"https://www.google.com\">link</a>!</b> <br/> <i>And some italic on the next line.</i>" boldFont:[UIFont boldSystemFontOfSize:12] italicFont:defaultFontItalic];
    self.label.attributedText = attrString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
