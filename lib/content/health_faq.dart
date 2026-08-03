/// Static FAQ entries for the Health assistant (no LLM).
class HealthFaqEntry {
  const HealthFaqEntry({required this.question, required this.answer});
  final String question;
  final String answer;
}

const List<HealthFaqEntry> kHealthFaqEntries = [
  HealthFaqEntry(
    question: 'What is Mobadra?',
    answer:
        'Mobadra helps you book hospital visits, explore offers, and manage wellness reminders in one place. Use the Book button for appointments.',
  ),
  HealthFaqEntry(
    question: 'How do I book a visit?',
    answer:
        'Tap the floating Book button, choose hospital and speciality, pick a preferred date, and submit. Our team will follow up to confirm.',
  ),
  HealthFaqEntry(
    question: 'Can I add family members?',
    answer:
        'Yes. Open your profile and manage family members so you can book on their behalf when your plan allows it.',
  ),
  HealthFaqEntry(
    question: 'What is the symptom check?',
    answer:
        'It walks through common symptoms using the EndlessMedical engine (synthetic clinical knowledge). It is not a diagnosis and does not replace a clinician.',
  ),
  HealthFaqEntry(
    question: 'Is the symptom check always right?',
    answer:
        'No. Results are probabilistic and educational. If you have severe or worsening symptoms, seek emergency care or call your local emergency number.',
  ),
  HealthFaqEntry(
    question: 'What about health insurance in the UAE?',
    answer:
        'Coverage depends on your insurer and plan. For plan-specific questions, contact your insurance provider or our support with your policy details.',
  ),
];
