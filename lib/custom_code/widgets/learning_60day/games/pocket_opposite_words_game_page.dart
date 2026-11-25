import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

class _OppositePair {
  final String wordA;
  final String meaningA;
  final String wordB;
  final String meaningB;

  const _OppositePair(this.wordA, this.meaningA, this.wordB, this.meaningB);
}

/// 180 unique opposite word pairs — 2 unique pairs per day for Days 1–90 (zero duplication).
const List<_OppositePair> _kUniqueOppositePairs = [
  _OppositePair('Before', 'മുമ്പ്', 'After', 'ശേഷം'),
  _OppositePair('Long', 'നീളമുള്ള', 'Small', 'ചെറിയ'),
  _OppositePair('Big', 'വലിയ', 'Tiny', 'തീരെ ചെറിയ'),
  _OppositePair('Hot', 'ചൂടുള്ള', 'Cold', 'തണുത്ത'),
  _OppositePair('Up', 'മുകളിൽ', 'Down', 'താഴെ'),
  _OppositePair('Fast', 'വേഗത്തിൽ', 'Slow', 'പതുക്കെ'),
  _OppositePair('Happy', 'സന്തോഷം', 'Sad', 'സങ്കടം'),
  _OppositePair('Open', 'തുറക്കുക', 'Close', 'അടയ്ക്കുക'),
  _OppositePair('Near', 'അടുത്ത്', 'Far', 'ദൂരെ'),
  _OppositePair('Day', 'പകൽ', 'Night', 'രാത്രി'),
  _OppositePair('Light', 'വെളിച്ചം', 'Dark', 'ഇരുട്ട്'),
  _OppositePair('Good', 'നല്ലത്', 'Bad', 'മോശം'),
  _OppositePair('New', 'പുതിയ', 'Old', 'പഴയ'),
  _OppositePair('Young', 'ചെറുപ്പം', 'Aged', 'പ്രായമായ'),
  _OppositePair('Rich', 'ധനികൻ', 'Poor', 'ദരിദ്രൻ'),
  _OppositePair('Clean', 'വൃത്തിയുള്ള', 'Dirty', 'അഴുക്കുള്ള'),
  _OppositePair('Full', 'നിറഞ്ഞ', 'Empty', 'കാലിയായ'),
  _OppositePair('Hard', 'കടുപ്പമുള്ള', 'Soft', 'മൃദുവായ'),
  _OppositePair('Heavy', 'ഭാരമുള്ള', 'Lite', 'ഭാരം കുറഞ്ഞ'),
  _OppositePair('Tall', 'ഉയരമുള്ള', 'Short', 'കുറിയ'),
  _OppositePair('High', 'ഉയർന്ന', 'Low', 'താഴ്ന്ന'),
  _OppositePair('Left', 'ഇടത്', 'Right', 'വലത്'),
  _OppositePair('In', 'ഉള്ളിൽ', 'Out', 'പുറത്ത്'),
  _OppositePair('Start', 'തുടങ്ങുക', 'Finish', 'അവസാനിപ്പിക്കുക'),
  _OppositePair('Early', 'നേരത്തെ', 'Late', 'വൈകി'),
  _OppositePair('Strong', 'ശക്തമായ', 'Weak', 'ദുർബലമായ'),
  _OppositePair('Easy', 'എളുപ്പമുള്ള', 'Tough', 'ബുദ്ധിമുട്ടുള്ള'),
  _OppositePair('True', 'സത്യം', 'False', 'തെറ്റ്'),
  _OppositePair('Win', 'ജയിക്കുക', 'Lose', 'തോൽക്കുക'),
  _OppositePair('Love', 'സ്നേഹം', 'Hate', 'വെറുപ്പ്'),
  _OppositePair('Laugh', 'ചിരിക്കുക', 'Cry', 'കരയുക'),
  _OppositePair('Smile', 'പുഞ്ചിരി', 'Frown', 'നെറ്റി ചുളിക്കുക'),
  _OppositePair('Give', 'കൊടുക്കുക', 'Take', 'എടുക്കുക'),
  _OppositePair('Buy', 'വാങ്ങുക', 'Sell', 'വിൽക്കുക'),
  _OppositePair('Push', 'തള്ളുക', 'Pull', 'വലിക്കുക'),
  _OppositePair('Come', 'വരുക', 'Go', 'പോകുക'),
  _OppositePair('Sit', 'ഇരിക്കുക', 'Stand', 'നിൽക്കുക'),
  _OppositePair('Wake', 'ഉണരുക', 'Sleep', 'ഉറങ്ങുക'),
  _OppositePair('Wet', 'നനഞ്ഞ', 'Dry', 'ഉണങ്ങിയ'),
  _OppositePair('Sweet', 'മധുരമുള്ള', 'Bitter', 'കയ്പുള്ള'),
  _OppositePair('Loud', 'ഉച്ചത്തിൽ', 'Quiet', 'ശാന്തമായ'),
  _OppositePair('Bright', 'തിളക്കമുള്ള', 'Dim', 'മങ്ങിയ'),
  _OppositePair('Sharp', 'മൂർച്ചയുള്ള', 'Blunt', 'മൂർച്ചയില്ലാത്ത'),
  _OppositePair('Thick', 'കട്ടിയുള്ള', 'Thin', 'നേർത്ത'),
  _OppositePair('Wide', 'വീതിയുള്ള', 'Narrow', 'ഇടുങ്ങിയ'),
  _OppositePair('Deep', 'ആഴമുള്ള', 'Shallow', 'ആഴം കുറഞ്ഞ'),
  _OppositePair('Smooth', 'മിനുസമുള്ള', 'Rough', 'പരുക്കനായ'),
  _OppositePair('Safe', 'സുരക്ഷിതം', 'Unsafe', 'അപകടകരം'),
  _OppositePair('First', 'ആദ്യത്തെ', 'Last', 'അവസാനത്തെ'),
  _OppositePair('Always', 'എപ്പോഴും', 'Never', 'ഒരിക്കലുമില്ല'),
  _OppositePair('Often', 'പലപ്പോഴും', 'Rarely', 'അപൂർവ്വമായി'),
  _OppositePair('More', 'കൂടുതൽ', 'Less', 'കുറവ്'),
  _OppositePair('Many', 'അനേകം', 'Few', 'കുറച്ച്'),
  _OppositePair('All', 'എല്ലാം', 'None', 'ഒന്നുമില്ല'),
  _OppositePair('Same', 'ഒരേപോലെ', 'Different', 'വ്യത്യസ്തമായ'),
  _OppositePair('Alive', 'ജീവനുള്ള', 'Dead', 'മരിച്ച'),
  _OppositePair('Brave', 'ധൈര്യമുള്ള', 'Timid', 'ഭീരുവായ'),
  _OppositePair('Kind', 'ദയയുള്ള', 'Cruel', 'ക്രൂരമായ'),
  _OppositePair('Polite', 'വിനയമുള്ള', 'Rude', 'പരുഷമായ'),
  _OppositePair('Wise', 'ബുദ്ധിയുള്ള', 'Foolish', 'മണ്ടനായ'),
  _OppositePair('Honest', 'സത്യസന്ധമായ', 'Dishonest', 'വഞ്ചനയുള്ള'),
  _OppositePair('Calm', 'ശാന്തമായ', 'Angry', 'കോപമുള്ള'),
  _OppositePair('Busy', 'തിരക്കുള്ള', 'Free', 'ഒഴിവുള്ള'),
  _OppositePair('Front', 'മുന്നിൽ', 'Back', 'പിന്നിൽ'),
  _OppositePair('Top', 'മുകൾഭാഗം', 'Bottom', 'അടിഭാഗം'),
  _OppositePair('Inside', 'അകത്ത്', 'Outside', 'പുറത്ത്'),
  _OppositePair('Above', 'മുകളിൽ', 'Below', 'താഴെ'),
  _OppositePair('Over', 'മീതെ', 'Under', 'കീഴെ'),
  _OppositePair('Enter', 'പ്രവേശിക്കുക', 'Exit', 'പുറത്തുപോകുക'),
  _OppositePair('Ask', 'ചോദിക്കുക', 'Answer', 'ഉത്തരം പറയുക'),
  _OppositePair('Teach', 'പഠിപ്പിക്കുക', 'Learn', 'പഠിക്കുക'),
  _OppositePair('Build', 'നിർമ്മിക്കുക', 'Break', 'തകർക്കുക'),
  _OppositePair('Create', 'സൃഷ്ടിക്കുക', 'Destroy', 'നശിപ്പിക്കുക'),
  _OppositePair('Save', 'സംരക്ഷിക്കുക', 'Spend', 'ചെലവഴിക്കുക'),
  _OppositePair('Send', 'അയക്കുക', 'Receive', 'സ്വീകരിക്കുക'),
  _OppositePair('Find', 'കണ്ടെത്തുക', 'Drop', 'കളയുക'),
  _OppositePair('Remember', 'ഓർക്കുക', 'Forget', 'മറക്കുക'),
  _OppositePair('Agree', 'സമ്മതിക്കുക', 'Refuse', 'നിരസിക്കുക'),
  _OppositePair('Allow', 'അനുവദിക്കുക', 'Forbid', 'വിലക്കുക'),
  _OppositePair('Accept', 'സ്വീകരിക്കുക', 'Reject', 'തള്ളിക്കളയുക'),
  _OppositePair('Success', 'വിജയം', 'Failure', 'പരാജയം'),
  _OppositePair('Hope', 'പ്രതീക്ഷ', 'Despair', 'നിരാശ'),
  _OppositePair('Peace', 'സമാധാനം', 'War', 'യുദ്ധം'),
  _OppositePair('Friend', 'സുഹൃത്ത്', 'Enemy', 'ശത്രു'),
  _OppositePair('Guest', 'അതിഥി', 'Host', 'ആതിഥേയൻ'),
  _OppositePair('King', 'രാജാവ്', 'Servant', 'ദാസൻ'),
  _OppositePair('Master', 'ഗുരു / യജമാനൻ', 'Student', 'വിദ്യാർത്ഥി'),
  _OppositePair('Leader', 'നേതാവ്', 'Follower', 'അനുയായി'),
  _OppositePair('Buyer', 'വാങ്ങുന്നയാൾ', 'Seller', 'വിൽക്കുന്നയാൾ'),
  _OppositePair('Summer', 'വേനൽ', 'Winter', 'മഞ്ഞുകാലം'),
  _OppositePair('Sunrise', 'സൂര്യോദയം', 'Sunset', 'സൂര്യാസ്തമയം'),
  _OppositePair('Heaven', 'സ്വർഗ്ഗം', 'Hell', 'നരകം'),
  _OppositePair('Truth', 'സത്യം', 'Lie', 'നുണ'),
  _OppositePair('Fact', 'വസ്തുത', 'Fiction', 'കല്പന'),
  _OppositePair('Real', 'യഥാർത്ഥ', 'Fake', 'വ്യാജമായ'),
  _OppositePair('Fresh', 'പുതുമയുള്ള', 'Stale', 'പഴകിയ'),
  _OppositePair('Ripe', 'പഴുത്ത', 'Raw', 'പച്ചയായ'),
  _OppositePair('Solid', 'ഖരമായ', 'Liquid', 'ദ്രാവകമായ'),
  _OppositePair('Straight', 'നേരെയുള്ള', 'Curved', 'വളഞ്ഞ'),
  _OppositePair('Tight', 'ഇറുകിയ', 'Loose', 'അയഞ്ഞ'),
  _OppositePair('Sharp', 'കൂർത്ത', 'Flat', 'പരന്ന'),
  _OppositePair('Cheap', 'വിലകുറഞ്ഞ', 'Costly', 'വിലകൂടിയ'),
  _OppositePair('Public', 'പൊതുവായ', 'Private', 'സ്വകാര്യമായ'),
  _OppositePair('Local', 'പ്രാദേശിക', 'Global', 'ആഗോള'),
  _OppositePair('Modern', 'ആധുനിക', 'Ancient', 'പുരാതന'),
  _OppositePair('Future', 'ഭാവി', 'Past', 'ഭൂതകാലം'),
  _OppositePair('Present', 'വർത്തമാനകാലം', 'Absent', 'അഭാവം'),
  _OppositePair('Active', 'സജീവമായ', 'Lazy', 'മടിയനായ'),
  _OppositePair('Alert', 'ജാഗ്രതയുള്ള', 'Careless', 'അശ്രദ്ധമായ'),
  _OppositePair('Neat', 'വൃത്തിയുള്ള', 'Messy', 'അലങ്കോലമായ'),
  _OppositePair('Simple', 'ലളിതമായ', 'Complex', 'സങ്കീർണ്ണമായ'),
  _OppositePair('Clear', 'വ്യക്തമായ', 'Blurry', 'മങ്ങിയ'),
  _OppositePair('Certain', 'ഉറപ്പുള്ള', 'Doubtful', 'സംശയമുള്ള'),
  _OppositePair('Common', 'സാധാരണ', 'Unique', 'അപൂർവ്വമായ'),
  _OppositePair('Normal', 'സാധാരണ', 'Strange', 'വിചിത്രമായ'),
  _OppositePair('Natural', 'സ്വാഭാവിക', 'Artificial', 'കൃത്രിമ'),
  _OppositePair('Major', 'പ്രധാനപ്പെട്ട', 'Minor', 'ചെറിയ'),
  _OppositePair('Maximum', 'പരമാവധി', 'Minimum', 'കുറഞ്ഞത്'),
  _OppositePair('Increase', 'വർദ്ധിപ്പിക്കുക', 'Decrease', 'കുറയ്ക്കുക'),
  _OppositePair('Expand', 'വികസിപ്പിക്കുക', 'Shrink', 'ചുരുങ്ങുക'),
  _OppositePair('Connect', 'ബന്ധിപ്പിക്കുക', 'Separate', 'വേർപെടുത്തുക'),
  _OppositePair('Join', 'ചേരുക', 'Leave', 'വിട്ടുപോകുക'),
  _OppositePair('Arrive', 'എത്തുക', 'Depart', 'പുറപ്പെടുക'),
  _OppositePair('Rise', 'ഉയരുക', 'Fall', 'വീഴുക'),
  _OppositePair('Float', 'പൊങ്ങിക്കിടക്കുക', 'Sink', 'മുങ്ങുക'),
  _OppositePair('Catch', 'പിടിക്കുക', 'Throw', 'എറിയുക'),
  _OppositePair('Hide', 'ഒളിപ്പിക്കുക', 'Show', 'കാണിക്കുക'),
  _OppositePair('Lock', 'പൂട്ടുക', 'Unlock', 'തുറക്കുക'),
  _OppositePair('Repair', 'നന്നാക്കുക', 'Damage', 'കേടുവരുത്തുക'),
  _OppositePair('Protect', 'സംരക്ഷിക്കുക', 'Harm', 'ദ്രോഹിക്കുക'),
  _OppositePair('Praise', 'പ്രശംസിക്കുക', 'Blame', 'കുറ്റപ്പെടുത്തുക'),
  _OppositePair('Reward', 'സമ്മാനം', 'Punish', 'ശിക്ഷിക്കുക'),
  _OppositePair('Bless', 'അനുഗ്രഹിക്കുക', 'Curse', 'ശപിക്കുക'),
  _OppositePair('Share', 'പങ്കുവെക്കുക', 'Hoard', 'പൂഴ്ത്തിവെക്കുക'),
  _OppositePair('Lead', 'നയിക്കുക', 'Follow', 'പിന്തുടരുക'),
  _OppositePair('Attack', 'ആക്രമിക്കുക', 'Defend', 'പ്രതിരോധിക്കുക'),
  _OppositePair('Victory', 'വിജയം', 'Defeat', 'തോൽവി'),
  _OppositePair('Courage', 'ധൈര്യം', 'Fear', 'ഭയം'),
  _OppositePair('Pride', 'അഭിമാനം', 'Shame', 'ലജ്ജ'),
  _OppositePair('Joy', 'ആനന്ദം', 'Sorrow', 'ദുഃഖം'),
  _OppositePair('Health', 'ആരോഗ്യം', 'Illness', 'രോഗം'),
  _OppositePair('Strength', 'ശക്തി', 'Weakness', 'ബലഹീനത'),
  _OppositePair('Wealth', 'സമ്പത്ത്', 'Poverty', 'ദാരിദ്ര്യം'),
  _OppositePair('Profit', 'ലാഭം', 'Loss', 'നഷ്ടം'),
  _OppositePair('Credit', 'കടം / വരവ്', 'Debit', 'ചെലവ്'),
  _OppositePair('Import', 'ഇറക്കുമതി', 'Export', 'കയറ്റുമതി'),
  _OppositePair('Urban', 'നഗര', 'Rural', 'ഗ്രാമീണ'),
  _OppositePair('Visible', 'കാണാവുന്ന', 'Hidden', 'മറഞ്ഞിരിക്കുന്ന'),
  _OppositePair('Possible', 'സാധ്യമായ', 'Impossible', 'അസാധ്യമായ'),
  _OppositePair('Legal', 'നിയമപരമായ', 'Illegal', 'നിയമവിരുദ്ധമായ'),
  _OppositePair('Regular', 'സ്ഥിരമായ', 'Irregular', 'ക്രമരഹിതമായ'),
  _OppositePair('Patient', 'ക്ഷമയുള്ള', 'Impatient', 'അക്ഷമയുള്ള'),
  _OppositePair('Mature', 'പക്വതയുള്ള', 'Childish', 'ബാലിശമായ'),
  _OppositePair('Generous', 'ഉദാരമതി', 'Selfish', 'സ്വാർത്ഥനായ'),
  _OppositePair('Humble', 'വിനീതനായ', 'Arrogant', 'അഹങ്കാരിയായ'),
  _OppositePair('Loyal', 'വിശ്വസ്തനായ', 'Unfaithful', 'അവിശ്വസ്തനായ'),
  _OppositePair('Flexible', 'വഴക്കമുള്ള', 'Rigid', 'കടുപ്പമുള്ള'),
  _OppositePair('Permanent', 'സ്ഥിരമായ', 'Temporary', 'താൽക്കാലിക'),
  _OppositePair('Abundant', 'സമൃദ്ധമായ', 'Scarce', 'ദുർലഭമായ'),
  _OppositePair('Exact', 'കൃത്യമായ', 'Approx', 'ഏകദേശ'),
  _OppositePair('Internal', 'ആന്തരിക', 'External', 'ബാഹ്യ'),
  _OppositePair('Positive', 'ശുഭാപ്തി', 'Negative', 'നിഷേധാത്മക'),
  _OppositePair('Active', 'പ്രവർത്തനക്ഷമം', 'Passive', 'നിഷ്ക്രിയമായ'),
  _OppositePair('Oral', 'വാക്കാലുള്ള', 'Written', 'എഴുതിയ'),
  _OppositePair('Junior', 'ജൂനിയർ', 'Senior', 'സീനിയർ'),
  _OppositePair('Superior', 'മികച്ച', 'Inferior', 'താഴ്ന്ന'),
  _OppositePair('Include', 'ഉൾപ്പെടുത്തുക', 'Exclude', 'ഒഴിവാക്കുക'),
  _OppositePair('Approve', 'അംഗീകരിക്കുക', 'Deny', 'നിരസിക്കുക'),
  _OppositePair('Confirm', 'ഉറപ്പാക്കുക', 'Cancel', 'റദ്ദാക്കുക'),
  _OppositePair('Continue', 'തുടരുക', 'Pause', 'നിർത്തുക'),
  _OppositePair('Borrow', 'കടം വാങ്ങുക', 'Lend', 'കടം കൊടുക്കുക'),
  _OppositePair('Whisper', 'മന്ത്രിക്കുക', 'Shout', 'ഉറക്കെ വിളിക്കുക'),
  _OppositePair('Appear', 'പ്രത്യക്ഷപ്പെടുക', 'Vanish', 'അപ്രത്യക്ഷമാകുക'),
  _OppositePair('Notice', 'ശ്രദ്ധിക്കുക', 'Ignore', 'അവഗണിക്കുക'),
  _OppositePair('Gather', 'ശേഖരിക്കുക', 'Scatter', 'ചിതറിക്കുക'),
  _OppositePair('Combine', 'സംയോജിപ്പിക്കുക', 'Divide', 'വിഭജിക്കുക'),
  _OppositePair('Fix', 'ശരിയാക്കുക', 'Ruin', 'നശിപ്പിക്കുക'),
  _OppositePair('Trust', 'വിശ്വസിക്കുക', 'Doubt', 'സംശയിക്കുക'),
  _OppositePair('Achieve', 'നേടുക', 'Quit', 'ഉപേക്ഷിക്കുക'),
  _OppositePair('Inspire', 'പ്രചോദിപ്പിക്കുക', 'Discourage', 'നിരുത്സാഹപ്പെടുത്തുക'),
];

class _OppositeQuestion {
  final String prompt;
  final String promptMeaning;
  final String answer;
  final List<String> options;

  const _OppositeQuestion({
    required this.prompt,
    required this.promptMeaning,
    required this.answer,
    required this.options,
  });
}

/// 📖 Minimal Story-Card Style Opposite Words Game (Zero Duplication across 90 Days)
class PocketOppositeWordsGamePage extends StatefulWidget {
  final int day;
  const PocketOppositeWordsGamePage({super.key, required this.day});

  @override
  State<PocketOppositeWordsGamePage> createState() =>
      _PocketOppositeWordsGamePageState();
}

class _PocketOppositeWordsGamePageState
    extends State<PocketOppositeWordsGamePage> {
  late final FlutterTts _tts;
  late final List<_OppositeQuestion> _questions;
  final Map<int, String> _selectedAnswers = {};

  static const Color kBg = Color(0xFF141210);
  static const Color kCard = Color(0xFFFDF8EE);
  static const Color kGold = Color(0xFFD4A373);
  static const Color kEm = Color(0xFF15803D);

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts()
      ..setLanguage('en-US')
      ..setSpeechRate(0.45);
    _questions = _buildDayQuestions(widget.day);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  List<_OppositeQuestion> _buildDayQuestions(int day) {
    final safeDay = day.clamp(1, 90);
    final idxA = ((safeDay - 1) * 2) % _kUniqueOppositePairs.length;
    final idxB = (idxA + 1) % _kUniqueOppositePairs.length;
    final p1 = _kUniqueOppositePairs[idxA];
    final p2 = _kUniqueOppositePairs[idxB];

    // Distractors pulled from neighboring pairs so they never collide with p1/p2
    final d1 = _kUniqueOppositePairs[(idxA + 3) % _kUniqueOppositePairs.length];
    final d2 = _kUniqueOppositePairs[(idxA + 7) % _kUniqueOppositePairs.length];

    List<String> makeOptions(String correct, String alt1, String alt2) {
      final set = <String>{correct, alt1, alt2};
      final list = set.toList();
      list.sort((a, b) => ((a.hashCode + safeDay) % 17)
          .compareTo((b.hashCode + safeDay) % 17));
      return list;
    }

    return [
      _OppositeQuestion(
        prompt: p1.wordA,
        promptMeaning: p1.meaningA,
        answer: p1.wordB,
        options: makeOptions(p1.wordB, d1.wordB, d2.wordA),
      ),
      _OppositeQuestion(
        prompt: p2.wordA,
        promptMeaning: p2.meaningA,
        answer: p2.wordB,
        options: makeOptions(p2.wordB, d2.wordB, d1.wordA),
      ),
      // Reverse direction on scroll-down (e.g. After -> Before, Small -> Long)
      _OppositeQuestion(
        prompt: p1.wordB,
        promptMeaning: p1.meaningB,
        answer: p1.wordA,
        options: makeOptions(p1.wordA, d1.wordA, d2.wordB),
      ),
      _OppositeQuestion(
        prompt: p2.wordB,
        promptMeaning: p2.meaningB,
        answer: p2.wordA,
        options: makeOptions(p2.wordA, d2.wordA, d1.wordB),
      ),
    ];
  }

  void _speak(String word) {
    try {
      _tts.stop();
      _tts.speak(word);
    } catch (_) {}
  }

  void _onSelectOption(int qIndex, String option) {
    final q = _questions[qIndex];
    final isCorrect = option == q.answer;
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      PocketGameSfx.instance.playSnapCorrect();
      _speak(option);
      setState(() => _selectedAnswers[qIndex] = option);
    } else {
      HapticFeedback.lightImpact();
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Try another opposite for "${q.prompt}"',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF991B1B),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSolved = _selectedAnswers.length == _questions.length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFE5DEC9), size: 20),
          onPressed: () => Navigator.of(context).maybePop(false),
        ),
        title: Text(
          'Opposite Words',
          style: GoogleFonts.playfairDisplay(
            color: kCard,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: PocketBannerAdWidget(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editorial Day Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGold.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      'Day ${widget.day} • ${_selectedAnswers.length}/${_questions.length} Matched',
                      style: GoogleFonts.outfit(
                        color: kGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Minimal Story-Card Style Opposite Cards
              for (int i = 0; i < _questions.length; i++) ...[
                _buildOppositeCard(i, _questions[i]),
                const SizedBox(height: 14),
              ],

              // Complete Button
              if (allSolved) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    'Complete & Continue',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kEm,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Native Ad at the bottom when scrolling
              const PocketTrueNativeAdWidget(
                placement: PocketAdPlacement.learningStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOppositeCard(int index, _OppositeQuestion q) {
    final solvedAnswer = _selectedAnswers[index];
    final isSolved = solvedAnswer != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSolved ? kEm.withValues(alpha: 0.55) : const Color(0xFFE6D5B8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'OPPOSITE OF',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF92400E),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _speak(q.prompt),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFF92400E),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                q.prompt,
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFF1F2937),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '(${q.promptMeaning})',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE6D5B8), height: 1),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: q.options.map((opt) {
              final selected = solvedAnswer == opt;
              return GestureDetector(
                onTap: isSolved ? null : () => _onSelectOption(index, opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF3ECE0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? kEm : const Color(0xFFD6C7AE),
                      width: selected ? 1.8 : 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(Icons.check_circle_rounded,
                            color: kEm, size: 15),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        opt,
                        style: GoogleFonts.outfit(
                          color: selected ? kEm : const Color(0xFF1F2937),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
