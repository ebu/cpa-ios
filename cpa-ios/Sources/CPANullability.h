//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

// Compatibility macros for Xcode versions < 6.3. Only temporary
#if ! __has_feature(nullability)
    #define NS_ASSUME_NONNULL_BEGIN
    #define NS_ASSUME_NONNULL_END
    #define nullable
    #define nonnull
    #define null_unspecified
    #define null_resettable
    #define __nullable
    #define __nonnull
    #define __null_unspecified
#endif
