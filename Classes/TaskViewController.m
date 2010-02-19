//
//  TaskViewController.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "TaskViewController.h"
#import "RESTClient.h"
#import "Walk.h"
#import "WalkViewController.h"

@interface TaskViewController (Private)

- (void)updateNavItem;

@end


@implementation TaskViewController

@synthesize author, description, descriptionScroll, background;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithTask:(NSDictionary *)aTask {
    if (self = [super initWithNibName:@"TaskView" bundle:nil]) {
        task = [aTask retain];
		self.title = [task objectForKey:@"title"];
		
		[self updateNavItem];
    }
    return self;
}

- (void)updateNavItem {
	Walk *current = [Walk currentWalk];
	if (current) {
		if ([[task objectForKey:@"nid"] isEqual:[current.task objectForKey:@"nid"]]) {
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Continue" 
																					   style:UIBarButtonItemStyleDone 
																					  target:self 
																					  action:@selector(startWalk)] autorelease];
		}
		else {
			self.navigationItem.rightBarButtonItem = nil;
		}

	}
	else {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Start" 
																				   style:UIBarButtonItemStyleDone 
																				  target:self 
																				  action:@selector(startWalk)] autorelease];
	}
}
				 
- (void)startWalk {
	WalkViewController *wc = [[[WalkViewController alloc] initWithTask:task] autorelease];
	[self.navigationController pushViewController:wc animated:YES];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(void) viewWillAppear:(BOOL)animated {
	[self updateNavItem];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.author.text = [task objectForKey:@"name"];
	
	self.background.image = [[UIImage imageNamed:@"magenta-box.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
	
	RESTClient *client = [RESTClient sharedClient];
	RESTClientRequest *request = [[[RESTClientRequest alloc] initWithUrl:[NSURL URLWithString:[task objectForKey:@"uri"]] method:@"GET"] autorelease];
	[client performRequestAsync:request target:self selector:@selector(restRequest:gotTask:) failSelector:@selector(restRequest:failed:)];
}

- (void)restRequest:(id)request gotTask:(NSDictionary *)aTask {
	[task release];
	task = [aTask retain];
	
	NSString *txt = [task objectForKey:@"body"];
	CGPoint origin = description.frame.origin;
    CGSize size = [txt sizeWithFont:description.font constrainedToSize:CGSizeMake(description.frame.size.width, 10000) lineBreakMode:UILineBreakModeWordWrap];
	
	description.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
	description.text = txt;
	descriptionScroll.contentSize = CGSizeMake(origin.x*2 + size.width, origin.y*2 + size.height);
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
