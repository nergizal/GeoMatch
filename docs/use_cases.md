# Use Case Analysis - GeoMatch

## 1. Actors
- **Primary Actor:** Player (Uygulamayı oynayan kullanıcı)
- **Secondary System:** Local Storage Engine (Cihaz içi kalıcı veri deposu)

## 2. Use Case Diagram

```text
+-------------------------------------------------------------------+
|                         GeoMatch System                           |
|                                                                   |
|   (UC-01: Start Quiz Session)                                     |
|          |                                                        |
|          +---> <<include>> (UC-02: Select Mode & Difficulty)      |
|          |                                                        |
|          v                                                        |
|   (UC-03: Answer Question) <---+                                  |
|          |                     | (Loop 10 times)                  |
|          +---> <<extend>> (UC-04: Handle Timeout - Expert Mode)   |
|          |                                                        |
|          v                                                        |
|   (UC-05: View Session Results & Save Progress)                   |
|                                                                   |
|   (UC-06: View Statistics & Achievements)                         |
|   (UC-07: Configure App Settings)                                 |
+-------------------------------------------------------------------+
         ^                                         ^
         |                                         |
     [Player]                           [Local Storage Engine]