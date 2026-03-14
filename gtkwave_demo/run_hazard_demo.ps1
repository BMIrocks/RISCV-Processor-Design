Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "    4-HAZARD DEMONSTRATION TESTBENCH" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Step 1/4] Assembling instructions..." -ForegroundColor Yellow
python ..\assembler.py "hazard_demo_instructions.txt" "..\..\instructions_demo_hex.txt"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Assembly failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Assembly complete" -ForegroundColor Green
Write-Host ""

Write-Host "[Step 2/4] Setting up instruction memory..." -ForegroundColor Yellow
Copy-Item "..\..\instructions_demo_hex.txt" "..\..\instructions.txt" -Force
Write-Host "  ✓ Instructions ready" -ForegroundColor Green
Write-Host ""

Write-Host "[Step 3/4] Compiling testbench..." -ForegroundColor Yellow
iverilog -o hazard_demo_sim hazard_demo_tb.v 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Compilation failed!" -ForegroundColor Red
    iverilog -o hazard_demo_sim hazard_demo_tb.v
    exit 1
}
Write-Host "  ✓ Compilation successful" -ForegroundColor Green
Write-Host ""

Write-Host "[Step 4/4] Running simulation..." -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Gray
Write-Host ""
vvp hazard_demo_sim
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Gray
Write-Host "  ✓ Simulation complete" -ForegroundColor Green
Write-Host ""

if (Test-Path "hazard_demo.vcd") {
    Write-Host "VCD file generated: hazard_demo.vcd" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host "    OPENING GTKWAVE..." -ForegroundColor Cyan
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Look for these key patterns in GTKWave:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  HAZARD 1 (EX Data Hazard):" -ForegroundColor White
    Write-Host "    - forward_A or forward_B = 10 (binary)" -ForegroundColor Cyan
    Write-Host "    - No stall signals" -ForegroundColor Cyan
    Write-Host "    - Immediate dependency resolved" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  HAZARD 2 (MEM Data Hazard):" -ForegroundColor White
    Write-Host "    - forward_A or forward_B = 01 (binary)" -ForegroundColor Cyan
    Write-Host "    - No stall signals" -ForegroundColor Cyan
    Write-Host "    - 2-instruction gap dependency" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  HAZARD 3 (Load-Use Hazard):" -ForegroundColor White
    Write-Host "    - load_use_hazard = 1" -ForegroundColor Cyan
    Write-Host "    - stall_IF = 1, stall_ID = 1" -ForegroundColor Cyan
    Write-Host "    - flush_ID_EX = 1 (bubble inserted)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  HAZARD 4 (Control Hazard):" -ForegroundColor White
    Write-Host "    - branch_taken = 1" -ForegroundColor Cyan
    Write-Host "    - flush_IF_ID = 1" -ForegroundColor Cyan
    Write-Host "    - Pipeline flushed" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Start-Process gtkwave -ArgumentList "hazard_demo.vcd", "hazard_demo.gtkw"
    
} else {
    Write-Host "ERROR: VCD file not generated!" -ForegroundColor Red
    exit 1
}

Write-Host "Done! Check the GTKWave window." -ForegroundColor Green
Write-Host ""