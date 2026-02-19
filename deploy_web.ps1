Write-Host "Building Web Portal..."
cd web_portal
npm run build
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE 
}
cd ..
Write-Host "Deploying to Firebase..."
firebase deploy --only hosting
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Deployment failed!" -ForegroundColor Red
    exit $LASTEXITCODE 
}
Write-Host "Deployment successful!" -ForegroundColor Green
