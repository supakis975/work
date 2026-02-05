<?php
// update_metacritic.php
// เรียก Metacritic_update.py แล้วส่งผลลัพธ์กลับเป็น JSON ให้หน้าเว็บ
header('Content-Type: application/json; charset=utf-8');

// ตั้งค่า command ที่จะรัน (ปรับเป็น "python3" ถ้าจำเป็น / หรือ path เต็มของ python)
$python = 'python';
$script = 'Metacritic_update.py';

// ถ้าต้องการรันด้วย environment พิเศษ ให้ใส่ full path หรือ virtualenv
$cmd = escapeshellcmd("$python $script");

// exec จะรอจนสคริปต์เสร็จ (ต้องระวังเวลารันนาน ๆ ของ PHP max_execution_time)
$output = [];
$return_var = 0;

// รันคำสั่งและเก็บ stdout/stderr (2>&1)
exec($cmd . ' 2>&1', $output, $return_var);

// รวม output เป็น string (ถ้าสคริปต์ print เป็น JSON จะอ่านได้)
$out_text = implode("\n", $output);

// ถ้า stdout เป็น JSON ให้ส่งกลับเป็น JSON จริง ๆ (พยายาม decode)
$decoded = json_decode($out_text, true);
if ($decoded !== null) {
    // ถ้า Python ส่ง JSON มา ให้ส่งต่อ
    echo json_encode([
        "status" => "ok",
        "python_return" => $decoded,
        "exit_code" => $return_var
    ], JSON_UNESCAPED_UNICODE);
} else {
    // otherwise ส่ง raw output
    echo json_encode([
        "status" => ($return_var === 0 ? "ok" : "error"),
        "exit_code" => $return_var,
        "output" => $out_text
    ], JSON_UNESCAPED_UNICODE);
}
