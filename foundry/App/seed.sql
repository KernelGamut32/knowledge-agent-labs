-- Fictional Lighthouse training knowledge. These are not SchoolsFirst policies.
-- Runs only when support.db is missing or you explicitly use --reset-db.
-- Reset replaces this lab table inside a transaction. Edit content values below.
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
 'All content is fictional training data, not SchoolsFirst Federal Credit Union policy. All phone numbers are nonworking placeholders. Never enter real passwords, PINs, verification codes, or full account or card numbers.');
