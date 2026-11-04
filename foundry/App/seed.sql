-- Fictional Lighthouse training knowledge. These are not SchoolsFirst policies.
-- Runs only when support.db is missing or you explicitly use --reset-db.
-- Reset replaces this lab table inside a transaction. Edit content values below.
-- Twelve short articles keep the tool result small for the local model.
DROP TABLE IF EXISTS knowledge_articles;

CREATE TABLE knowledge_articles (
    article_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL
);

INSERT INTO knowledge_articles (article_id, title, content) VALUES
('member_care', 'Member Care contact and hours',
 'Lighthouse Member Care: +1 614 555 0118. Hours: Monday to Friday 08:00 to 18:00; Saturday 09:00 to 13:00; Sunday closed. Time zone: America/New_York.'),
('card_security', 'Lost cards and suspected unauthorized activity',
 'Lighthouse Card Security: +1 614 555 0199. Available 24 hours daily for lost cards or suspected unauthorized activity.'),
('capabilities', 'What this assistant can and cannot do',
 'This training assistant provides support information. It cannot access accounts, perform account actions, block cards, create cases or tickets, confirm refunds, or transfer to a person. No live service status is available.'),
('training_notice', 'Fictional training data only',
 'All content is fictional training data, not SchoolsFirst Federal Credit Union policy. All phone numbers are nonworking placeholders. Never enter real passwords, PINs, verification codes, or full account or card numbers.'),
('digital_banking_login', 'Help with digital banking sign-in',
 'Use Forgot password on the sign-in screen to start a password reset. If sign-in remains blocked, contact Member Care during its published hours. Staff and this assistant will never request your password, PIN, or verification code.'),
('mobile_check_deposit', 'Mobile deposit eligibility and limits',
 'Mobile check deposit is available for eligible personal checking accounts in the fictional Lighthouse app. Training limits are $2,000 per check and $3,000 total per day. The assistant cannot determine account eligibility, submit a check, or confirm acceptance.'),
('deposit_review', 'Mobile deposit review timing',
 'Mobile deposits submitted before 17:00 America/New_York on a business day enter that day''s review queue. Submissions at or after 17:00, on weekends, or on holidays enter the next business day''s review queue. Review timing does not guarantee funds availability.'),
('internal_transfers', 'Where to request an internal transfer',
 'Use Transfers in digital banking to request transfers between eligible Lighthouse checking and savings accounts. The assistant can explain this route but cannot check balances, verify available funds, schedule or execute a transfer, or confirm completion. Transfer fees and processing times are not provided.'),
('statements', 'Statement history and older copies',
 'Digital banking provides the most recent 24 months of monthly statements under Documents > Statements. Contact Member Care about older copies. Any applicable statement fees are not provided in this training knowledge. The assistant cannot open statements or verify document availability for a specific account.'),
('branch_appointments', 'Appointment windows and booking requests',
 'Training appointment windows are Monday to Friday 09:00 to 16:00 America/New_York. These are appointment windows, not branch opening hours. Contact Member Care to request an appointment. The assistant cannot check slot availability or book one. Branch addresses and opening hours are not provided.'),
('accessibility_support', 'Written instructions and extra support time',
 'Member Care can provide written step-by-step instructions and allow extra time for support conversations. Ask for your preferred communication format when contacting Member Care. The assistant can explain these options but cannot confirm interpreter availability or arrange support services.'),
('complaint_followup', 'Complaint acknowledgement and follow-up',
 'Contact Member Care to submit a service complaint. The training target is an acknowledgement within two business days. Resolution depends on the issue; no resolution deadline is provided. The assistant cannot submit, track, escalate, or confirm the status of a complaint.');
