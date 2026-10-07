const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..', 'assets', 'curriculum');

function contextualNounExample(word) {
  const article = /^[aeiou]/i.test(word) ? 'an' : 'a';
  return `Could you point out ${article} ${word} for me?`;
}

function learnerErrorTraps(day) {
  const patterns = [
    ['He go to work every day.', 'He goes to work every day.', 'With he/she/it in the present simple, add -s or -es to the verb.'],
    ['Did you went to the market?', 'Did you go to the market?', 'After did, use the base verb (V1), not the past form.'],
    ['We discussed about the plan.', 'We discussed the plan.', 'Discuss already includes the idea of about.'],
    ['She is good in English.', 'She is good at English.', 'Use good at for a skill or subject.'],
    ['He is married with a teacher.', 'He is married to a teacher.', 'Use married to when naming a spouse.'],
    ['I am having two brothers.', 'I have two brothers.', 'Use have, not am having, for possession.'],
  ];
  const [incorrect, correct, explanation] = patterns[(day - 1) % patterns.length];
  return {
    id: `trap_d${day}_1`,
    question: 'Choose the natural, correct sentence.',
    options: [correct, incorrect, 'She go to the market yesterday.', 'I discussed about it yesterday.'],
    answer: correct,
    explanation,
  };
}

function grammarTrap(day) {
  return {
    id: `trap_d${day}_2`,
    question: 'Complete the correction: “Did she ___ the email?”',
    options: ['send', 'sent', 'sends', 'sending'],
    answer: 'send',
    explanation: 'After did, use the base form: did she send?',
  };
}

function prepositionTrap(day) {
  return {
    id: `trap_d${day}_3`,
    question: 'Choose the correct preposition: “Please reply ___ this message.”',
    options: ['to', 'on', 'at', 'with'],
    answer: 'to',
    explanation: 'We reply to a message, email, or question.',
  };
}

function milestoneExam(day) {
  const byDay = {
    30: {
      label: 'House 1 Cumulative Gate Exam',
      audio: 'Listen: “She does not work on Sundays.”',
      listening: ['She does not work on Sundays.', 'She do not work on Sundays.', 'She does not works on Sundays.', 'She not work on Sundays.'],
      repair: ['Did you go to the market yesterday?', 'Did you went to the market yesterday?', 'Did you went the market yesterday?', 'Did you goes to the market yesterday?'],
      role: ['Could you tell me where the pharmacy is?', 'Tell me pharmacy where is.', 'Where pharmacy?', 'You tell pharmacy.'],
      spoken: 'Describe your daily routine in three short sentences. Include a time, an activity, and one preference.',
      grammar: ['There are two chairs in the room.', 'There is two chairs in the room.', 'There are two chair in the room.', 'There two chairs are in the room.'],
    },
    60: {
      label: 'House 2 Cumulative Gate Exam',
      audio: 'Listen: “I missed the bus, so I took a taxi.”',
      listening: ['I missed the bus, so I took a taxi.', 'I miss the bus, so I take a taxi.', 'I missed the bus, so I take a taxi.', 'I was miss the bus, so I took taxi.'],
      repair: ['She did not buy anything yesterday.', 'She did not bought anything yesterday.', 'She did not buys anything yesterday.', 'She not buy anything yesterday.'],
      role: ['Could you please tell me when the next train leaves?', 'Tell me next train when leave.', 'When next train leaving?', 'You tell next train.'],
      spoken: 'Tell a short story about yesterday: where you went, what happened, and what you will do next time.',
      grammar: ['I am going to call the doctor tomorrow.', 'I going to call the doctor tomorrow.', 'I am go to call the doctor tomorrow.', 'I will going call the doctor tomorrow.'],
    },
    90: {
      label: '90-Day Graduation Assessment',
      audio: 'Listen: “I have worked here for three years.”',
      listening: ['I have worked here for three years.', 'I have work here for three years.', 'I am working here since three years.', 'I worked here since three years.'],
      repair: ['I discussed the proposal with my manager.', 'I discussed about the proposal with my manager.', 'I have discussed about the proposal to my manager.', 'I discussed the proposal to my manager yesterday.'],
      role: ['I see your point; however, I recommend a different approach.', 'I am not agree with you.', 'Your idea is wrong.', 'I recommend to change it.'],
      spoken: 'Give a 45-second professional introduction: your experience, one strength, and a goal for the next year.',
      grammar: ['If I had more time, I would prepare a fuller report.', 'If I would have more time, I will prepare a fuller report.', 'If I had more time, I will prepare a fuller report.', 'If I have more time, I would prepared a fuller report.'],
    },
  }[day];

  return [
    { assessmentType: 'listening_discrimination', audioPrompt: byDay.audio, q: 'Choose the sentence you hear.', options: byDay.listening, answer: byDay.listening[0] },
    { assessmentType: 'repair_correction', q: 'Choose the corrected sentence.', options: byDay.repair, answer: byDay.repair[0] },
    { assessmentType: 'pragmatic_response', q: 'Choose the most appropriate spoken response.', options: byDay.role, answer: byDay.role[0] },
    { assessmentType: 'spoken_response', responseMode: 'speech', q: byDay.spoken, options: ['Record my response', 'Skip speaking', 'Read silently', 'Use a translation app'], answer: 'Record my response', expectedElements: ['clear complete sentences', 'relevant details', 'intelligible speech'] },
    { assessmentType: 'cumulative_grammar', q: 'Choose the grammatically correct sentence.', options: byDay.grammar, answer: byDay.grammar[0] },
  ];
}

const canonicalDays = [];
const canonicalHouses = new Map();

for (let day = 1; day <= 90; day++) {
  const file = path.join(root, `day_${day}_curriculum.json`);
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  for (const noun of data.vocabulary?.nouns ?? []) {
    if (/^We learned about .+ in today's lesson\.$/.test(noun.example ?? '')) {
      noun.example = contextualNounExample(noun.word);
    }
  }
  const defense = data.steps.find((step) => step.gameType === 'house_defense_trap_builder');
  if (defense) defense.traps = [learnerErrorTraps(day), grammarTrap(day), prepositionTrap(day)];
  if ([30, 60, 90].includes(day)) {
    const exam = data.steps.find((step) => step.gameType === 'daily_exam');
    exam.title.en = milestoneExam(day) && ({30: 'House 1 Cumulative Gate Exam', 60: 'House 2 Cumulative Gate Exam', 90: '90-Day Graduation Assessment'})[day];
    exam.examQuestions = milestoneExam(day);
  }
  fs.writeFileSync(file, `${JSON.stringify(data, null, 2)}\n`, 'utf8');

  const course = data.course ?? {};
  const grammar = data.grammarRule ?? {};
  const steps = data.steps ?? [];
  const house = course.house;
  if (!canonicalHouses.has(house)) {
    canonicalHouses.set(house, {
      house,
      titleEn: course.houseTitle?.en ?? `House ${house}`,
      titleMl: course.houseTitle?.ml ?? '',
      dayRange: house === 1 ? 'Days 1–30' : house === 2 ? 'Days 31–60' : 'Days 61–90',
      colorHex: house === 1 ? '#10B981' : house === 2 ? '#38BDF8' : '#A855F7',
      gateExamDay: house * 30,
    });
  }
  canonicalDays.push({
    day,
    house,
    topic: course.topic ?? {},
    themeEn: course.topic?.en ?? '',
    themeMl: course.topic?.ml ?? '',
    grammarTarget: grammar.formula ?? '',
    grammarRule: grammar,
    vocabulary: data.vocabulary ?? {},
    gameMetadata: steps.map((step) => ({
      stepNumber: step.stepNumber,
      id: step.id,
      gameType: step.gameType,
      ...(step.targetObjects ? {targetObjects: step.targetObjects} : {}),
      ...(step.challengePatterns ? {challengePatterns: step.challengePatterns} : {}),
      ...(step.passScore != null ? {passScore: step.passScore} : {}),
    })),
  });
}

const master = {
  curriculum_version: '90_day_master_v3',
  sourceOfTruth: 'assets/curriculum/day_{N}_curriculum.json',
  title: 'Pocket Mates 90-Day Spoken English Master Roadmap',
  houses: [...canonicalHouses.values()].sort((a, b) => a.house - b.house),
  days: canonicalDays,
};
fs.writeFileSync(
  path.join(root, 'master_90_days_syllabus.json'),
  `${JSON.stringify(master, null, 2)}\n`,
  'utf8',
);

console.log('Updated content and generated 90 canonical master syllabus entries.');
