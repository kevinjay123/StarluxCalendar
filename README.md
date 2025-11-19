# StarluxCalendar

[![Swift](https://img.shields.io/badge/swift-5.8-brightgreen.svg)](https://developer.apple.com/swift/)
[![SwiftUI](https://img.shields.io/badge/-SwiftUI-ff69b4)](https://developer.apple.com/documentation/swiftui)
![iOS 18](https://img.shields.io/badge/-iOS%2018-blue)
[![The Composable Architecture](https://img.shields.io/badge/-TCA-blue)](https://developer.apple.com/ios/)
[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)](https://en.wikipedia.org/wiki/MIT_License)

A modern SwiftUI project for flight date and price calendar selection, built with the Composable Architecture (TCA) and best practices for scalable state management and API integration.

![image](https://github.com/kevinjay123/StarluxCalendar/blob/main/Image/all.png)

## Framework Versions
- The Composable Architecture (TCA) version: **1.23.1**
- iOS minimum deployment target: **18.4**

## Technology Stack

### The Composable Architecture (TCA)

This project fully adopts [TCA](https://github.com/pointfreeco/swift-composable-architecture) emphasizing unidirectional data flow with State-Action-Reducer pattern. All UI, networking, navigation, and modal sheets are managed by TCA, featuring:

- **Clear State Flow**: All pages and modals such as airport list, date picker, and cabin selection are driven by TCA State.
- **Separated Reducers**: Each feature (e.g. YearMonthPicker, CabinFeature) has independent reducer, easy to test and extend.
- **@Presents Modal Management**: Sheet/modals use the latest TCA `@Presents` and `PresentationAction` for simplified UI complexity.
- **StackState Navigation**: Nested navigation stacks like calendar details managed by TCA StackState.

### SwiftUI Visual Design

- **LazyVGrid Calendar Layout**: Dynamic monthly calendar grid showing date, price, and status (highest price in red, lowest in green, others in blue). Text auto-scales to fit a single line.
- **Custom Month/Year Selector UI**: Year and month picker modals driven and controlled by TCA.

### Network/API Management

- **Enum Config for APIs**: Centralized API URL, method, headers, and body configuration using enum.
- **Dependency Injection for Network Layer**: Network services injected via DependencyKey, enabling easy mocking and unit testing.

### Unit Testing with TestStore

- Comprehensive tests on each reducer covering modal interactions, city swapping, API loading, and navigation stack pushing.
- Strict TCA modal action/state clearing order to ensure stable and precise tests.

## Installation
To get started with the project:
1.	**Fetch the repository using Git:**

```bash
git clone https://github.com/kevinjay123/StarluxCalendar.git
cd StarluxCalendar
```

2.	**Build and run the project:** 

    Open `StarluxCalendar.xcodeproj` in Xcode, then build and run it on a simulator or device running iOS 18.4 or later.
