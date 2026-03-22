# Food Tracker

SwiftUI iOS app for logging meals and tracking **calories and macros** (protein, carbs, fat). It supports **per-meal sections** (breakfast, lunch, dinner, snacks), a **history** view, and a **profile** with BMR-based calorie targets using the Mifflin–St Jeor equation.

---

## Features

| Area | What you get |
|------|----------------|
| **Today** | Pick a date, see daily totals, macro breakdown, meals, and logged items (with delete). |
| **Add food** | Search foods, set amount in grams, pick meal type; macros scale from per-100g values. |
| **History** | Weekly / monthly summaries and per-day detail. |
| **Profile** | Name, gender, weight, height, age, activity level; BMR and macro targets (manual or calculated). |
| **Storage** | All entries and profile persist in **UserDefaults** on device. |

---

## Requirements

- **Xcode** 16.2+ (project last opened with Xcode 26.2 toolchain; use a current Xcode that matches your SDK).
- **iOS** deployment target **18.5** (see target build settings in Xcode).
- **Swift** 5 (as set in the project).

No Swift Package Manager dependencies are required; the app uses system frameworks only.

---

## Project layout

Open the Xcode project from the repository root:

```text
FoodTrackerApp/
├── FoodTrackerApp.xcodeproj          ← open this in Xcode
└── FoodTrackerApp/                   ← source folder (synced with the project)
    ├── FoodTrackerAppApp.swift       ← @main entry, hosts MainTabView
    ├── Models/                       ← Food, FoodEntry, User, Product, API DTOs
    ├── Views/                        ← SwiftUI screens + Components
    ├── ViewModels/                   ← FoodTrackerViewModel
    ├── Managers/                     ← NutritionAPIManager, APIServices
    ├── Storage/                      ← FoodStorage (UserDefaults)
    ├── Design/                       ← DesignSystem
    └── Resources/
        └── products.json             ← bundled product list (offline / fallback)
```

**Architecture:** MVVM with SwiftUI; async network calls use Swift concurrency (`async`/`await`). The main `FoodTrackerViewModel` is created in `MainTabView` and shared across tabs.

---

## Run the app

1. Clone or copy the project.
2. In Terminal (from the folder that contains `FoodTrackerApp.xcodeproj`):

   ```bash
   open FoodTrackerApp.xcodeproj
   ```

3. Select an **iPhone simulator** or a **physical device**, then run (**⌘R**).

### Optional: local product API

`APIServices` loads products from:

- **`GET http://localhost:8000/products`** — JSON array matching the `Product` model (`id`, `name`, `calories`, `protein`, `fat`, `carbs` as in `Models/Product.swift`).

If the request fails (server down, wrong URL, or device cannot reach `localhost`), the app **falls back** to **`Resources/products.json`** in the bundle.

- **Simulator:** `http://localhost:8000` usually works for a server running on your Mac.
- **Physical device:** replace `localhost` with your Mac’s LAN IP (e.g. `http://192.168.1.10:8000`) in `Managers/APIServices.swift` (`baseURL`), and ensure **App Transport Security** allows plain HTTP if you stay on `http://`.

---

## How food search works

`NutritionAPIManager.searchFoods(query:)` tries sources in order:

1. **`APIServices`** — fetch products (server or bundled JSON), then **client-side filter** by query.
2. **BusyBody-style HTTP API** — multiple candidate base URLs and paths are probed; responses are decoded into app `Food` models.
3. **Built-in example foods** — small static list if nothing else returns results.

So the app works **offline** for search as long as `products.json` (or examples) can satisfy the query.

---

## Configuration and security

- **Do not commit real API keys.** If you use the BusyBody (or any external) integration, set **`apiKey`** in `Managers/NutritionAPIManager.swift` to your own key (or refactor to read from a local xcconfig / environment that is gitignored).
- **`Managers/APIServices.swift`** — adjust **`baseURL`** if your backend is not on `localhost:8000`.

---

## Data model and persistence

| Key | Purpose |
|-----|---------|
| `food_entries` | Encoded `[FoodEntry]` — all logged meals. |
| `user_profile` | Encoded `User` — profile and targets. |

Implemented in `Storage/FoodStorage.swift`; saves run when entries or profile change.

---

## UI / design

Shared styling lives in `Design/DesignSystem.swift` (colors, typography, cards). Macros use consistent color coding (e.g. protein / carbs / fat / calories) in the tracker and history flows.

---

## Tabs (user-facing)

1. **Today** — daily log and progress.  
2. **History** — past ranges and stats.  
3. **Profile** — body metrics, activity, BMR-related targets.

---

## BMR and targets

BMR uses **Mifflin–St Jeor**, then applies an **activity multiplier** from `User.activityLevel`. Macro targets can be **manual** or **derived** from BMR and weight (see computed properties on `User` in `Models/User.swift`).

---

## Troubleshooting

| Issue | What to check |
|--------|----------------|
| Empty search on device | Server URL in `APIServices`; use machine IP instead of `localhost` on a real phone. |
| No products from server | Backend returns 200 and JSON matching `Product`; otherwise bundle JSON is used. |
| External API never hits | BusyBody base URL / path / key may not match your provider; check Xcode console logs. |

---

## License

Provided for educational use unless you add your own license.
