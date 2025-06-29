# ItunesSearch

<p align="center">
  <img src="https://github.com/rdgonzalez85/ItunesSearch/blob/main/demo-itunes_search.gif" alt="animated" />
</p>

**ItunesSearch** is a simple iOS application built with **UIKit** that lets users search for media content using the [Apple iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/).  
Users can enter a search term, browse results, and view details for each item.

---

## Features

- Search the iTunes catalog for music, movies, apps, podcasts, and more.
- Display search results in a clean, scrollable list.
- Tap an item to see detailed information.
- Uses `URLSession` with Combine for reactive networking.

---

## Tech Stack

- **Language:** Swift
- **Framework:** UIKit
- **Networking:** `URLSession`
- **Reactive Programming:** Combine
- **Architecture:** MVVM (Model-View-ViewModel)

---

## Getting Started

### Requirements

- Xcode 14 or later
- iOS 15 or later

### Installation

1. Clone the repository:
```bash
   git clone https://github.com/rdgonzalez85/ItunesSearch.git
```
2. Open the project in Xcode:
```bash
  open ItunesSearch.xcodeproj
```
3. Build & run on a simulator or physical device.

## Project Structure
- Models: Data models for iTunes API results.
- ViewModels: Business logic and API calls.
- Views / ViewControllers: UIKit views and navigation.
- Services: Networking layer for fetching data.

## TODO / Possible Improvements
- Implement pagination for large result sets.
- Improve error handling and display user-friendly messages.

## License
This project is open source under the MIT License.

