//
//  TaskListViewController.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "TaskListViewController.h"
#import "RESTClient.h"
#import "DocuWalkAppDelegate.h"
#import "TaskViewController.h"

@implementation TaskListViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Tasks";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tasks" image:[UIImage imageNamed:@"map.png"] tag:0];
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	
	RESTClient *client = [RESTClient sharedClient];
	RESTClientRequest *request = [[RESTClientRequest alloc] initWithUrl:[DocuWalkAppDelegate 
																		 apiURL:@"docuwalk-task?fields=nid,title,name&order_by=created&sort_order=DESC"] method:@"GET"];
	[client performRequestAsync:[request autorelease] target:self selector:@selector(restClient:gotTasks:) failSelector:@selector(restClient:failed:)];
}

- (void)restClient:(id)request gotTasks:(NSArray *)recievedTasks {
	[tasks release];
	tasks = [recievedTasks retain];
	[tableView reloadData];
}

- (void)restClient:(id)request failed:(NSError *)error {
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tasks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseIdentifier = @"taskCell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
		[cell autorelease];
	}
	
	NSDictionary *task = [tasks objectAtIndex:indexPath.row];
	cell.textLabel.text = [task objectForKey:@"title"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *task = [tasks objectAtIndex:indexPath.row];
	TaskViewController *controller = [[[TaskViewController alloc] initWithTask:task] autorelease];
	[self.navigationController pushViewController:controller animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

