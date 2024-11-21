@echo off

echo --- Python PIP cache ---
python -m pip cache purge

echo:
echo:
echo --- Dotnet Nuget packages ---
dotnet nuget locals --clear all

echo:
echo:
echo --- Node NPM packages ---
:: npm cache clean --force
npm cache verify

PAUSE