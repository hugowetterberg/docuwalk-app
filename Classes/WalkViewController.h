//
//  WalkViewController.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CSMapRouteLayerView.h"
#import "Walk.h"

@interface WalkViewController : UIViewController <CLLocationManagerDelegate, WalkDelegate, UIImagePickerControllerDelegate> {
	CSMapRouteLayerView *routeView;
	MKMapView *mapView;
	CLLocationManager *locationManager;
	UIImagePickerController *imagePicker;
	Walk *walk;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet UIImagePickerController *imagePicker;

+ (UIImage *)resizeImage:(UIImage *)image toFitFrame:(CGSize)frame;

- (id)initWithTask:(NSDictionary *)task;
- (IBAction)takePicture;
- (IBAction)writeNote;

@end
