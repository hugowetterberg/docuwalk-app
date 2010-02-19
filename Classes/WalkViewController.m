//
//  WalkViewController.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "WalkViewController.h"
#import "NoteViewController.h"
#import "NoteAnnotation.h"
#import "DocuWalkAppDelegate.h"
#import "RESTClient.h"

@interface WalkViewController (Private)

- (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end


@implementation WalkViewController

@synthesize mapView, imagePicker;

- (id)initWithTask:(NSDictionary *)task {
	if (self = [self initWithNibName:@"WalkView" bundle:nil]) {
		Walk *current = [Walk currentWalk];
		if (current) {
			if ([[task objectForKey:@"nid"] isEqual:[current.task objectForKey:@"nid"]]) {
				walk = [current retain];
			}
		}
		if (!walk) {
			walk = [[Walk alloc] initWithTask:task];
			[Walk setCurrentWalk:walk];
		}
		walk.delegate = self;
		
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	mapView.centerCoordinate = newLocation.coordinate;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000);
	[mapView setRegion:region animated:YES];

	[locationManager stopUpdatingLocation];
	[locationManager autorelease];
	locationManager = nil;
}

- (IBAction)takePicture {
	BOOL has_camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Ladda upp en bild" delegate:self 
											   cancelButtonTitle:nil destructiveButtonTitle:nil 
											   otherButtonTitles:@"Välj bild från biblioteket", nil];
	if (has_camera) {
		[action addButtonWithTitle:@"Ta bild med kameran"];
	}
	
	action.cancelButtonIndex = [action addButtonWithTitle:@"Avbryt"];
	[action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	switch (buttonIndex) {
		case 0:
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
		case 1:
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		default:
			return;
	}
	[self.navigationController presentModalViewController:imagePicker animated:YES];
}


+ (UIImage *)resizeImage:(UIImage *)image toFitFrame:(CGSize)frame {
    if (image.size.width <= frame.width && image.size.height <= frame.height) {
        return image;
    }
    
    CGSize original = image.size;
    CGSize scaled;
    
    float xratio = original.width / frame.width;
    float yratio = original.height / frame.height;
    
    if (xratio <= yratio) {
        scaled = CGSizeMake(original.width / yratio, original.height / yratio);
    }
    else {
        scaled = CGSizeMake(original.width / xratio, original.height / xratio);
    }
    
    CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap = CGBitmapContextCreate(NULL, scaled.width, scaled.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, scaled.width, scaled.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resized = [UIImage imageWithCGImage:ref];
    
    CGColorSpaceRelease(colorSpaceInfo);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resized;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self.navigationController dismissModalViewControllerAnimated:YES];
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	RESTClient *client = [RESTClient sharedClient];
	RESTClientRequest *request = [[RESTClientRequest alloc] initWithUrl:[DocuWalkAppDelegate apiURL:@"docuwalk-picture"] method:@"POST"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:@"Picture" forKey:@"title"];
	[dict setValue:@"" forKey:@"body"];
	[dict setValue:[walk.solution objectForKey:@"nid"] forKey:@"solution"];
	[dict setValue:[NSString stringWithFormat:@"%f %f", walk.location.coordinate.latitude, walk.location.coordinate.longitude] forKey:@"position"];
	[request setJSONBody:[dict autorelease]];
	request.infoObject = [WalkViewController resizeImage:image toFitFrame:CGSizeMake(480, 480)];
	[client performRequestAsync:[request autorelease] target:self selector:@selector(restClient:imageCreated:) failSelector:@selector(restClient:failedToCreateImage:)];
}

- (void)restClient:(RESTClientAsyncRequest *)request imageCreated:(NSDictionary *)result {
	UIImage *image = request.restRequest.infoObject;
	image = [self scaleAndRotateImage:image];
	
	RESTClient *client = [RESTClient sharedClient];
	NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/file", [result objectForKey:@"uri"]]];
	RESTClientRequest *uploadRequest = [[RESTClientRequest alloc] initWithUrl:fileURL method:@"POST"];
	[uploadRequest.headers setValue:@"image/jpeg" forKey:@"Content-type"];
	[uploadRequest.headers setValue:[NSString stringWithFormat:@"inline; filename=\"%@.jpg\"", [result objectForKey:@"nid"]] forKey:@"Content-disposition"];
	uploadRequest.body = UIImageJPEGRepresentation(image, 0.7);
	[client performRequestAsync:[uploadRequest autorelease] target:self selector:@selector(restClient:imageUploaded:) failSelector:@selector(restClient:failedToUploadImage:)];
}

- (void)restClient:(id)request failedToCreateImage:(NSError *)error {
}

- (void)restClient:(RESTClientAsyncRequest *)request imageUploaded:(NSDictionary *)result {
	NSLog(@"Upload result: %@", result);
}

- (void)restClient:(id)request failedToUploadImage:(NSError *)error {
	NSLog(@"Upload error: %@", [error localizedDescription]);
}

-(void) noteAdded:(DocuWalkNote *)note {
	NoteAnnotation *annotation = [[[NoteAnnotation alloc] initWithNote:note] autorelease];
	NSLog(@"Adding note to map: %@", note.text);
	[mapView addAnnotation:annotation];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
	int kMaxResolution = 1200;
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	NSLog(@"Bounds %@", bounds);
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

- (IBAction)writeNote {
	NoteViewController *noteView = [[[NoteViewController alloc] initWithWalk:walk] autorelease];
	[self.navigationController pushViewController:noteView animated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
	[walk release];
    [super dealloc];
}


@end
