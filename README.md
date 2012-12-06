NSAttributedString+DDHTML
=========================

Simplifies working with NSAttributedString by allowing you to use HTML to describe formatting behaviors.


## License
---

It is open source and covered by a standard BSD license. That means you have to mention *Derek Bowen @ Deloite Digital* as the original author of this code.

## Requirements
---
NSAttributedString+DDHTML requires a minimum iOS deployment target of iOS 4.3 becuse of:

* ARC

## Setup
---

1. Add NSAttributedString+DDHTML.m/h to your project.
2. Add *libxml2.dylib* to the *"Link Binary With Libraries"* section of your target's build phase.
3. Add *${SDKROOT}/usr/include/libxml2* to your project's *Header Search Paths* under *Build Settings*.
4. Start using it!

## Usage
---
	#import "NSAttributedString+DDHTML.h"
	
	...
	
	NSAttibutedString *attributedString = [NSAttributedString attributedStringFromHTML:@"My <b>formatted</b> string." boldFont:[UIFont boldSystemFontOfSize:12.0]];
	
	...
	
	