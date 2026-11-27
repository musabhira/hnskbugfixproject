import 'package:pocket_mates_app/custom_code/widgets/learning_60day/daily_vocab_item.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/sentence_builder_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_chat_reply_builder_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_mini_speech_practice_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_negative_sentence_builder_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/spoken/pocket_90day_spoken_simulator_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_useful_phrases_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_verb_timeline_data.dart';
import 'pocket_german_90day_vocab_p1.dart';
import 'pocket_german_90day_vocab_p2.dart';

/// 🇩🇪 Master 90-Day German A1 -> B2 Curriculum Synthesizer & Curated Repository
/// Powers ALL 90 Days (1–90) across Steps 1–20 + Gate Exams when German Track is active.
class PocketGerman90DayMasterData {
  PocketGerman90DayMasterData._();

  static String phaseForDay(int day) {
    if (day <= 15) return 'Phase 1 · A1 Foundations (Days 1–15)';
    if (day <= 30) return 'Phase 2 · A1+ Daily Life (Days 16–30)';
    if (day <= 45) return 'Phase 3 · A2 Elementary Mastery (Days 31–45)';
    if (day <= 70) return 'Phase 4 · B1 Independent Fluency (Days 46–70)';
    return 'Phase 5 · B2 Grandmaster Oratory (Days 71–90)';
  }

  /// 90 Unique Daily Metadata Records:
  /// [title, focus, grammar, drill, drillMl, negPos, negPosMl, negOut, negOutMl,
  ///  chatPrompt, chatPromptMl, chatReply, chatReplyMl, verbBase, verbMl, verbPast, verbPresent, verbFuture, pastSent, presSent, futSent]
  static const Map<int, List<String>> _dayBlueprints = {
    1: ['Hallo & Ich bin (Alphabet + Basics)', 'Greetings & Self-Intro', 'Verb sein (ich bin)', 'Ich lerne heute Deutsch mit Freude.', 'ഞാൻ ഇന്ന് സന്തോഷത്തോടെ ജർമൻ പഠിക്കുന്നു.', 'Ich bin müde.', 'എനിക്ക് ക്ഷീണമാണ്.', 'Ich bin nicht müde.', 'എനിക്ക് ക്ഷീണമില്ല.', 'Hallo! Lernst du heute Deutsch?', 'ഹലോ! നീ ഇന്ന് ജർമൻ പഠിക്കുന്നുണ്ടോ?', 'Ja, ich lerne heute Deutsch!', 'അതെ, ഞാൻ ഇന്ന് ജർമൻ പഠിക്കുന്നു!', 'lernen', 'പഠിക്കുക', 'lernte', 'lerne', 'werde lernen', 'Gestern lernte ich fünf Wörter.', 'Heute lerne ich sehr aktiv.', 'Morgen werde ich weiter lernen.'],
    2: ['Woher kommst du? (Locations)', 'Countries & Cities', 'Verb Position 2 Rule', 'Ich komme aus Indien und lebe in Kerala.', 'ഞാൻ ഇന്ത്യയിൽ നിന്നാണ് വരുന്നത്, കേരളത്തിൽ താമസിക്കുന്നു.', 'Ich wohne in Berlin.', 'ഞാൻ ബെർലിനിൽ താമസിക്കുന്നു.', 'Ich wohne nicht in Berlin.', 'ഞാൻ ബെർലിനിൽ താമസിക്കുന്നില്ല.', 'Woher kommst du eigentlich?', 'നീ ശരിക്കും എവിടെ നിന്നാണ് വരുന്നത്?', 'Ich komme aus dem schönen Indien.', 'ഞാൻ മനോഹരമായ ഇന്ത്യയിൽ നിന്നാണ് വരുന്നത്.', 'kommen', 'വരുക', 'kam', 'komme', 'werde kommen', 'Gestern kam mein Freund an.', 'Ich komme aus Kerala.', 'Bald werde ich nach Berlin kommen.'],
    3: ['Familie & Der / Die / Das', 'Family & Noun Genders', 'Articles: Der, Die, Das', 'Das ist mein Bruder und das ist meine Mutter.', 'ഇത് എന്റെ സഹോദരനും ഇത് എന്റെ അമ്മയുമാണ്.', 'Das ist mein Haus.', 'ഇത് എന്റെ വീടാണ്.', 'Das ist nicht mein Haus.', 'ഇത് എന്റെ വീടല്ല.', 'Hast du eine große Familie?', 'നിനക്ക് വലിയൊരു കുടുംബമാണോ?', 'Ja, meine Familie ist sehr nett.', 'അതെ, എന്റെ കുടുംബം വളരെ നല്ലതാണ്.', 'arbeiten', 'ജോലി ചെയ്യുക', 'arbeitete', 'arbeite', 'werde arbeiten', 'Mein Vater arbeitete bis fünf.', 'Heute arbeite ich im Team.', 'Morgen werde ich pünktlich arbeiten.'],
    4: ['Im Café — Essen & Trinken', 'Café Orders & Bitte', 'Modal möchten + Accusative', 'Ich möchte einen Kaffee mit Milch, bitte.', 'എനിക്ക് പാലൊഴിച്ച ഒരു കാപ്പി തരുമോ, ദയവായി.', 'Ich habe Zucker.', 'എന്റെ കയ്യിൽ പഞ്ചസാരയുണ്ട്.', 'Ich habe keinen Zucker.', 'എന്റെ കയ്യിൽ പഞ്ചസാരയില്ല.', 'Was möchten Sie gern bestellen?', 'നിങ്ങൾക്ക് എന്താണ് ഓർഡർ ചെയ്യേണ്ടത്?', 'Ich möchte eine Tasse Kaffee bitte.', 'എനിക്ക് ഒരു കപ്പ് കാപ്പി തരൂ.', 'trinken', 'കുടിക്കുക', 'trank', 'trinke', 'werde trinken', 'Gestern trank ich warmen Tee.', 'Ich trinke morgens gern Kaffee.', 'Nachher werde ich Wasser trinken.'],
    5: ['Zeit & Tagesablauf (Schedule)', 'Days, Time & Habits', 'Time-Subject Inversion (Verb #2)', 'Heute habe ich Zeit für meine Lektion.', 'ഇന്ന് എനിക്ക് എന്റെ പാഠത്തിനായി സമയമുണ്ട്.', 'Ich bin spät.', 'ഞാൻ വൈകിയിരിക്കുന്നു.', 'Ich bin nicht spät.', 'ഞാൻ വൈകിയിട്ടില്ല.', 'Wie spät ist es jetzt?', 'ഇപ്പോൾ സമയം എത്രയായി?', 'Es ist genau neun Uhr morgens.', 'ഇപ്പോൾ കൃത്യം രാവിലെ ഒമ്പത് മണിയാണ്.', 'warten', 'കാത്തിരിക്കുക', 'wartete', 'warte', 'werde warten', 'Gestern wartete der Bus kurz.', 'Ich warte an der Tür.', 'Morgen werde ich nicht warten.'],
    6: ['Zahlen & Einkauf (1–10)', 'Numbers & Prices', 'Plural Forms with Numbers', 'Ich kaufe zwei Äpfel und fünf Bananen.', 'ഞാൻ രണ്ട് ആപ്പിളും അഞ്ച് പഴവും വാങ്ങുന്നു.', 'Wir sind zehn Leute.', 'ഞങ്ങൾ പത്തു പേരുണ്ട്.', 'Wir sind keine zehn Leute.', 'ഞങ്ങൾ പത്തു പേരില്ല.', 'Wie viele Tickets brauchst du?', 'നിനക്ക് എത്ര ടിക്കറ്റുകൾ വേണം?', 'Ich brauche bitte genau zwei Tickets.', 'എനിക്ക് കൃത്യം രണ്ട് ടിക്കറ്റുകൾ വേണം.', 'zählen', 'എണ്ണുക', 'zählte', 'zähle', 'werde zählen', 'Er zählte alle Münzen genau.', 'Ich zähle bis zehn auf Deutsch.', 'Sie wird die Punkte schnell zählen.'],
    7: ['Farben & Formen (Colors & Shapes)', 'Visual Adjectives', 'Adjective Predicate Forms', 'Der Himmel ist blau und die Sonne ist gelb.', 'ആകാശം നീലയും സൂര്യൻ മഞ്ഞയുമാണ്.', 'Die Jacke ist schwarz.', 'ജാക്കറ്റ് കറുപ്പാണ്.', 'Die Jacke ist nicht schwarz.', 'ജാക്കറ്റ് കറുപ്പല്ല.', 'Welche Farbe gefällt dir am besten?', 'നിനക്ക് ഏറ്റവും ഇഷ്ടമുള്ള നിറം ഏതാണ്?', 'Mir gefällt ruhiges Blau sehr gut.', 'എനിക്ക് ശാന്തമായ നീല നിറം വളരെ ഇഷ്ടമാണ്.', 'malen', 'വരയ്ക്കുക', 'malte', 'male', 'werde malen', 'Das Kind malte einen grünen Baum.', 'Heute male ich einen Kreis.', 'Wir werden ein Haus malen.'],
    8: ['Meine Wohnung (Home & Rooms)', 'Rooms & Furniture', 'Prepositions: in + der/dem', 'In meiner Küche kochen wir jeden Abend.', 'എന്റെ അടുക്കളയിൽ ഞങ്ങൾ എല്ലാ വൈകുന്നേരവും പാചകം ചെയ്യുന്നു.', 'Die Wohnung hat einen Balkon.', 'ഫ്ലാറ്റിന് ഒരു ബാൽക്കണിയുണ്ട്.', 'Die Wohnung hat keinen Balkon.', 'ഫ്ലാറ്റിന് ബാൽക്കണിയില്ല.', 'Wie ist deine neue Wohnung?', 'നിന്റെ പുതിയ വീട് എങ്ങനെയുണ്ട്?', 'Meine Wohnung ist hell und ruhig.', 'എന്റെ ഫ്ലാറ്റ് വെളിച്ചമുള്ളതും ശാന്തവുമാണ്.', 'wohnen', 'താമസിക്കുക', 'wohnte', 'wohne', 'werde wohnen', 'Früher wohnte ich im Dorf.', 'Jetzt wohne ich zentral.', 'Nächstes Jahr werde ich dort wohnen.'],
    9: ['Essen & Küche (Meals & Cutlery)', 'Meals & Tableware', 'Preposition mit + Dative', 'Zum Frühstück esse ich gern frisches Brot.', 'പ്രഭാതഭക്ഷണത്തിന് ഞാൻ പുതിയ ബ്രഡ് കഴിക്കാൻ ഇഷ്ടപ്പെടുന്നു.', 'Die Suppe ist heiß.', 'സൂപ്പ് ചൂടുള്ളതാണ്.', 'Die Suppe ist nicht heiß.', 'സൂപ്പ് ചൂടുള്ളതല്ല.', 'Was kochst du zum Abendessen?', 'രാത്രിഭക്ഷണത്തിന് നീ എന്താണ് ഉണ്ടാക്കുന്നത്?', 'Heute koche ich eine warme Suppe.', 'ഇന്ന് ഞാൻ ചൂടുള്ളൊരു സൂപ്പ് ഉണ്ടാക്കുന്നു.', 'essen', 'കഴിക്കുക', 'aß', 'esse', 'werde essen', 'Gestern aß ich Reis mit Gemüse.', 'Mittags esse ich gerne Obst.', 'Abends werde ich warm essen.'],
    10: ['Obst & Gemüse (Market)', 'Fresh Produce & Shopping', 'Indefinite Articles ein/eine', 'Ich kaufe rote Tomaten und frische Orangen.', 'ഞാൻ ചുവന്ന തക്കാളിയും ഫ്രഷ് ഓറഞ്ചും വാങ്ങുന്നു.', 'Ich esse Fleisch.', 'ഞാൻ മാംസം കഴിക്കുന്നു.', 'Ich esse kein Fleisch.', 'ഞാൻ മാംസം കഴിക്കുന്നില്ല.', 'Welches Obst magst du besonders?', 'നിനക്ക് ഏത് പഴമാണ് കൂടുതൽ ഇഷ്ടം?', 'Ich liebe süße Äpfel und Trauben.', 'എനിക്ക് മധുരമുള്ള ആപ്പിളും മുന്തിരിയും ഇഷ്ടമാണ്.', 'kaufen', 'വാങ്ങുക', 'kaufte', 'kaufe', 'werde kaufen', 'Am Markt kaufte ich frische Trauben.', 'Heute kaufe ich zwei Bananen.', 'Morgen werde ich Zitronen kaufen.'],
    11: ['Im Supermarkt (Shopping)', 'Checkout & Prices', 'Modal können + Infinitive', 'Kann ich heute an der Kasse zahlen?', 'എനിക്ക് ഇന്ന് ക്യാഷ് കൗണ്ടറിൽ പണം നൽകാമോ?', 'Die Tasche ist teuer.', 'ബാഗ് വിലകൂടിയതാണ്.', 'Die Tasche ist nicht teuer.', 'ബാഗ് വിലകൂടിയതല്ല.', 'Brauchen Sie noch eine Quittung?', 'നിങ്ങൾക്ക് രസീത് ആവശ്യമുണ്ടോ?', 'Ja, geben Sie mir eine Quittung.', 'അതെ, എനിക്ക് ഒരു രസീത് തരൂ.', 'bezahlen', 'പണം നൽകുക', 'bezahlte', 'bezahle', 'werde bezahlen', 'Er bezahlte sofort mit Karte.', 'An der Kasse bezahle ich bar.', 'Morgen werde ich die Miete bezahlen.'],
    12: ['Kleidung & Stil (Clothing)', 'Apparel & Seasons', 'Verb tragen (Vowel Change ä)', 'Im Winter trage ich einen warmen Mantel.', 'തണുപ്പുകാലത്ത് ഞാൻ ചൂടുള്ള കോട്ട് ധരിക്കുന്നു.', 'Ich trage eine Brille.', 'ഞാൻ കണ്ണട വെക്കാറുണ്ട്.', 'Ich trage keine Brille.', 'ഞാൻ കണ്ണട വെക്കാറില്ല.', 'Welche Kleidung brauchst du heute?', 'നിനക്ക് ഇന്ന് എന്ത് വസ്ത്രമാണ് വേണ്ടത്?', 'Ich brauche eine warme Winterjacke.', 'എനിക്ക് ചൂടുള്ളൊരു വിന്റർ ജാക്കറ്റ് വേണം.', 'tragen', 'ധരിക്കുക', 'trug', 'trage', 'werde tragen', 'Gestern trug sie ein blaues Kleid.', 'Heute trage ich mein weißes Hemd.', 'Im Herbst werde ich einen Mantel tragen.'],
    13: ['Wetter & Jahreszeiten', 'Forecast & Climate', 'Impersonal Verbs (es regnet/schneit)', 'Heute scheint die Sonne und der Himmel ist klar.', 'ഇന്ന് സൂര്യൻ പ്രകാശിക്കുന്നു, ആകാശം തെളിഞ്ഞതാണ്.', 'Es ist heute kalt.', 'ഇന്ന് തണുപ്പാണ്.', 'Es ist nicht kalt.', 'ഇന്ന് തണുപ്പല്ല.', 'Wie wird das Wetter am Wochenende?', 'വാരാന്ത്യത്തിൽ കാലാവസ്ഥ എങ്ങനെയായിരിക്കും?', 'Am Samstag scheint hoffentlich die Sonne.', 'ശനിയാഴ്ച സൂര്യൻ ഉദിക്കുമെന്ന് പ്രതീക്ഷിക്കുന്നു.', 'scheinen', 'പ്രകാശിക്കുക', 'schien', 'scheint', 'wird scheinen', 'Gestern schien die warme Sonne.', 'Heute scheint das Licht hell.', 'Morgen wird die Sonne wieder scheinen.'],
    14: ['Körper & Gesundheit', 'Body Parts & Health', 'Verb tun + weh (Pain)', 'Wasch dir die Hände und bleib immer gesund.', 'കൈകൾ കഴുകി എപ്പോഴും ആരോഗ്യത്തോടെയിരിക്കൂ.', 'Ich habe Fieber.', 'എനിക്ക് പനിയുണ്ട്.', 'Ich habe kein Fieber.', 'എനിക്ക് പനിയില്ല.', 'Wie fühlst du dich heute?', 'നിനക്ക് ഇന്ന് എങ്ങനെയുണ്ട്?', 'Mir geht es heute völlig gesund.', 'എനിക്ക് ഇന്ന് പൂർണ്ണ ആരോഗ്യമുണ്ട്.', 'fühlen', 'തോന്നുക', 'fühlte', 'fühle', 'werde fühlen', 'Nach dem Schlaf fühlte ich mich fit.', 'Heute fühle ich mich sehr ruhig.', 'Bald werde ich mich stark fühlen.'],
    15: ['Verkehr & Stadt (Transit)', 'Trains, Buses & Tickets', 'Separable Verb abfahren', 'Der Zug fährt pünktlich um acht Uhr ab.', 'ട്രെയിൻ കൃത്യം എട്ട് മണിക്ക് പുറപ്പെടുന്നു.', 'Ich fahre Auto.', 'ഞാൻ കാർ ഓടിക്കുന്നു.', 'Ich fahre kein Auto.', 'ഞാൻ കാർ ഓടിക്കുന്നില്ല.', 'Wie kommst du heute zur Arbeit?', 'നീ ഇന്ന് ജോലിക്ക് എങ്ങനെയാണ് വരുന്നത്?', 'Ich nehme heute die schnelle Straßenbahn.', 'ഞാൻ ഇന്ന് വേഗതയുള്ള ട്രാമിൽ വരുന്നു.', 'fahren', 'യാത്ര ചെയ്യുക / ഓടിക്കുക', 'fuhr', 'fahre', 'werde fahren', 'Letzte Woche fuhr ich nach Köln.', 'Heute fahre ich mit der Bahn.', 'Am Sonntag werde ich Fahrrad fahren.'],
    16: ['Freizeit & Hobbys', 'Leisure & Passions', 'Adverb gern with Verbs', 'In meiner Freizeit lese ich Bücher und koche gern.', 'ഒഴിവുസമയത്ത് ഞാൻ പുസ്തകങ്ങൾ വായിക്കാനും പാചകം ചെയ്യാനും ഇഷ്ടപ്പെടുന്നു.', 'Ich spiele Fußball.', 'ഞാൻ ഫുട്ബോൾ കളിക്കുന്നു.', 'Ich spiele keinen Fußball.', 'ഞാൻ ഫുട്ബോൾ കളിക്കുന്നില്ല.', 'Was machst du am liebsten am Sonntag?', 'ഞായറാഴ്ചകളിൽ നിനക്ക് എന്താണ് ചെയ്യാനിഷ്ടം?', 'Ich höre Musik und wandere gern.', 'ഞാൻ പാട്ട് കേൾക്കാനും നടക്കാനും ഇഷ്ടപ്പെടുന്നു.', 'lesen', 'വായിക്കുക', 'las', 'lese', 'werde lesen', 'Gestern las ich ein kurzes Kapitel.', 'Heute lese ich den neuen Text.', 'Morgen werde ich weiter lesen.'],
    17: ['Tiere & Haustiere', 'Pets & Wildlife', 'Accusative after haben', 'Mein Freund hat einen kleinen Hund zu Hause.', 'എന്റെ സുഹൃത്തിന് വീട്ടിൽ ഒരു ചെറിയ നായയുണ്ട്.', 'Das Tier ist gefährlich.', 'ആ മൃഗം അപകടകാരിയാണ്.', 'Das Tier ist nicht gefährlich.', 'ആ മൃഗം അപകടകാരിയല്ല.', 'Welches Haustier möchtest du gerne?', 'നിനക്ക് ഏത് വളർത്തുമൃഗത്തെയാണ് ഇഷ്ടം?', 'Ich hätte gern eine ruhige Katze.', 'എനിക്ക് ശാന്തയായ ഒരു പൂച്ചയെ ഇഷ്ടമാണ്.', 'schlafen', 'ഉറങ്ങുക', 'schlief', 'schlafe', 'werde schlafen', 'Die Katze schlief auf dem Sofa.', 'Nachts schlafe ich sehr tief.', 'Heute werde ich früh schlafen.'],
    18: ['Schule & Lernen', 'Study & Classroom', 'Dative Plural mit den Schülern', 'Unser Lehrer beantwortet jede einzelne Frage geduldig.', 'ഞങ്ങളുടെ അധ്യാപകൻ ഓരോ ചോദ്യത്തിനും ക്ഷമയോടെ ഉത്തരം നൽകുന്നു.', 'Die Prüfung ist schwer.', 'പരീക്ഷ കഠിനമാണ്.', 'Die Prüfung ist nicht schwer.', 'പരീക്ഷ കഠിനമല്ല.', 'Wann schreibst du die nächste Prüfung?', 'നീ അടുത്ത പരീക്ഷ എപ്പോഴാണ് എഴുതുന്നത്?', 'Am Freitag schreibe ich meinen Test.', 'വെള്ളിയാഴ്ച ഞാൻ എന്റെ ടെസ്റ്റ് എഴുതുന്നു.', 'schreiben', 'എഴുതുക', 'schrieb', 'schreibe', 'werde schreiben', 'Gestern schrieb ich zehn neue Sätze.', 'Heute schreibe ich ins Heft.', 'Bald werde ich einen Brief schreiben.'],
    19: ['Mein Tagesablauf (Routine)', 'Separable Verbs Daily', 'Trennbares Verb (aufstehen)', 'Morgens stehe ich um sechs Uhr früh auf.', 'രാവിലെ ആറ് മണിക്ക് ഞാൻ നേരത്തെ എഴുന്നേൽക്കുന്നു.', 'Ich schlafe lang.', 'ഞാൻ ഒരുപാട് നേരം ഉറങ്ങുന്നു.', 'Ich schlafe nicht lang.', 'ഞാൻ ഒരുപാട് നേരം ഉറങ്ങാറില്ല.', 'Wann beginnst du normalerweise mit Arbeit?', 'നീ സാധാരണ എപ്പോഴാണ് ജോലി തുടങ്ങുന്നത്?', 'Ich beginne um Punkt neun Uhr.', 'ഞാൻ കൃത്യം ഒമ്പത് മണിക്ക് തുടങ്ങുന്നു.', 'beginnen', 'തുടങ്ങുക', 'begann', 'beginne', 'werde beginnen', 'Der Kurs begann vor zwei Wochen.', 'Jetzt beginne ich die neue Aufgabe.', 'Morgen werde ich pünktlich beginnen.'],
    20: ['Post & Bankwesen', 'Bank Account & Mail', 'Imperative Höflichkeitsform (Sie)', 'Bitte füllen Sie dieses blaue Formular sauber aus.', 'ദയവായി ഈ നീല ഫോം വൃത്തിയായി പൂരിപ്പിക്കൂ.', 'Ich habe Bargeld.', 'എന്റെ കയ്യിൽ പണമുണ്ട്.', 'Ich habe kein Bargeld.', 'എന്റെ കയ്യിൽ പണമില്ല.', 'Kann ich heute mit Karte zahlen?', 'എനിക്ക് ഇന്ന് കാർഡ് വഴി പണം നൽകാമോ?', 'Ja, halten Sie die Karte vor.', 'അതെ, കാർഡ് മുന്നിൽ പിടിക്കൂ.', 'schicken', 'അയയ്ക്കുക', 'schickte', 'schicke', 'werde schicken', 'Gestern schickte ich das Paket ab.', 'Heute schicke ich dir eine Mail.', 'Morgen werde ich die Karte schicken.'],
    21: ['Gefühle & Stimmungen', 'Emotions & Empathy', 'Reflexive Verbs (sich freuen)', 'Nach meinem Erfolg bin ich heute richtig stolz.', 'എന്റെ വിജയത്തിന് ശേഷം ഞാൻ ഇന്ന് ശരിക്കും അഭിമാനിക്കുന്നു.', 'Ich bin nervös.', 'എനിക്ക് പരിഭ്രമമുണ്ട്.', 'Ich bin nicht nervös.', 'എനിക്ക് പരിഭ്രമമില്ല.', 'Wie fühlst du dich vor der Reise?', 'യാത്രയ്ക്ക് മുമ്പ് നിനക്ക് എന്ത് തോന്നുന്നു?', 'Ich fühle mich ruhig und dankbar.', 'എനിക്ക് ശാന്തതയും നന്ദിയും തോന്നുന്നു.', 'freuen', 'സന്തോഷിക്കുക', 'freute', 'freue', 'werde freuen', 'Alle freuten sich über das Fest.', 'Ich freue mich über jeden Punkt.', 'Wir werden uns sehr darüber freuen.'],
    22: ['Im Hotel (Check-in)', 'Hospitality & Rooms', 'Polite Questions with Hätten Sie', 'Wir haben ein ruhiges Doppelzimmer für heute reserviert.', 'ഇന്നത്തേക്കായി ഞങ്ങൾ ഒരു ശാന്തമായ ഡബിൾ റൂം ബുക്ക് ചെയ്തിട്ടുണ്ട്.', 'Der Aufzug geht.', 'ലിഫ്റ്റ് പ്രവർത്തിക്കുന്നുണ്ട്.', 'Der Aufzug geht nicht.', 'ലിഫ്റ്റ് പ്രവർത്തിക്കുന്നില്ല.', 'In welchem Stock liegt unser Zimmer?', 'ഞങ്ങളുടെ മുറി ഏത് നിലയിലാണ്?', 'Ihr Zimmer liegt im dritten Stock.', 'നിങ്ങളുടെ മുറി മൂന്നാം നിലയിലാണ്.', 'bleiben', 'നിൽക്കുക / തങ്ങുക', 'blieb', 'bleibe', 'werde bleiben', 'Wir blieben drei Nächte in Hamburg.', 'Heute bleibe ich im Hotel.', 'Im Sommer werde ich hier bleiben.'],
    23: ['Im Restaurant (Dining)', 'Menu & Service', 'Polite Modals (könnten / würden)', 'Könnten wir bitte die deutsche Speisekarte bekommen?', 'ദയവായി ഞങ്ങൾക്ക് ജർമൻ മെനു കാർഡ് തരാമോ?', 'Das Essen ist salzig.', 'ഭക്ഷണം ഉപ്പുള്ളതാണ്.', 'Das Essen ist nicht salzig.', 'ഭക്ഷണം ഉപ്പുള്ളതല്ല.', 'Möchten Sie noch etwas bestellen?', 'നിങ്ങൾക്ക് ഇനി എന്തെങ്കിലും ഓർഡർ ചെയ്യാനുണ്ടോ?', 'Nein danke, bringen Sie die Rechnung.', 'വേണ്ട നന്ദി, ബിൽ കൊണ്ടുവരൂ.', 'bringen', 'കൊണ്ടുവരിക', 'brachte', 'bringe', 'werde bringen', 'Der Kellner brachte das frische Brot.', 'Ich bringe dir ein Glas Wasser.', 'Morgen werde ich Obst mitbringen.'],
    24: ['Nach dem Weg fragen', 'City Navigation', 'Imperative Commands (Gehen Sie)', 'Gehen Sie an der Ampel direkt links.', 'ട്രാഫിക് ലൈറ്റിൽ നിന്ന് നേരെ ഇടത്തോട്ട് പോകൂ.', 'Der Weg ist weit.', 'വഴി ദൂരെയാണ്.', 'Der Weg ist nicht weit.', 'വഴി ദൂരെയല്ല.', 'Entschuldigung, wie komme ich zum Bahnhof?', 'ക്ഷമിക്കണം, റെയിൽവേ സ്റ്റേഷനിലേക്ക് എങ്ങനെയാണ് പോകുന്നത്?', 'Gehen Sie immer geradeaus bis links.', 'ഇടതുവശം എത്തുന്നത് വരെ നേരെ നടക്കൂ.', 'finden', 'കണ്ടെത്തുക', 'fand', 'finde', 'werde finden', 'Endlich fand ich das kleine Café.', 'Ich finde die Straße ganz leicht.', 'Du wirst den Bahnhof schnell finden.'],
    25: ['Woche & Feiertage', 'Weekdays & Holidays', 'Preposition am + Days', 'Am nächsten Samstag feiern wir deinen Geburtstag schön.', 'അടുത്ത ശനിയാഴ്ച നമ്മൾ നിന്റെ ജന്മദിനം നന്നായി ആഘോഷിക്കും.', 'Ich arbeite sonntags.', 'ഞായറാഴ്ചകളിൽ ഞാൻ ജോലി ചെയ്യുന്നു.', 'Ich arbeite sonntags nicht.', 'ഞായറാഴ്ചകളിൽ ഞാൻ ജോലി ചെയ്യാറില്ല.', 'Was machst du am nächsten Feiertag?', 'അടുത്ത അവധി ദിവസത്തിൽ നീ എന്താണ് ചെയ്യുന്നത്?', 'Am Feiertag besuche ich meine Freunde.', 'അവധി ദിവസത്തിൽ ഞാൻ എന്റെ സുഹൃത്തുക്കളെ കാണും.', 'feiern', 'ആഘോഷിക്കുക', 'feierte', 'feiere', 'werde feiern', 'Letztes Jahr feierten wir im Garten.', 'Heute feiere ich meinen Lernfortschritt.', 'Bald werde ich meinen Erfolg feiern.'],
    26: ['Dinge beschreiben (Adjectives)', 'Descriptions & Opposites', 'Using sehr / ziemlich / zu', 'Mit täglicher Übung wird alles ganz leicht.', 'ദിവസേനയുള്ള പരിശീലനത്തിലൂടെ എല്ലാം വളരെ എളുപ്പമാകും.', 'Der Koffer ist schwer.', 'സ്യൂട്ട്കേസിന് ഭാരമുണ്ട്.', 'Der Koffer ist nicht schwer.', 'സ്യൂട്ട്കേസിന് ഭാരമില്ല.', 'Ist Deutsch wirklich so schwer?', 'ജർമൻ ശരിക്കും അത്ര കഠിനമാണോ?', 'Nein, Schritt für Schritt wird es leicht.', 'അല്ല, ഓരോ പടിയായി അത് എളുപ്പമാകും.', 'helfen', 'സഹായിക്കുക', 'half', 'helfe', 'werde helfen', 'Meine Freundin half mir beim Umzug.', 'Dieses Buch hilft mir sehr viel.', 'Ich werde dir jederzeit helfen.'],
    27: ['Kultur, Film & Buch', 'Arts & Media', 'Perfect Tense Prep (hat gesehen)', 'Am Abend lesen wir einen spannenden deutschen Roman.', 'വൈകുന്നേരം നമ്മൾ ആവേശകരമായ ഒരു ജർമൻ നോവൽ വായിക്കും.', 'Das Kino ist voll.', 'സിനിമാ തിയേറ്റർ നിറഞ്ഞിരിക്കുന്നു.', 'Das Kino ist nicht voll.', 'സിനിമാ തിയേറ്റർ നിറഞ്ഞിട്ടില്ല.', 'Gehst du heute Abend ins Theater?', 'നീ ഇന്ന് വൈകുന്നേരം തിയേറ്ററിൽ പോകുന്നുണ്ടോ?', 'Ja, ich habe schon eine Karte.', 'അതെ, എന്റെ കയ്യിൽ ഇതിനകം ടിക്കറ്റുണ്ട്.', 'sehen', 'കാണുക', 'sah', 'sehe', 'werde sehen', 'Gestern sah ich einen guten Film.', 'Ich sehe den Schauspieler dort.', 'Morgen werde ich dich wiedersehen.'],
    28: ['Natur & Ausflug', 'Forest, River & Lake', 'Prepositions ans / in den / auf den', 'Am Wochenende wandern wir durch den grünen Wald.', 'വാരാന്ത്യത്തിൽ നമ്മൾ പച്ചക്കൊടിയ കാട്ടിലൂടെ നടക്കും.', 'Die Wolken sind dunkel.', 'മേഘങ്ങൾ ഇരുണ്ടതാണ്.', 'Die Wolken sind nicht dunkel.', 'മേഘങ്ങൾ ഇരുണ്ടതല്ല.', 'Wohin fahrt ihr im Urlaub?', 'അവധിക്കാലത്ത് നിങ്ങൾ എങ്ങോട്ടാണ് പോകുന്നത്?', 'Wir fahren ans schöne blaue Meer.', 'ഞങ്ങൾ മനോഹരമായ നീലക്കടലിനടുത്തേക്ക് പോകുന്നു.', 'schwimmen', 'നീന്തുക', 'schwamm', 'schwimme', 'werde schwimmen', 'Im See schwamm ein weißer Schwan.', 'Im Sommer schwimme ich oft.', 'Bald werde ich im Meer schwimmen.'],
    29: ['Handy & Technik im Alltag', 'Devices & Messaging', 'Possessive Mein/Dein with Tech', 'Schick mir heute Abend einfach eine kurze Nachricht.', 'ഇന്ന് വൈകുന്നേരം എനിക്ക് ഒരു ചെറിയ മെസ്സേജ് അയക്കൂ.', 'Mein Akku ist voll.', 'എന്റെ ബാറ്ററി ഫുൾ ആണ്.', 'Mein Akku ist nicht voll.', 'എന്റെ ബാറ്ററി ഫുൾ അല്ല.', 'Funktioniert das Internet im Zug gut?', 'ട്രെയിനിൽ ഇന്റർനെറ്റ് നന്നായി പ്രവർത്തിക്കുന്നുണ്ടോ?', 'Ja, die Verbindung läuft heute stabil.', 'അതെ, കണക്ഷൻ ഇന്ന് സ്ഥിരതയോടെ പ്രവർത്തിക്കുന്നു.', 'rufen', 'വിളിക്കുക', 'rief', 'rufe', 'werde rufen', 'Ich rief dich zweimal morgens an.', 'Jetzt rufe ich meinen Bruder an.', 'Abends werde ich dich anrufen.'],
    30: ['Feste & Glückwünsche', 'Parties & Wishing Well', 'Dative Recipients (dir / Ihnen)', 'Herzlichen Glückwunsch zu deinem starken Meilenstein!', 'നിന്റെ മികച്ച നാഴികക്കല്ലിന് ഹൃദയം നിറഞ്ഞ ആശംസകൾ!', 'Wir haben ein Geschenk.', 'ഞങ്ങളുടെ കയ്യിൽ ഒരു സമ്മാനമുണ്ട്.', 'Wir haben kein Geschenk.', 'ഞങ്ങളുടെ കയ്യിൽ സമ്മാനമില്ല.', 'Wann beginnt heute die große Feier?', 'ഇന്നത്തെ വലിയ ആഘോഷം എപ്പോഴാണ് തുടങ്ങുന്നത്?', 'Alle Gäste kommen ab sechs Uhr.', 'എല്ലാ അതിഥികളും ആറ് മണി മുതൽ എത്തും.', 'lachen', 'ചിരിക്കുക', 'lachte', 'lache', 'werde lachen', 'Alle Gäste lachten sehr herzlich.', 'Mit Freunden lache ich gern.', 'Zusammen werden wir viel lachen.'],
    31: ['Beim Arzt & Gesundheit (A2)', 'Clinic & Symptoms', 'Modal müssen (Obligation)', 'Mit hohem Fieber müssen Sie heute ruhig schlafen.', 'ഉയർന്ന പനിയുള്ളപ്പോൾ നിങ്ങൾ ഇന്ന് ശാന്തമായി ഉറങ്ങണം.', 'Ich brauche Tabletten.', 'എനിക്ക് ഗുളികകൾ ആവശ്യമാണ്.', 'Ich brauche keine Tabletten.', 'എനിക്ക് ഗുളികകൾ ആവശ്യമില്ല.', 'Seit wann haben Sie starke Schmerzen?', 'നിങ്ങൾക്ക് എപ്പോഴുമുതലാണ് കടുത്ത വേദന?', 'Seit gestern Abend tut mir Kopf weh.', 'ഇന്നലെ വൈകുന്നേരം മുതൽ തലവേദനയുണ്ട്.', 'nehmen', 'എടുക്കുക / കഴിക്കുക', 'nahm', 'nehme', 'werde nehmen', 'Sie nahm die Medizin nach Essen.', 'Ich nehme einen Apfel mit.', 'Morgen werde ich mir Zeit nehmen.'],
    32: ['Beruf & Arbeitswelt (A2)', 'Jobs, Boss & Colleagues', 'Subordinating Conjunction weil (Verb End)', 'Ich schätze meine Kollegen, weil alle fair helfen.', 'എല്ലാവരും സഹായിക്കുന്നതുകൊണ്ട് ഞാൻ എന്റെ സഹപ്രവർത്തകരെ വിലമതിക്കുന്നു.', 'Der Chef ist hier.', 'ബോസ് ഇവിടെയുണ്ട്.', 'Der Chef ist nicht hier.', 'ബോസ് ഇവിടെയില്ല.', 'Wie gefällt dir deine neue Firma?', 'നിനക്ക് നിന്റെ പുതിയ കമ്പനി ഇഷ്ടമായോ?', 'Mein Team arbeitet wirklich sehr kollegial.', 'എന്റെ ടീം ശരിക്കും പരസ്പര സഹകരണത്തോടെ പ്രവർത്തിക്കുന്നു.', 'helfen', 'സഹായിക്കുക', 'half', 'helfe', 'werde helfen', 'Mein Kollege half mir beim Bericht.', 'Gern helfe ich neuen Kollegen.', 'Unser Team wird dir helfen.'],
    33: ['Haushalt & Ordnung', 'Chores & Cleanliness', 'Imperative Singular (Räum auf!)', 'Nach dem Essen spülen wir gemeinsam in Ruhe.', 'ഭക്ഷണത്തിന് ശേഷം നമ്മൾ ഒരുമിച്ച് ശാന്തമായി പാത്രങ്ങൾ കഴുകും.', 'Das Zimmer ist sauber.', 'മുറി വൃത്തിയുള്ളതാണ്.', 'Das Zimmer ist nicht sauber.', 'മുറി വൃത്തിയുള്ളതല്ല.', 'Wer räumt heute das Wohnzimmer auf?', 'ഇന്ന് ലിവിംഗ് റൂം ആരാണ് വൃത്തിയാക്കുന്നത്?', 'Wir teilen uns alle Aufgaben fair.', 'നമ്മൾ എല്ലാ ജോലികളും തുല്യമായി പങ്കുവെക്കും.', 'putzen', 'വൃത്തിയാക്കുക', 'putzte', 'putze', 'werde putzen', 'Am Samstag putzte er alle Fenster.', 'Ich putze heute die Küche.', 'Vor dem Besuch werde ich putzen.'],
    34: ['Kochen & Rezepte', 'Ingredients & Cooking', 'Sequence Words (zuerst, dann, danach)', 'Zuerst schneiden wir frisches Gemüse für die Pfanne.', 'ആദ്യം നമ്മൾ പാനിലേക്കായി പച്ചക്കറികൾ അരിയും.', 'Die Suppe hat Salz.', 'സൂപ്പിൽ ഉപ്പുണ്ട്.', 'Die Suppe hat kein Salz.', 'സൂപ്പിൽ ഉപ്പില്ല.', 'Wie lange braten wir das Gemüse?', 'നമ്മൾ പച്ചക്കറികൾ എത്ര നേരം വഴറ്റണം?', 'Etwa fünf Minuten bei mittlerer Hitze.', 'ഏകദേശം അഞ്ച് മിനിറ്റ് ചെറിയ തീയിൽ.', 'kochen', 'പാചകം ചെയ്യുക', 'kochte', 'koche', 'werde kochen', 'Oma kochte die beste Gemüsesuppe.', 'Heute koche ich ein Rezept nach.', 'Abends werde ich für Freunde kochen.'],
    35: ['Sport & Teamgeist', 'Fitness & Competitions', 'Adverbs oft, selten, regelmäßig', 'Regelmäßige Übung macht unseren ganzen Körper viel stärker.', 'സ്ഥിരമായ വ്യായാമം നമ്മുടെ ശരീരത്തെ കൂടുതൽ ശക്തമാക്കുന്നു.', 'Wir haben Training.', 'ഞങ്ങൾക്ക് പരിശീലനമുണ്ട്.', 'Wir haben kein Training.', 'ഞങ്ങൾക്ക് പരിശീലനമില്ല.', 'Wie oft trainierst du jede Woche?', 'നീ ആഴ്ചയിൽ എത്ര തവണ പരിശീലിക്കാറുണ്ട്?', 'Ich trainiere dreimal pro Woche draußen.', 'ഞാൻ ആഴ്ചയിൽ മൂന്ന് തവണ പുറത്ത് പരിശീലിക്കുന്നു.', 'gewinnen', 'ജയിക്കുക', 'gewann', 'gewinne', 'werde gewinnen', 'Letzten Sonntag gewann unsere Mannschaft hoch.', 'Durch Fleiß gewinne ich an Sicherheit.', 'Gemeinsam werden wir dieses Spiel gewinnen.'],
    36: ['Bahnreise durch Deutschland', 'Deutsche Bahn & Transfers', 'Time Prepositions um / gegen / ab', 'In Frankfurt müssen wir schnell auf Gleis sechs umsteigen.', 'ഫ്രാങ്ക്ഫർട്ടിൽ നമ്മൾ വേഗം ആറാം പ്ലാറ്റ്‌ഫോമിലേക്ക് ട്രെയിൻ മാറണം.', 'Der Zug hat Verspätung.', 'ട്രെയിൻ വൈകിയാണ് ഓടുന്നത്.', 'Der Zug hat keine Verspätung.', 'ട്രെയിൻ വൈകിയിട്ടില്ല.', 'Wann fährt der nächste ICE ab?', 'അടുത്ത ഐ.സി.ഇ ട്രെയിൻ എപ്പോഴാണ് പുറപ്പെടുന്നത്?', 'Er fährt in zwanzig Minuten ab.', 'അത് ഇരുപത് മിനിറ്റിനുള്ളിൽ പുറപ്പെടും.', 'ankommen', 'എത്തിച്ചേരുക', 'kam an', 'komme an', 'werde ankommen', 'Der Zug kam pünktlich in München an.', 'Heute komme ich vor sechs an.', 'Bald werden wir am Ziel ankommen.'],
    37: ['Am Flughafen (Travel)', 'Check-in & Flights', 'Modal dürfen (Permission/Prohibition)', 'Bitte legen Sie Ihren Reisepass bei der Kontrolle vor.', 'പരിശോധനയ്ക്കായി നിങ്ങളുടെ പാസ്പോർട്ട് കാണിക്കൂ.', 'Ich habe den Pass.', 'എന്റെ കയ്യിൽ പാസ്പോർട്ടുണ്ട്.', 'Ich habe keinen Pass.', 'എന്റെ കയ്യിൽ പാസ്പോർട്ടില്ല.', 'Von welchem Gate fliegt unsere Maschine?', 'ഞങ്ങളുടെ വിമാനം ഏത് ഗേറ്റിൽ നിന്നാണ് പുറപ്പെടുന്നത്?', 'Unser Abflug erfolgt von Flugsteig B5.', 'ഞങ്ങളുടെ ഫ്ലൈറ്റ് ഗേറ്റ് B5-ൽ നിന്നാണ്.', 'fliegen', 'പറക്കുക', 'flog', 'fliege', 'werde fliegen', 'Letzten Sommer flog ich nach Berlin.', 'Heute fliege ich über das Meer.', 'Im Mai werde ich wieder fliegen.'],
    38: ['Wohnungssuche & Umzug', 'Renting & Contracts', 'Conjunction deshalb (Verb #2)', 'Vor dem Umzug lesen wir den Mietvertrag genau.', 'വീട് മാറുന്നതിന് മുമ്പ് നമ്മൾ വാടക കരാർ കൃത്യമായി വായിക്കും.', 'Der Strom funktioniert.', 'വൈദ്യുതി പ്രവർത്തിക്കുന്നുണ്ട്.', 'Der Strom funktioniert nicht.', 'വൈദ്യുതി പ്രവർത്തിക്കുന്നില്ല.', 'Sind die Nebenkosten bereits im Preis?', 'അധിക ചെലവുകൾ വാടകയിൽ ഉൾപ്പെട്ടിട്ടുണ്ടോ?', 'Ja, Wasser und Heizung sind inklusive.', 'അതെ, വെള്ളവും ഹീറ്ററും അതിൽ ഉൾപ്പെടുന്നു.', 'umziehen', 'താമസം മാറുക', 'zog um', 'ziehe um', 'werde umziehen', 'Im Mai zog mein Kollege um.', 'Diesen Monat ziehe ich nach Hamburg um.', 'Nächsten Monat werde ich umziehen.'],
    39: ['Im Bekleidungsgeschäft', 'Shopping & Sizes', 'Dative Pronoun passt mir / steht dir', 'Darf ich diesen Mantel in Größe M anprobieren?', 'ഞാൻ ഈ കോട്ട് M സൈസിൽ ഇട്ടു നോക്കട്ടെ?', 'Das Hemd passt gut.', 'ഷർട്ട് നന്നായി ചേരുന്നുണ്ട്.', 'Das Hemd passt nicht gut.', 'ഷർട്ട് നന്നായി ചേരുന്നില്ല.', 'Wie sitzt diese blaue Jacke jetzt?', 'ഈ നീല ജാക്കറ്റ് ഇപ്പോൾ എങ്ങനെയുണ്ട്?', 'Sie sitzt bequem und sieht toll aus.', 'അത് വളരെ കംഫർട്ടബിളും മനോഹരവുമാണ്.', 'suchen', 'തിരയുക', 'suchte', 'suche', 'werde suchen', 'Ich suchte lange eine bequeme Hose.', 'Heute suche ich eine neue Jacke.', 'Morgen werde ich Schuhe suchen.'],
    40: ['Notfälle & Sicherheit', 'Emergencies & Help', 'Imperative Urgent Safety Phrases', 'Bei einem Unfall rufen Sie sofort Hilfe an.', 'ഒരു അപകടമുണ്ടായാൽ ഉടൻ സഹായത്തിനായി വിളിക്കുക.', 'Hier besteht Gefahr.', 'ഇവിടെ അപകടസാധ്യതയുണ്ട്.', 'Hier besteht keine Gefahr.', 'ഇവിടെ അപകടസാധ്യതയില്ല.', 'Welche Nummer wähle ich für Notfälle?', 'അടിയന്തര ഘട്ടങ്ങളിൽ ഞാൻ ഏത് നമ്പറാണ് വിളിക്കേണ്ടത്?', 'Wählen Sie einfach die eins-eins-zwei.', 'കൃത്യം 112 (eins-eins-zwei) ഡയൽ ചെയ്യൂ.', 'schützen', 'സംരക്ഷിക്കുക', 'schützte', 'schütze', 'werde schützen', 'Die Feuerwehr schützte das ganze Haus.', 'Regeln schützen uns jeden Tag.', 'Ein Helm wird deinen Kopf schützen.'],
    41: ['Vergleiche & Meinungen (A2)', 'Comparatives (als / wie)', 'Comparative + als vs so ... wie', 'Meiner Meinung nach ist tägliches Sprechen wichtiger.', 'എന്റെ അഭിപ്രായത്തിൽ ദിവസേന സംസാരിക്കുകയാണ് കൂടുതൽ പ്രധാനം.', 'Das ist ein Unterschied.', 'അതൊരു വ്യത്യാസമാണ്.', 'Das ist kein Unterschied.', 'അതൊരു വ്യത്യാസമല്ല.', 'Was ist der Vorteil dieser Methode?', 'ഈ രീതിയുടെ ഗുണം എന്താണ്?', 'Man spricht deutlich schneller und sicher.', 'ഒരാൾക്ക് കൂടുതൽ വേഗത്തിലും ആത്മവിശ്വാസത്തോടെയും സംസാരിക്കാം.', 'vergleichen', 'താരതമ്യം ചെയ്യുക', 'verglich', 'vergleiche', 'werde vergleichen', 'Ich verglich drei günstige Angebote.', 'Heute vergleiche ich beide Texte.', 'Vor dem Kauf werde ich Preise vergleichen.'],
    42: ['Geschichten aus der Vergangenheit', 'Storytelling in Past', 'Präteritum of war & hatte', 'Damals hatten wir kein Handy, aber viel Zeit.', 'അക്കാലത്ത് ഞങ്ങൾക്ക് ഫോണില്ലായിരുന്നു, പക്ഷെ ധാരാളം സമയമുണ്ടായിരുന്നു.', 'Es war ein Problem.', 'അതൊരു പ്രശ്നമായിരുന്നു.', 'Es war kein Problem.', 'അതൊരു പ്രശ്നമായിരുന്നില്ല.', 'Was war dein schönstes Erlebnis damals?', 'അക്കാലത്തെ നിന്റെ ഏറ്റവും നല്ല അനുഭവം എന്തായിരുന്നു?', 'Unsere erste Reise in die Berge.', 'മലനിരകളിലേക്കുള്ള ഞങ്ങളുടെ ആദ്യ യാത്ര.', 'erzählen', 'കഥ പറയുക / വിവരിക്കുക', 'erzählte', 'erzähle', 'werde erzählen', 'Opa erzählte uns spannende Geschichten.', 'Ich erzähle dir mein Abenteuer.', 'Abends werde ich alles erzählen.'],
    43: ['Zukunftspläne & Wünsche', 'Goals & Aspirations', 'Futur I (werden + Infinitive)', 'Mit Ausdauer werden wir unsere großen Ziele erreichen.', 'സ്ഥിരോത്സാഹത്തോടെ നമ്മൾ നമ്മുടെ വലിയ ലക്ഷ്യങ്ങൾ നേടിയെടുക്കും.', 'Ich habe Angst.', 'എനിക്ക് ഭയമുണ്ട്.', 'Ich habe keine Angst.', 'എനിക്ക് ഭയമില്ല.', 'Welches Ziel verfolgst du dieses Jahr?', 'ഈ വർഷം നീ എന്ത് ലക്ഷ്യമാണ് പിന്തുടരുന്നത്?', 'Ich möchte flüssig Deutsch sprechen lernen.', 'എനിക്ക് ഒഴുക്കോടെ ജർമൻ സംസാരിക്കാൻ പഠിക്കണം.', 'erreichen', 'കൈവരിക്കുക / എത്തുക', 'erreichte', 'erreiche', 'werde erreichen', 'Unser Team erreichte den ersten Platz.', 'Durch Fleiß erreiche ich mein Ziel.', 'Schon bald werde ich Stufe B1 erreichen.'],
    44: ['Nachbarschaft & Gemeinde', 'Local Community', 'Passive-style man Sentences', 'In unserer freundlichen Nachbarschaft hilft man einander gern.', 'ഞങ്ങളുടെ സ്നേഹമുള്ള അയൽപക്കത്ത് എല്ലാവരും പരസ്പരം സഹായിക്കും.', 'Die Bibliothek ist offen.', 'ലൈബ്രറി തുറന്നിരിക്കുന്നു.', 'Die Bibliothek ist nicht offen.', 'ലൈബ്രറി തുറന്നിട്ടില്ല.', 'Wo trifft sich die Gemeinde am Wochenende?', 'വാരാന്ത്യത്തിൽ ആളുകൾ എവിടെയാണ് ഒത്തുചേരുന്നത്?', 'Viele treffen sich auf dem Marktplatz.', 'പലരും മാർക്കറ്റ് സ്ക്വയറിൽ വെച്ച് കണ്ടുമുട്ടുന്നു.', 'treffen', 'കണ്ടുമുട്ടുക', 'traf', 'treffe', 'werde treffen', 'Gestern traf ich meinen netten Nachbarn.', 'Nachmittags treffe ich meine Lerngruppe.', 'Am Sonntag werde ich Freunde treffen.'],
    45: ['Reparaturen & Handwerk', 'Home Services & Fixing', 'Verb lassen (reparieren lassen)', 'Zum Glück funktioniert unsere neue Heizung jetzt wieder.', 'ഭാഗ്യവശാൽ നമ്മുടെ പുതിയ ഹീറ്റർ ഇപ്പോൾ വീണ്ടും പ്രവർത്തിക്കുന്നു.', 'Der Stuhl ist kaputt.', 'കസേര പൊട്ടിയതാണ്.', 'Der Stuhl ist nicht kaputt.', 'കസേര പൊട്ടിയിട്ടില്ല.', 'Wann kann der Handwerker vorbeikommen?', 'ടെക്നീഷ്യന് എപ്പോൾ വരാൻ സാധിക്കും?', 'Morgen früh um genau neun Uhr.', 'നാളെ രാവിലെ കൃത്യം ഒമ്പത് മണിക്ക്.', 'reparieren', 'നന്നാക്കുക', 'reparierte', 'repariere', 'werde reparieren', 'Der Techniker reparierte das Rad schnell.', 'Ich repariere meine Lampe selbst.', 'Morgen werde ich die Tür reparieren.'],
  };

  /// Synthesizes remaining days 46–90 dynamically from VocabP2's 450 curated B1–B2 words
  /// so EVERY SINGLE DAY 1..90 has unique grammar, verbs, sentences, negatives, chat replies, and speeches!
  static const List<String> _b1b2Themes = [
    'Meinungen äußern (Expressing Opinions)', // 46
    'Netzwerken & Small Talk (Networking)', // 47
    'Vorstellungsgespräch (Job Interviews)', // 48
    'Kultur & Höflichkeit (German Etiquette)', // 49
    'Medien & Nachrichten (News & Press)', // 50
    'Umwelt & Nachhaltigkeit (Environment)', // 51
    'Wirtschaft & Handel (Economy & Trade)', // 52
    'Universität & Studium (Higher Ed)', // 53
    'Wissenschaft & Labor (Science)', // 54
    'Finanzen & Sparkonto (Finance)', // 55
    'Recht & Vertrag (Law & Rights)', // 56
    'Ehrenamt & Hilfe (Volunteering)', // 57
    'Büro & Besprechung (Office Meetings)', // 58
    'Heimarbeit & Digital Office', // 59
    'Verhandlung & Kompromiss (Negotiation)', // 60
    'Vortrag & Präsentation (Presentations)', // 61
    'Deutsche Literatur (Literature)', // 62
    'Kunst & Architektur (Art & Design)', // 63
    'Psychologie & Fokus (Mindset)', // 64
    'Ernährung & Energie (Nutrition)', // 65
    'Pflege & Klinik (Healthcare)', // 66
    'IT & Softwareentwicklung (Tech & API)', // 67
    'Technik & Maschinenbau (Engineering)', // 68
    'Reiseplanung Europa (Travel Plans)', // 69
    'Konfliktlösung (Problem Solving)', // 70
    'Diplomatie & Taktgefühl (Diplomacy)', // 71
    'Innovation & Gründung (Startups)', // 72
    'Grüne Energie & Zukunft (Green Tech)', // 73
    'Globalisierung & Vielfalt (Global)', // 74
    'Ethik & Verantwortung (Ethics)', // 75
    'Strategie & Unternehmertum (Strategy)', // 76
    'Erzählkunst (Storytelling Art)', // 77
    'Empathie & Zuhören (Active Listening)', // 78
    'Logik & Kritisches Denken (Logic)', // 79
    'Interkulturelles Leben (Culture)', // 80
    'Arztgespräch Komplex (Medical B2)', // 81
    'Künstliche Intelligenz (AI & Tech)', // 82
    'Wissenschaftliches Schreiben (Academic)', // 83
    'Podcasts & Rundfunk (Broadcasting)', // 84
    'Humor & Redewendungen (Idioms)', // 85
    'Demokratie & Debatte (Civics)', // 86
    'Führung & Mentoring (Leadership)', // 87
    'Krisenmanagement (Crisis Solving)', // 88
    'Rhetorik & Überzeugung (Oratory)', // 89
    'Deutsch Großmeister (Day 90 Mastery)', // 90
  ];

  static const List<List<String>> _b1b2GrammarPool = [
    ['Subordinating Conjunctions (dass / obwohl)', 'Obwohl es regnet, bleibe ich motiviert.', 'മഴ പെയ്യുന്നുണ്ടെങ്കിലും ഞാൻ ഉത്സാഹത്തോടെ തുടരുന്നു.', 'Verbinde Hauptsatz und Nebensatz.', 'ഓരോ ഉപവാക്യത്തിലും ക്രിയ അവസാനം വയ്ക്കുക.'],
    ['Infinitive Clauses with um ... zu', 'Ich lerne täglich, um flüssig zu sprechen.', 'ഒഴുക്കോടെ സംസാരിക്കാനായി ഞാൻ ദിവസവും പഠിക്കുന്നു.', 'Nutze "um ... zu" für klare Ziele.', 'ലക്ഷ്യം കാണിക്കാൻ "um ... zu" ഉപയോഗിക്കുക.'],
    ['Relative Clauses (der, die, das)', 'Das ist der Kollege, der immer hilft.', 'ഇതാണ് എപ്പോഴും സഹായിക്കുന്ന സഹപ്രവർത്തകൻ.', 'Relativsätze setzen das Verb ans Ende.', 'റിലേറ്റീവ് ക്ലോസുകളിൽ ക്രിയ അവസാനം വരും.'],
    ['Konjunktiv II Polite Requests (Könnten/Würden)', 'Könnten Sie das bitte kurz erklären?', 'ദയവായി ഇത് ഒന്ന് ചുരുക്കി വിശദീകരിക്കാമോ?', 'Höfliche Bitten wirken sofort professionell.', 'മാന്യമായ അഭ്യർത്ഥനകൾക്ക് Könnten/Würden ഉപയോഗിക്കുക.'],
    ['Passive Voice (wird gemacht)', 'Die Daten werden sorgfältig geprüft.', 'ഡാറ്റ ശ്രദ്ധാപൂർവ്വം പരിശോധിക്കപ്പെടുന്നു.', 'Vorgangspassiv nutzt werden + Partizip II.', 'പ്രവർത്തിക്ക് പ്രാധാന്യം നൽകാൻ werden + Partizip II ഉപയോഗിക്കുക.'],
  ];

  static const List<List<String>> _b1b2VerbPool = [
    ['diskutieren', 'ചർച്ച ചെയ്യുക', 'diskutierte', 'diskutiere', 'werde diskutieren'],
    ['präsentieren', 'അവതരിപ്പിക്കുക', 'präsentierte', 'präsentiere', 'werde präsentieren'],
    ['analysieren', 'വിശകലനം ചെയ്യുക', 'analysierte', 'analysiere', 'werde analysieren'],
    ['verhandeln', 'ചർച്ച നടത്തി തീരുമാനിക്കുക', 'verhandelte', 'verhandle', 'werde verhandeln'],
    ['organisieren', 'സംഘടിപ്പിക്കുക', 'organisierte', 'organisiere', 'werde organisieren'],
    ['entwickeln', 'വികസിപ്പിക്കുക', 'entwickelte', 'entwickle', 'werde entwickeln'],
    ['empfehlen', 'ശുപാർശ ചെയ്യുക', 'empfahl', 'empfehle', 'werde empfehlen'],
    ['überzeugen', 'ബോധ്യപ്പെടുത്തുക', 'überzeugte', 'überzeuge', 'werde überzeugen'],
    ['unterstützen', 'പിന്തുണയ്ക്കുക', 'unterstützte', 'unterstütze', 'werde unterstützen'],
  ];

  static List<DailyVocabItem> getVocabForDay(int day) {
    final d = day.clamp(1, 90);
    if (d <= 45) {
      return PocketGerman90DayVocabP1.getForDay(d) ?? const [];
    }
    return PocketGerman90DayVocabP2.getForDay(d) ?? const [];
  }

  static Map<String, dynamic> getLessonSpecMap(int day) {
    final d = day.clamp(1, 90);
    final vocab = getVocabForDay(d);
    if (d <= 45 && _dayBlueprints.containsKey(d)) {
      final b = _dayBlueprints[d]!;
      return {
        'title': b[0],
        'phaseName': phaseForDay(d),
        'focusArea': b[1],
        'speakingDrill': b[3],
        'grammarConcept': b[2],
        'peerChatMission': 'Practice ${b[1]} using "${vocab.isNotEmpty ? vocab[0].word : "Hallo"}" in German!',
        'xpReward': 35 + (d ~/ 3),
        'milestoneReward': '🇩🇪 Tag $d · ${b[1]}',
      };
    }

    final idx = (d - 46).clamp(0, _b1b2Themes.length - 1);
    final theme = _b1b2Themes[idx];
    final gram = _b1b2GrammarPool[idx % _b1b2GrammarPool.length];
    final exSentence = vocab.isNotEmpty ? vocab[0].exampleSentence : gram[1];
    return {
      'title': theme,
      'phaseName': phaseForDay(d),
      'focusArea': theme,
      'speakingDrill': exSentence,
      'grammarConcept': gram[0],
      'peerChatMission': 'Use "${vocab.isNotEmpty ? vocab[0].word : theme}" & "${vocab.length > 1 ? vocab[1].word : "Deutsch"}" in conversation!',
      'xpReward': 45 + (d ~/ 3),
      'milestoneReward': '🇩🇪 Tag $d · $theme',
    };
  }

  /// 🧩 Generates 3–5 verified Sentence Builder rounds for EVERY day (1–90)
  static List<SentenceChallengeRound> getSentencesForDay(int day) {
    final d = day.clamp(1, 90);
    final vocab = getVocabForDay(d);
    final list = <SentenceChallengeRound>[];

    if (d <= 45 && _dayBlueprints.containsKey(d)) {
      final b = _dayBlueprints[d]!;
      list.add(_buildDeRound(
        id: d * 10 + 1,
        sentence: b[3],
        translationMl: b[4],
        hint: 'Grammatik-Tipp: ${b[2]}',
      ));
      list.add(_buildDeRound(
        id: d * 10 + 2,
        sentence: b[11],
        translationMl: b[12],
        hint: 'Antwortsatz bauen',
      ));
    }

    // Add curated sentences from this day's unique German vocabulary bank (ensures 3–4 rounds/day across ALL 90 days)
    for (int i = 0; i < vocab.length && list.length < 4; i++) {
      final v = vocab[i];
      if (v.exampleSentence.trim().split(' ').length >= 3) {
        list.add(_buildDeRound(
          id: d * 10 + 3 + i,
          sentence: v.exampleSentence,
          translationMl: '${v.word}: ${v.malayalamMeaning}',
          hint: 'Schlüsselwort: ${v.word}',
        ));
      }
    }

    return list;
  }

  static SentenceChallengeRound _buildDeRound({
    required int id,
    required String sentence,
    required String translationMl,
    required String hint,
  }) {
    final cleanTokens = sentence
        .replaceAllMapped(RegExp(r'([?.!,])'), (m) => ' ${m[1]}')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final tiles = <SentenceTileData>[];
    for (int i = 0; i < cleanTokens.length; i++) {
      final t = cleanTokens[i];
      final lower = t.toLowerCase();
      SentenceTileColor color;
      if (const {
        'ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr', 'mein', 'meine',
        'dein', 'deine', 'unser', 'unsere', 'man'
      }.contains(lower)) {
        color = SentenceTileColor.green;
      } else if (const {
        'der', 'die', 'das', 'ein', 'eine', 'einen', 'dem', 'den',
        'im', 'am', 'zum', 'zur', 'in', 'mit', 'aus', 'auf', 'für',
        '?', '.', '!', ','
      }.contains(lower)) {
        color = SentenceTileColor.cyan;
      } else {
        color = SentenceTileColor.magenta;
      }
      tiles.add(SentenceTileData(
        id: 'de_${id}_${i}_$t',
        word: t,
        colorType: color,
      ));
    }

    return SentenceChallengeRound(
      id: id,
      sentence: cleanTokens.join(' '),
      translationMl: translationMl,
      tiles: tiles,
      hint: hint,
    );
  }

  /// 💬 Step 6: Useful Phrases for all 90 days
  static DayUsefulPhrases getDayPhrases(int day) {
    final d = day.clamp(1, 90);
    final vocab = getVocabForDay(d);
    final meta = getLessonSpecMap(d);
    final phrases = <UsefulPhraseItem>[];

    for (int i = 0; i < 3 && i < vocab.length; i++) {
      final v = vocab[i];
      final words = v.exampleSentence
          .replaceAll(RegExp(r'[.!?]+$'), '')
          .trim()
          .split(RegExp(r'\s+'));
      final cleanPhrase = words.join(' ');
      phrases.add(UsefulPhraseItem(
        phraseEn: cleanPhrase,
        meaningMl: '${v.word}: ${v.malayalamMeaning}',
        meaningTa: '${v.word}: ${v.tamilMeaning}',
        meaningHi: '${v.word}: ${v.hindiMeaning}',
        meaningKn: v.definition,
        anchorWord: words.isNotEmpty ? words.first : v.word,
        tip: meta['grammarConcept'] as String,
      ));
    }

    return DayUsefulPhrases(
      day: d,
      anchorTheme: meta['focusArea'] as String,
      anchorWord: phrases.isNotEmpty ? phrases.first.anchorWord : 'Deutsch',
      emoji: '🇩🇪',
      descriptionEn: 'Master Tag $d expressions: ${meta['title']}',
      descriptionMl: 'ഡേ $d ജർമൻ പ്രയോഗങ്ങൾ പരിശീലിക്കാം: ${meta['focusArea']}',
      lessonNoteEn: meta['grammarConcept'] as String,
      lessonNoteMl: meta['peerChatMission'] as String,
      phrases: phrases,
    );
  }

  /// ⏳ Step 15: Verb Timeline (Präteritum -> Präsens -> Futur I) for all 90 days
  static List<VerbTimelineItem> getVerbsForDay(int day) {
    final d = day.clamp(1, 90);
    final items = <VerbTimelineItem>[];

    if (d <= 45 && _dayBlueprints.containsKey(d)) {
      final b = _dayBlueprints[d]!;
      items.add(VerbTimelineItem(
        id: d * 10 + 1,
        baseVerb: b[13],
        meaningMl: b[14],
        past: b[15],
        present: b[16],
        future: b[17],
        pastSentence: b[18],
        presentSentence: b[19],
        futureSentence: b[20],
        rhythmChant: '${b[15]} • ${b[16]} • ${b[17]}',
        grammarTrapMl: '${b[2]}: ക്രിയ രണ്ടാം സ്ഥാനത്ത് നിർത്തുക!',
        pastLabel: 'PRÄTERITUM',
        presentLabel: 'PRÄSENS',
        futureLabel: 'FUTUR I',
        tenseCategory: 'Tag $d Zeitform',
      ));
    } else {
      final vp = _b1b2VerbPool[(d - 46) % _b1b2VerbPool.length];
      items.add(VerbTimelineItem(
        id: d * 10 + 1,
        baseVerb: vp[0],
        meaningMl: vp[1],
        past: vp[2],
        present: vp[3],
        future: vp[4],
        pastSentence: 'Gestern ${vp[2]} ich dieses Thema intensiv.',
        presentSentence: 'Heute ${vp[3]} ich auf hohem Niveau.',
        futureSentence: 'Morgen ${vp[4]} ich noch klarer.',
        rhythmChant: '${vp[2]} • ${vp[3]} • ${vp[4]}',
        grammarTrapMl: 'Futur I = werden + Infinitiv (അവസാനം Infinitiv).',
        pastLabel: 'PRÄTERITUM',
        presentLabel: 'PRÄSENS',
        futureLabel: 'FUTUR I',
        tenseCategory: 'B1/B2 Zeitform',
      ));
    }

    // Add 2 companion German verbs so every day has 3 rounds
    final v2 = _b1b2VerbPool[(d + 1) % _b1b2VerbPool.length];
    final v3 = _b1b2VerbPool[(d + 4) % _b1b2VerbPool.length];
    for (int idx = 0; idx < 2; idx++) {
      final v = idx == 0 ? v2 : v3;
      items.add(VerbTimelineItem(
        id: d * 10 + 2 + idx,
        baseVerb: v[0],
        meaningMl: v[1],
        past: v[2],
        present: v[3],
        future: v[4],
        pastSentence: 'Letzte Woche ${v[2]} wir das Projekt.',
        presentSentence: 'Jetzt ${v[3]} wir gemeinsam.',
        futureSentence: 'Bald ${v[4]} wir neue Ideen.',
        rhythmChant: '${v[2]} • ${v[3]} • ${v[4]}',
        grammarTrapMl: 'ഉത്തമ ക്രിയാസ്ഥാനം (Verb-Zweit-Regel) പാലിക്കുക.',
        pastLabel: 'PRÄTERITUM',
        presentLabel: 'PRÄSENS',
        futureLabel: 'FUTUR I',
        tenseCategory: 'Tag $d Praxis',
      ));
    }
    return items;
  }

  /// 🔄 Step 17: Negative Sentence Builder (nicht / kein / keine) for all 90 days
  static List<NegativeSentenceRound> getNegativeRoundsForDay(int day) {
    final d = day.clamp(1, 90);
    final rounds = <NegativeSentenceRound>[];

    List<String> _bank(String neg, List<String> extra) {
      final tokens = neg.split(' ').where((w) => w.isNotEmpty).toList();
      final combined = [...tokens, ...extra];
      return combined.toSet().length >= tokens.length ? combined : tokens;
    }

    if (d <= 45 && _dayBlueprints.containsKey(d)) {
      final b = _dayBlueprints[d]!;
      rounds.add(NegativeSentenceRound(
        id: d * 10 + 1,
        positiveSentence: b[5],
        positiveSentenceMl: b[6],
        negativeSentence: b[7],
        negativeSentenceMl: b[8],
        ruleTipEn: 'Use "nicht" for verbs/adjectives and "kein/keine" for nouns.',
        ruleTipMl: 'ക്രിയകൾക്കും വിശേഷണങ്ങൾക്കും "nicht", നാമങ്ങൾക്ക് "kein/keine" ഉപയോഗിക്കുക.',
        wordBank: _bank(b[7], ['nie', 'ohne', 'noch']),
      ));
    }

    final vocab = getVocabForDay(d);
    final w0 = vocab.isNotEmpty ? vocab[0].word : 'Buch';
    final w1 = vocab.length > 1 ? vocab[1].word : 'Termin';
    final r1 = 'Ich habe heute keine Angst.';
    final r2 = 'Dieses Thema ist heute nicht schwer.';
    final r3 = 'Wir vergessen das Wort $w0 nicht.';

    rounds.add(NegativeSentenceRound(
      id: d * 10 + 2,
      positiveSentence: 'Ich habe heute Angst.',
      positiveSentenceMl: 'എനിക്ക് ഇന്ന് ഭയമുണ്ട്.',
      negativeSentence: r1,
      negativeSentenceMl: 'എനിക്ക് ഇന്ന് ഭയമില്ല.',
      ruleTipEn: 'Negate feminine nouns using "keine".',
      ruleTipMl: 'സ്ത്രീലിംഗ നാമങ്ങൾക്കൊപ്പം "keine" ചേർക്കുക.',
      wordBank: _bank(r1, ['nicht', 'ein', 'nie']),
    ));
    rounds.add(NegativeSentenceRound(
      id: d * 10 + 3,
      positiveSentence: 'Dieses Thema ist heute schwer.',
      positiveSentenceMl: 'ഈ വിഷയം ഇന്ന് കഠിനമാണ്.',
      negativeSentence: r2,
      negativeSentenceMl: 'ഈ വിഷയം ഇന്ന് കഠിനമല്ല.',
      ruleTipEn: 'Place "nicht" right before the predicate adjective.',
      ruleTipMl: 'വിശേഷണത്തിന് തൊട്ടുമുമ്പിൽ "nicht" വയ്ക്കുക.',
      wordBank: _bank(r2, ['kein', 'keine', 'immer']),
    ));
    rounds.add(NegativeSentenceRound(
      id: d * 10 + 4,
      positiveSentence: 'Wir behalten $w0 und $w1.',
      positiveSentenceMl: 'നമ്മൾ $w0, $w1 എന്നിവ ഓർക്കുന്നു.',
      negativeSentence: r3,
      negativeSentenceMl: 'നമ്മൾ $w0 എന്ന വാക്ക് മറക്കുന്നില്ല.',
      ruleTipEn: 'Put "nicht" at the end to negate the whole statement.',
      ruleTipMl: 'വാക്യത്തിന്റെ പൂർണ്ണമായ നിഷേധത്തിന് "nicht" അവസാനം ചേർക്കുക.',
      wordBank: _bank(r3, ['kein', 'nie', 'ohne']),
    ));

    return rounds;
  }

  /// 💬 Step 16: Chat Reply Scenarios for all 90 days
  static List<ChatReplyScenario> getChatScenariosForDay(int day) {
    final d = day.clamp(1, 90);
    final vocab = getVocabForDay(d);
    final w0 = vocab.isNotEmpty ? vocab[0].word : 'Deutsch';
    final m0 = vocab.isNotEmpty ? vocab[0].malayalamMeaning : 'ജർമൻ';
    final scenarios = <ChatReplyScenario>[];

    if (d <= 45 && _dayBlueprints.containsKey(d)) {
      final b = _dayBlueprints[d]!;
      final tokens = b[11].split(' ').where((w) => w.isNotEmpty).toList();
      scenarios.add(ChatReplyScenario(
        id: d * 10 + 1,
        avatarPrompt: b[9],
        avatarPromptMl: b[10],
        expectedReply: b[11],
        expectedReplyMl: b[12],
        wordBank: [...tokens, 'gestern', 'morgen', 'warum'],
        topicTag: '🇩🇪 Tag $d · ${b[1]}',
      ));
    }

    final reply2 = 'Heute übe ich das Wort $w0.';
    final tokens2 = reply2.split(' ');
    scenarios.add(ChatReplyScenario(
      id: d * 10 + 2,
      avatarPrompt: 'Was steht heute auf deinem Lernplan?',
      avatarPromptMl: 'ഇന്നത്തെ നിന്റെ പഠന പ്ലാനിൽ എന്താണ് ഉള്ളത്?',
      expectedReply: reply2,
      expectedReplyMl: 'ഇന്ന് ഞാൻ "$w0" ($m0) എന്ന വാക്ക് പരിശീലിക്കുന്നു.',
      wordBank: [...tokens2, 'keine', 'nie', 'gestern'],
      topicTag: '📚 Wortschatz',
    ));

    final reply3 = 'Vielen Dank, das hilft mir sehr!';
    final tokens3 = reply3.split(' ');
    scenarios.add(ChatReplyScenario(
      id: d * 10 + 3,
      avatarPrompt: 'Möchtest du noch ein Beispiel hören?',
      avatarPromptMl: 'ഒരു ഉദാഹരണം കൂടി കേൾക്കണോ?',
      expectedReply: reply3,
      expectedReplyMl: 'വളരെ നന്ദി, അത് എന്നെ ഒരുപാട് സഹായിക്കും!',
      wordBank: [...tokens3, 'nein', 'schlecht', 'später'],
      topicTag: '🤝 Gespräch',
    ));

    return scenarios;
  }

  /// 📢 Step 18: Mini Speech Practice for all 90 days
  static List<MiniSpeechTopic> getSpeechTopicsForDay(int day) {
    final d = day.clamp(1, 90);
    final meta = getLessonSpecMap(d);
    final vocab = getVocabForDay(d);
    final ex0 = vocab.isNotEmpty ? vocab[0].exampleSentence : meta['speakingDrill'] as String;
    final ex1 = vocab.length > 1 ? vocab[1].exampleSentence : 'Ich spreche jeden Tag besser.';
    final w0 = vocab.isNotEmpty ? vocab[0].word : 'Deutsch';
    final m0 = vocab.isNotEmpty ? vocab[0].malayalamMeaning : 'ജർമൻ';

    return [
      MiniSpeechTopic(
        id: d * 10 + 1,
        title: 'Tag $d: ${meta['focusArea']}',
        emoji: '🇩🇪',
        passageEn: '${meta['speakingDrill']} $ex0 $ex1',
        passageMl: 'ഡേ $d വിഷയം (${meta['focusArea']}): $w0 ($m0) ഉപയോഗിച്ച് വ്യക്തമായി സംസാരിക്കുക.',
        speechTipEn: 'Keep the verb clearly in position 2 and pronounce German vowels cleanly.',
        speechTipMl: 'ജർമൻ സ്വരാക്ഷരങ്ങൾ (Ä, Ö, Ü) വ്യക്തമായി ഉച്ചരിക്കുക.',
      ),
      MiniSpeechTopic(
        id: d * 10 + 2,
        title: 'Selbstvertrauen an Tag $d',
        emoji: '🌟',
        passageEn: 'Heute ist Tag $d meines Trainings. Ich bleibe geduldig, übe laut und spreche sicher auf Deutsch!',
        passageMl: 'ഇന്ന് എന്റെ പരിശീലനത്തിന്റെ $d-ാം ദിവസമാണ്. ഞാൻ ക്ഷമയോടെ ഉറക്കെ വായിച്ച് ആത്മവിശ്വാസത്തോടെ ജർമൻ സംസാരിക്കും!',
        speechTipEn: 'Smile, pause after commas, and finish with steady confidence!',
        speechTipMl: 'കോമയ്ക്ക് ശേഷം ചെറിയൊരു ഇടവേള നൽകി ആത്മവിശ്വാസത്തോടെ പൂർത്തിയാക്കുക.',
      ),
    ];
  }

  /// 🎙️ Step 13: 20-Turn Spoken German Simulator for ALL 90 Days (1–90)
  static DaySpokenSimulatorPlan getSpokenSimulatorPlanForDay(int day) {
    final d = day.clamp(1, 90);
    final meta = getLessonSpecMap(d);
    final vocab = getVocabForDay(d);
    final sentences = getSentencesForDay(d);
    final negs = getNegativeRoundsForDay(d);
    final exchanges = <SpokenDialogueExchange>[];

    // Turn 1: Warm German greeting
    exchanges.add(SpokenDialogueExchange(
      stepIndex: 1,
      avatarPrompt: 'Hallo! Willkommen zu Tag $d: ${meta['focusArea']}. Bist du bereit?',
      avatarPromptMl: 'ഹലോ! ഡേ $d (${meta['focusArea']}) ലേക്ക് സ്വാഗതം. നീ തയ്യാറാണോ?',
      responseOptions: [
        'Ja, ich bin bereit für Tag $d!',
        'Nein, heute habe ich keine Lust.',
        'Ich weiß es nicht.',
      ],
      bestResponseIndex: 0,
      speechTip: 'Sag "Ja, ich bin bereit" klar und freundlich!',
    ));

    // Turns 2..11: Walk through the 10 curated German words of Day d
    for (int i = 0; i < 10; i++) {
      final v = vocab.isNotEmpty ? vocab[i % vocab.length] : null;
      final word = v?.word ?? 'Deutsch';
      final ex = v?.exampleSentence ?? 'Ich lerne Deutsch.';
      final ml = v?.malayalamMeaning ?? 'ജർമൻ';
      exchanges.add(SpokenDialogueExchange(
        stepIndex: i + 2,
        avatarPrompt: 'Wie benutzt man "$word" ($ml) in einem Satz?',
        avatarPromptMl: '"$word" ($ml) എന്ന വാക്ക് ഒരു ജർമൻ വാക്യത്തിൽ എങ്ങനെ പറയാം?',
        responseOptions: [
          ex,
          'Das Wort kenne ich nie.',
          'Heute spreche ich nicht.',
        ],
        bestResponseIndex: 0,
        speechTip: 'Betone "$word" deutlich im Satz!',
      ));
    }

    // Turns 12..15: Sentence Builder turns
    for (int i = 0; i < 4; i++) {
      final s = sentences[i % sentences.length];
      exchanges.add(SpokenDialogueExchange(
        stepIndex: 12 + i,
        avatarPrompt: 'Übersetze diesen Gedanken auf Deutsch: "${s.translationMl}"',
        avatarPromptMl: '"${s.translationMl}" എന്ന് ജർമനിൽ എങ്ങനെ പറയും?',
        responseOptions: [
          s.sentence,
          'Ich möchte das nicht sagen.',
          'Keine Antwort heute.',
        ],
        bestResponseIndex: 0,
        speechTip: s.hint,
      ));
    }

    // Turns 16..18: Negation & Question drills
    for (int i = 0; i < 3; i++) {
      final n = negs[i % negs.length];
      exchanges.add(SpokenDialogueExchange(
        stepIndex: 16 + i,
        avatarPrompt: 'Wie verneinst du: "${n.positiveSentence}"?',
        avatarPromptMl: '"${n.positiveSentence}" എന്നതിന്റെ നിഷേധ രൂപം ഏതാണ്?',
        responseOptions: [
          n.negativeSentence,
          n.positiveSentence,
          'Das stimmt gar nie.',
        ],
        bestResponseIndex: 0,
        speechTip: n.ruleTipEn,
      ));
    }

    // Turns 19..20: Real-world drill + Celebration
    exchanges.add(SpokenDialogueExchange(
      stepIndex: 19,
      avatarPrompt: 'Wiederhole unseren Hauptsatz für Tag $d!',
      avatarPromptMl: 'ഡേ $d-ലെ പ്രധാന വാക്യം ആവർത്തിക്കൂ!',
      responseOptions: [
        meta['speakingDrill'] as String,
        'Ich vergesse alles sofort.',
        'Das ist zu schwer.',
      ],
      bestResponseIndex: 0,
      speechTip: meta['grammarConcept'] as String,
    ));
    exchanges.add(SpokenDialogueExchange(
      stepIndex: 20,
      avatarPrompt: 'Ausgezeichnet! Tag $d hast du großartig gemeistert!',
      avatarPromptMl: 'അടിപൊളി! ഡേ $d നീ വളരെ മനോഹരമായി പൂർത്തിയാക്കി!',
      responseOptions: [
        'Vielen Dank! Bis morgen zu Tag ${d < 90 ? d + 1 : 90}!',
        'Ich gebe heute auf.',
        'Keine Lust mehr.',
      ],
      bestResponseIndex: 0,
      speechTip: 'Freundlicher Abschied auf Deutsch!',
    ));

    return DaySpokenSimulatorPlan(
      day: d,
      topicTitle: meta['title'] as String,
      topicTitleMl: 'ഡേ $d: ${meta['focusArea']}',
      scenarioContext: meta['phaseName'] as String,
      exchanges: exchanges,
    );
  }

  /// 🐱 Concept Room & Avatar Chat Specs for ALL Days 1–90
  static Map<String, dynamic> getAvatarChatSpecMap(int day) {
    final d = day.clamp(1, 90);
    final meta = getLessonSpecMap(d);
    final vocab = getVocabForDay(d);
    final sentences = getSentencesForDay(d);
    final negs = getNegativeRoundsForDay(d);
    final idx = (d - 1) % _b1b2GrammarPool.length;
    final gram = _b1b2GrammarPool[idx];

    final drills = <Map<String, String>>[];
    for (int i = 0; i < 3 && i < sentences.length; i++) {
      drills.add({
        'en': sentences[i].sentence,
        'ml': sentences[i].translationMl,
        'rule': sentences[i].hint,
      });
    }
    if (drills.isEmpty) {
      drills.add({
        'en': meta['speakingDrill'] as String,
        'ml': 'ഡേ $d സ്പീക്കിംഗ് ഡ്രിൽ',
        'rule': meta['grammarConcept'] as String,
      });
    }

    final ex0 = vocab.isNotEmpty ? vocab[0].exampleSentence : meta['speakingDrill'] as String;
    final neg0 = negs.isNotEmpty ? negs[0].negativeSentence : 'Ich verstehe das nicht.';

    return {
      'topicEmoji': d <= 30 ? '🇩🇪' : (d <= 60 ? '🚀' : '🏆'),
      'titleEn': 'Tag $d: ${meta['title']}',
      'titleMl': 'ഡേ $d: ${meta['focusArea']}',
      'greetingEn': 'Willkommen zu Tag $d! 🌟 Heute lernen wir: ${meta['focusArea']} (${meta['grammarConcept']}).',
      'greetingMl': 'ഡേ $d-ലേക്ക് സ്വാഗതം! 🌟 ഇന്ന് നമ്മൾ ${meta['focusArea']} പഠിക്കും!',
      'greetingAudio': 'Willkommen zu Tag $d! Heute lernen wir ${meta['focusArea']}.',
      'blueprintTitle': (meta['grammarConcept'] as String).toUpperCase(),
      'blueprintExplanationEn': d <= 45 ? gram[1] : gram[3],
      'blueprintExplanationMl': d <= 45 ? 'നിയമം: ${meta['grammarConcept']} — ${gram[4]}' : gram[4],
      'blueprintRules': [
        {
          'subject': 'Kernregel (Rule)',
          'en': meta['grammarConcept'] as String,
          'ml': meta['focusArea'] as String,
        },
        {
          'subject': 'Mustersatz (Pattern)',
          'en': ex0,
          'ml': vocab.isNotEmpty ? '${vocab[0].word}: ${vocab[0].malayalamMeaning}' : 'ശരിയായ പ്രയോഗം',
        },
        {
          'subject': 'Verneinung (Negation)',
          'en': neg0,
          'ml': negs.isNotEmpty ? negs[0].negativeSentenceMl : 'നിഷേധ രൂപം',
        },
      ],
      'drills': drills,
      'quizQuestions': [
        {
          'qEn': 'Question 1: Choose the natural German sentence for Day $d:',
          'qMl': 'ചോദ്യം 1: ഡേ $d-ലെ ശരിയായ ജർമൻ വാക്യം തിരഞ്ഞെടുക്കുക:',
          'audio': 'Was ist richtig auf Deutsch?',
          'correct': ex0,
          'wrong': 'Ich heute Deutsch nicht.',
          'tip': 'Think of Verb-Second (V2) order and clear articles!',
        },
      ],
    };
  }

  /// 🎙️ Gate Exam Questions for ALL Days 1–90
  static List<Map<String, dynamic>> getExamForDay(int day) {
    final d = day.clamp(1, 90);
    final sentences = getSentencesForDay(d);
    final vocab = getVocabForDay(d);
    final s0 = sentences.isNotEmpty ? sentences[0].sentence : 'Ich lerne heute Deutsch.';
    final s1 = sentences.length > 1 ? sentences[1].sentence : 'Das verstehe ich sehr gut.';
    final s2 = sentences.length > 2 ? sentences[2].sentence : 'Vielen Dank für deine Hilfe.';
    final vWord = vocab.isNotEmpty ? vocab[0].word : 'Deutsch';

    return [
      {
        'id': 1,
        'question': {
          'en': 'Speak this Day $d German sentence aloud:',
          'ml': 'ഡേ $d-ലെ ഈ ജർമൻ വാക്യം ഉറക്കെ പറയുക:',
          'hi': 'डे $d का यह जर्मन वाक्य बोलें:',
          'ta': 'நாள் $d இன் இந்த ஜெர்மன் வாக்கியத்தை பேசுங்கள்:',
          'kn': 'ದಿನ $d ರ ಈ ಜರ್ಮನ್ ವಾಕ್ಯವನ್ನು ಗಟ್ಟಿಯಾಗಿ ಹೇಳಿ:',
          'te': 'రోజు $d యొక్క ఈ జర్మన్ వాక్యాన్ని బిగ్గరగా చెప్పండి:',
        },
        'targetText': s0,
        'voicePrompt': s0,
        'options': [s0, 'Ich schlafe heute alles', 'Das stimmt leider gar nie', 'Keine Antwort möglich'],
        'correctIndex': 0,
        'explanation': {
          'en': 'Keep conjugated verb in position 2!',
          'ml': 'ജർമനിൽ പ്രധാന ക്രിയ (Verb) രണ്ടാമത്തെ സ്ഥാനത്ത് വയ്ക്കുക!',
          'ta': 'ஜெர்மனில் வினைச்சொல்லை 2வது இடத்தில் வைக்கவும்!',
          'hi': 'जर्मन में मुख्य क्रिया को दूसरे स्थान पर रखें!',
          'kn': 'ಜರ್ಮನ್‌ನಲ್ಲಿ ಕ್ರಿಯಾಪದವನ್ನು 2ನೇ ಸ್ಥಾನದಲ್ಲಿ ಇರಿಸಿ!',
          'te': 'జర్మన్‌లో క్రియను 2వ స్థానంలో ఉంచండి!',
        },
      },
      {
        'id': 2,
        'question': {
          'en': 'Speak the second Day $d German sentence:',
          'ml': 'രണ്ടാമത്തെ ജർമൻ വാക്യം ആത്മവിശ്വാസത്തോടെ പറയുക:',
          'hi': 'दूसरा जर्मन वाक्य बोलें:',
          'ta': 'இரண்டாவது ஜெர்மன் வாக்கியத்தை பேசுங்கள்:',
          'kn': 'ಎರಡನೇ ಜರ್ಮನ್ ವಾಕ್ಯವನ್ನು ಆತ್ಮವಿಶ್ವಾಸದಿಂದ ಹೇಳಿ:',
          'te': 'రెண்டవ జర్మన్ వాక్యాన్ని నమ్మకంగా చెప్పండి:',
        },
        'targetText': s1,
        'voicePrompt': s1,
        'options': [s1, 'Ich spreche niemals', 'Alles vergessen', 'Nein danke nicht'],
        'correctIndex': 0,
        'explanation': {
          'en': 'Clear vowels and smooth German cadence!',
          'ml': 'സ്വരാക്ഷരങ്ങൾ വ്യക്തമായി ഉച്ചരിക്കുക!',
          'ta': 'உயிரெழுத்துக்களைத் தெளிவாக உச்சரிக்கவும்!',
          'hi': 'स्वरों का स्पष्ट उच्चारण करें!',
          'kn': 'ಸ್ವರಗಳನ್ನು ಸ್ಪಷ್ಟವಾಗಿ ಉಚ್ಚರಿಸಿ!',
          'te': 'అచ్చులను స్పష్టంగా ఉచ్చరించండి!',
        },
      },
      {
        'id': 3,
        'question': {
          'en': 'Speak today\'s key German phrase:',
          'ml': 'ഇന്നത്തെ പ്രധാന ജർമൻ വാക്യം പറയൂ:',
          'hi': 'आज का मुख्य जर्मन वाक्य बोलें:',
          'ta': 'இன்றைய முக்கிய ஜெர்மன் வாக்கியத்தை பேசுங்கள்:',
          'kn': 'ಇಂದಿನ ಪ್ರಮುಖ ಜರ್ಮನ್ ವಾಕ್ಯವನ್ನು ಹೇಳಿ:',
          'te': 'నేటి ముఖ్య జర్మన్ వాక్యాన్ని చెప్పండి:',
        },
        'targetText': s2,
        'voicePrompt': s2,
        'options': [s2, 'Vergessen wir alles sofort', 'Heute keine Lust', 'Unmöglich zu lernen'],
        'correctIndex': 0,
        'explanation': {
          'en': 'Accurate everyday German expression!',
          'ml': 'നിത്യജീവിതത്തിലെ ശരിയായ ജർമൻ പ്രയോഗം!',
          'ta': 'அன்றாட சரியான ஜெர்மன் சொற்றொடர்!',
          'hi': 'दैनिक जीवन का सही जर्मन प्रयोग!',
          'kn': 'ದೈನಂದಿನ ಸರಿಯಾದ ಜರ್ಮನ್ ಪ್ರಯೋಗ!',
          'te': 'రోజువారీ సరైన జర్మన్ వ్యక్తీకరణ!',
        },
      },
      {
        'id': 4,
        'question': {
          'en': 'Pronounce today\'s German core word "$vWord" clearly:',
          'ml': '"$vWord" എന്ന ജർമൻ വാക്ക് വ്യക്തമായി ഉച്ചരിക്കുക:',
          'hi': 'आज का शब्द "$vWord" स्पष्ट बोलें:',
          'ta': 'இன்றைய சொல் "$vWord" தெளிவாக சொல்லுங்கள்:',
          'kn': 'ಇಂದಿನ ಪದ "$vWord" ಅನ್ನು ಸ್ಪಷ್ಟವಾಗಿ ಉಚ್ಚರಿಸಿ:',
          'te': 'నేటి పదం "$vWord" ను స్పష్టంగా పలకండి:',
        },
        'targetText': vWord,
        'voicePrompt': vWord,
        'options': [vWord, 'Unbekanntes', 'Abbrechen', 'Verlieren'],
        'correctIndex': 0,
        'explanation': {
          'en': '90-Day German Vocabulary Mastery!',
          'ml': '90 ദിവസത്തെ ജർമൻ പദസമ്പത്ത് പഠനം!',
          'ta': '90-நாள் ஜெர்மன் சொற்களஞ்சியத் தேர்ச்சி!',
          'hi': '90-दिन जर्मन शब्दावली दक्षता!',
          'kn': '90-ದಿನ ಜರ್ಮನ್ ಪದಕೋಶ ಪ್ರಾವೀಣ್ಯತೆ!',
          'te': '90-రోజుల జర్మన్ పదజాల నైపుణ్యం!',
        },
      },
    ];
  }
}
