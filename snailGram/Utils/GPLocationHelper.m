//
//  GPSHelper.m
//  GymPact
//
//  Created by Bobby Ren on 3/4/13.
//  Copyright (c) 2013 GymPact Inc. All rights reserved.
//

#import "GPLocationHelper.h"
#import "UIAlertView+MKBlockAdditions.h"

@implementation GPLocationHelper

#define DebugLog NSLog

//static Gym_PactAppDelegate * appDelegate;

static GPLocationHelper * sharedLocationHelper; // used for delegate
static CLLocationManager * locationManager;

@synthesize bestLocation, gymRadius, gymLocation;
@synthesize checkinState, gpsState;
@synthesize locationTaskQueue;

@synthesize cancellationLocation;

#define LOW_ACCURACY_INTERVAL 10
#define HIGH_ACCURACY_INTERVAL 20

static BOOL initialized;
+(void)initLocationManager {
//    appDelegate = (Gym_PactAppDelegate*)[UIApplication sharedApplication].delegate;

    if (!sharedLocationHelper) {
        sharedLocationHelper = [[GPLocationHelper alloc] init];
    }
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = sharedLocationHelper;
    }
    if (!sharedLocationHelper.backgroundLocationMeasurements)
        sharedLocationHelper.backgroundLocationMeasurements = [[NSMutableArray alloc] init];
    if (!sharedLocationHelper.locationTaskQueue)
        sharedLocationHelper.locationTaskQueue = [[NSMutableArray alloc] init];

    [sharedLocationHelper switchCheckInToState:kCheckInStateNoCheckin];
    [sharedLocationHelper switchGPSToState:kGPSStateSleep];
    
    [self loadCachedGPLocationHelperState];

    initialized = YES;
}

+(BOOL)initialized {
    return initialized;
}

+(void)clearCachedLocations {
    sharedLocationHelper.bestLocation = nil;
    [sharedLocationHelper.backgroundLocationMeasurements removeAllObjects];
}

+(void)checkLocationForTask:(NSString*)locationTask {
    // first check if location services are enabled
    DebugLog(@"CheckLocationForTask: %@ Authorization status: %d", locationTask, [CLLocationManager authorizationStatus]);
    //if denied, straight up cancel task and warn user
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        // cancel previous delayed timeout for this task
        [NSObject cancelPreviousPerformRequestsWithTarget:sharedLocationHelper selector:@selector(locationTimeout:) object:locationTask];
        
        // show an alert immediately if we are trying to do certain things
        NSString * title;
        NSString * message;
        title = @"GPS is disabled";
        message = @"GPS is disabled";
        // so that on timeout we do not display a second error message
        [sharedLocationHelper switchGPSToState:kGPSStateDenied];

        // we have to warn user so we have to clear locations so timeout doesn't trigger checkin
        if ([GPLocationHelper currentLocation]) {
            [GPLocationHelper clearCachedLocations];
        }
        
        // the only situation not to display GPS error for checkout is if we are allowed to checkout even without GPS
        // because a post 30 min in gym location was already found
        // medium accuracy monitor needed is only true if we're past 30 mins, and no location has been found
        // it is NO if we are under 30 minutes, or checkout location already exists
        if ([locationTask isEqualToString:kLocationTaskCheckOut] && sharedLocationHelper.postWorkoutState == kPostWorkoutStateWorkoutCompleteLocationFound) {
            DebugLog(@"CheckLocationForTask: checking out, we already have a good location, don't worry about gps errors");
        }
        else {
            [UIAlertView alertViewWithTitle:title message:message];
        }
        
        // timeout so we can reset the UI to its original state
        [sharedLocationHelper locationTimeout:locationTask];
        return;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        DebugLog(@"Not ready yet!");
    }
    
    // GPS is not denied, but may be terrible. if can't get location, just let timeout occur
    DebugLog(@"Location services enabled!");
    int timeout = 10;
    
    // add tasks to queue for responses
    if (![sharedLocationHelper.locationTaskQueue containsObject:locationTask])
        [sharedLocationHelper.locationTaskQueue addObject:locationTask];
    
    if ([locationTask isEqualToString:kLocationTaskStartup])
    {
        DebugLog(@"GPLocationHelper: Check location on startup");
        timeout = 30;
    }
    else if ([locationTask isEqualToString:kLocationTaskNearbyGyms]) {
        DebugLog(@"GPLocationHelper: Check location for nearby gyms");
        timeout = 10;
    }
    else if ([locationTask isEqualToString:kLocationTaskCheckIn]) {
        DebugLog(@"GPLocationHelper: Check location for checkin");
        timeout = 10;
    }
    else if ([locationTask isEqualToString:kLocationTaskCheckOut]) {
        DebugLog(@"GPLocationHelper: Check location for checkout");
        timeout = 10;
    }
    
    if ([sharedLocationHelper bestLocationIsRecentEnough]) {
        DebugLog(@"Location already exists!");
        [sharedLocationHelper locationTimeout:locationTask];
    }
    else {
        // start GPS service with high accuracy
        [sharedLocationHelper startUpdatingLocation];
        [sharedLocationHelper switchGPSToState:kGPSStateHighAccuracy];
        
        // cancel any previous timeouts for this task
        [NSObject cancelPreviousPerformRequestsWithTarget:sharedLocationHelper selector:@selector(locationTimeout:) object:locationTask];
        
        // set timeout
        [sharedLocationHelper performSelector:@selector(locationTimeout:) withObject:locationTask afterDelay:timeout];
    }
}

+(CLLocation*)currentLocation {
    // returns best location if recent enough, otherwise a backup location if recent enough, otherwise nil
    if ([sharedLocationHelper bestLocationIsRecentEnough])
        return sharedLocationHelper.bestLocation;
    CLLocation * backupLocation = (CLLocation*)[sharedLocationHelper.backgroundLocationMeasurements lastObject];
    if (backupLocation && IS_RECENT_ENOUGH(backupLocation))
        return backupLocation;
    return nil;
}

+(float)distanceFromGym {
    // returns best location or backup location's current distance from gym
    
    // error values, but not handled because only used as log
    if ([GPLocationHelper currentLocation] == nil)
        return -1;
    if (sharedLocationHelper.gymLocation == nil)
        return -1;

    return [[GPLocationHelper currentLocation] distanceFromLocation:sharedLocationHelper.gymLocation];
}

+(void)monitorGymLocation:(CLLocation*)gymLoc andRadius:(float)gymRad {
    // at the end of a checkin
    DebugLog(@"GPLocationHelper monitorGymLocation: %f %f with radius %f", gymLoc.coordinate.latitude, gymLoc.coordinate.longitude, gymRad);
    if (gymLoc)
        sharedLocationHelper.gymLocation = gymLoc;
    if (gymRad > 0)
        sharedLocationHelper.gymRadius = gymRad;
    
    // now at a gym
    [sharedLocationHelper switchCheckInToState:kCheckInStateAtGym];
}

+(void)startBackgroundMode {
    DebugLog(@"GPLocationHelper: Starting background monitor");
    // cancel previous requests to change monitor cycle
    
    // check current mode
    if (sharedLocationHelper.checkinState == kCheckInStateLeftGymGracePeriod || sharedLocationHelper.checkinState == kCheckInStateGPSOffGracePeriod) {
        // do not go into background mode, but stay in high alert
        DebugLog(@"Going to back ground monitor but with high accuracy because we are in a cancellation period");
    }
    else {
        // either checkinState == kCheckInStateAtGym, or not at gym but in home workouts!
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
        [sharedLocationHelper switchGPSToState:kGPSStateBackground];
    }
}

+(void)startBackgroundModeForBackgroundCheckout {
    // come here to force background mode in order to checkout in background. at this time, we probably are in checkinState kCheckInStateLeftGymGracePeriod or kCheckInStateGPSOffGracePeriod, but the grace period is already over. the regular startBackgroundMode will not go into background because of the checkinState
    [sharedLocationHelper switchGPSToState:kGPSStateBackground];
}

+(void)returnFromBackgroundModeWithGymLocation:(CLLocation*)gymLoc andRadius:(float)gymRad {
    DebugLog(@"GPLocationHelper returning from background. Last checkin state %d gps state %d. gymLoc %@ radius %f", sharedLocationHelper.checkinState, sharedLocationHelper.gpsState, gymLoc, gymRad);
    
    if (gymLoc && !sharedLocationHelper.gymLocation) {
        sharedLocationHelper.gymLocation = gymLoc;
        sharedLocationHelper.gymRadius = gymRad;
    }
    
    if (sharedLocationHelper.checkinState == kCheckInStateLeftGymGracePeriod) {
        DebugLog(@"Already left gym and in grace period! Continuing grace period");
        // need to start timers again. todo: store amount of time that passed. for now, start cancellation grace period over
        [sharedLocationHelper switchCheckInToState:kCheckInStateLeftGymGracePeriod];
    }
    else if (sharedLocationHelper.checkinState == kCheckInStateGPSOffGracePeriod) {
        DebugLog(@"Already turned GPS off and in grace period! Continuing grace period");
        // need to start timers again. todo: store amount of time that passed. for now, start cancellation grace period over
        [sharedLocationHelper switchCheckInToState:kCheckInStateGPSOffGracePeriod];
    }
    else if (sharedLocationHelper.checkinState == kCheckInStateAtGym) {
        [GPLocationHelper monitorGymLocation:gymLoc andRadius:gymRad];
    }
    else if (sharedLocationHelper.checkinState == kCheckInStateNoCheckin) {
        [sharedLocationHelper switchGPSToState:kGPSStateSleep];
    }
}

+(void)stopMonitoringGymLocation {
    // only happens after checkout is successful, so can end all GPS functionality
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedLocationHelper selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedLocationHelper selector:@selector(highAccuracyEnded) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedLocationHelper selector:@selector(keepAlive) object:nil];
//    [sharedLocationHelper switchCheckInToState:kCheckInStateNoCheckin];
    [sharedLocationHelper switchGPSToState:kGPSStateSleep];
}

+(void)shouldRequireMediumAccuracy:(BOOL)required isWorkoutComplete:(BOOL)complete {
    // every tick of the workout timer updates this status so we know whether medium accuracy is needed in order to get a post workout checkout location
    if (!complete) {
        sharedLocationHelper.postWorkoutState = kPostWorkoutStateWorkoutIncomplete;
    }
    else {
        if (required) {
            sharedLocationHelper.postWorkoutState = kPostWorkoutStateWorkoutCompleteNoLocation;
            
            // force into medium accuracy mode if we're in low accuracy mode or background
            if (sharedLocationHelper.gpsState != kGPSStateMediumAccuracy) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
                [sharedLocationHelper monitorWorkoutWithMediumAccuracy];
            }
        }
        else {
            sharedLocationHelper.postWorkoutState = kPostWorkoutStateWorkoutCompleteLocationFound;
        }
    }
}

+(void)manualLeftGym {
    DebugLog(@"Check out initiated by user while outside gym.");
    if (sharedLocationHelper.checkinState != kCheckInStateLeftGymGracePeriod)
        [sharedLocationHelper leftGym];
}

+(void)cacheGPLocationHelperState {
    DebugLog(@"Cached checkinState: %d gpsState: %d", sharedLocationHelper.checkinState, sharedLocationHelper.gpsState);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sharedLocationHelper.checkinState] forKey:@"GPLocationHelperCheckinState"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sharedLocationHelper.gpsState] forKey:@"GPLocationHelperGPSState"];
}

+(void)loadCachedGPLocationHelperState {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"GPLocationHelperCheckinState"]) {
        sharedLocationHelper.checkinState = [[NSUserDefaults standardUserDefaults] integerForKey:@"GPLocationHelperCheckinState"];
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"GPLocationHelperGPSState"]) {
        sharedLocationHelper.gpsState = [[NSUserDefaults standardUserDefaults] integerForKey:@"GPLocationHelperGPSState"];
    }
    DebugLog(@"Loading cached GPLocationHelper CheckinState: %d gpsState %d", sharedLocationHelper.checkinState, sharedLocationHelper.gpsState);
}

+(void)clearCachedGPLocationHelperState {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GPLocationHelperCheckinState"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GPLocationHelperGPSState"];
}

+(BOOL)isGPSOffCancellation {
    // checks to see if cancellation was due to GPS off
    if (sharedLocationHelper.checkinState == kCheckInStateGPSOffGracePeriod)
        return YES;
    return NO;
}

+(BOOL)isLeftGymCancellation {
    if (sharedLocationHelper.checkinState == kCheckInStateLeftGymGracePeriod)
        return YES;
    return NO;
}

+(void)shutDownLocationServices {
    DebugLog(@"Shutting down loaction services");
    [GPLocationHelper clearCachedGPLocationHelperState];
    locationManager.delegate = nil;
    [locationManager stopUpdatingLocation];
    sharedLocationHelper = nil;
    locationManager = nil;
    initialized = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)startUpdatingLocation {
    // this is used so we can debug and display states while starting/stopping
    DebugLog(@"Starting location. checkin state: %d GPS State: %d", self.checkinState, self.gpsState);
    [locationManager startUpdatingLocation];
}

-(void)stopUpdatingLocation {
    // this is used so we can debug and display states while starting/stopping
    DebugLog(@"Stopping location. checkin state: %d GPS State: %d", self.checkinState, self.gpsState);
    [locationManager stopUpdatingLocation];
}

-(void)returnedToGym {
    // called from state grace period after finding an accurate location within the gym radius, using performSelector so can be cancelled

    // Cancel workout cancellation request
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelWorkout) object:nil];

    // start to monitor workout regularly
    [GPLocationHelper monitorGymLocation:gymLocation andRadius:gymRadius];
}

-(void)switchGPSToState:(int)newGPSState {
    if (self.gpsState == kGPSStateDenied) {
        // if we are currently denied we can't change it
        DebugLog(@"Current GPS State is denied! not changing to %d", newGPSState);
    }
    else {
        self.gpsState = newGPSState;
    }
    
    switch (newGPSState) {
        case kGPSStateSleep:
            DebugLog(@"GPLocationHelper: GPS to sleep");
            [self stopUpdatingLocation];
            break;
            
        case kGPSStateBackground: // background mode, just to allow phone to stay awake in BG
            DebugLog(@"GPLocationHelper: GPS to background");
            [self startUpdatingLocation];
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            locationManager.distanceFilter = 100000000000000.0; //00.0;
            [self performSelector:@selector(keepAlive) withObject:nil afterDelay:GPLOCATION_KEEPALIVE_INTERVAL];
            break;
            
        case kGPSStateLowAccuracy:
        {
            DebugLog(@"GPLocationHelper: GPS to low accuracy");
            [self startUpdatingLocation];
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            locationManager.distanceFilter = 100000000000000.0;
        }
            break;
            
        case kGPSStateMediumAccuracy:
        {
            DebugLog(@"GPLocationHelper: GPS to slightly higher accuracy");
            // still no checkout location
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.distanceFilter = 50.0;
        }
            break;
            
        case kGPSStateHighAccuracy:
            DebugLog(@"GPLocationHelper: GPS to high accuracy");
            [self startUpdatingLocation];
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            break;
            
        // error cases
        case kGPSStateDenied:
        {
            DebugLog(@"GPLocationHelper: GPS to error/denied");
            if (self.checkinState == kCheckInStateAtGym) {
                // GPS off while checked in at gym
                [self switchCheckInToState:kCheckInStateGPSOffGracePeriod];
            }
            else if (self.checkinState == kCheckInStateLeftGymGracePeriod) {
                // currently in cancellation for left gyms
                // if user gets cancelled because their gps was turned off and they could
                // not get a signal even if they returned to the gym, we have to tell them
                // that it was because GPS was off
                [self switchCheckInToState:kCheckInStateGPSOffGracePeriod];
            }
            else {
                // no check in state, just ignore
            }
            return;
        }
            break;
            
        default:
            break;
    }
}

-(void)switchCheckInToState:(int)newCheckInState {
    self.checkinState = newCheckInState;
    
    switch (newCheckInState) {
        case kCheckInStateNoCheckin:
            DebugLog(@"GPLocationHelper: Check In state is No Checkin");
            // don't stop GPS - may still be searching for nearby gyms and wait on timeout
            break;
            
        case kCheckInStateAtGym:
        {
            // just checked in successfully
            // since we hve an accurate location, start the cycle by monitoring low accuracy
            DebugLog(@"GPLocationHelper: Check In state is At Gym");
            [sharedLocationHelper monitorWorkoutWithLowAccuracy];

            [GPLocationHelper cacheGPLocationHelperState];
        }
            break;
            
        case kCheckInStateLeftGymGracePeriod:
        {
            DebugLog(@"GPLocationHelper: Check In state is Left Gym");
            // cancel previous requests to change monitor cycle
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
            
            // just left gym. monitor at high accuracy, and do cancellation at end of grace period
            [self switchGPSToState:kGPSStateHighAccuracy];
            [self performSelector:@selector(cancelWorkout) withObject:nil afterDelay:10];

            [GPLocationHelper cacheGPLocationHelperState];
        }
            break;
            
        // GPS error
        case kCheckInStateGPSOffGracePeriod:
        {
            DebugLog(@"GPLocationHelper: Check In state is GPS Off during workout");
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
            // do not cancel other/multiple calls to start grace period - if we are already in grace period continue it
            //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(leftGym) object:nil];

            // initiate cancellation period. if previous already exists, that's fine
            [self performSelector:@selector(cancelWorkout) withObject:nil afterDelay:10];

            // cache because if we're outside the app, we need to store GPS state so it is correct when we return
            [GPLocationHelper cacheGPLocationHelperState];
        }
            break;

        default:
            break;
    }
}

-(void)monitorWorkoutWithHighAccuracy {
    // cycle between low state and high state with 1 part high accuracy and 4 parts low accuracy
    [self switchGPSToState:kGPSStateHighAccuracy];

    self.cancellationLocation = nil;
    
    // at end of monitorWorkoutWithHighAccuracy, trigger grace period if we are not going to low accuracy due to finding a location
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
    [self performSelector:@selector(highAccuracyEnded) withObject:nil afterDelay:HIGH_ACCURACY_INTERVAL];
}

-(void)monitorWorkoutWithLowAccuracy {
    // cycle between low state and high state with 1 part high accuracy and 4 parts low accuracy
    [self switchGPSToState:kGPSStateLowAccuracy];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
    [self performSelector:@selector(monitorWorkoutWithHighAccuracy) withObject:nil afterDelay:LOW_ACCURACY_INTERVAL];
}

-(void)monitorWorkoutWithMediumAccuracy {
    // low accuracy cycle but with higher GPS
    [self switchGPSToState:kGPSStateMediumAccuracy];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
    [self performSelector:@selector(monitorWorkoutWithHighAccuracy) withObject:nil afterDelay:LOW_ACCURACY_INTERVAL];
}

-(void)highAccuracyEnded {
    // handles end of high accuracy.
    // if no location found, go to low accuracy
    // if bad location found, go to leftGym
    DebugLog(@"High accuracy ended. Where should we go?");
    
    if (self.cancellationLocation == nil) {
        DebugLog(@"No GPS Received...go to low accuracy");
        // no bad location found by the end of the workout period, so start low accuracy cycle
        if (self.postWorkoutState == kPostWorkoutStateWorkoutCompleteNoLocation)
            [self monitorWorkoutWithMediumAccuracy];
        else
            [self monitorWorkoutWithLowAccuracy];
    }
    else {
        DebugLog(@"We got a cancellation location outside gym: %@", self.cancellationLocation);
        [self leftGym];
    }
}

-(void)keepAlive {
    // performed every 5 minutes to keep gps awake and phone from locking
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(keepAlive) object:nil];
    if (self.gpsState == kGPSStateBackground)
    {
        DebugLog(@"Ah ah ah ah stayin alive! stayin alive!");
        [self stopUpdatingLocation];
        [self switchGPSToState:kGPSStateBackground]; // equivalent to calling background
    }
}

-(void)leftGym {
    // left gym
    // this is triggered after a minute of monitorWorkoutWithHighAccuracy without getting an accurate location
    // change state to left gym. next time high accuracy monitoring ends we will start cancellation process
    [self switchCheckInToState:kCheckInStateLeftGymGracePeriod];
    DebugLog(@"Left gym");
}

-(void)locationTimeout:(NSString*)locationTask {
    // task is only used to mark which timeout requests to cancel
    DebugLog(@"GPLocationHelper LocationTimeout with task %@", locationTask);

    if (![locationTask isEqualToString:kLocationTaskTriggerAll] && ![self.locationTaskQueue containsObject:locationTask])
        return;
    
    // after timeout, call either did find accurate location or failed accurate location
    if ([self bestLocationIsRecentEnough]) {
        // bestLocation exists, so use that for all requests
        DebugLog(@"GPLocationHelper Timeout: Accurate location found!");
        NSMutableArray * tasksToRemove = [NSMutableArray array];
        for (NSString * task in self.locationTaskQueue) {
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:bestLocation forKey:@"foundLocation"];

            [tasksToRemove addObject:task];
        }
        [self.locationTaskQueue removeObjectsInArray:tasksToRemove];
    }
    else {
        // if not checkout, we can use a backup location. if it is recent enough
        if (![locationTask isEqualToString:kLocationTaskCheckOut] && [sharedLocationHelper.backgroundLocationMeasurements lastObject] && IS_RECENT_ENOUGH( ((CLLocation*)[sharedLocationHelper.backgroundLocationMeasurements lastObject]) )) {
            CLLocation * backupLocation = (CLLocation*)[sharedLocationHelper.backgroundLocationMeasurements lastObject];
            DebugLog(@"GPLocationHelper Timeout: Backup location found! Only using this location for current task: %@", locationTask);
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:backupLocation forKey:@"foundLocation"];
            [self.locationTaskQueue removeObject:locationTask];
        }
        // if checkout or no recent backup location, just do it
        else {
            // didFailFindLocation
            DebugLog(@"GPLocationHelper Timeout: Could not find location! Task that timed out: %@", locationTask);
            if ([locationTask isEqualToString:kLocationTaskCheckIn] || [locationTask isEqualToString:kLocationTaskCheckOut]) {
                // if requesting checkin, must notify for failed checkin
                NSMutableDictionary * userInfo = nil;
                if (self.gpsState == kGPSStateDenied) {
                    // because location services are denied, we've already displayed a message
                    userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"shouldDisplayAlert"];
                }
                // remove task from queue
                [self.locationTaskQueue removeObject:locationTask];
            }
            else if ([locationTask isEqualToString:kLocationTaskNearbyGyms]) {
                // if requesting nearby gyms, must notify for failed gyms
                // keep task in queue in case another request is successful in getting location
                //[self.locationTaskQueue removeObject:locationTask];
            }
            else {
                // for locationTasks kLocationTaskStartup
                // no need to call any timeout failure
                [self.locationTaskQueue removeObject:locationTask]; // no need to be in queue
            }
        }
    }
    
    // put GPS to sleep if not monitoring workout, monitoring background, or if we had a temporary error
    if (self.checkinState == kCheckInStateNoCheckin) {
        // only let GPS sleep if we are not checked in or in background mode
        // if cycling lo/hi, or on high mode, or if we know gps is denied
        if (self.gpsState != kGPSStateDenied && self.gpsState != kGPSStateBackground)
            [self switchGPSToState:kGPSStateSleep];
    }
    else {
        DebugLog(@"GPLocationHelper after timeout, continuing to monitor GPS. Checkin state: %d", self.checkinState);
    }
}

-(BOOL)bestLocationIsRecentEnough {
    // tests to see if bestLocation exists, and is within the LOCATION_EXPIRATION_TIME 
    DebugLog(@"Best Location already exists? %d %@ Is recent? %d", (bestLocation != nil), bestLocation?bestLocation:@"", IS_RECENT_ENOUGH(bestLocation));
    if ((bestLocation != nil) && (IS_RECENT_ENOUGH(bestLocation))) {
        DebugLog(@"Existing location is recent enough: time %f accuracy %f", [bestLocation.timestamp timeIntervalSinceNow], bestLocation.horizontalAccuracy);
        return YES;
    }
    return NO;
}

+(BOOL)insideGymRadius:(CLLocation*)newLocation {
    return YES;
}

-(void)cancelWorkout {
    DebugLog(@"GPLocationHelper Cancel workout! Grace period over, current GPS State %d Checkin State %d", self.gpsState, self.checkinState);
    
    // if multiple cancels have been requested, only do the first one
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelWorkout) object:nil];
    
    if (self.checkinState == kCheckInStateNoCheckin) {
        DebugLog(@"GPLocationHelper must be a stale cancelWorkout request because we are not checked in!");
        return;
    }
    
    NSDictionary * userInfo = nil;
    if (self.cancellationLocation)
        userInfo = @{@"cancellationLocation": self.cancellationLocation};
    else if ([GPLocationHelper currentLocation])
        userInfo = @{@"cancellationLocation": [GPLocationHelper currentLocation]};
    else
        DebugLog(@"No location for cancellation");
    // an automatic cancellation (not user initiated), possibly due to GPS disabled
}

#pragma mark cllocationdelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    DebugLog(@"DidUpdateLocations");
    CLLocation * oldLocation = nil;
    if ([locations count] > 1)
        oldLocation = [locations objectAtIndex:[locations count]-2];
    CLLocation * newLocation = [locations lastObject];
    [self locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        DebugLog(@"Still updating location for homeworkouts in bg");
    }
    
    if (locationEnabledCallback) {
        locationEnabledCallback(kLocationEnabledStatusOK);
    }
    
    // test the age of the location measurement to determine if the measurement is cached
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    DebugLog(@"Background location: latitude: %f; longitude: %f; accuracy: %f age: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy, locationAge);
    
    // test that the horizontal accuracy does not indicate an invalid measurement and that measurement is not old
    if (locationAge > 5.0) {
        DebugLog(@"Discarding location: reason: age = %f", locationAge);
        return;
    }
    if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > LOCATION_ACCURACY_LIMIT)
    {
        DebugLog(@"Discarding location: reason: inaccurate. (bestEffortAtLocation is NOT saved, so we will not call didGetAccurateLocation)");
        return;
    }
    
    // always store backlocation into array, max 10 objects
    if ([self.backgroundLocationMeasurements count] > 10)
        [self.backgroundLocationMeasurements removeAllObjects];
    [self.backgroundLocationMeasurements addObject:newLocation];
    
    // only store bestLocation if it is the most recent, high accuracy location
    if (newLocation.horizontalAccuracy <= LOCATION_ACCURACY_BEST) {
        DebugLog(@"Acquired new best location: %@", newLocation);
        bestLocation = newLocation;
        // we have a measurement that meets our requirements, so we can stop updating the location
        // do timeout
        if ([self.locationTaskQueue count] > 0) {
            // triggers all currently queued didGetAccurateLocation observers
            [self locationTimeout:kLocationTaskTriggerAll];
        }
    }
    
    [self processLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // can happen if we lose gps signal, or in the simulator briefly, when you switch custom locations
    DebugLog(@"LocationManager failure: %@", error);
    if ([error code] == kCLErrorDenied) {
        if (self.checkinState != kCheckInStateGPSOffGracePeriod)
            [self switchGPSToState:kGPSStateDenied];
        if (locationEnabledCallback) {
            locationEnabledCallback(kLocationEnabledStatusDenied);
        }
    }
    else {
        if ([error code] == kCLErrorNetwork) {
            DebugLog(@"LocationManager failure: network");
        }
        else if ([error code] == kCLErrorLocationUnknown) {
            DebugLog(@"LocationManager failure location unknown");
        }
        else {
            DebugLog(@"Location Manager failure: code %d", error.code);
        }
        if (locationEnabledCallback) {
            locationEnabledCallback(kLocationEnabledStatusError);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // only happens if user changes the location permissions or turns on airplane mode
    DebugLog(@"LocationManager didChangeAuthorizationStatus: %d", status);
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            if (self.checkinState != kCheckInStateGPSOffGracePeriod)
                [self switchGPSToState:kGPSStateDenied];
            
            // send user immediate warning
            UILocalNotification *warning = [[UILocalNotification alloc] init];
            warning.soundName = UILocalNotificationDefaultSoundName;
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                warning.applicationIconBadgeNumber = 1;
            }
            warning.alertBody = @"GPS Was denied";
            [[UIApplication sharedApplication] presentLocalNotificationNow:warning];
        }
            break;
        case kCLAuthorizationStatusAuthorized:
        {
            DebugLog(@"GPS authorization returned");
            // if gps status was denied, thank the user for undenying us
            if (self.gpsState == kGPSStateDenied) {
                DebugLog(@"Thanks for turning GPS back on!");
                // send user immediate warning
                UILocalNotification *warning = [[UILocalNotification alloc] init];
                warning.soundName = UILocalNotificationDefaultSoundName;
                warning.alertBody = @"GPS Was undenied";
                [[UIApplication sharedApplication] presentLocalNotificationNow:warning];
                
                //[self switchGPSToState:kGPSStateSleep];
                if (self.gpsState == kGPSStateDenied)
                    self.gpsState = kGPSStateSleep; // manually change to override denied check
                
            }
            
            //If the user has turned the GPS back on, start updating location
            if (self.checkinState == kCheckInStateAtGym)
            {
                DebugLog(@"At gym");
                // do nothing?
                // tell workoutViewController that GPS is enabled so if we're in the background, we'll reenable background mode
            }
            else if (self.checkinState == kCheckInStateGPSOffGracePeriod || self.checkinState == kCheckInStateLeftGymGracePeriod) {
                [self monitorWorkoutWithHighAccuracy];
            }
            else {
                // no checkin, sleep
                [self switchGPSToState:kGPSStateSleep];

                // tell workoutViewController that GPS is enabled so if we're in the background, we'll reenable background mode
            }

            if ([locationTaskQueue count] != 0) {
                [GPLocationHelper checkLocationForTask:[locationTaskQueue objectAtIndex:0]];
            }
        }
            break;
        default:
            DebugLog(@"Authorization status other!");
            break;
    }
}

-(void)processLocation:(CLLocation*)newLocation {
    if (self.checkinState == kCheckInStateAtGym) {
        DebugLog(@"Distance from gym: %f distance required for warning: %f", [newLocation distanceFromLocation:gymLocation], newLocation.horizontalAccuracy + 100.0);
        // if checked in, check for location inside gym radius
        if (![GPLocationHelper insideGymRadius:newLocation]) {
            // outside the gym
            DebugLog(@"Checked in but not inside gym: %@ currently in %@ accuracy mode ", self.gpsState == kGPSStateHighAccuracy?newLocation:@"", self.gpsState == kGPSStateHighAccuracy? @"high":@"low");
            
            // store cancellation if we're on high accuracy mode
            if (self.gpsState == kGPSStateHighAccuracy || self.gpsState == kGPSStateMediumAccuracy) {
                self.cancellationLocation = newLocation; // will trigger cancellation at end of high interval
            }
        }
        else {
            // checked in, and still in gym
            DebugLog(@"Still at the ol' gym! currently in %@ accuracy mode", self.gpsState == kGPSStateHighAccuracy? @"high":@"low");
            
            // send in-gym location to workoutViewController to process - goes to locationFoundInGymDuringWorkout
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:newLocation forKey:@"foundLocation"];

            if (self.gpsState == kGPSStateHighAccuracy || self.gpsState == kGPSStateMediumAccuracy) {
                DebugLog(@"We can go to low accuracy mode");
                // cancel timed switch to grace period, and ignore any previous cancellation
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorWorkoutWithHighAccuracy) object:nil];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
                self.cancellationLocation = nil;
                
                // switch to low accuracy cycle NOW
                [self monitorWorkoutWithLowAccuracy];
            }
        }
    }
    else if (self.checkinState == kCheckInStateLeftGymGracePeriod || self.checkinState == kCheckInStateGPSOffGracePeriod) {
        // if left gym, check for returning to gym
        if ([GPLocationHelper insideGymRadius:newLocation]) {
            // just returned
            DebugLog(@"Back at gym");
            DebugLog(@"Just returned and turns out we're at the ol' gym! currently in %@ accuracy mode", self.gpsState == kGPSStateHighAccuracy? @"high":@"low");
            DebugLog(@"We can go to low accuracy mode and monitor");
            
            // send in-gym location to workoutViewController to process - goes to locationFoundInGymDuringWorkout
            NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[GPLocationHelper currentLocation] forKey:@"foundLocation"];

            // cancel timed switch to low accuracy
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highAccuracyEnded) object:nil];
            [self returnedToGym];
        }
        else {
            // location not good enough, record as last known location
            DebugLog(@"GPS Returned but not near gym. current checkin state: %d", self.checkinState);
        }
    }
    else {
        // not checked in. probably a background location request or checkin or checkout request
    }
}
@end
