# 🌍 POCKET WORLD: THE 90-DAY ENGLISH LEARNING GAME
## 📜 Master Game Design, Architecture & Rulebook (കോഡ് & ഗെയിം റൂൾ ബുക്ക്)

> **Core Philosophy**: *"Game with Education"* — transforming everyday learners into flawlessly confident, fluent English speakers (public speaking, executive interviews, boardroom negotiations, forensic debate, and native conversational ease) within 90 days.

---

## 🏛️ 1. The World & The English Home (പോക്കറ്റ് വേൾഡും ഇംഗ്ലീഷ് ഹോമും)

1. **The Living Neighborhood**:
   - Every learner in Pocket Mates owns a personalized virtual **English Home** on the 2D parallax street of Pocket World.
   - The street is populated by real peers and AI neighbors matching the player's level bracket (+1 to +3 levels higher for combat growth).
   - In Pocket World, **English is the universal currency and language**.

2. **House Health (HP) & Vault Coins**:
   - Each English Home begins with **100 HP**.
   - Vault Coins represent accumulated economic and learning rewards.
   - When an attacker breaches a house, **45 coins** (or 20% of the vault) are looted, and the house suffers damage.
   - Homeowners can repair damaged walls using their activity points or earned coins.

---

## 🛡️ 2. Home Defense Architecture (ഹോം ഡിഫൻസ് നിയമങ്ങൾ)

1. **Simplified Terminology**:
   - Complex/academic jargon like *"Citadel Defense Shield"* has been replaced with simple, clean **"Home Defense"** so learners immediately understand their objective.

2. **The Golden Rule: 1 Day = 1 Defense Question Slot**:
   - **Day 1**: Exactly 1 defense trap question slot.
   - **Day 10**: 10 defense trap question slots (Gate 1 full).
   - **Day 50**: 50 defense trap question slots (5 Gates full).
   - **Day 90**: 90 defense trap question slots distributed across all **9 Gates** (exactly 10 questions per gate).

3. **The 9 Defense Challenge Gates**:
   - **Gate 1 (Days 1–10)**: `vocab_gate` (Vocabulary Synonyms & Antonyms)
   - **Gate 2 (Days 11–20)**: `grammar_sentry` (Subject-Verb Agreement, Pronoun Reference)
   - **Gate 3 (Days 21–30)**: `tense_fortress` (Past Modals, Conditionals & Passive Voice)
   - **Gate 4 (Days 31–40)**: `syntax_wall` (Inversion, Cleft Sentences & Parallelism)
   - **Gate 5 (Days 41–50)**: `idiom_maze` (Native Idioms & Metaphors)
   - **Gate 6 (Days 51–60)**: `rhetoric_bastion` (Chiasmus, Antithesis, Oratorical Triads)
   - **Gate 7 (Days 61–70)**: `fallacy_redoubt` (Spotting Logical Fallacies & Counter-Arguments)
   - **Gate 8 (Days 71–80)**: `executive_sanctum` (STAR Interview, Negotiation & Crisis Management)
   - **Gate 9 (Days 81–90)**: `sovereign_citadel` (Sovereign Accords & Universal Statecraft)

4. **Self-Built Defense (No Fake/Pre-filled Player Traps)**:
   - Players start with empty defense slots; they must manually craft, arm, and customize their own English challenge traps based on daily lessons.
   - If an attacker raids a neighbor who hasn't finished arming all slots, the system loads authentic curated traps so the raid is always rigorous and educational.

5. **Diverse Interactive Game Formats**:
   - Standard 4-Option Multiple Choice
   - **Word Scramble**: Unscrambling high-frequency letters under pressure
   - **Sentence Jigsaw**: Re-arranging jumbled sentence tokens in proper syntax order
   - **Spot the Error**: Pinpointing the grammatically flawed segment in a 4-part sentence

6. **Anti-Duplicate Rule**:
   - Players cannot arm identical or near-duplicate questions; normalized text checks enforce creative variety across gates.

---

## ⚔️ 3. Battle Arena Raids (റെയ്ഡ് അറ്റാക്ക് നിയമങ്ങൾ)

1. **Direct Attack (No Doorbell Delay)**:
   - As per audio directive: *"റിംഗ് ബെൽ അടിക്കേണ്ട ആവശ്യമൊന്നുമില്ല, അറ്റാക്ക് എന്ന് പറഞ്ഞു ചെയ്യുക"* (No ringing doorbell required; direct and immediate action).
   - Players tap **RAID / ATTACK** on a house to enter the **Battle Arena**.

2. **Raid Unlock Level**:
   - Raids unlock at **Level 4**, after players complete Days 1–3 foundational English missions and arm their initial Home Defense.

3. **Daily Attack Limit**:
   - Maximum **2 attacks per day** (`kMaxAttacksPerDay = 2`) to ensure focused, deliberate learning rather than mindless spamming.

4. **Escalated Combat Growth Matchmaking**:
   - Attackers are matched with houses **+1 to +3 levels higher** (e.g. Level 4 attacker matches with Level 5 or 6).
   - Challenging higher houses provides genuine pressure and yields **+50 Bonus Coins** on successful breach.

5. **Attacker Lifelines by Level Bracket**:
   - **Days 1–24**: 0 lifelines (pure skill required).
   - **Days 25–49**: 1 lifeline (50-50 elimination).
   - **Days 50–79**: 2 lifelines (50-50 + Time Freeze).
   - **Days 80–90**: 3 lifelines (50-50 + Time Freeze + Hint).

6. **Target Cooldown**:
   - A target house cannot be attacked again by the same player within **24 hours** (`kAttackCooldownHours = 24`).

---

## 🤖 4. Pocket Robo Fallback Matchmaker (പോക്കറ്റ് റോബോ)

1. **Guaranteed Opponents**:
   - When a player reaches advanced levels (e.g., Day 18, Day 35, Day 50) where few or no real human peers exist yet on that server, the game **NEVER stalls or displays empty streets**.
2. **Pocket Robo AI Defender**:
   - Automatically generates a `PocketNeighbor` (`isPocketRobo = true`, avatar `🤖`, rank `Robo Home Guardian`) calibrated precisely to the player's level bracket.
   - Equipped with curated, authentic English defense questions matching that level's exact curriculum.
   - Victorious attacks against Pocket Robo reward coins, trophies, and full mission progress.

---

## 👮‍♂️ 5. 48-Hour Presidential Police Protection (പ്രസിഡൻഷ്യൽ പ്രൊട്ടക്ഷൻ)

1. **Automatic Breach Trigger**:
   - When a house's defense is breached in a raid (`processRaidBreach`), it automatically enters **48-Hour Presidential Police Protection** (`isUnderPresidentialProtection = true`).
2. **Police Guard Stationed**:
   - The house displays a police barrier badge (`👮‍♂️ Under 48-Hour Presidential Police Protection`) and remaining recovery time.
   - Opponents cannot attack this house while protected.
3. **Rebuild & Recovery**:
   - The homeowner can calmly repair HP, re-arm defense traps with newly learned grammar, and restore their house without suffering back-to-back griefing attacks.

---

## ⚖️ 6. President Call & Anti-Cheat Decrees (പ്രസിഡന്റ് കോൾ & ചീറ്റ് ബാങ്ക്)

1. **President Call (പ്രസിഡന്റ് കോൾ)**:
   - If an attacker encounters an offensive, nonsensical, or ungrammatical defense trap armed by a neighbor, they can file a **President Call**.
   - The house enters **Presidential Inspection** (`under_inspection`).
2. **Presidential Decrees (വിധിപ്രസ്താവം)**:
   - **Warning Notice**: First minor offense warning.
   - **Jail / Suspension**: Repeated low-effort spam.
   - **Demotion**: Level reset.
   - **Asset Confiscation / Banned**: Permanent condemnation of the house.
3. **Rebuild from Scratch**:
   - Banned/condemned players can rebuild their house from Day 1 to re-earn citizenship in Pocket World.

---

## ⚡ 7. Activity-Powered Reinforcements (FDC സിസ്റ്റം)

1. **Earn Activity Points**:
   - Voice Calls, WhatsApp group chats, Vibe interactions, and daily mission drills award **Fortress Defense Credits (FDC)**.
2. **Iron Dome Defense**:
   - Players can activate an **Iron Dome** using their earned activity points.
   - If breached while Iron Dome is active, the dome completely absorbs the attack: **0 HP damage, 0 coins looted**, and the dome is consumed.

---

## 📈 8. The 90-Day Progressive Curriculum Roadmap (90 ദിവസത്തെ സിലബസ്)

- **Days 1–10**: Foundations of Spoken English, Active Listening & Habit Formation
- **Days 11–18**: Rhetorical Cohesion, Conversational Softeners, Cleft Focus & Parallelism
- **Days 19–28**: Workplace Fluency, Executive STAR Interviews, Salary Negotiations & Crisis Management
- **Days 29–38**: Forensic Cross-Examination, Logical Fallacy Neutralization, Technical Demystification & Sovereign Accords
- **Days 39–50**: Geopolitical Strategy, High-Stakes Investor Keynotes, Corporate M&A, Diplomatic Protocol & Media Mastery
- **Days 51–65**: Advanced Sociolinguistic Registers, Constitutional Jurisprudence & Cross-Cultural Dialectics
- **Days 66–80**: Forensic Dialectics, Planetary Governance, Public Policy & Crisis Leadership
- **Days 81–90**: Sovereign Mastery, Universal Oratorical Fluency, Imperial Capstone & VIP Master Certification
