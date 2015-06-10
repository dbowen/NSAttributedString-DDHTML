NSAttributedString+DDHTML
=========================

Simplifies working with attributed strings by allowing you to use HTML to describe formatting behaviors.

NSAttributedString+DDHTML isn't intended to support full HTML rendering.  Instead it provides a quick, effient and light-weight implementation for leveraging attributed strings when utilizing native UIKit interface elements.

## License
-----

It is open source and covered by a standard BSD license. That means you have to mention *Derek Bowen @ Deloite Digital* as the original author of this code.

## Requirements
-----
NSAttributedString+DDHTML requires a minimum iOS deployment target of iOS 4.3 becuse of:

* ARC

## Setup
-----

### Using CocoaPods

One of the easiest ways to integrate NSAttributedString+DDHTML in your project is to use [CocoaPods](http://cocoapods.org/):

1. Add the following line to your `Podfile`:

    ````ruby
    pod "NSAttributedString-DDHTML"
    ````

2. In your project directory, run `pod update`
3. You should now be able to add `#import <NSAttributedString-DDHTML/NSAttributedString+DDHTML.h>` to any of your target's source files to use the library!

### Manual

1. Add NSAttributedString+DDHTML.m/h to your project.
2. Add *libxml2.dylib* to the *"Link Binary With Libraries"* section of your target's build phase.
3. Add *${SDKROOT}/usr/include/libxml2* to your project's *Header Search Paths* under *Build Settings*.
4. Start using it!

## Usage
-----
	#import "NSAttributedString+DDHTML.h"
	
	...
	
	NSAttributedString *attributedString = [NSAttributedString attributedStringFromHTML:@"My <b>formatted</b> string."];
	
	...
	
	
## Supported Tags
-----

### b, strong - Bold

### i - Italics

### u - Underline

### strike - Strikethrough

### stroke - Stroke
* **color**: Color of stroke, e.g. stroke="#ff0000"
* **width**: Width of stroke, e.g. stroke="2.0"
* **nofill**: If present text color will be transparent

### shadow - Shadow
* **offset**: Amount to offset shadow from center of text, e.g. offset="{1.0, 1.0}"
* **blurRadius**: Radius/thickness of the shadow
* **color**: Color of the shadow

### font - Font
* **face**: Name of font to use, e.g. face="Avenir-Heavy"
* **size**: Size of the text, e.g. size="12.0"
* **color**: Color of the text, e.g. color="#fafafa"
* **backgroundColor**: Color of the text background, e.g. backgroundColor="#333333"

### br - Line Break

### p - Paragraph
* **align**: Alignment of text, e.g. align="center"
  * Available values: left, center, right, justify
* **lineBreakMode**: How to handle text which doesn't fit horizontally in the view
  * Available values: WordWrapping, CharWrapping, Clipping, TruncatingHead, TruncatingTail, TruncatingMiddle
* **firstLineHeadIndent**
* **headIndent**
* **hyphenationFactor**
* **lineHeightMultiple**
* **lineSpacing**
* **maximumLineHeight**
* **minimumLineHeight**
* **paragraphSpacing**
* **paragraphSpacingBefore**
* **tailIndent**
