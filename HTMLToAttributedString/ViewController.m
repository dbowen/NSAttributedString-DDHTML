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
    
    
    NSAttributedString *attrString = [NSAttributedString attributedStringFromHTML:@"<h1>Heading1</h1><br/><h3>Heading2</h3><br/><h5>Heading3</h5><br/><sup>superscript</sup>normal<sub>subscript</sub><br/><font face=\"Avenir-Heavy\" color=\"#FF0000\">This</font> <shadow>is</shadow> <b>Happy bold, <u>underlined</u>, <stroke width=\"2.0\" color=\"#00FF00\">awesomeness </stroke><a href=\"https://www.google.com\">link</a>!</b> <br/> <i>And some italic on the next line.</i><img src=\"car.png\" width=\"50\" height=\"50\" /> <br/> <br/> <samp>printf(\"Hello World!\")</samp><br/>"
                                                                       normalFont:[UIFont systemFontOfSize:12.0]
                                                                         boldFont:[UIFont boldSystemFontOfSize:12.0]
                                                                       italicFont:[UIFont italicSystemFontOfSize:12.0]
                                      ];
    self.label.attributedText = attrString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
