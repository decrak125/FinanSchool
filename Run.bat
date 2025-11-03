@echo off
echo Démarrage des serveurs Backend et Frontend...

REM Démarrer le serveur Backend
cd Backend
if %errorlevel% neq 0 (
    echo Erreur: Dossier Backend introuvable
    pause
    exit /b 1
)
start "Serveur Backend" cmd /k "php artisan serve"
@REM start "Serveur Backend" cmd /k "php artisan reverb:start"
start "Serveur Backend" cmd /k "php artisan schedule:work"


REM Démarrer le serveur Frontend
cd ..
cd Frontend
if %errorlevel% neq 0 (
    echo Erreur: Dossier Frontend introuvable
    pause
    exit /b 1
)
start "Serveur Frontend" cmd /k "npm run dev"

echo Les deux serveurs ont été démarrés dans des fenêtres séparées
pause