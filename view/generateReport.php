<?php
/* ─────────────────────────
   0.  ERROR‑HANDLING POLICY
   ───────────────────────── */
ini_set('display_errors', 0);   // keep HTML out of JSON
ini_set('log_errors', 1);       // write to Apache/PHP error log
error_reporting(E_ALL);

// Ensure we're sending JSON
header('Content-Type: application/json; charset=utf-8');

/* ─────────────────────────
   1.  LOAD .env + API KEY
   ───────────────────────── */
$envPath = realpath(__DIR__ . '/../.env') ?: __DIR__ . '/.env';
if (!is_readable($envPath)) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "error"   => ".env missing or unreadable at $envPath"
    ]);
    exit;
}

$env = @parse_ini_file($envPath, false, INI_SCANNER_RAW);
$apiKey = trim($env['OPENAI_API_KEY'] ?? '');
if ($apiKey === '') {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "error"   => "OPENAI_API_KEY not set in .env"
    ]);
    exit;
}

/* ─────────────────────────
   2.  READ POST PAYLOAD
   ───────────────────────── */
$input = file_get_contents("php://input");
if ($input === false) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "error"   => "Failed to read request body"
    ]);
    exit;
}

$body = json_decode($input, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "error"   => "Invalid JSON in request body: " . json_last_error_msg()
    ]);
    exit;
}

$uid = $body['uid'] ?? null;
$name = $body['name'] ?? 'Unknown';
$readings = $body['heart_rate'] ?? [];
$contractions = $body['contractions'] ?? [];


if (!$uid || !is_array($readings) || !$readings) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "error"   => "Missing UID or FHR readings"
    ]);
    exit;
}

/* ─────────────────────────
   3.  BUILD PROMPT
   ───────────────────────── */
$count = count($readings);
$avg   = round(array_sum($readings) / $count, 2);
$min   = min($readings);
$max   = max($readings);
$list  = implode(', ', $readings);

$keys = array_keys($readings);
sort($keys);
$start = $keys[0];
$end = $keys[count($keys) - 1];

$userPrompt = <<<TXT
Generate a clinical summary report based on fetal heart rate (FHR) readings and contraction data for a pregnant patient.

Patient Name: $name
Number of FHR readings: $count
FHR Readings: $list

Contractions:
TXT;

if (!$contractions || count($contractions) === 0) {
    $userPrompt .= " None detected during this monitoring period.\n\n";
} else {
    $userPrompt .= " " . count($contractions) . " contractions detected.\n";
    $userPrompt .= " Contraction Timestamps: " . implode(', ', $contractions) . "\n\n";
}

$userPrompt .= <<<RULES
Instructions:
- Define bradycardia as any reading below 110 bpm.
- Define tachycardia as any reading above 160 bpm.
- Calculate and report the total time (in seconds) that FHR readings remained in bradycardia.
- Calculate and report the total time (in seconds) that FHR readings remained in tachycardia.
- Assume each reading was taken at 1-second intervals.
- Use bullet points to report the following:
  • Average FHR: $avg bpm
  • Minimum FHR: $min bpm
  • Maximum FHR: $max bpm
  • Monitoring period: {$start} to {$end}
  • Total duration of bradycardia (in seconds)
  • Total duration of tachycardia (in seconds)
  • Number of contractions
  • Contraction timestamps (if any)
- Do not use full sentences.
- Do not include any emotional or conversational language.
- Do not refer to the patient directly.
- Keep tone objective, clinical, and concise for medical professionals.
RULES;
/* ─────────────────────────
   4.  CALL OPENAI
   ───────────────────────── */
$ch = curl_init('https://api.openai.com/v1/chat/completions');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST           => true,
    CURLOPT_HTTPHEADER     => [
        'Content-Type: application/json',
        "Authorization: Bearer $apiKey",
    ],
    CURLOPT_POSTFIELDS     => json_encode([
        "model"    => "gpt-3.5-turbo",          // or "gpt-4o"
        "messages" => [
            ["role" => "system",    "content" => "You are a helpful medical assistant."],
            ["role" => "user",      "content" => $userPrompt]
        ],
        "max_tokens" => 500
    ]),
]);

$response = curl_exec($ch);

if (curl_errno($ch)) {
    http_response_code(502);
    echo json_encode([
        "success" => false,
        "error"   => "cURL: " . curl_error($ch)
    ]);
    curl_close($ch);
    exit;
}
curl_close($ch);

/* ─────────────────────────
   5.  PARSE & RETURN JSON
   ───────────────────────── */
$data   = json_decode($response, true);
$report = $data['choices'][0]['message']['content'] ?? null;

if (!$report) {
    http_response_code(502);
    echo json_encode([
        "success" => false,
        "error"   => "Bad response from OpenAI",
        "raw"     => $data
    ]);
    exit;
}

echo json_encode([
    "success" => true,
    "report"  => trim($report)
]);