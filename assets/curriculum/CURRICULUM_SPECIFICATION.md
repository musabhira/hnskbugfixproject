# 📘 Pocket Mates 90-Day Spoken English Master Curriculum Specification

> **Official Blueprint & Architecture Document**  
> **Directory:** `assets/curriculum/`  
> **Target Audience:** All Learners (Zero Foundation, Core Middle, Higher Fluency) & Development Team  
> **Version:** 2.0 (100% Modular JSON, Zero Placeholders)

---

## 🌟 1. Overview & Core Philosophy

**Pocket Mates 90-Day English Game** is a gamified, habit-forming spoken English journey designed specifically for South Asian learners (with native Malayalam, Hindi, and Tamil localized support).

### 🎯 Key Principles
1. **One Day, One Main English Topic:** No overwhelming textbook grammar. Each day teaches exactly **one golden formula**, practiced immediately through gameplay.
2. **Three Parallel Tracks from Day 1:** 
   - Every learner starts at **Day 1**, but the content dynamically adapts to their ability:
     - 🌱 **Zero Foundation:** Audio-first, phonics, AI Robot voice practice, zero stranger calls until Day 10.
     - 🗣️ **Core Middle:** Sentence building patterns, routine & past tenses, rapid reflex speech, full multiplayer from Day 1.
     - 🚀 **Higher Fluency:** Expressive idioms, nuance, debate, professional interviews, leadership finesse from Day 1.
3. **100% Modular JSON Driven:** Every day's curriculum is a self-contained JSON file (`day_1_curriculum.json` to `day_90_curriculum.json`). Anyone can inspect or update content without editing Dart code.

---

## 🏛️ 2. The 3-House Progressive Structure (90 Days)

```
┌────────────────────────────────────────────────────────────────────────┐
│ 🟢 HOUSE 1: Foundation & Daily Living (Days 1–30)                      │
│    • Level: CEFR A1 → A2                                               │
│    • Focus: Am/Is/Are, Phonics, Daily Routines, Family, Home, Food,     │
│             Directions, 150 Core Survival Words, Simple Present V1.    │
│    • Milestone: Day 30 House 1 Gate Exam 🏆                           │
├────────────────────────────────────────────────────────────────────────┤
│ 🔵 HOUSE 2: Real-World Social & Time Travel (Days 31–60)               │
│    • Level: CEFR A2 → B1                                               │
│    • Focus: Simple Past V2 (Yesterday), Future Plans (Will / Going to),│
│             Modal Verbs (Can, Could, Should, Must), Travel, Shopping,   │
│             Doctor Consultations, Spontaneous Reflex Drills.           │
│    • Milestone: Day 60 House 2 Gate Exam 🏆                           │
├────────────────────────────────────────────────────────────────────────┤
│ 🟣 HOUSE 3: Professional Fluency & Career Mastery (Days 61–90)         │
│    • Level: CEFR B1 → B2/C1                                            │
│    • Focus: Present Perfect (Have/Has + V3), Sentence Connectors,      │
│             Job Interviews (STAR Method), Workplace Meetings, Salary   │
│             Negotiation, Native Phrasal Verbs, Public Speaking.        │
│    • Milestone: Day 90 Grand Graduation & Lifetime Certificate 🎓      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🎮 3. Daily 10-Step Activity Flow (Daily Loop)

Each day contains structured, interactive steps taking **12 to 15 minutes** of focused daily engagement:

```
[Step 1] 🏛️ Concept Room         -> Tutor NPC + 2-Min Golden Formula + Audio
[Step 2] 📦 Vocabulary Vault     -> 4 Verbs (V1, V2, V3) + 5 Nouns (with ML/HI/TA meanings)
[Step 3] 🏃 Game 1: Word Hunt    -> 2D Meadow Runner arcade word collection
[Step 4] 🧩 Game 2: Builder      -> Word Catcher / Falling Word Sentence Constructor
[Step 5] 📖 Reading Room         -> Native Audio Listening + Read Aloud with Mic
[Step 6] 🎙️ Spoken Speech Lab    -> Pronunciation Analyzer & Reflex Speed Scoring
[Step 7] 🛡️ House Defense        -> Install 3 English Grammar Traps to protect fortress
[Step 8] ⚔️ Citadel Attack Raids -> Raid rival houses with English challenges (UNLOCKED DAY 4+)
[Step 9] 🤝 Social Arena         -> English Hub, Random Call, PocketTalk (UNLOCKED DAY 10+ FOR ZERO)
[Step 10] 🎓 Daily Gate Exam     -> 5 Multiple Choice Questions (70% pass threshold to advance)
```

---

## 🔒 4. Unlocking Rules & Game Progression

| Feature | Rule | Rationale |
| :--- | :--- | :--- |
| **Day Unlocking** | Day `N+1` unlocks **only after scoring 70%+ on Day `N` Gate Exam**. | Prevents skipping ahead without mastering current concept. |
| **Citadel Attack Raids** | **Locked Days 1–3**. **Fully Unlocks on Day 4** (`isUnlocked: true`). | Gives players 3 days to build their house defense before raiding others. |
| **Zero Track Social Arena** | **Locked Days 1–9** with **Tutor Robot Voice Practice** fallback. **Unlocks on Day 10**. | Eliminates stranger anxiety for absolute beginners until basic sounds are mastered. |
| **Middle & Higher Social** | **Active from Day 1**. | Intermediate & advanced learners thrive on early live practice. |
| **Retries & Soft Fails** | Mini-games (Steps 3 & 4) have **unlimited retries with hints**. | Ensures positive reinforcement; players never get stuck indefinitely. |

---

## 📊 5. Scoring & Rewards Matrix

* **Daily XP Reward:** 250 XP (Day 1) scaling to 430 XP (Day 90)
* **Daily Coins Reward:** 50 Coins scaling to 140 Coins
* **Daily Streak:** +1 on passing Gate Exam
* **Exam Passing Mark:** **70%** (minimum 4 out of 5 questions correct)
* **Defense Shield:** Each correct trap adds +30 HP to house protection against raids.

---

## 🗂️ 6. JSON Schema Reference (`day_X_curriculum.json`)

Every file follows this exact validated schema:

```json
{
  "course": {
    "day": 35,
    "house": 2,
    "houseTitle": { "en": "...", "ml": "...", "hi": "...", "ta": "..." },
    "version": "day-35-v1",
    "topic": { "en": "Yesterday's Full Story", "ml": "ഇന്നലത്തെ ദിവസത്തിന്റെ വിവരണം" },
    "unlockRule": "Unlocks after Day 34 Exam. Day 36 unlocks after 70%+ score.",
    "passPercentage": 70,
    "totalXpReward": 320,
    "totalCoinsReward": 85
  },
  "grammarRule": {
    "formula": "Time Sequencers: In the morning, Then, Later",
    "explanation": { "ml": "...", "en": "..." },
    "goldenTip": { "ml": "...", "en": "..." }
  },
  "vocabulary": {
    "verbs": [
      {
        "v1": "wake", "v2": "woke", "v3": "woken",
        "meaning": { "ml": "ഉണർന്നു", "hi": "जागना", "ta": "விழி" },
        "example": "Yesterday I woke at 7.",
        "exampleMl": "..."
      }
    ],
    "nouns": [
      {
        "word": "routine",
        "meaning": { "ml": "പതിവ്", "hi": "दिनचर्या", "ta": "வழக்கம்" },
        "example": "A consistent routine builds success."
      }
    ]
  },
  "steps": [
    { "stepNumber": 1, "id": "step_1_concept_room", "gameType": "tutor_concept", "xpReward": 25, "passScore": 100 },
    { "stepNumber": 2, "id": "step_2_vocab_vault", "gameType": "vocab_vault", "xpReward": 30, "passScore": 80 },
    { "stepNumber": 3, "id": "step_3_game_hunt", "gameType": "meadow_runner_hunt", "xpReward": 40, "passScore": 70 },
    { "stepNumber": 4, "id": "step_4_game_builder", "gameType": "word_catcher_builder", "xpReward": 40, "passScore": 80 },
    { "stepNumber": 5, "id": "step_5_reading_room", "gameType": "reading_listening", "xpReward": 35, "passScore": 75 },
    { "stepNumber": 6, "id": "step_6_spoken_lab", "gameType": "speech_analyzer", "xpReward": 35, "passScore": 70 },
    { "stepNumber": 7, "id": "step_7_house_defense", "gameType": "house_defense_trap_builder", "xpReward": 30, "passScore": 100, "traps": [...] },
    { "stepNumber": 8, "id": "step_attack_raids", "gameType": "citadel_attack_raid", "xpReward": 45, "passScore": 100, "attackConfig": { "isUnlocked": true } },
    { "stepNumber": 9, "id": "step_social_arena", "gameType": "social_arena", "xpReward": 30, "passScore": 100, "socialConfig": { ... } },
    { "stepNumber": 10, "id": "step_daily_exam", "gameType": "daily_exam", "xpReward": 50, "passScore": 70, "examQuestions": [...] }
  ]
}
```

---

## 🛠️ 7. Flutter Integration (`pocket_day_curriculum_service.dart`)

The Flutter client accesses the curriculum asynchronously:

```dart
// Load any day dynamically:
final dayData = await PocketDayCurriculumService.loadDayCurriculum(35);

// Resolve localized string with fallback:
final topicTitle = PocketDayCurriculumService.getLocalizedText(
  dayData['course']['topic'],
  lang: 'ml', // 'en', 'hi', 'ta', 'te'
);
```

---

## 📜 8. Maintenance & Content Editing Guide

* To update any day's topic, verbs, exam questions, or defense traps:
  1. Open `assets/curriculum/day_{N}_curriculum.json`.
  2. Edit the plain English/Malayalam/Hindi text.
  3. Save the file.
  4. Changes reflect immediately in app without recompiling Dart code!

---

## 🕹️ 9. The 180-Game Engine Architecture (Fixed Engines, Dynamic Content)

### 📌 Core Architecture Rule
* **Total Game Sessions:** Exactly **180 Game Sessions** (90 Days × 2 Games per day).
* **Game Engines are FIXED & PERMANENT:** Developers do NOT need to code 180 different game systems.
* **Content is 100% DYNAMIC:** The 2 game engines are completely data-driven. When redesigning or updating lessons, **ONLY the JSON content changes**, while the underlying Flame / Flutter game engines remain 100% stable.

### 🏃 Game Engine 1: Meadow Runner Hunt (`meadow_runner_hunt`)
* **Role in Day:** Step 3 (Word & Object Collection)
* **Mechanic:** Fast-paced 2D arcade runner. The player avatar runs through the meadow/town, jumps over obstacles, and collects today's vocabulary items and phonics letters.
* **JSON Contract (Step 3):**
  ```json
  {
    "stepNumber": 3,
    "id": "step_3_game_hunt",
    "gameType": "meadow_runner_hunt",
    "targetObjects": ["Clock", "Bed", "Morning", "Time"],
    "xpReward": 40,
    "passScore": 70
  }
  ```
* **Pass Condition:** Collect at least 70% of target vocabulary items before timer runs out.

### 🧩 Game Engine 2: Sentence Constructor (`word_catcher_builder`)
* **Role in Day:** Step 4 (Active Sentence Formation)
* **Mechanic:** Word tile catcher and grammar unscramble puzzle. Words fall from the top of the screen; the player must catch/tap them in the exact grammatical sequence to construct today's target sentence formula.
* **JSON Contract (Step 4):**
  ```json
  {
    "stepNumber": 4,
    "id": "step_4_game_builder",
    "gameType": "word_catcher_builder",
    "challengePatterns": [
      "I wake up at 6 AM.",
      "I wash my face with water.",
      "We eat breakfast together."
    ],
    "xpReward": 40,
    "passScore": 80
  }
  ```
* **Pass Condition:** Assemble all challenge sentences with at least 80% accuracy.

### 🔄 Future Redesign Workflow
When updating curriculum content in the future:
1. **Never edit Flame/Flutter game engine code.**
2. Open `day_X_curriculum.json`.
3. Update `targetObjects` (for Game 1) or `challengePatterns` (for Game 2).
4. Save the JSON — the game engine automatically plays the new content!

