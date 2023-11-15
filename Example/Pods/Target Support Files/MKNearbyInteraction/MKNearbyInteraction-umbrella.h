#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CBPeripheral+MKNBAdd.h"
#import "MKNBCentralManager.h"
#import "MKNBPeripheral.h"
#import "MKNBSDKNormalDefines.h"

FOUNDATION_EXPORT double MKNearbyInteractionVersionNumber;
FOUNDATION_EXPORT const unsigned char MKNearbyInteractionVersionString[];

