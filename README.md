# CyphlensSSE

[![CI Status](https://img.shields.io/travis/24449613/CyphlensSSE.svg?style=flat)](https://travis-ci.org/24449613/CyphlensSSE)
[![Version](https://img.shields.io/cocoapods/v/CyphlensSSE.svg?style=flat)](https://cocoapods.org/pods/CyphlensSSE)
[![License](https://img.shields.io/cocoapods/l/CyphlensSSE.svg?style=flat)](https://cocoapods.org/pods/CyphlensSSE)
[![Platform](https://img.shields.io/cocoapods/p/CyphlensSSE.svg?style=flat)](https://cocoapods.org/pods/CyphlensSSE)

A lightweight iOS SDK designed to simplify 2FA authentication with Cyphlens' Server-Sent Events (SSE) integration. The SDK establishes an SSE connection, listens for authentication events from the backend, and notifies the host application about the current authentication status via callbacks.

## Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 14.0+

## Installation

### CocoaPods

CyphlensSSE is available through [CocoaPods](https://cocoapods.org). To install it, add the following to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
pod 'CyphlensSSE'
end
```

Then run:

```bash
pod install
```

### Swift Package Manager

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/cyphlens/cyphlens-ios-sse-sdk", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Packages...
2. Enter the repository URL: `https://github.com/cyphlens/cyphlens-ios-sse-sdk.git`
3. Select the version you want to use

## Quick Start

```swift
import CyphlensSSE

// Initialize Cyphlens (defaults to .production environment)
let cyphlens = Cyphlens()

// Optionally set environment (defaults to .production)
cyphlens.setEnvironment(.production) // or .sandbox

// Start listening for events
cyphlens.listen(
    sessionId: "your-session-id",
    onData: { eventType, event in
        switch eventType {
        case .mfaSwipe:
            if let mfaEvent = event as? TwoFactorEvent {
                print("Status: \(mfaEvent.status)")
            }
        case .disconnect:
            if let disconnectEvent = event as? DisconnectEvent {
                print("Disconnected: \(disconnectEvent.message)")
            }
        }
    },
    onError: { error in
        print("Error: \(error.localizedDescription)")
    }
)

// Stop listening when done
cyphlens.stop()
```

## API Documentation

### Classes

#### `Cyphlens`

The main class for managing Server-Sent Events (SSE) connections for 2FA authentication.

**Initialization:**

```swift
init()
```

The SDK initializes with `.production` environment by default. Use `setEnvironment(_:)` to change it before starting to listen.

**Methods:**

##### `listen(sessionId:onData:onError:)`

Starts listening for authentication events.

```swift
func listen(
    sessionId: String,
    onData: EventCallback? = nil,
    onError: CyphlensErrorCallback? = nil
)
```

**Parameters:**
- `sessionId`: The session ID used for authentication (provided by your backend)
- `onData`: Optional callback function for handling successful authentication events
  - Closure signature: `(EventType, CyphlensEvent) -> Void`
- `onError`: Optional callback function for handling errors
  - Closure signature: `(Error) -> Void`

**Example:**

```swift
cyphlens.listen(
    sessionId: "0b883083541a49d896367202ed80fc1e",
    onData: { eventType, event in
        // Handle events
    },
    onError: { error in
        // Handle errors
    }
)
```

##### `stop()`

Stops the SSE connection and clears any active timeouts.

```swift
func stop()
```

**Example:**

```swift
cyphlens.stop()
```

##### `setEnvironment(_:)`

Updates the environment for the SDK.

```swift
func setEnvironment(_ environment: CyphlensEnvironment)
```

**Parameters:**
- `environment`: The new environment (`.sandbox` or `.production`)

**Example:**

```swift
cyphlens.setEnvironment(.sandbox)
```

### Types

#### `CyphlensEnvironment`

An enum representing the API environment.

**Cases:**
- `.sandbox`: Sandbox environment
- `.production`: Production environment (default)

**Example:**

```swift
let cyphlens = Cyphlens()
cyphlens.setEnvironment(.sandbox)
```

#### `EventType`

An enum representing the type of SSE event received.

**Cases:**
- `.mfaSwipe`: MFA swipe authentication event
- `.disconnect`: Disconnect event

**Example:**

```swift
switch eventType {
case .mfaSwipe:
    // Handle MFA swipe event
case .disconnect:
    // Handle disconnect event
}
```

#### `StatusType`

An enum representing the authentication status.

**Cases:**
- `.pending`: Authentication is pending
- `.success`: Authentication was successful
- `.expired`: Authentication has expired

**Example:**

```swift
switch mfaEvent.status {
case .pending:
    print("Waiting for authentication...")
case .success:
    print("Authentication successful!")
case .expired:
    print("Authentication expired")
}
```

#### `TwoFactorEvent`

A struct representing a two-factor authentication event.

**Properties:**
- `sessionId: String` - The session ID associated with the event
- `status: StatusType` - The current authentication status
- `timestamp: Int64` - Event timestamp in milliseconds
- `expiresAt: Int64?` - Optional expiration timestamp in milliseconds

**Example:**

```swift
if let mfaEvent = event as? TwoFactorEvent {
    print("Session ID: \(mfaEvent.sessionId)")
    print("Status: \(mfaEvent.status)")
    print("Timestamp: \(mfaEvent.timestamp)")
    if let expiresAt = mfaEvent.expiresAt {
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(expiresAt / 1000))
        print("Expires at: \(expirationDate)")
    }
}
```

#### `DisconnectEvent`

A struct representing a disconnect event.

**Properties:**
- `message: String` - The disconnect message

**Example:**

```swift
if let disconnectEvent = event as? DisconnectEvent {
    print("Disconnected: \(disconnectEvent.message)")
}
```

#### `CyphlensEvent`

A protocol that all Cyphlens events conform to. Currently implemented by:
- `TwoFactorEvent`
- `DisconnectEvent`

### Type Aliases

#### `EventCallback`

Callback type for handling successful events.

```swift
typealias EventCallback = (EventType, CyphlensEvent) -> Void
```

#### `CyphlensErrorCallback`

Callback type for handling errors.

```swift
typealias CyphlensErrorCallback = (Error) -> Void
```

## Usage Examples

### Basic Usage

```swift
import UIKit
import CyphlensSSE

class ViewController: UIViewController {
    private var cyphlens: Cyphlens?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize with default environment (.production)
        cyphlens = Cyphlens()
        
        // Optionally set a different environment
        // cyphlens?.setEnvironment(.sandbox)
    }
    
    func startListening(sessionId: String) {
        // Initialize with default environment (.production)
        cyphlens = Cyphlens()
        
        // Optionally set environment before listening
        // cyphlens?.setEnvironment(.sandbox)
        
        cyphlens?.listen(
            sessionId: sessionId,
            onData: { [weak self] eventType, event in
                DispatchQueue.main.async {
                    self?.handleEvent(eventType: eventType, event: event)
                }
            },
            onError: { [weak self] error in
                DispatchQueue.main.async {
                    self?.handleError(error)
                }
            }
        )
    }
    
    func handleEvent(eventType: EventType, event: CyphlensEvent) {
        switch eventType {
        case .mfaSwipe:
            if let mfaEvent = event as? TwoFactorEvent {
                switch mfaEvent.status {
                case .pending:
                    print("Authentication pending...")
                case .success:
                    print("✅ Authentication successful!")
                case .expired:
                    print("⏰ Authentication expired")
                }
            }
        case .disconnect:
            if let disconnectEvent = event as? DisconnectEvent {
                print("Disconnected: \(disconnectEvent.message)")
            }
        }
    }
    
    func handleError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func stopListening() {
        cyphlens?.stop()
    }
    
    deinit {
        cyphlens?.stop()
    }
}
```

### Switching Environments

```swift
// Initialize (defaults to .production)
let cyphlens = Cyphlens()

// Set to sandbox
cyphlens.setEnvironment(.sandbox)

// Switch to production later
cyphlens.setEnvironment(.production)
```

### Handling Timestamps

```swift
if let mfaEvent = event as? TwoFactorEvent {
    // Convert milliseconds to Date
    let eventDate = Date(timeIntervalSince1970: TimeInterval(mfaEvent.timestamp / 1000))
    print("Event occurred at: \(eventDate)")
    
    if let expiresAt = mfaEvent.expiresAt {
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(expiresAt / 1000))
        print("Expires at: \(expirationDate)")
    }
}
```

## Example Project

To run the example project, clone the repo and run:

```bash
cd Example
pod install
```

Then open `CyphlensSSE.xcworkspace` in Xcode.

### Troubleshooting Network Issues

- **403 Forbidden Error**: Check that your session ID is valid and has proper permissions
- **Connection Timeout**: Verify network connectivity and that the server endpoints are accessible
- **SSL/TLS Errors**: Ensure the server has valid SSL certificates. For development, you may need ATS exceptions
## Importing the Framework

To use the `CyphlensSSE` SDK in your project, ensure the `.xcframework` is added to your target’s **Frameworks, Libraries, and Embedded Content** section in Xcode.

Your setup should look like this:

![Framework Add Screenshot](.framework_embeded.png)

- **CyphlensSSE.xcframework** should be set to "Embed & Sign".
- If you see "**Pods_CyphlensSSE_Example.framework**", it is managed by CocoaPods and does not need embedding.

If you have not imported the framework yet, follow these steps:
1. In Xcode, select your project in the Project Navigator.
2. Select your app target.
3. Go to the **General** tab.
4. Scroll down to **Frameworks, Libraries, and Embedded Content**.
5. Click the `+` button and add `CyphlensSSE.xcframework`.
6. Make sure the "Embed" option is set to **Embed & Sign**.

> **Note:** If you're distributing your app, always use "Embed & Sign" for xcframeworks.
  
You are now ready to import and use CyphlensSSE in your code:

```swift
import CyphlensSSE
```


## Important Notes

- The SDK automatically handles reconnection when the app comes back to the foreground
- Always call `stop()` when you're done listening to clean up resources
- The session ID should be obtained from your backend API
- Timestamps are in milliseconds (Unix epoch)

## Author

Cyphlens, support@cyphlens.com

## License

CyphlensSSE is available under the ISC license. See the LICENSE file for more info.
