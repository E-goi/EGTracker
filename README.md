# EGTracker

[![Version](https://img.shields.io/cocoapods/v/EGTracker.svg?style=flat)](http://cocoapods.org/pods/EGTracker)
[![License](https://img.shields.io/cocoapods/l/EGTracker.svg?style=flat)](http://cocoapods.org/pods/EGTracker)
[![Platform](https://img.shields.io/cocoapods/p/EGTracker.svg?style=flat)](http://cocoapods.org/pods/EGTracker)

## Usage

This Library allows the user to track events from his iOS Apps to the E-Goi server.

## Requirements

## Installation

EGTracker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EGTracker", '~> 0.1.0'
```

To use just configure the parameters and start tracking events:

```
import EGTracker

// Events struct (Suggestion)
struct EGEvents {
static let appOpen = "APP_OPEN"
static let eventButton = "EVENT_BUTTON"
static let viewHome = "VIEW_HOME"
}
```

Then in your AppDelegate in the didFinishLaunchingWithOptions add:

```
// Init the tracker
EGTracker.sharedInstance.initEngine()

// Configure with E-Goi information about your App
EGTracker.sharedInstance.url = "http://myappname.ios"
EGTracker.sharedInstance.clientID = 1234
EGTracker.sharedInstance.listID = 2143
EGTracker.sharedInstance.idsite = 4321
EGTracker.sharedInstance.subscriber = "mysubscriber@email.com"

// Track App Open
EGTracker.sharedInstance.trackEvent(EGEvents.appOpen)
```

## Author

Miguel Chaves, mchaves.apps@gmail.com

## License

Copyright (c) 2016 Miguel Chaves <mchaves.apps@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
