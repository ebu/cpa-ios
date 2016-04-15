# Cross-Platform Authentication - iOS Client

[![Build Status](https://img.shields.io/travis/ebu/cpa-ios/develop.svg?style=flat)](https://travis-ci.org/ebu/cpa-ios)
[![Platform](https://img.shields.io/cocoapods/p/cpa-ios.svg?style=flat)](http://cocoadocs.org/docsets/cpa-ios/)
[![Pod Version](https://img.shields.io/cocoapods/v/cpa-ios.svg?style=flat)](http://cocoadocs.org/docsets/cpa-ios/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/cpa-ios.svg?style=flat)](LICENSE)

The Cross-platform Authentication (CPA) protocol provides a common formalism between device manufacturers and content providers to offer personalized services to their audience. It makes it possible for a user to conveniently access these services as a single identity accross devices and applications.

This software implements version 1.0 of the Cross-Platform Authentication Protocol ([ETSI TS 103 407](https://portal.etsi.org/webapp/WorkProgram/Report_WorkItem.asp?WKI_ID=47970)).

More information is available on the [EBU Cross-Platform Authentication project page](http://tech.ebu.ch/cpa).

## Compatibility

The CPA iOS library requires the most recent versions of Xcode and of the iOS SDK, currently:

* Xcode 7.2
* iOS 9.2 SDK

Deployment is supported for the two most recent major iOS versions, currently:

* iOS 8.x
* iOS 9.x

All architectures are supported:

* i386 and x86_64
* armv7, armv7s and arm64

The CPA iOS library can be used both from Objective-C or Swift files. It does not contain any private API method calls and is therefore App Store compliant.

## Getting started

The library can be added to a project with [CocoaPods](http://cocoapods.org/) or [Carthage](https://github.com/Carthage/Carthage).

### Installation with CocoaPods

Add `CrossPlatformAuthentication` as dependency in your `Podfile`:

```ruby
pod 'CrossPlatformAuthentication', '<version>'
```

Then run `pod install` to update the dependencies. You can also add the `use_frameworks!` directive in your `Podfile`, which embeds the library as a native Cocoa Touch framework.

For more information about CocoaPods and the `Podfile`, please refer to the [official documentation](http://guides.cocoapods.org/).

### Installation with Carthage

You can use the library as an embedded Cocoa Touch framework, conveniently managed using Carthage. 

Add `cpa-ios` as dependency in your `Cartfile`:

```
github "ebu/cpa-ios" == <version>
```

Then run `carthage update` to update the dependencies. Unlike CocoaPods, your project is not changed. You will need to manually add the `CrossPlatformAuthentication.framework` generated in the `Carthage/Build/iOS` folder to your projet. Refer to the [official documentation](https://github.com/Carthage/Carthage) for more information.

### Usage

A global `CrossPlatformAuthentication .h` header file is provided. You can of course individually import public header files if you prefer, though.

#### Usage from Objective-C source files

Import the global header file using

```objective-c
#import <CrossPlatformAuthentication/CrossPlatformAuthentication.h>
```

You can similarly import individual files, e.g.

```objective-c
#import <CrossPlatformAuthentication/CAPProvider.h>
```

If you use Carthage or CocoaPods with the `use_frameworks!` directive, it is easier to import the `CrossPlatformAuthentication` module itself where needed:

```objective-c
@import CrossPlatformAuthentication;
```

#### Usage from Swift source files

If you installed the library with CocoaPods but without the `use_frameworks!` directive, import the global header from a bridging header:

```objective-c
#import <CrossPlatformAuthentication/CrossPlatformAuthentication.h>
```

If you use Carthage or CocoaPods with the `use_frameworks!` directive, it is easier to import the library module where needed instead:

```swift
import CrossPlatformAuthentication
```

### Concepts

A brief overview of the main CPA iOS library concepts is provided below. For more information about CPA itself, please refer to the [EBU Tech 3366 specification document](https://tech.ebu.ch/docs/tech/tech3366.pdf).

#### Authorization provider

The most important class you will use is `CPAProvider`, which manages authentication with a single authorization provider (AP). APs are authorities responsible for the delivery of tokens, in general for several service providers corresponding to various domains. Most applications should only require a single `CPAProvider` instance, which you can install as default instance for convenient application-wide access:

```objective-c
CPAProvider *provider = [[CPAProvider alloc] initWithAuthorizationProviderURL:providerURL];
[CPAProvider setDefaultProvider:provider];
```

and easily retrieve when needed:

```objective-c
CPAProvider *defaultProvier = [CPAProvider defaultProvider];
```

#### Tokens

APs can deliver two kinds of tokens for domains:

* Client tokens, associated with an anonymous identity. This anonymous identity is meant for _out of the box_ experience without requiring immediate registration with a user account
* User token, associated with an account

To request a token, simply call the dedicated `CPAProvider` method. If you have set a default provider as described above, this boils down to:

```objective-c
[[CPAProvider defaultProvider] requestTokenForDomain:@"cpa.mydomain.com" withType:type completionBlock:^(CPAToken *token, NSError *error) {
    if (error) {
        // Deal with the error
    }
    else {
      // Use the received token
    }
}];
```

where type is either `CPATokenTypeClient` or `CPATokenTypeUser` for client, respectively user tokens. The domain must be a host name, `cpa.mydomain.com` in the example above, optionally followed by a port number. Tokens received for a domain are valid for all endpoints related to this domain, e.g. `https://cpa.mydomain.com/playlist` or `https://cpa.mydomain.com/hbbtv`.

A token received for a domain is automatically stored within the keychain, and can simply be retrieved without performing a request to the AP:

```objective-c
CPAToken *token = [[CPAProvider defaultProvider] tokenForDomain:@"cpa.mydomain.com"];
if (token) {
    // Use the token
}
```

Tokens might expire, though. If the service provider hapens to reject an associated token available from the keychain, request another token using the same method as above.

#### User tokens and supplying credentials

When requesting a user token for a domain, the AP will in general require the user to supply her credentials. These are entered using a web page displayed by an in-app web browser (though it would have been better to use Safari instead of a built in solution, Apple has a history of rejecting applications using Safari for this purpose).

An AP might provide single sign-on for several domains. In such cases, provided a user already obtained a user token for a domain, she might obtain a token for an affiliated domain without the need to supply her credentials again.

By default, the in-app browser is presented modally. This might not always suit your needs, in which case you can supply an additional presentation block when rquesting the token. For example, to present the browser in a navigation controller:

```objective-c
[[CPAProvider defaultProvider] requestTokenForDomain:domain withType:type credentialsPresentationBlock:^(UIViewController *viewController, CPAPresentationAction action) {
    if (action == CPAPresentationActionShow) {
        [navigationController pushViewController:viewController animated:YES];
    }
    else {
        [navigationController popViewControllerAnimated:YES];
    }
} completionBlock:^(CPAToken *token, NSError *error) {
    if (error) {
        // Deal with the error
    }
    else {
        // Use the received token
    }
}];
```

#### Token group sharing

Tokens can be shared between applications from the same group:

* Create an application group on the developer portal, and associate it with each application. For more information, please refer to the [official documentation](https://developer.apple.com/library/ios/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html)
* Provide the group identifier when instantiating the `CPAProvider`:

    ```objective-c
    CPAProvider *provider = [[CPAProvider alloc] initWithAuthorizationProviderURL:providerURL
                                                              keyChainAccessGroup:@"group.mygroup.identifier"];
    ```
    
For this provider, tokens will now be saved and retrieved for the application group as a whole.

## Demo project

A demo project is available, just build `cpa-ios-demo` (Objective-C implementation) or `cpa-ios-demo-swift` (Swift implementation).

The application provides a way to retrieve tokens for two different services (playlist and HbbTV) from a common AP. A third dummy domain, for which the AP cannot deliver tokens, can be selected as well.

When requesting a token for a domain, you can:

* Ask for an authenticated (user) or unauthenticated (client) token
* Force token renewal to avoid using a token already available from the keychain
* Use a custom transition when displaying the in-app browser (navigation controller push and pop instead of modal presentation)

Clicking on the _Retrieve token_ button retrieves a token and display it below.

The two playlist and HbbTV services should provide single sign-on. This means that if you obtain a user token for one of them, you can obtain a user token for the other one without the need to supply your credentials again.

## Contributing

You can contribute to the project using pull requests. Simply checkout the project and update CocoaPods dependencies by running:

```
$ pod install
```

from the main project directory.

An `install_git_hooks.sh` script is available from the main directory. You should run it once to install convenient git hooks which take care of properly assigning Travis CI badges on a branch basis.

### Code coverage

To get code coverage results locally, proceed as follows:

* Clone XcodeCoverage somewhere:

    ```
    $ git clone git@github.com:jonreid/XcodeCoverage.git
    ```
    
* Switch to the `cpa-ios` subdirectory and create a symbolic link to your XcodeCoverage working copy:

    ```
    $ cd cpa-ios
    $ ln -s /path/to/XcodeCoverage
    ```

* Run the tests within Xcode by switching to the `cpa-ios-tests-runner` target and pressing ⌘+U
* Generate the code coverage report by running the `getcov` command:

    ```
    $ cd cpa-ios
    $ ./XcodeCoverage/getcov -s
    ```
    
Your default browser should open and display the coverage results.


## Related projects

* [Tutorial](https://github.com/ebu/cpa-tutorial)
* [Authentication Provider](https://github.com/ebu/cpa-auth-provider)
* [Service Provider](https://github.com/ebu/cpa-service-provider)
* [Android Client](https://github.com/ebu/cpa-android)
* [JavaScript Client](https://github.com/ebu/cpa.js)


## Contributors

* [Samuel Défago](https://github.com/defagos) (RTS)
* [Michael Barroco](https://github.com/barroco) (EBU)

## Copyright & license

Copyright (c) 2015-2016, EBU-UER Technology & Innovation

The code is under BSD (3-Clause) License. (see LICENSE)
