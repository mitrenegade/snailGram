//
//  GPLocationHelper
//  GymPact
//
//  Created by Bobby Ren on 5/11/13.
//  Copyright (c) 2013 Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^CheckLocationServicesCallback)(int);

CheckLocationServicesCallback locationEnabledCallback;

#if TESTING
#define LOCATION_EXPIRATION_SEC 15
#else
#define LOCATION_EXPIRATION_SEC 60
#endif
#define LOCATION_ACCURACY_BEST 30
#define LOCATION_ACCURACY_LIMIT 500
#define GPLOCATION_KEEPALIVE_INTERVAL 300

#define IS_RECENT_ENOUGH(x) ([x.timestamp timeIntervalSinceNow] > -LOCATION_EXPIRATION_SEC)

static NSString * const kLocationTaskStartup = @"Location Task Startup"; // initial location request on startup
static NSString * const kLocationTaskNearbyGyms = @"Location Task Nearby Gyms"; // location used to search for nearby gyms
static NSString * const kLocationTaskCheckIn = @"Location Task CheckIn"; // checkin for gyms
static NSString * const kLocationTaskCheckOut = @"Location Task CheckOut"; // different from checkin because messaging behavior is different
static NSString *const kLocationTaskTriggerAll = @"Acquired best location, trigger all timeouts";
//static NSString * const kLocationTaskWorkout = @"Location Task Monitor Workout"; // no timeout, starts hi/lo monitoring cycle
//static NSString * const kLocationTaskBackground = @"Location Task Monitor Background"; // no timeout, hi/lo cycle for when app goes into background

enum CHECKIN_STATE {
    kCheckInStateNoCheckin = 0,
    kCheckInStateAtGym = 1,
    kCheckInStateLeftGymGracePeriod = 2, // cancellation grace period for leaving gym unless return to gym
    kCheckInStateGPSOffGracePeriod = 3 // cancellation grace period for disabling GPS unless GPS is turned back on
    };

enum GPS_STATE {
    kGPSStateDenied = -1,
    kGPSStateSleep = 0,
    kGPSStateLowAccuracy = 1,
    kGPSStateHighAccuracy = 2,
    kGPSStateBackground = 3,
    kGPSStateMediumAccuracy = 4
};

enum LOCATION_ENABLED_CODE {
    kLocationEnabledStatusOK = 0,
    kLocationEnabledStatusDenied = 1, // settings are off
    kLocationEnabledStatusError = 2 // temporary error, or airplane mode
};

enum POST_WORKOUT_LOCATION_FOUND_STATE {
    kPostWorkoutStateWorkoutIncomplete = 0, // workout not yet reached 30 mins so don't require medium accuracy
    kPostWorkoutStateWorkoutCompleteNoLocation = 1, // workout completed, need medium accuracy
    kPostWorkoutStateWorkoutCompleteLocationFound = 2 // workout completed and location in gym found, don't need medium accuracy
};

@interface GPLocationHelper : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *backgroundLocationMeasurements;
@property (nonatomic, strong) CLLocation * bestLocation;
@property (nonatomic, strong) CLLocation * gymLocation;
@property (nonatomic, assign) float gymRadius;

@property (nonatomic, strong) CLLocation * cancellationLocation; // location outside the gym found during high accuracy mode

@property (nonatomic, assign) int checkinState;
@property (nonatomic, assign) int gpsState;

@property (nonatomic, assign) int postWorkoutState; // if we meet certain conditions, low accuracy should also look for location. (we've passed the 30 minute mark and do not have a valid location).

@property (nonatomic, strong) NSMutableArray * locationTaskQueue;

+(BOOL)initialized;

+(void)initLocationManager;
+(void)clearCachedLocations;
+(void)checkLocationForTask:(NSString*)locationTask;
+(CLLocation*)currentLocation;
+(BOOL)insideGymRadius:(CLLocation*)newLocation;
+(void)monitorGymLocation:(CLLocation*)gymLoc andRadius:(float)gymRad;
+(void)stopMonitoringGymLocation;
+(void)startBackgroundMode;
+(void)returnFromBackgroundModeWithGymLocation:(CLLocation*)gymLoc andRadius:(float)gymRad;
+(float)distanceFromGym;
+(void)cacheGPLocationHelperState;
+(void)loadCachedGPLocationHelperState;
+(void)clearCachedGPLocationHelperState;
+(void)shutDownLocationServices; // on logout
+(BOOL)isGPSOffCancellation;
+(BOOL)isLeftGymCancellation;
+(void)startBackgroundModeForBackgroundCheckout;
+(void)shouldRequireMediumAccuracy:(BOOL)required isWorkoutComplete:(BOOL)complete;
+(void)manualLeftGym;
@end
