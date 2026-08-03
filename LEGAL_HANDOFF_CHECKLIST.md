# Legal Handoff Checklist (Client-Filled)

Use this checklist to collect all legal/compliance inputs required for releasing:

- **Creative Mobadra** (User app)
- **Mobadra Staff** (Staff/Admin app)

---

## 1) Company Identity (Required)

- [x] Legal company name: `Creative Multi Solutions LLC`
- [x] Trade/brand name (if different): `Creative Multi Solutions`
- [x] Registered address: `AlWadi Building, Office 203 Sheikh Zaid Road, Dubai, UAE`
- [x] Country/Jurisdiction: `Dubai, UAE`
- [x] Support email: `info@creativemultisolutions.com`
- [x] Legal/privacy email: `info@creativemultisolutions.com`
- [x] Support phone: `+971508339005`
- [x] Website domain (public): `https://www.creativemultisolutions.com/`

---

## 2) Ownership & Responsibility

- [ ] Company confirms it is the legal data controller/owner for both apps.
- [ ] Company confirms developer is implementing on company instruction.
- [ ] Company accepts legal responsibility for policy accuracy.
- [x] Company legal representative name: `Mr. Mahmoud Imam`
- [x] Title: `Founder - CEO`
- [ ] Date: `not known`

---

## 3) Privacy Policy Finalization

- [ ] Privacy policy reviewed by legal counsel.
- [x] Final privacy policy URL published (HTTPS): `https://www.creativemultisolutions.com/privacy`
- [ ] Policy includes:
  - [ ] Data categories collected
  - [ ] Purpose of processing
  - [ ] Data sharing recipients
  - [ ] Retention periods
  - [ ] User rights (access/correction/deletion)
  - [ ] Contact details
  - [ ] International transfer clause (if applicable)

---

## 4) Terms of Service Finalization

- [ ] Terms reviewed by legal counsel.
- [x] Final terms URL published (HTTPS): `https://www.creativemultisolutions.com/terms`
- [ ] Terms include:
  - [ ] Eligibility/account responsibilities
  - [ ] Acceptable use
  - [ ] Healthcare disclaimer / emergency disclaimer
  - [ ] Liability limitations (as allowed by law)
  - [ ] Governing law/jurisdiction
  - [ ] Termination/suspension terms

---

## 5) Data Collection & Sharing Disclosure

### 5.1 Data Categories (mark all that apply)

- [ ] Name
- [ ] Phone
- [ ] Email
- [ ] Date of birth
- [ ] Family member data
- [ ] Appointment details
- [ ] Notes/user-generated text
- [ ] Wellness/reminder entries
- [ ] Uploaded images/documents
- [ ] Device identifiers
- [ ] Crash/performance diagnostics
- [ ] Other: `____________________________`

### 5.2 Data Uses (mark all that apply)

- [ ] Core app functionality
- [ ] Customer support
- [ ] Security/fraud prevention
- [ ] Analytics/product improvement
- [ ] Marketing
- [ ] Legal compliance
- [ ] Other: `____________________________`

### 5.3 Data Sharing

- [ ] Shared with healthcare providers/hospitals
- [ ] Shared with infrastructure vendors/processors
- [ ] Shared with government/regulators when required by law
- [ ] Not sold to data brokers
- [ ] Not used for third-party advertising (if true)

---

## 6) User Rights & Support Operations

- [ ] Process exists for user access requests.
- [ ] Process exists for correction requests.
- [ ] Process exists for deletion requests.
- [x] SLA for legal/privacy requests: `2 business days`
- [ ] Contact channel for rights requests: `not known`

---

## Critical Release Blockers (Must be resolved before store submission)

1. Publish live legal URLs on the company website (privacy, terms, data collection). ✅ Done
2. Get written legal review approval (privacy policy + terms).
3. Provide exact user-rights request contact channel (email/workflow owner).
4. Complete Play Data Safety and App Store Privacy answers for both User and Staff apps.
5. Fill sign-off table with Product Owner, Legal, Security/Compliance approvals.

---

## 7) Security & Technical Controls (Company Confirmation)

- [ ] All production APIs use HTTPS.
- [ ] Access controls and authentication are enforced.
- [ ] Backups and incident response process exist.
- [ ] Data breach notification process is defined.
- [ ] Retention/deletion process defined with backend team.

---

## 8) Google Play Compliance (Per App)

For each app (`User`, `Staff`):

- [ ] Data Safety form completed
- [ ] Privacy Policy URL entered
- [ ] Permissions justification complete (camera/photos/notifications/etc)
- [ ] App content rating completed
- [ ] Ads declaration completed
- [ ] Target audience declaration completed

Notes:
`____________________________________________________________`

---

## 9) Apple App Store Compliance (Per App)

For each app (`User`, `Staff`):

- [ ] App Privacy questionnaire completed
- [ ] Privacy Policy URL entered
- [ ] EULA/terms provided (if custom)
- [ ] Encryption/export compliance answered
- [ ] Medical/health disclaimers included where needed

Notes:
`____________________________________________________________`

---

## 10) Final URLs for App Build Defines

Fill these before release build:

- `PRIVACY_POLICY_URL = https://www.creativemultisolutions.com/privacy`
- `TERMS_OF_SERVICE_URL = https://www.creativemultisolutions.com/terms`
- `DATA_COLLECTION_URL = https://www.creativemultisolutions.com/data-collection`

---

## 11) Release Sign-off Table

| Role | Name | Date | Signature/Approval |
|------|------|------|--------------------|
| Product Owner |  |  |  |
| Legal Counsel |  |  |  |
| Security/Compliance |  |  |  |
| Engineering Lead |  |  |  |

---

## 12) Developer Completion Notes

- [ ] Legal URLs wired in app settings/help screens.
- [ ] Placeholder legal text replaced with approved final text.
- [ ] Store metadata reflects final legal wording.
- [ ] Build commands use correct `--dart-define` legal URLs.

Developer notes:
`____________________________________________________________`
