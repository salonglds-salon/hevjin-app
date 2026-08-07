# Hevjin - E-Mail Deliverability

Stand: 07.08.2026

## DNS-Status (geprueft)

| Record | Wert | Status |
|---|---|---|
| A (hevjin.app) | 185.199.108-111.153 | OK - GitHub Pages |
| TXT (hevjin.app) | `v=spf1 include:_spf-eu.ionos.com ~all` | OK - IONOS Default |
| TXT (resend._domainkey) | `v=DKIM1; k=rsa; p=MIGfMA0...` | OK - DKIM aktiv |
| TXT (send.hevjin.app) | `v=spf1 include:amazonses.com ~all` | OK - Resend SPF |
| MX (send.hevjin.app) | `feedback-smtp.eu-west-1.amazonses.com` | OK - Bounce-Handling |
| TXT (_dmarc.hevjin.app) | `v=DMARC1; p=none; rua=mailto:hevjinsupport@gmail.com; fo=1` | OK - erledigt 07.08.2026 |

**Fazit:** Die Technik ist korrekt. SPF, DKIM und Bounce-Handling stimmen.
DKIM signiert mit `d=hevjin.app`, passt also zur Absenderadresse
`noreply@hevjin.app` -> DMARC-Alignment ist erfuellt.

---

## Warum landen Mails trotzdem im Spam?

| Ursache | Gewicht | Loesbar? |
|---|---|---|
| **Domain-Reputation** - hevjin.app ist brandneu, hat keine Sendehistorie | Hoch | Nur mit Zeit |
| **Link zeigt auf supabase.co**, Absender ist hevjin.app -> Domain-Mismatch | Mittel | Nur mit Supabase Pro (Custom Auth Domain) |
| **Mail-Inhalt zu duenn** - kurzes HTML mit einem einzigen Link = Phishing-Muster | Mittel | JA - sofort |
| **DMARC minimal** - kein `rua`, kein Alignment-Modus | Niedrig | JA - sofort |

Die zwei loesbaren Punkte gehen wir jetzt an.

---

## Fix 1: DMARC verbessern (IONOS) -- ERLEDIGT 07.08.2026

Der alte Eintrag war ein CNAME `_dmarc` -> `dmarc.ionos.de` (von IONOS gehostet,
Wert `v=DMARC1; p=none;`). CNAME wurde geloescht und durch einen eigenen
TXT-Record ersetzt. Verifiziert per DNS-Abfrage: live.

Hinweis: `adkim=r` / `aspf=r` wurden weggelassen, da relaxed laut RFC 7489
ohnehin der Standardwert ist. Echter Gewinn ist nur `rua=` (Reports).

**IONOS -> Domains & SSL -> hevjin.app -> DNS**

Bestehenden Eintrag `_dmarc` bearbeiten:

| Feld | Wert |
|---|---|
| Typ | TXT |
| Hostname | `_dmarc` |
| Wert | `v=DMARC1; p=none; rua=mailto:hevjinsupport@gmail.com; adkim=r; aspf=r; fo=1; pct=100` |
| TTL | 3600 |

Was das bringt:
- `rua=` -> du bekommst woechentliche Reports, wer in deinem Namen sendet
- `adkim=r` / `aspf=r` -> relaxed Alignment, verhindert Fehlschlaege bei Subdomains
- `fo=1` -> Report auch bei Teilfehlern
- `p=none` bleibt erstmal (nur beobachten, nichts blockieren)

**Spaeter** (nach 2-4 Wochen ohne Auffaelligkeiten in den Reports):
`p=none` auf `p=quarantine` aendern. Das erhoeht das Vertrauen zusaetzlich.

---

## Fix 2: E-Mail-Templates aufwerten (Supabase)

Die aktuellen Templates sind 3 Zeilen HTML mit einem Link.
Genau dieses Muster filtern Gmail und Outlook aggressiv.

Die neuen Templates unten haben:
- deutlich mehr Textinhalt (senkt Spam-Score)
- klare Absender-Identitaet + Adresse im Footer (wie echte Firmenmails)
- die URL auch als sichtbaren Text (Transparenz statt versteckter Link)
- Tabellen-Layout (E-Mail-Client-Standard, kein modernes CSS)
- HTML-Entities fuer Umlaute (keine Encoding-Probleme in alten Clients)

**Wo einfuegen:** Supabase -> Authentication -> Emails

---

### Template A: "Confirm sign up"

**Subject:**
```
Bestaetige deine E-Mail-Adresse fuer Hevjin
```

**Body:**
```html
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
  <tr><td align="center">
    <table width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;padding:32px;">
      <tr><td>
        <h1 style="margin:0 0 8px;font-size:22px;color:#1a1a1a;">Willkommen bei Hevj&#238;n</h1>
        <p style="margin:0 0 20px;font-size:14px;color:#6b6b6b;">Partnersuche f&#252;r &#202;ziden</p>

        <p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#333;">
          Hallo,
        </p>
        <p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#333;">
          vielen Dank f&#252;r deine Registrierung bei Hevj&#238;n. Damit wir sicher sein
          k&#246;nnen, dass diese E-Mail-Adresse wirklich dir geh&#246;rt, bitten wir dich
          um eine kurze Best&#228;tigung.
        </p>
        <p style="margin:0 0 24px;font-size:15px;line-height:1.6;color:#333;">
          Klicke dazu einfach auf den folgenden Button:
        </p>

        <table cellpadding="0" cellspacing="0" style="margin:0 0 24px;">
          <tr><td style="background:#e02020;border-radius:6px;">
            <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:bold;color:#ffffff;text-decoration:none;">
              E-Mail-Adresse best&#228;tigen
            </a>
          </td></tr>
        </table>

        <p style="margin:0 0 8px;font-size:13px;line-height:1.6;color:#6b6b6b;">
          Falls der Button nicht funktioniert, kopiere diese Adresse in deinen Browser:
        </p>
        <p style="margin:0 0 24px;font-size:12px;line-height:1.5;color:#0066cc;word-break:break-all;">
          {{ .ConfirmationURL }}
        </p>

        <p style="margin:0 0 24px;font-size:13px;line-height:1.6;color:#6b6b6b;">
          Der Link ist aus Sicherheitsgr&#252;nden 24 Stunden g&#252;ltig. Solltest du dich
          nicht bei Hevj&#238;n registriert haben, kannst du diese E-Mail einfach
          ignorieren &#8211; es wird kein Konto angelegt.
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" style="border-top:1px solid #eeeeee;padding-top:16px;">
          <tr><td>
            <p style="margin:0 0 4px;font-size:12px;line-height:1.6;color:#999;">
              <strong>Hevj&#238;n</strong> &#8211; Partnersuche f&#252;r &#202;ziden<br>
              Dalshad Kasim, Bahnhofstr. 30, 49413 Dinklage, Deutschland<br>
              hevjinsupport@gmail.com &#183; https://hevjin.app
            </p>
            <p style="margin:8px 0 0;font-size:11px;color:#bbb;">
              Du erh&#228;ltst diese E-Mail, weil mit dieser Adresse eine Registrierung
              bei Hevj&#238;n gestartet wurde.
            </p>
          </td></tr>
        </table>
      </td></tr>
    </table>
  </td></tr>
</table>
```

---

### Template B: "Reset password"

**Subject:**
```
Neues Passwort fuer dein Hevjin-Konto
```

**Body:**
```html
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
  <tr><td align="center">
    <table width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;padding:32px;">
      <tr><td>
        <h1 style="margin:0 0 8px;font-size:22px;color:#1a1a1a;">Passwort zur&#252;cksetzen</h1>
        <p style="margin:0 0 20px;font-size:14px;color:#6b6b6b;">Hevj&#238;n &#8211; Partnersuche f&#252;r &#202;ziden</p>

        <p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#333;">
          Hallo,
        </p>
        <p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#333;">
          f&#252;r dein Hevj&#238;n-Konto wurde ein neues Passwort angefordert.
          Du kannst jetzt ein neues Passwort festlegen.
        </p>
        <p style="margin:0 0 24px;font-size:15px;line-height:1.6;color:#333;">
          Klicke dazu auf den folgenden Button:
        </p>

        <table cellpadding="0" cellspacing="0" style="margin:0 0 24px;">
          <tr><td style="background:#e02020;border-radius:6px;">
            <a href="{{ .ConfirmationURL }}" style="display:inline-block;padding:14px 28px;font-size:15px;font-weight:bold;color:#ffffff;text-decoration:none;">
              Neues Passwort festlegen
            </a>
          </td></tr>
        </table>

        <p style="margin:0 0 8px;font-size:13px;line-height:1.6;color:#6b6b6b;">
          Falls der Button nicht funktioniert, kopiere diese Adresse in deinen Browser:
        </p>
        <p style="margin:0 0 24px;font-size:12px;line-height:1.5;color:#0066cc;word-break:break-all;">
          {{ .ConfirmationURL }}
        </p>

        <p style="margin:0 0 24px;font-size:13px;line-height:1.6;color:#6b6b6b;">
          Der Link ist aus Sicherheitsgr&#252;nden 1 Stunde g&#252;ltig und kann nur
          einmal verwendet werden. Wenn du kein neues Passwort angefordert hast,
          ist nichts passiert &#8211; dein bisheriges Passwort bleibt g&#252;ltig
          und du kannst diese E-Mail ignorieren.
        </p>

        <table width="100%" cellpadding="0" cellspacing="0" style="border-top:1px solid #eeeeee;padding-top:16px;">
          <tr><td>
            <p style="margin:0 0 4px;font-size:12px;line-height:1.6;color:#999;">
              <strong>Hevj&#238;n</strong> &#8211; Partnersuche f&#252;r &#202;ziden<br>
              Dalshad Kasim, Bahnhofstr. 30, 49413 Dinklage, Deutschland<br>
              hevjinsupport@gmail.com &#183; https://hevjin.app
            </p>
            <p style="margin:8px 0 0;font-size:11px;color:#bbb;">
              Diese E-Mail wurde an dich gesendet, weil f&#252;r diese Adresse ein
              Hevj&#238;n-Konto existiert.
            </p>
          </td></tr>
        </table>
      </td></tr>
    </table>
  </td></tr>
</table>
```

---

## Fix 3: Absendername in Supabase

**Supabase -> Project Settings -> Authentication -> SMTP Settings**

| Feld | Wert |
|---|---|
| Sender email | `noreply@hevjin.app` |
| Sender name | `Hevjin` |

Kein `noreply` im Anzeigenamen - nur in der Adresse.

---

## Was du selbst tun kannst (wirkt am staerksten)

Domain-Reputation baut sich durch **Engagement** auf. Die ersten Mails
entscheiden, wie Gmail die Domain dauerhaft einstuft.

1. **Erste 10-20 Nutzer briefen:** Mail aus dem Spam holen, auf
   "Kein Spam" klicken, Absender zu Kontakten hinzufuegen.
   Jede solche Aktion ist ein starkes positives Signal.
2. **Nicht an ungueltige Adressen senden.** Bounces schaden stark.
   Deshalb ist die E-Mail-Bestaetigung (jetzt aktiv) genau richtig.
3. **Langsam hochfahren.** Nicht 500 Mails am ersten Tag.

Erfahrungswert: nach ca. **2-4 Wochen** regulaerer Nutzung landen die
Mails im Hauptpostfach.

---

## Spaeter pruefen

Testtool: https://www.mail-tester.com
Registriere einen Testaccount mit der dort angezeigten Adresse
-> du bekommst einen Score von 0-10 und eine Liste der Abzuege.
Ziel: 8 oder besser.
