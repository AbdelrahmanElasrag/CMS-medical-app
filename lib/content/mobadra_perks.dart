/// Creative Mobadra member perks (all free). Drives home grid and detail dialogs.
class MobadraPerk {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String description;

  const MobadraPerk({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.description,
  });
}

const int kGiftPointsThreshold = 1000;

const List<MobadraPerk> kMobadraPerks = [
  MobadraPerk(
    title: 'Transportation',
    subtitle: 'Door-to-hospital • Member benefit',
    imageUrl: 'assets/perks images/path.gif',
    description:
        'Complimentary transportation from your home or workplace to partner hospitals, coordinated by Creative Mobadra.',
  ),
  MobadraPerk(
    title: 'On-site coordinators',
    subtitle: 'Personal support • Every visit',
    imageUrl: 'assets/perks images/reception.gif',
    description:
        'Dedicated coordinators at partner hospitals help with registration, wayfinding, and paperwork so your visit runs smoothly.',
  ),
  MobadraPerk(
    title: 'Fast check-in',
    subtitle: 'Less waiting • Priority flow',
    imageUrl: 'assets/perks images/check-in.gif',
    description:
        'Streamlined check-in with our team working alongside hospital staff to reduce delays where available.',
  ),
  MobadraPerk(
    title: 'Follow-up appointments',
    subtitle: 'Scheduling • Care continuity',
    imageUrl: 'assets/perks images/appointment.gif',
    description:
        'We help schedule and track follow-up visits and connect you with the right departments after your initial appointment.',
  ),
  MobadraPerk(
    title: 'Patient support',
    subtitle: 'Questions • Guidance',
    imageUrl: 'assets/perks images/helpdesk.gif',
    description:
        'Ongoing support for non-clinical questions about your journey, logistics, and next steps with partner providers.',
  ),
  MobadraPerk(
    title: 'Post-treatment visits',
    subtitle: 'Recovery • Check-ins',
    imageUrl: 'assets/perks images/clipboard.gif',
    description:
        'Coordination of post-treatment visit logistics and reminders so you stay on track with your care plan.',
  ),
];
