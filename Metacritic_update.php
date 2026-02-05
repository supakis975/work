<?php
// Metacritic_update.php
header('Content-Type: application/json; charset=utf-8');

// ไม่ให้ PHP หมดเวลา
@set_time_limit(0);

// ---- CONFIG ----
$pythonScript = __DIR__ . DIRECTORY_SEPARATOR . 'webscrape.py'; // ปรับชื่อไฟล์ถ้าจำเป็น
// ถ้าต้องการระบุ python แบบเต็มพาธ ให้เพิ่มใน $candidates
$pythonCandidates = [
    'python',       
    'python3',      
    '"C:\xampp2\htdocs\ProjectMine1\ProjectMine\.venv\Scripts\python.exe"e', // ตัวอย่าง Windows path - แก้ให้ตรงเครื่องคุณถ้าต้องการ
    '"C:\xampp2\htdocs\ProjectMine1\ProjectMine\.venv\Scripts\python.exe"'
];

function json_error($msg, $extra = []) {
    $out = array_merge(['status' => 'error', 'message' => $msg], $extra);
    echo json_encode($out, JSON_UNESCAPED_UNICODE);
    exit;
}

function is_exec_allowed() {
    // ตรวจสอบว่าฟังก์ชันรันคำสั่ง shell ถูกปิดหรือไม่
    $disabled = ini_get('disable_functions');
    if (!$disabled) return true;
    $disabled = array_map('trim', explode(',', $disabled));
    foreach (['proc_open','shell_exec','exec','system'] as $f) {
        if (in_array($f, $disabled)) {
            return false;
        }
    }
    return true;
}

// ตรวจสอบสคริปต์ Python มีอยู่หรือไม่
if (!file_exists($pythonScript)) {
    json_error('Script not found: ' . basename($pythonScript));
}

// ตรวจสอบว่า PHP สามารถเรียกคำสั่งภายนอกได้
if (!is_exec_allowed()) {
    json_error('Server configuration prevents executing external commands (disabled functions). Ask host to allow proc_open/shell_exec/exec or use CRON/background job.');
}

// หาพาธ python ที่ใช้งานได้
$pythonCmd = null;
foreach ($pythonCandidates as $c) {
    // บน Windows, is_executable อาจไม่เช็คได้เสมอ จึงลองเรียก --version แบบเงียบๆ
    $testCmd = escapeshellcmd($c) . ' --version 2>&1';
    $testOut = null;
    $testRet = null;
    @exec($testCmd, $testOut, $testRet);
    if ($testRet === 0 || (is_array($testOut) && count($testOut) > 0)) {
        // เจอ python ที่ตอบกลับได้ (แม้ exit code จะไม่ 0 ก็ตาม ในบางระบบ)
        $pythonCmd = $c;
        break;
    }
}
// ถ้ายังไม่เจอ ให้ลอง path แบบเต็มที่ผู้ใช้อาจตั้งใน ENV
if ($pythonCmd === null) {
    // ลองอ่าน ENV PATH (สำรอง)
    $which = null;
    if (stripos(PHP_OS, 'WIN') === 0) {
        // windows try where
        @exec('where python 2>&1', $which, $ret);
        if ($ret === 0 && !empty($which)) $pythonCmd = $which[0];
    } else {
        @exec('which python3 2>&1', $which, $ret1);
        if ($ret1 === 0 && !empty($which)) $pythonCmd = $which[0];
        else {
            @exec('which python 2>&1', $which, $ret2);
            if ($ret2 === 0 && !empty($which)) $pythonCmd = $which[0];
        }
    }
}

if ($pythonCmd === null) {
    json_error('No python executable found. Ensure python is installed and available in PATH on the server.');
}

// สร้างคำสั่งอย่างปลอดภัย
$cmd = escapeshellcmd($pythonCmd) . ' ' . escapeshellarg($pythonScript);

// ใช้ proc_open เพื่ออ่าน stdout/stderr และรับ exit code
$descriptorspec = [
   0 => ["pipe", "r"],   // stdin
   1 => ["pipe", "w"],   // stdout
   2 => ["pipe", "w"]    // stderr
];

$process = @proc_open($cmd, $descriptorspec, $pipes, __DIR__);
if (!is_resource($process)) {
    json_error('Unable to start process. proc_open failed or permission denied. Check PHP settings and permissions.');
}

// ปิด stdin (เราไม่ส่งค่าเข้า)
fclose($pipes[0]);

// อ่าน stdout และ stderr (ไม่บล็อกตลอดจน EOF)
$stdout = '';
$stderr = '';

// อ่านแบบ non-blocking loop (ให้ timeout ยืดหยุ่น)
stream_set_blocking($pipes[1], false);
stream_set_blocking($pipes[2], false);

$start = time();
$timeout_seconds = 300; // safety timeout (5 นาที) - ปรับตามต้องการ
while (true) {
    $read = [$pipes[1], $pipes[2]];
    $write = null;
    $except = null;
    // stream_select เพื่อรอข้อมูล
    $num = @stream_select($read, $write, $except, 1, 0);
    if ($num === false) break;
    foreach ($read as $r) {
        $chunk = stream_get_contents($r);
        if ($r === $pipes[1]) $stdout .= $chunk;
        else $stderr .= $chunk;
    }
    $status = proc_get_status($process);
    if (!$status['running']) break;
    // safety timeout
    if (time() - $start > $timeout_seconds) {
        // ถ้า timeout ให้ปิด process
        proc_terminate($process, 9);
        $stdout .= "\n[PROCESS KILLED: timeout]\n";
        $stderr .= "\n[PROCESS KILLED: timeout]\n";
        break;
    }
    // small sleep to avoid busy loop
    usleep(100000);
}

// อ่านที่เหลือ
$stdout .= stream_get_contents($pipes[1]);
$stderr .= stream_get_contents($pipes[2]);

fclose($pipes[1]);
fclose($pipes[2]);

// รอ proc_close เพื่อรับ exit code
$exitCode = proc_close($process);

// รวมผลเป็นหนึ่ง string (limit สำหรับส่งกลับ)
$full_output = trim($stdout . "\n" . $stderr);
$snippet = mb_substr($full_output, 0, 8000);

// เตรียม JSON ตอบกลับ
$response = [
    'status' => ($exitCode === 0) ? 'ok' : 'error',
    'exit_code' => $exitCode,
    'python_cmd' => $pythonCmd,
    'script' => basename($pythonScript),
    'output_snippet' => $snippet,
    'full_output_length' => mb_strlen($full_output),
];

// ถ้า exitCode != 0 ให้แนบ stderr ย่อมา
if ($exitCode !== 0) {
    $response['message'] = 'Script finished with non-zero exit code.';
    // แนบบรรทัดแรกของ stderr ถ้ามี
    if (!empty($stderr)) {
        $response['stderr_head'] = mb_substr(trim($stderr), 0, 1000);
    }
} else {
    $response['message'] = 'Script finished successfully.';
}

echo json_encode($response, JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT);
exit;
