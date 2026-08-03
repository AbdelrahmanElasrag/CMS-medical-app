# Data Collection Disclosure (Store Preparation)

This file is a practical checklist for Play Console "Data safety" and App Store "App Privacy" forms.

## Data Categories Used by This App

Mark only what is actually used in production:

- Contact info (name, phone, email)
- Health / wellness info (user-entered health-related inputs)
- User content (notes, reminder text, uploaded images where applicable)
- Identifiers (account ID, staff ID, patient ID)
- Diagnostics (crash/performance data, if enabled)

## Data Uses

Typical uses:

- App functionality (appointments, reminders, account features)
- Customer support
- Security / fraud prevention
- Analytics / product improvement (if enabled)

## Data Sharing

Potential sharing:

- Healthcare/hospital partners for scheduling and service workflow
- Backend infrastructure/service providers acting on your behalf

Do not declare "data not shared" if operational sharing exists.

## Encryption and Security

- Data transmitted over secure channels (HTTPS)
- Authenticated backend access controls
- Production database and infrastructure protections

## User Rights / Controls

- Access/correction/deletion requests via support/legal contact
- Account deletion process policy and workflow

## You Must Finalize Before Submission

1. Confirm exact production data map with backend team.
2. Confirm whether any analytics/crash SDKs are enabled.
3. Confirm whether any data is used for advertising (usually "No").
4. Align Play/App Store declarations with Privacy Policy wording.
