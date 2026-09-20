import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Conditionals (If Clauses) speaking exercise
class ConditionalsExerciseItem {
  final String category; // 'ZERO', 'FIRST', 'SECOND', 'THIRD'
  final String conditionalType;
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const ConditionalsExerciseItem({
    required this.category,
    required this.conditionalType,
    required this.rule,
    required this.promptSentence,
    required this.targetWord,
    required this.acceptableWords,
    required this.fullSentence,
    required this.localizedHints,
    required this.localizedTranslations,
  });

  String getHint(String language) {
    final key = language.toLowerCase();
    for (final entry in localizedHints.entries) {
      if (entry.key.toLowerCase() == key && entry.value.isNotEmpty) return entry.value;
    }
    return localizedHints['Malayalam'] ?? localizedHints['Tamil'] ?? localizedHints['English'] ?? '';
  }

  String getTranslation(String language) {
    final key = language.toLowerCase();
    for (final entry in localizedTranslations.entries) {
      if (entry.key.toLowerCase() == key && entry.value.isNotEmpty) return entry.value;
    }
    return localizedTranslations['Malayalam'] ?? localizedTranslations['Tamil'] ?? localizedTranslations['English'] ?? '';
  }
}

// ─────────────────────────────────────────────
//  EXERCISE DATA  (20 exercises: 5 per type)
// ─────────────────────────────────────────────
const List<ConditionalsExerciseItem> _kConditionalsExercises = [
  // ── ZERO CONDITIONAL (General Truths) ──
  ConditionalsExerciseItem(
    category: 'ZERO',
    conditionalType: 'Zero Conditional',
    rule: 'If + present simple, present simple -> general truth / scientific fact',
    promptSentence: 'If you heat ice, it ___ (melt).',
    targetWord: 'melts',
    acceptableWords: ['melt', 'it melts'],
    fullSentence: 'If you heat ice, it melts.',
    localizedHints: {
      'Malayalam': 'Zero Conditional: if + present simple -> present simple. Itu oru shasthreeyasathyam.',
      'Tamil': 'Zero Conditional: if + present simple -> present simple. Itu oru vignyana unmmai.',
      'Hindi': 'Zero Conditional: if + present simple -> present simple. Yeh ek vaigyanik tathya hai.',
      'Telugu': 'Zero Conditional: if + present simple -> present simple. Idi oka sasthreeyasathyam.',
      'Kannada': 'Zero Conditional: if + present simple -> present simple. Idu vaigyaanika satya.',
      'English': 'Zero Conditional: if + present simple -> present simple. Scientific fact: heat + ice = melts.',
    },
    localizedTranslations: {
      'Malayalam': 'Ningal aisu chudumaakiyaal, atu urukum.',
      'Tamil': 'Paniyai choodaakkinaal, atu urukum.',
      'Hindi': 'Agar aap baraf garam karte hain, to vah pighal jaati hai.',
      'Telugu': 'Meeru manchuni vedi chesthe, adi karugutundi.',
      'Kannada': 'Neevu manjugadde bisi madidare, adu karaaguttade.',
      'English': 'If you heat ice, it melts.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'ZERO',
    conditionalType: 'Zero Conditional',
    rule: 'If + present simple, present simple -> always true',
    promptSentence: 'If it rains, the grass ___ (get) wet.',
    targetWord: 'gets',
    acceptableWords: ['get', 'gets wet'],
    fullSentence: 'If it rains, the grass gets wet.',
    localizedHints: {
      'Malayalam': 'Zero Conditional: mazha peytaal, pullu nanayu. Itu sthiram sathyam.',
      'Tamil': 'Zero Conditional: mazhai peythaal, pul eeramaaagum. Itu nirantara unmmai.',
      'Hindi': 'Zero Conditional: baarish hone par ghaas geeli hoti hai. Sadaa sach.',
      'Telugu': 'Zero Conditional: varsham kuriste, gaddi tadisipotundi. Nithya sathyam.',
      'Kannada': 'Zero Conditional: male biddale hullu oddeyaaguttade. Sthira satya.',
      'English': 'Zero Conditional: always true fact. Rain -> grass gets wet.',
    },
    localizedTranslations: {
      'Malayalam': 'Mazha peytaal, pullu nanayu.',
      'Tamil': 'Mazhai peythaal, pul eeramaaagum.',
      'Hindi': 'Agar baarish hoti hai, to ghaas geeli ho jaati hai.',
      'Telugu': 'Varsham kuriste, gaddi tadisipotundi.',
      'Kannada': 'Male biddale, hullu oddeyaaguttade.',
      'English': 'If it rains, the grass gets wet.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'ZERO',
    conditionalType: 'Zero Conditional',
    rule: 'If + present simple, present simple -> personal habit',
    promptSentence: 'If I am tired, I ___ (drink) coffee.',
    targetWord: 'drink',
    acceptableWords: ['drinks', 'i drink coffee'],
    fullSentence: 'If I am tired, I drink coffee.',
    localizedHints: {
      'Malayalam': 'Zero Conditional: kshenam vannal, njaan coffee kudikkum. Oru sheelam.',
      'Tamil': 'Zero Conditional: soorvaaka irundaal kaapi kudippeen. Oru pazhakkam.',
      'Hindi': 'Zero Conditional: thakane par coffee peeta hun. Ek aadat.',
      'Telugu': 'Zero Conditional: alasipothee coffee taagutaanu. Oka alavatu.',
      'Kannada': 'Zero Conditional: daNidaaga kaafi kudiyuttene. Oka abhyaasa.',
      'English': 'Zero Conditional: personal habit. Tired -> drink coffee.',
    },
    localizedTranslations: {
      'Malayalam': 'Njaan kshenithanaanennikil, njaan coffee kudikkum.',
      'Tamil': 'Naan soorvaaka irundaal, kaapi kudippeen.',
      'Hindi': 'Agar main thaka hua hun, to coffee peeta hun.',
      'Telugu': 'Nenu alasipothee, coffee taagutaanu.',
      'Kannada': 'Naanu daNididdaree, kaafi kudiyuttene.',
      'English': 'If I am tired, I drink coffee.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'ZERO',
    conditionalType: 'Zero Conditional',
    rule: 'If + present simple, present simple -> scientific fact',
    promptSentence: 'If you mix blue and yellow, you ___ (get) green.',
    targetWord: 'get',
    acceptableWords: ['gets', 'you get green'],
    fullSentence: 'If you mix blue and yellow, you get green.',
    localizedHints: {
      'Malayalam': 'Zero Conditional: neelavum manjhapum cheerthal, pachha kittum. Shasthreeya sathyam.',
      'Tamil': 'Zero Conditional: neelamum manjalum kalandhaal, pachhai kidaikkum.',
      'Hindi': 'Zero Conditional: neela + peela = haraa. Scientific fact.',
      'Telugu': 'Zero Conditional: neelam + pasupu = aakupacha. Sasthreeya sathyam.',
      'Kannada': 'Zero Conditional: neeli + haladi = hasiru. Vaigyaanika satya.',
      'English': 'Zero Conditional: scientific fact. Blue + yellow = green.',
    },
    localizedTranslations: {
      'Malayalam': 'Neelavum manjhapum mix cheytal, ningalkku pachha kittum.',
      'Tamil': 'Neelamum manjalum kalandhaal, pachhai kidaikkum.',
      'Hindi': 'Agar aap neele aur peele ko milaate hain, to aapko haraa milta hai.',
      'Telugu': 'Meeru neelam mariyu pasupu kalipite, aakupacha vastundi.',
      'Kannada': 'Neevu neeli mattu haladi beresidare, hasiru siguttade.',
      'English': 'If you mix blue and yellow, you get green.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'ZERO',
    conditionalType: 'Zero Conditional',
    rule: 'If + present simple, present simple -> natural consequence',
    promptSentence: 'If plants do not get water, they ___ (die).',
    targetWord: 'die',
    acceptableWords: ['dies', 'they die'],
    fullSentence: 'If plants do not get water, they die.',
    localizedHints: {
      'Malayalam': 'Zero Conditional: chedikalkku vellam kittiyillennikil, avayy chathupoakum.',
      'Tamil': 'Zero Conditional: thaavarangangalukku thanneer kidaikkaaviTTaal, avai iranthuvidum.',
      'Hindi': 'Zero Conditional: paudhon ko paani nahi milne par ve mar jaate hain.',
      'Telugu': 'Zero Conditional: mokkalu ku neeru raakapothe, avi chanipotaayi.',
      'Kannada': 'Zero Conditional: gidagaLige neeru sigadiddaree, avu saayuttave.',
      'English': 'Zero Conditional: natural consequence. No water -> plants die.',
    },
    localizedTranslations: {
      'Malayalam': 'Chedikalkku vellam kittiyillennikil, avayy chathupoakum.',
      'Tamil': 'Thaavarangangalukku thanneer kidaikkaaviTTaal, avai iranthuvidum.',
      'Hindi': 'Agar paudhon ko paani nahi milta, to ve mar jaate hain.',
      'Telugu': 'Mokkalu ku neeru raakapothe, avi chanipotaayi.',
      'Kannada': 'GidagaLige neeru sigadiddaree, avu saayuttave.',
      'English': 'If plants do not get water, they die.',
    },
  ),

  // ── FIRST CONDITIONAL (Real Future) ──
  ConditionalsExerciseItem(
    category: 'FIRST',
    conditionalType: 'First Conditional',
    rule: 'If + present simple, will + base verb -> real future possibility',
    promptSentence: 'If it rains, I ___ (take) an umbrella.',
    targetWord: 'will take',
    acceptableWords: ['take', 'will take an umbrella', 'i will take'],
    fullSentence: 'If it rains, I will take an umbrella.',
    localizedHints: {
      'Malayalam': 'First Conditional: if + present -> will + verb. Mazha peytaal, njaan oru kuda edukkum.',
      'Tamil': 'First Conditional: mazhai peythaal kudai eduppeen. Unarmaiyaana bhaavikalam.',
      'Hindi': 'First Conditional: baarish hui to chhaata lunga. Vastavik bhavishy.',
      'Telugu': 'First Conditional: varsham kuriste godugu teesukoontaanu. Niramayana bhavishyattu.',
      'Kannada': 'First Conditional: male biddale chhatra tegeyuttene. Nija bhavishya.',
      'English': 'First Conditional: real future possibility. If + present -> will + verb.',
    },
    localizedTranslations: {
      'Malayalam': 'Mazha peytaal, njaan oru kuda edukkum.',
      'Tamil': 'Mazhai peythaal, naan kudai eduppeen.',
      'Hindi': 'Agar baarish hogi, to main chhaata lunga.',
      'Telugu': 'Varsham kuriste, nenu godugu teesukoontaanu.',
      'Kannada': 'Male biddale, naanu chhatra tegeyuttene.',
      'English': 'If it rains, I will take an umbrella.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'FIRST',
    conditionalType: 'First Conditional',
    rule: 'If + present simple, will + base verb -> real future result',
    promptSentence: 'If she studies hard, she ___ (pass) the exam.',
    targetWord: 'will pass',
    acceptableWords: ['pass', 'will pass the exam', 'she will pass'],
    fullSentence: 'If she studies hard, she will pass the exam.',
    localizedHints: {
      'Malayalam': 'First Conditional: kathinamaayi padithaal, perithsha jayikkum.',
      'Tamil': 'First Conditional: katinamaaka padiththaal tervil vetri peavaal.',
      'Hindi': 'First Conditional: mehnat kare to paas hogi.',
      'Telugu': 'First Conditional: kastapadi chadivite pariksha pass avutundi.',
      'Kannada': 'First Conditional: kashTapaTTu odidare pariksha paaas maaduttaale.',
      'English': 'First Conditional: real future result. Study hard -> will pass.',
    },
    localizedTranslations: {
      'Malayalam': 'Aa kathinamaayyi padichaal, aa pariksha jayikkum.',
      'Tamil': 'Aval katinamaaka padittaal, tervil vetri peavaal.',
      'Hindi': 'Agar vah kari mehnat karti hai, to pariksha paas karegi.',
      'Telugu': 'Ame kashTapadi chadivite, pariksha pass avutundi.',
      'Kannada': 'Avalu kashTapaTTu odidare, pariksha paaas maaduttaale.',
      'English': 'If she studies hard, she will pass the exam.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'FIRST',
    conditionalType: 'First Conditional',
    rule: 'If + present simple, will + base verb -> warning',
    promptSentence: 'If you do not hurry, you ___ (miss) the bus.',
    targetWord: 'will miss',
    acceptableWords: ['miss', 'will miss the bus', 'you will miss'],
    fullSentence: 'If you do not hurry, you will miss the bus.',
    localizedHints: {
      'Malayalam': 'First Conditional: dhruthi koottiyillennikil, bus miss aakum. Oru munnariyippu.',
      'Tamil': 'First Conditional: vegamaaka pogaaviTTaal, bas taviriviTuveergal. Etchcharikkai.',
      'Hindi': 'First Conditional: jaldi nahi ki to bus chootegi. Chetavani.',
      'Telugu': 'First Conditional: tondara padakapothe, bus miss avutaav. Hechcharika.',
      'Kannada': 'First Conditional: avara maadadiddaree, bas tapputtade. Eccharike.',
      'English': 'First Conditional: warning. Do not hurry -> will miss the bus.',
    },
    localizedTranslations: {
      'Malayalam': 'Dhruthi koottiyillennikil, ningal bus miss aakum.',
      'Tamil': 'Vegamaaka pogaaviTTaal, pattiyai taviriviTuveergal.',
      'Hindi': 'Agar aap jaldi nahi karte, to aap bus chook jaayenge.',
      'Telugu': 'Meeru tondara padakapothe, bus miss avutaaru.',
      'Kannada': 'Neevu avara maadadiddaree, bas tapputtade.',
      'English': 'If you do not hurry, you will miss the bus.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'FIRST',
    conditionalType: 'First Conditional',
    rule: 'If + present simple, will + base verb -> real future plan',
    promptSentence: 'If the weather is nice, we ___ (go) to the beach.',
    targetWord: 'will go',
    acceptableWords: ['go', 'will go to the beach', 'we will go'],
    fullSentence: 'If the weather is nice, we will go to the beach.',
    localizedHints: {
      'Malayalam': 'First Conditional: kaalavastha nannaayal, beach il poakum.',
      'Tamil': 'First Conditional: vaanilai nannaka irundaal kadarkkarai poavoom.',
      'Hindi': 'First Conditional: mausam acha ho to beach chalenge.',
      'Telugu': 'First Conditional: vaatyavarnnam baaguntee beach ki vellaamu.',
      'Kannada': 'First Conditional: havaamaana chennaagiddaree beach ge hogutteve.',
      'English': 'First Conditional: real future plan. Nice weather -> will go to beach.',
    },
    localizedTranslations: {
      'Malayalam': 'Kaalavastha nannaayal, njangal beach il poakum.',
      'Tamil': 'Vaanilai nannaka irundaal, naangal kadarkkaraiku poavoom.',
      'Hindi': 'Agar mausam achha hai, to hum beach par jaayenge.',
      'Telugu': 'Vaataavaranam baaguntee, maemu beach ki vellaamu.',
      'Kannada': 'Havaamaana chennaagiddaree, naavu beach ge hogutteve.',
      'English': 'If the weather is nice, we will go to the beach.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'FIRST',
    conditionalType: 'First Conditional',
    rule: 'If + present simple, will + base verb -> real future promise',
    promptSentence: 'If you help me, I ___ (help) you tomorrow.',
    targetWord: 'will help',
    acceptableWords: ['help', 'will help you', 'i will help'],
    fullSentence: 'If you help me, I will help you tomorrow.',
    localizedHints: {
      'Malayalam': 'First Conditional: ningal enne sahaayichaal, njaane naale ningale sahaayikkum.',
      'Tamil': 'First Conditional: nee enakku udavinaal naale udavuven.',
      'Hindi': 'First Conditional: aap madad karo to kal madad karunga.',
      'Telugu': 'First Conditional: meeru naaku sahaaym chesthe, raeppu meeku sahaaym chestaanu.',
      'Kannada': 'First Conditional: neevu naanage sahaayta maadidare, naale naanu nimage sahaayta maaduttene.',
      'English': 'First Conditional: real future promise. Help me -> I will help you.',
    },
    localizedTranslations: {
      'Malayalam': 'Ningal enne sahaayichaal, njaan naale ningale sahaayikkum.',
      'Tamil': 'Nee enakku udavinaal, naan naale unakku udavuven.',
      'Hindi': 'Agar aap meri madad karte hain, to main kal aapki madad karunga.',
      'Telugu': 'Meeru naaku sahaaym chesthe, nenu raeppu meeku sahaaym chestaanu.',
      'Kannada': 'Neevu naanage sahaayta maadidare, naanu naale nimage sahaayta maaduttene.',
      'English': 'If you help me, I will help you tomorrow.',
    },
  ),

  // ── SECOND CONDITIONAL (Unreal Present/Future) ──
  ConditionalsExerciseItem(
    category: 'SECOND',
    conditionalType: 'Second Conditional',
    rule: 'If + past simple, would + base verb -> imaginary / unlikely',
    promptSentence: 'If I won the lottery, I ___ (travel) the world.',
    targetWord: 'would travel',
    acceptableWords: ['travel', 'would travel the world', 'i would travel'],
    fullSentence: 'If I won the lottery, I would travel the world.',
    localizedHints: {
      'Malayalam': 'Second Conditional: if + past -> would + verb. Oru sankalpam. Lottery jayichirunnenkil, lokam churri sanccharikkumayirunnu.',
      'Tamil': 'Second Conditional: oru karpanai nilai. Lottery vendrirunthaal ulakam paNipeen.',
      'Hindi': 'Second Conditional: kalpana. Lottery jeette to duniya ghoomta.',
      'Telugu': 'Second Conditional: oka kalpana paristhiti. Lottery gelelthe prapancham thirugutaanu.',
      'Kannada': 'Second Conditional: kalpanaa sthiti. Lottery geddiddaree prapanca suttuttidde.',
      'English': 'Second Conditional: imaginary/unlikely. If + past -> would + verb.',
    },
    localizedTranslations: {
      'Malayalam': 'Njaan lottery jayichirunnenkil, lokam churri sanccharikkumayirunnu.',
      'Tamil': 'Naan lottery vendrirunthaal, ulakam suttruven.',
      'Hindi': 'Agar main lottery jeetta, to duniya ki yaatra karta.',
      'Telugu': 'Nenu lottery geliste, prapancham thirugutaanu.',
      'Kannada': 'Naanu lottery geddiddaree, prapanca suttuttidde.',
      'English': 'If I won the lottery, I would travel the world.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'SECOND',
    conditionalType: 'Second Conditional',
    rule: 'If + were (all subjects), could/would + base verb -> imaginary',
    promptSentence: 'If she were taller, she ___ (be) a model.',
    targetWord: 'could be',
    acceptableWords: ['would be', 'be', 'could be a model'],
    fullSentence: 'If she were taller, she could be a model.',
    localizedHints: {
      'Malayalam': 'Second Conditional: "were" ell subjects-num. Uyaram koottutharunnenkil, model aakumayirunnu.',
      'Tamil': 'Second Conditional: "were" ell subjects-kum. Uyarampaka irundhaal modale aakiyiruppaal.',
      'Hindi': 'Second Conditional: "were" sabhi ke liye. Lambi hoti to model ban sakti thi.',
      'Telugu': 'Second Conditional: "were" anni subjects-ku. Podugga untee model kagalugutundi.',
      'Kannada': 'Second Conditional: "were" ella subjects-ge. Ettara iddiddare model aagabahuditti.',
      'English': 'Second Conditional: use "were" for all subjects. Imaginary present.',
    },
    localizedTranslations: {
      'Malayalam': 'Aval kootti uyaram ullavaLayirunnenkil, model aakumayirunnu.',
      'Tamil': 'Aval uyarampaka irundaal, model aaka mudiyum.',
      'Hindi': 'Agar vah lamba hoti, to model ban sakti thi.',
      'Telugu': 'Ame podugga untee, model kaagalugutundi.',
      'Kannada': 'Avalu ettara iddiddare, model aagabahuditti.',
      'English': 'If she were taller, she could be a model.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'SECOND',
    conditionalType: 'Second Conditional',
    rule: 'If + past simple, would + base verb -> hypothetical wish',
    promptSentence: 'If I had more time, I ___ (learn) piano.',
    targetWord: 'would learn',
    acceptableWords: ['learn', 'would learn piano', 'i would learn'],
    fullSentence: 'If I had more time, I would learn piano.',
    localizedHints: {
      'Malayalam': 'Second Conditional: kootti samayam undayirunnenkil, piano padikkumayirunnu. Oru agraham.',
      'Tamil': 'Second Conditional: adhika neram irundaal piano katriruppeen. Oru aasai.',
      'Hindi': 'Second Conditional: zyada samay hota to piano seekhta. Kalpana icchha.',
      'Telugu': 'Second Conditional: ekkuva samayam untee piano nerchukuntaanu. Oka koration.',
      'Kannada': 'Second Conditional: hechchu samaya iddiddare piano kaliyuttidde. Oka aase.',
      'English': 'Second Conditional: hypothetical wish. More time -> would learn piano.',
    },
    localizedTranslations: {
      'Malayalam': 'Eniku kootti samayam undayirunnenkil, piano padikkumayirunnu.',
      'Tamil': 'Ennadam adhika neram irundaal, piano katriruppeen.',
      'Hindi': 'Agar mere paas zyada samay hota, to main piano seekhta.',
      'Telugu': 'Naaku ekkuva samayam untee, piano nerchukuntaanu.',
      'Kannada': 'Naanage hechchu samaya iddiddare, piano kaliyuttidde.',
      'English': 'If I had more time, I would learn piano.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'SECOND',
    conditionalType: 'Second Conditional',
    rule: 'If + were (all subjects), would + base verb -> giving advice',
    promptSentence: 'If I were you, I ___ (accept) the job offer.',
    targetWord: 'would accept',
    acceptableWords: ['accept', 'would accept the job', 'i would accept'],
    fullSentence: 'If I were you, I would accept the job offer.',
    localizedHints: {
      'Malayalam': 'Second Conditional (advice): "If I were you..." - upadeham nalkunnathin upayogikkum.',
      'Tamil': 'Second Conditional (advice): "If I were you..." - aalochanai tharavadu.',
      'Hindi': 'Second Conditional (advice): "If I were you..." - salah dene ke liye.',
      'Telugu': 'Second Conditional (advice): "If I were you..." - salaah ivvadam.',
      'Kannada': 'Second Conditional (advice): "If I were you..." - salahe needalu baLasi.',
      'English': 'Second Conditional: "If I were you" -> giving advice.',
    },
    localizedTranslations: {
      'Malayalam': 'Njaan ningalaayirunnenkil, ajo job il sammathikumayirunnu.',
      'Tamil': 'Naan ungal idathil irundaal, velai vaayppai ettriruppeen.',
      'Hindi': 'Agar main aapki jagah hota, to naukari ka prastav sweekar karta.',
      'Telugu': 'Nenu meeru sthaanam lo untee, job offer accept chestanu.',
      'Kannada': 'Naanu nimage jaagadalli iddiddaree, udyoga amantraNa sweekarisuddidde.',
      'English': 'If I were you, I would accept the job offer.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'SECOND',
    conditionalType: 'Second Conditional',
    rule: 'If + past simple, would + base verb -> imaginary situation',
    promptSentence: 'If I lived near the sea, I ___ (swim) every day.',
    targetWord: 'would swim',
    acceptableWords: ['swim', 'would swim every day', 'i would swim'],
    fullSentence: 'If I lived near the sea, I would swim every day.',
    localizedHints: {
      'Malayalam': 'Second Conditional: kadal theerathu jeevichirunnenkil, divasavum neentumayirunnu.',
      'Tamil': 'Second Conditional: kadal arukilum vazhindhaal thinanum neendum.',
      'Hindi': 'Second Conditional: samudra ke paas rehta to roz tairta.',
      'Telugu': 'Second Conditional: samudram daggaranivasisthe, rozu edutunu.',
      'Kannada': 'Second Conditional: samudrada baLi vaasisiddare pratidinavu eeduttidde.',
      'English': 'Second Conditional: imaginary. Live near sea -> would swim every day.',
    },
    localizedTranslations: {
      'Malayalam': 'Njaan kadal theerathu jeevichirunnenkil, divasavum neentumayirunnu.',
      'Tamil': 'Naan kadal arukilum vaazhindhaal, thinanum neeendum.',
      'Hindi': 'Agar main samudra ke paas rehta, to main roz tairta.',
      'Telugu': 'Nenu samudram daggaranivishistee, rozu edutunu.',
      'Kannada': 'Naanu samudrada baLi vaasisiddare, pratidinavu eeduttidde.',
      'English': 'If I lived near the sea, I would swim every day.',
    },
  ),

  // ── THIRD CONDITIONAL (Unreal Past) ──
  ConditionalsExerciseItem(
    category: 'THIRD',
    conditionalType: 'Third Conditional',
    rule: 'If + had + past participle, would have + past participle -> unreal past',
    promptSentence: 'If I had studied harder, I ___ (pass) the exam.',
    targetWord: 'would have passed',
    acceptableWords: ['would have pass', 'passed', 'would have passed the exam'],
    fullSentence: 'If I had studied harder, I would have passed the exam.',
    localizedHints: {
      'Malayalam': 'Third Conditional: if + had + V3 -> would have + V3. Kootthi padichirunnenkil, pariksha jayikkumayirunnu - paksha padichilla.',
      'Tamil': 'Third Conditional: katinamaaka padithirundaal tervil vetri pEriruppen. Aanal padikkavil.',
      'Hindi': 'Third Conditional: mehnat ki hoti to paas hota. Lekin nahi ki.',
      'Telugu': 'Third Conditional: kastapadi chadivuntee pass ayiyuntaanu. Kaani chadavale.',
      'Kannada': 'Third Conditional: kashTapaTTu odiddaree paas aguttidde. Aadare odaLilla.',
      'English': 'Third Conditional: unreal past. Had studied -> would have passed (but did not).',
    },
    localizedTranslations: {
      'Malayalam': 'Njaan kootthi padichirunnenkil, pariksha jayikkumayirunnu.',
      'Tamil': 'Naan katinamaaka padithirundaal, tervil vetri pEriruppen.',
      'Hindi': 'Agar maine zyada mehnat ki hoti, to pariksha paas karta.',
      'Telugu': 'Nenu kastapadi chadivuntee, pariksha pass ayiyuntaanu.',
      'Kannada': 'Naanu kashTapaTTu odiddaree, pariksha paas aguttidde.',
      'English': 'If I had studied harder, I would have passed the exam.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'THIRD',
    conditionalType: 'Third Conditional',
    rule: 'If + had + past participle, would not have + past participle -> regret',
    promptSentence: 'If she had left earlier, she would not have ___ (miss) the train.',
    targetWord: 'missed',
    acceptableWords: ['missed the train', 'would not have missed'],
    fullSentence: 'If she had left earlier, she would not have missed the train.',
    localizedHints: {
      'Malayalam': 'Third Conditional: neraththe irangunirunnenkil, train miss aakilla. Oru khEdam.',
      'Tamil': 'Third Conditional: munnathaaka purappattirundaal raiyilai taviraviruppaL. Varuththam.',
      'Hindi': 'Third Conditional: pehle nikli hoti to train nahi chhootti. Pachhataava.',
      'Telugu': 'Third Conditional: munduggaa bayaluderadarsthe train miss ayyeedi kaadu. Visaadam.',
      'Kannada': 'Third Conditional: modeLE horaTTiddare rail tapputtiralailla. VishaaData.',
      'English': 'Third Conditional: regret. Left earlier -> would not have missed the train.',
    },
    localizedTranslations: {
      'Malayalam': 'Aval neraththe irangunirunnenkil, train miss aakumayirunilla.',
      'Tamil': 'Aval munnathaaka purappattirundaal, railai taviraviruppaL.',
      'Hindi': 'Agar vah pehle nikli hoti, to train nahi chhootti.',
      'Telugu': 'Ame munduggaa bayaluderadarsthe, train miss ayyeedi kaadu.',
      'Kannada': 'Avalu modeLE horaTTiddare, rail tapputtiralailla.',
      'English': 'If she had left earlier, she would not have missed the train.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'THIRD',
    conditionalType: 'Third Conditional',
    rule: 'If + had + past participle, would have + past participle -> unreal past',
    promptSentence: 'If we had known, we ___ (come) earlier.',
    targetWord: 'would have come',
    acceptableWords: ['would have come earlier', 'come', 'we would have come'],
    fullSentence: 'If we had known, we would have come earlier.',
    localizedHints: {
      'Malayalam': 'Third Conditional: arinjirunnenkil, njangal neraththe varumayirunnu. Bhoothakalam.',
      'Tamil': 'Third Conditional: therinthirundaal munnathaaka vanthiruppom.',
      'Hindi': 'Third Conditional: pata hota to pehle aate.',
      'Telugu': 'Third Conditional: telisuntee munduggaa vastunnaamu.',
      'Kannada': 'Third Conditional: tiLididdare muNdE baruttiddeve.',
      'English': 'Third Conditional: unreal past. Had known -> would have come earlier.',
    },
    localizedTranslations: {
      'Malayalam': 'Njangalkku arinjirunnenkil, njangal neraththe varumayirunnu.',
      'Tamil': 'Engalukkku therinthirundaal, munnathaaka vanthiruppom.',
      'Hindi': 'Agar humein pata hota, to hum pehle aate.',
      'Telugu': 'Maaku telisuntee, maemu munduggaa vastunnaamu.',
      'Kannada': 'Namagee tiLididdare, naavu muNdE baruttiddeve.',
      'English': 'If we had known, we would have come earlier.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'THIRD',
    conditionalType: 'Third Conditional',
    rule: 'If + had + past participle, would have + past participle -> missed opportunity',
    promptSentence: 'If he had applied earlier, he ___ (get) the job.',
    targetWord: 'would have got',
    acceptableWords: ['would have gotten', 'got', 'gotten', 'would have got the job'],
    fullSentence: 'If he had applied earlier, he would have got the job.',
    localizedHints: {
      'Malayalam': 'Third Conditional: neraththe apply cheytirunenkil, thozhil kittumayirunnu. Nashttappetta avakasham.',
      'Tamil': 'Third Conditional: munnathaaka viNNappittirundaal velai kidaithirukum. Tavaravittha vaaypu.',
      'Hindi': 'Third Conditional: pehle aavedan kiya hota to naukari milti. Khoya mauka.',
      'Telugu': 'Third Conditional: mundugaa apply chesiyuntee job vaccheydi. Pogottukona avakasham.',
      'Kannada': 'Third Conditional: muNdE arji haakiddare kelasa siguttittu. TappikoNda avasara.',
      'English': 'Third Conditional: missed opportunity. Applied earlier -> would have got the job.',
    },
    localizedTranslations: {
      'Malayalam': 'Avan neraththe apply cheytirunenkil, thozhil kittumayirunnu.',
      'Tamil': 'Avan munnathaaka viNNappittirundaal, velai kidaithirukum.',
      'Hindi': 'Agar usne pehle aavedan kiya hota, to use naukari milti.',
      'Telugu': 'Atanu mundugaa apply chesiyuntee, job vaccheydi.',
      'Kannada': 'Avanu muNdE arji haakiddare, kelasa siguttittu.',
      'English': 'If he had applied earlier, he would have got the job.',
    },
  ),
  ConditionalsExerciseItem(
    category: 'THIRD',
    conditionalType: 'Third Conditional',
    rule: 'If + had + past participle, would have + past participle -> different outcome',
    promptSentence: 'If they had taken the highway, they ___ (arrive) faster.',
    targetWord: 'would have arrived',
    acceptableWords: ['would have arrive', 'arrived', 'they would have arrived faster'],
    fullSentence: 'If they had taken the highway, they would have arrived faster.',
    localizedHints: {
      'Malayalam': 'Third Conditional: highway upayogichirunnenkil, vegam ethuyumayirunnu. Vythyastha phalam.',
      'Tamil': 'Third Conditional: neDunchaalai eduthirundaal vegamaaka vanthiruppargal.',
      'Hindi': 'Third Conditional: highway liya hota to jaldi pahunche hote.',
      'Telugu': 'Third Conditional: highway loteydarsthe vegangaa cheriydaamu.',
      'Kannada': 'Third Conditional: highway tagedukoNdiddare bEga taLuputtiDEvu.',
      'English': 'Third Conditional: different outcome. Taken highway -> would have arrived faster.',
    },
    localizedTranslations: {
      'Malayalam': 'Avark highway upayogichirunnenkil, vegam ethuyumayirunnu.',
      'Tamil': 'Avargal neDunchaalai eduthirundaal, vegamaaka vanthiruppargal.',
      'Hindi': 'Agar ve highway lete, to ve jaldi pahunchte.',
      'Telugu': 'Vaaru highway teesukonitey, vegangaa cheri uyantaaru.',
      'Kannada': 'Avaru highway tagedukoNdiddare, bEga taLuputtiddaru.',
      'English': 'If they had taken the highway, they would have arrived faster.',
    },
  ),
];

/// 🔀 Conditionals (If Clauses) Practice Card
/// Zero, First, Second and Third Conditional with STT, TTS,
/// 6-language support, collapsible rules matrix, and completion tracking.
class PocketConditionalsPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketConditionalsPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '13',
  });

  @override
  State<PocketConditionalsPracticeCard> createState() =>
      _PocketConditionalsPracticeCardState();
}

class _PocketConditionalsPracticeCardState
    extends State<PocketConditionalsPracticeCard>
    with SingleTickerProviderStateMixin {
  // ── state ──────────────────────────────────────────────────────────
  int _currentExerciseIndex = 0;
  String _activeFilter = 'ALL';
  bool _showRuleTable = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _isExerciseAnswered = false;
  bool _isCorrect = false;
  Timer? _listeningTimeoutTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── lifecycle ───────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initSpeechRecognizer();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _listeningTimeoutTimer?.cancel();
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  // ── TTS ─────────────────────────────────────────────────────────────
  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakText(String text) async {
    if (widget.onSpeak != null) {
      widget.onSpeak!(text);
      return;
    }
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  // ── STT ─────────────────────────────────────────────────────────────
  Future<void> _initSpeechRecognizer() async {
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (err) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) _stopListening();
          }
        },
      );
    } catch (_) {
      _isSpeechInitialized = false;
    }
  }

  Future<void> _startListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }
    HapticFeedback.mediumImpact();
    if (!_isSpeechInitialized) await _initSpeechRecognizer();
    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _isExerciseAnswered = false;
      _isCorrect = false;
    });
    _listeningTimeoutTimer?.cancel();
    _listeningTimeoutTimer = Timer(const Duration(seconds: 14), () {
      if (mounted && _isListening) _stopListening();
    });
    try {
      if (_isSpeechInitialized) {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() => _recognizedWords = result.recognizedWords);
              if (result.finalResult) {
                _evaluateSpokenAnswer(result.recognizedWords);
                _stopListening();
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 12),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            localeId: 'en_US',
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      }
    } catch (_) {
      if (mounted) _stopListening();
    }
  }

  Future<void> _stopListening() async {
    _listeningTimeoutTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isListening = false);
      if (_recognizedWords.isNotEmpty && !_isExerciseAnswered) {
        _evaluateSpokenAnswer(_recognizedWords);
      }
    }
  }

  // ── Evaluation ───────────────────────────────────────────────────────
  bool _matchesPhrase(String text, String phrase) {
    final t = text.trim();
    final p = phrase.trim();
    if (t.isEmpty || p.isEmpty) return false;
    if (t == p) return true;
    final escaped = RegExp.escape(p);
    return RegExp('\\b$escaped\\b', caseSensitive: false).hasMatch(t);
  }

  void _evaluateSpokenAnswer(String spokenText) {
    if (spokenText.trim().isEmpty) return;
    final ex = _filteredExercises[_currentExerciseIndex];
    String clean(String s) =>
        s.toLowerCase().replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '').trim();

    final spoken = clean(spokenText);
    final target = clean(ex.targetWord);
    final full = clean(ex.fullSentence);

    bool matched = _matchesPhrase(spoken, target);
    if (!matched) {
      for (final alt in ex.acceptableWords) {
        if (_matchesPhrase(spoken, clean(alt))) {
          matched = true;
          break;
        }
      }
    }
    if (!matched && (_matchesPhrase(spoken, full) || spoken == full)) {
      matched = true;
    }
    if (!matched) {
      final tokens = target.split(' ').where((w) => w.isNotEmpty).toList();
      if (tokens.length > 1 && tokens.every((t) => _matchesPhrase(spoken, t))) {
        matched = true;
      }
    }

    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = matched;
    });
    if (matched) {
      HapticFeedback.heavyImpact();
      _speakText(ex.fullSentence);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  // ── Filter & Nav ─────────────────────────────────────────────────────
  List<ConditionalsExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'ZERO':
        return _kConditionalsExercises.where((e) => e.category == 'ZERO').toList();
      case 'FIRST':
        return _kConditionalsExercises.where((e) => e.category == 'FIRST').toList();
      case 'SECOND':
        return _kConditionalsExercises.where((e) => e.category == 'SECOND').toList();
      case 'THIRD':
        return _kConditionalsExercises.where((e) => e.category == 'THIRD').toList();
      default:
        return _kConditionalsExercises;
    }
  }

  void _setFilter(String filter) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeFilter = filter;
      _currentExerciseIndex = 0;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToNext() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex = (_currentExerciseIndex + 1) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToPrevious() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex =
          (_currentExerciseIndex - 1 + list.length) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _forcePassForTesting() {
    final ex = _filteredExercises[_currentExerciseIndex];
    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = true;
      _recognizedWords = ex.targetWord;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  String _getLocalizedSubtitle(String lang) {
    switch (lang.toLowerCase()) {
      case 'tamil':
        return 'நிபந்தனை வாக்கியங்கள் (If Clauses)';
      case 'telugu':
        return 'షరతు వాక్యాలు (Conditionals)';
      case 'hindi':
        return 'सशर्त वाक्य (If Clauses)';
      case 'kannada':
        return 'ಷರತ್ತು ವಾಕ್ಯಗಳು (Conditionals)';
      case 'malayalam':
      default:
        return 'ഷർത്തുകൾ ഉള്ള വാക്യങ്ങൾ (Conditionals)';
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'ZERO':   return const Color(0xFF38BDF8);
      case 'FIRST':  return const Color(0xFF4ADE80);
      case 'SECOND': return const Color(0xFFFBBF24);
      case 'THIRD':  return const Color(0xFFF87171);
      default:       return const Color(0xFFC084FC);
    }
  }

  Color _filterChipColor(String filter) {
    switch (filter) {
      case 'ZERO':   return const Color(0xFF38BDF8);
      case 'FIRST':  return const Color(0xFF4ADE80);
      case 'SECOND': return const Color(0xFFFBBF24);
      case 'THIRD':  return const Color(0xFFF87171);
      default:       return const Color(0xFFC084FC);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    if (exercises.isEmpty) return const SizedBox.shrink();
    final safeIndex = _currentExerciseIndex.clamp(0, exercises.length - 1);
    final ex = exercises[safeIndex];
    final catColor = _categoryColor(ex.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : const Color(0xFF38BDF8).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── HEADER ───
          _buildHeader(),

          // ─── FILTER TABS ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'ALL (20)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('ZERO', 'ZERO (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('FIRST', 'FIRST (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('SECOND', 'SECOND (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('THIRD', 'THIRD (5)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ─── COLLAPSIBLE RULES GUIDE ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showRuleTable = !_showRuleTable);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Conditionals Rules Guide  (Zero → Third + Unless)',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _showRuleTable
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_showRuleTable) ...[
            const SizedBox(height: 8),
            _buildRuleTable(),
          ],

          const SizedBox(height: 10),

          // ─── CONDITIONAL TYPE BADGE ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: catColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    ex.conditionalType.toUpperCase(),
                    style: GoogleFonts.firaCode(
                      color: catColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ex.rule,
                    style: GoogleFonts.inter(
                        color: Colors.white54, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ─── EXERCISE CARD ───
          _buildExerciseCard(ex, safeIndex, exercises.length, catColor),

          const SizedBox(height: 12),

          // ─── CONTROLS: PREV | SAY IT | NEXT ───
          _buildControls(catColor),

          const SizedBox(height: 10),

          // ─── DEV BYPASS ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextButton(
              onPressed: _forcePassForTesting,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8)),
              child: Text(
                '🧪 TEST: Auto-answer & play TTS',
                style: GoogleFonts.firaCode(
                    color: Colors.white24,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STEP ${widget.stepNumber} • 🔀 Conditionals (If Clauses)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedSubtitle(widget.selectedLanguage),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onCompleted(!widget.isCompleted);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.white24,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: widget.isCompleted ? Colors.black : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isCompleted ? 'DONE ✓' : 'MARK STEP',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: widget.isCompleted ? Colors.black : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ConditionalsExerciseItem ex, int index, int total, Color catColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: catColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Counter + TTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${index + 1} of $total',
                  style: GoogleFonts.firaCode(
                      color: catColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _speakText(ex.fullSentence),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.volume_up_rounded, color: catColor, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Prompt sentence
            Text(
              ex.promptSentence,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
            ),
            const SizedBox(height: 6),

            // Rule hint chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '💡 ${ex.rule.split("->").last.trim()}',
                style: GoogleFonts.inter(color: catColor.withValues(alpha: 0.85), fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),

            // STT result + feedback
            if (_recognizedWords.isNotEmpty || _isExerciseAnswered) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isExerciseAnswered
                      ? (_isCorrect
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFEF4444).withValues(alpha: 0.15))
                      : const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isExerciseAnswered
                        ? (_isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        : Colors.white24,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recognizedWords.isNotEmpty)
                      Text('"$_recognizedWords"',
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 13)),
                    if (_isExerciseAnswered) ...[
                      const SizedBox(height: 4),
                      Text(
                        _isCorrect
                            ? '✅ Correct! "${ex.targetWord}"'
                            : '❌ Answer: "${ex.targetWord}"',
                        style: GoogleFonts.outfit(
                          color: _isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.fullSentence,
                        style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Translation
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ex.getTranslation(widget.selectedLanguage),
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Hint
            Text(
              ex.getHint(widget.selectedLanguage),
              style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Color catColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Prev
          InkWell(
            onTap: _goToPrevious,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text('◀',
                  style: TextStyle(color: Colors.white60, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),

          // SAY IT
          Expanded(
            child: GestureDetector(
              onTap: _startListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [catColor, catColor.withValues(alpha: 0.75)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic,
                        color: Colors.black,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isListening ? 'LISTENING...' : '🎤 SAY IT',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Next
          InkWell(
            onTap: _goToNext,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text('▶',
                  style: TextStyle(color: Colors.white60, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isActive = _activeFilter == value;
    final chipColor = _filterChipColor(value);
    return GestureDetector(
      onTap: () => _setFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? chipColor.withValues(alpha: 0.2)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? chipColor : Colors.white12,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isActive ? chipColor : Colors.white38,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleTable() {
    final rows = [
      ['Type', 'Form', 'Use', 'Example'],
      ['Zero', 'if + present\n→ present', 'General truths & facts', 'If you heat ice, it melts.'],
      ['First', 'if + present\n→ will + verb', 'Real future possibility', 'If it rains, I will stay.'],
      ['Second', 'if + past\n→ would + verb', 'Imaginary / hypothetical', 'If I won, I would travel.'],
      ['Third', 'if + had + V3\n→ would have + V3', 'Unreal past / regret', 'If I had studied, I would have passed.'],
      ['Unless', '= "if not"', 'Conditional exception', 'I\'ll go unless it rains.'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: List.generate(rows.length, (rowIdx) {
            final row = rows[rowIdx];
            final isHeader = rowIdx == 0;
            return Container(
              decoration: BoxDecoration(
                color: isHeader
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.12)
                    : rowIdx.isOdd
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.transparent,
                borderRadius: rowIdx == 0
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : rowIdx == rows.length - 1
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(12))
                        : BorderRadius.zero,
              ),
              child: Row(
                children: List.generate(row.length, (colIdx) {
                  return Expanded(
                    flex: colIdx == 1 ? 2 : colIdx == 3 ? 3 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 7),
                      child: Text(
                        row[colIdx],
                        style: GoogleFonts.inter(
                          color: isHeader
                              ? const Color(0xFF38BDF8)
                              : colIdx == 0
                                  ? Colors.white70
                                  : Colors.white54,
                          fontSize: 10,
                          fontWeight: isHeader
                              ? FontWeight.w700
                              : colIdx == 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
