#!/bin/bash
# Shared fixture: disposable populated mail profile for .opencode#2532
# behavioral scenarios (SC-8 search-read, SC-9 draft dry-run).
#
# Creates a minimal Thunderbird-format profile under <workdir>/.test-fixture-profile/
# with two inbound messages (one with a MIME attachment) and an identity
# (bob@example.org). Records a SHA256 manifest of the fixture for the
# orchestrator's pre/post integrity comparison. Never touches any real profile.
#
# Usage: sourced by the harness with $1 = test workdir.

make_fixture_profile() {
    local wd="$1"
    local root="$wd/.test-fixture-profile/.thunderbird"
    local prof="$root/fixture.default"
    local maildir="$prof/Mail/Local Folders"

    rm -rf "$wd/.test-fixture-profile"
    mkdir -p "$maildir"

    printf '[Profile0]\nName=default\nIsRelative=1\nPath=fixture.default\nDefault=1\n' \
        > "$root/profiles.ini"

    cat > "$prof/prefs.js" <<'PREFS'
user_pref("mail.account.account1.identities", "id1");
user_pref("mail.account.account1.server", "server1");
user_pref("mail.accountmanager.accounts", "account1");
user_pref("mail.accountmanager.defaultaccount", "account1");
user_pref("mail.identity.id1.useremail", "bob@example.org");
user_pref("mail.identity.id1.fullName", "Bob Example");
user_pref("mail.server.server1.directory", "Mail/Local Folders");
user_pref("mail.server.server1.hostname", "Local Folders");
user_pref("mail.server.server1.type", "none");
user_pref("mail.server.server1.userName", "nobody");
PREFS

    python3 - "$maildir/Inbox" <<'PYMSG'
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

m1 = """From - Mon Oct 05 10:00:00 2026
From: carol@example.net
To: bob@example.org
Subject: Re: server maintenance window
Message-ID: <m2@example.net>
Date: Mon, 5 Oct 2026 11:00:00 +0000

The maintenance window is moved to Friday 22:00 UTC.

Carol

"""
m = MIMEMultipart()
m['From'] = 'alice@example.net'; m['To'] = 'bob@example.org'
m['Subject'] = 'Quarterly invoice and statement'
m['Message-ID'] = '<att1@example.net>'
m['Date'] = 'Mon, 5 Oct 2026 12:00:00 +0000'
m.attach(MIMEText('Hello Bob,\nattached are the quarterly invoice and statement.\n\nAlice\n'))
m.attach(MIMEApplication(b'INVOICE-Q3-DEMO-CONTENT\n', Name='invoice-q3.pdf'))
with open(sys.argv[1], 'w') as f:
    f.write(m1)
    f.write('From - Mon Oct 05 12:00:00 2026\n')
    for line in m.as_string().splitlines():
        if line.startswith('From '):
            line = '>From ' + line[5:]
        f.write(line + '\n')
    f.write('\n')
PYMSG

    ( cd "$wd/.test-fixture-profile" && find . -type f -print0 \
        | sort -z | xargs -0 sha256sum ) > "$wd/.test-fixture-profile.sha256"
}

make_fixture_profile "$1"
