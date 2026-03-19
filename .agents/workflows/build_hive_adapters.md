---
description: Build Hive adapters for offline chat
---

1. Open a terminal in the project root.
2. Run the following command to generate Hive type adapters:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   // turbo
3. Verify that the `*.g.dart` files are created under `lib/custom_code/widgets/chat/`.
4. Re‑run the app to ensure the offline cache works.
