// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "GenEditTextVC.h"
#import "AppDelegate.h"

@implementation GenEditTextViewController

@synthesize listener, identifier, text;

+ (GenEditTextViewController *)genEditTextViewController:(id<GenEditTextViewListener>)listener title:(NSString*)title identifier:(int)id
{
	GenEditTextViewController *vc = [[[GenEditTextViewController alloc]
										 initWithNibName:@"GenEditTextView"
										 bundle:[NSBundle mainBundle]] autorelease];
	vc.listener = listener;
	vc.title = title;
	vc.identifier = id;

	return vc;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	textField.placeholder = self.title;
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self
											   action:@selector(doneAction)] autorelease];
}

- (void)dealloc {
	[text release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	textField.text = text;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)doneAction
{
	self.text = textField.text;
	[listener genEditTextViewChanged:self identifier:identifier];

	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end