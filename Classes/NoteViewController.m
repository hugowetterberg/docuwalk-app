//
//  NoteViewController.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "NoteViewController.h"

@implementation NoteViewController

@synthesize note, background;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithWalk:(Walk *)aWalk {
    if (self = [super initWithNibName:@"NoteView" bundle:nil]) {
		walk = aWalk;
        self.title = @"Write a note";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNote)];
    }
    return self;
}

- (IBAction)saveNote {
	[walk saveNote:self.note.text];
	[self.navigationController popViewControllerAnimated:YES];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.background.image = [[UIImage imageNamed:@"magenta-box.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
	[self.note becomeFirstResponder];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
