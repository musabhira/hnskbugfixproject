# WebRTC Implementation for PocketMates

## Overview
Successfully migrated from PeerJS + InAppWebView to native **flutter_webrtc** package for direct peer-to-peer video/audio calling.

## Architecture

### 1. **WebRTCMatchingService** (`webrtc_matching_service.dart`)
- Handles user matching via Supabase Realtime
- Manages WebRTC peer connections
- Implements offer/answer exchange (SDP negotiation)
- Handles ICE candidate exchange for NAT traversal
- Supports Video, Voice, and Text modes

### 2. **WebRTCSessionScreen** (`webrtc_session_screen.dart`)
- Native Flutter UI with RTCVideoRenderer widgets
- Real-time video/audio display
- Control buttons (mute, video toggle, end call)
- Text chat interface for text-only mode
- Status overlays and connection indicators

## How It Works

### Connection Flow (Omegle-style)
```
User A                          Supabase Realtime                    User B
------                          -----------------                    ------
1. Join lobby_video     ────►   Match users          ◄────          Join lobby_video
2. Create session channel ◄──── Create session ID   ────►           Create session channel
3. Initialize WebRTC                                                 Initialize WebRTC
4. Create Offer         ────►   Signal: offer        ────►          Receive Offer
5. Collect ICE          ────►   Signal: ice_candidate ────►         Add ICE candidate
6. Receive Answer       ◄────   Signal: answer       ◄────          Create Answer
7. Direct P2P Connection Established (no server in between)
8. Video/Audio streams flow directly between devices
```

### Key Components

#### STUN Servers (FREE - Google's Public STUN)
```dart
'iceServers': [
  {'urls': 'stun:stun.l.google.com:19302'},
  {'urls': 'stun:stun1.l.google.com:19302'},
  {'urls': 'stun:stun2.l.google.com:19302'},
  {'urls': 'stun:stun3.l.google.com:19302'},
  {'urls': 'stun:stun4.l.google.com:19302'},
]
```

#### Signaling via Supabase
- **Lobby Channel**: `lobby_{mode}` - for matching users
- **Session Channel**: `session_{mode}_{userId1}_{userId2}` - for WebRTC signaling
- **Events**:
  - `webrtc_signal`: SDP offers/answers and ICE candidates
  - `message`: Text chat messages
  - `disconnect`: User left notification

## Features

### ✅ Implemented
- [x] Video calling with local/remote video display
- [x] Voice calling (audio-only mode)
- [x] Text chat mode
- [x] Mute/unmute audio
- [x] Toggle video on/off
- [x] Auto-reconnect on stranger disconnect
- [x] Free STUN servers (no cost)
- [x] Direct P2P (no bandwidth cost)
- [x] Native Flutter widgets (no WebView)

### 🔄 How to Test

#### On Two Phones:
1. Deploy to Firebase Hosting (already done)
2. Open `https://pocketmates.web.app` on both phones
3. Navigate to PocketMates → Video Call
4. Grant camera/microphone permissions
5. Both users will auto-match and connect

#### On Desktop + Phone:
1. Run `flutter run -d chrome` on desktop
2. Open deployed app on phone
3. Both select same mode (Video/Voice/Text)
4. Connection establishes automatically

## Technical Details

### Dependencies
```yaml
flutter_webrtc: ^1.2.1  # Latest version for web compatibility
supabase_flutter: 2.9.0  # For signaling
```

### Permissions Required
- **Android**: `CAMERA`, `RECORD_AUDIO`, `INTERNET`
- **iOS**: `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`
- **Web**: Browser prompts automatically

### WebRTC vs PeerJS Comparison

| Feature | PeerJS (Old) | flutter_webrtc (New) |
|---------|-------------|---------------------|
| Platform | Web-only (via WebView) | Native (iOS/Android/Web) |
| Performance | Slower (JS bridge) | Faster (native) |
| Bundle Size | +HTML/JS files | Pure Dart |
| Debugging | Console logs in WebView | Native Flutter debugging |
| Maintenance | External dependency | Official Flutter plugin |

## Cost Analysis

### FREE Components:
- ✅ Google STUN servers (unlimited)
- ✅ Supabase Realtime (signaling only, minimal data)
- ✅ Firebase Hosting (static files)
- ✅ WebRTC P2P (direct device-to-device)

### Potential Costs (if needed):
- ❌ TURN server (only if users behind strict firewalls)
  - Estimate: $5-10/month for small VPS (Coturn)
  - Most users won't need this (STUN works 80%+ of time)

## Next Steps

1. **Test on Real Devices**: Deploy and test video quality
2. **Add TURN Fallback** (optional): For corporate networks
3. **Implement Reporting**: Block/report abusive users
4. **Add Filters**: Interest-based matching
5. **Analytics**: Track connection success rates

## Files Modified
- ✅ `pubspec.yaml` - Added flutter_webrtc
- ✅ `webrtc_matching_service.dart` - New WebRTC service
- ✅ `webrtc_session_screen.dart` - New session UI
- ✅ `pocket_mates_dashboard.dart` - Updated navigation
- ✅ `index.dart` - Exported new components

## Migration Notes
The old PeerJS implementation files can be safely removed:
- `stranger_matching_service.dart` (replaced by webrtc_matching_service.dart)
- `pocket_mates_session_screen.dart` (replaced by webrtc_session_screen.dart)
- `assets/html/call_ui.html` (no longer needed)

---

**Status**: ✅ Ready for testing on real devices
**Last Updated**: 2026-01-03
