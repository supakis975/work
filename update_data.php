<?php
// update_data.php
header('Content-Type: application/json; charset=utf-8');
set_time_limit(0);

// ปรับชื่อตามไฟล์ Python ของคุณ
$pythonScript = __DIR__ . DIRECTORY_SEPARATOR . 'update_db_only.py';
$pythonCmd = 'python'; // หรือ 'python3' หรือ พาธเต็มของ Python executable

if (!file_exists($pythonScript)) {
    echo json_encode(['status' => 'error', 'message' => 'Python script not found: ' . basename($pythonScript)]);
    exit;
}

// รันสคริปต์ (จับ output เพื่อ debug)
$cmd = escapeshellcmd("$pythonCmd " . escapeshellarg($pythonScript) . " 2>&1");
$output = shell_exec($cmd);

if ($output === null) {
    echo json_encode(['status' => 'error', 'message' => 'No output from Python. Check server permissions or python path.']);
    exit;
}

// ถ้าต้องการ สามารถวิเคราะห์ output เพื่อเช็ค success/fail ได้
echo json_encode(['status' => 'ok', 'message' => 'Script executed', 'output' => mb_substr($output, 0, 8000)]);
exit;
